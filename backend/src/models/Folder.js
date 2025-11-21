const pool = require('../config/database');

class Folder {
  static async create(userId, { name, parent_folder_id }) {
    const query = `
      INSERT INTO folders (user_id, name, parent_folder_id)
      VALUES ($1, $2, $3)
      RETURNING *
    `;
    const result = await pool.query(query, [userId, name, parent_folder_id || null]);
    return result.rows[0];
  }

  static async findAll(userId) {
    const query = `
      SELECT f.*,
        COUNT(rf.recipe_id) as recipe_count
      FROM folders f
      LEFT JOIN recipe_folders rf ON f.id = rf.folder_id
      WHERE f.user_id = $1
      GROUP BY f.id
      ORDER BY f.name
    `;
    const result = await pool.query(query, [userId]);
    return result.rows;
  }

  static async findById(id, userId) {
    const query = `
      SELECT f.*,
        COALESCE(
          json_agg(
            DISTINCT jsonb_build_object(
              'id', r.id,
              'title', r.title,
              'primary_image', (SELECT image_url FROM recipe_images WHERE recipe_id = r.id AND is_primary = true LIMIT 1)
            )
          ) FILTER (WHERE r.id IS NOT NULL),
          '[]'
        ) as recipes
      FROM folders f
      LEFT JOIN recipe_folders rf ON f.id = rf.folder_id
      LEFT JOIN recipes r ON rf.recipe_id = r.id
      WHERE f.id = $1 AND f.user_id = $2
      GROUP BY f.id
    `;
    const result = await pool.query(query, [id, userId]);
    return result.rows[0];
  }

  static async update(id, userId, { name, parent_folder_id }) {
    const query = `
      UPDATE folders
      SET name = COALESCE($1, name),
          parent_folder_id = COALESCE($2, parent_folder_id)
      WHERE id = $3 AND user_id = $4
      RETURNING *
    `;
    const result = await pool.query(query, [name, parent_folder_id, id, userId]);
    return result.rows[0];
  }

  static async delete(id, userId) {
    const query = 'DELETE FROM folders WHERE id = $1 AND user_id = $2 RETURNING id';
    const result = await pool.query(query, [id, userId]);
    return result.rows[0];
  }

  static async addRecipeToFolder(recipeId, folderId, userId) {
    // Verify ownership
    const recipeCheck = await pool.query('SELECT id FROM recipes WHERE id = $1 AND user_id = $2', [recipeId, userId]);
    const folderCheck = await pool.query('SELECT id FROM folders WHERE id = $1 AND user_id = $2', [folderId, userId]);

    if (!recipeCheck.rows[0] || !folderCheck.rows[0]) {
      throw new Error('Recipe or folder not found');
    }

    const query = `
      INSERT INTO recipe_folders (recipe_id, folder_id)
      VALUES ($1, $2)
      ON CONFLICT DO NOTHING
      RETURNING *
    `;
    const result = await pool.query(query, [recipeId, folderId]);
    return result.rows[0];
  }

  static async removeRecipeFromFolder(recipeId, folderId) {
    const query = 'DELETE FROM recipe_folders WHERE recipe_id = $1 AND folder_id = $2';
    await pool.query(query, [recipeId, folderId]);
  }
}

module.exports = Folder;
