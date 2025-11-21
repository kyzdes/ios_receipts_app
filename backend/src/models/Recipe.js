const pool = require('../config/database');

class Recipe {
  static async create(userId, recipeData) {
    const {
      title,
      ingredients,
      instructions,
      prep_time,
      cook_time,
      servings,
      difficulty,
      notes
    } = recipeData;

    const query = `
      INSERT INTO recipes (
        user_id, title, ingredients, instructions, prep_time,
        cook_time, servings, difficulty, notes
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *
    `;

    const result = await pool.query(query, [
      userId,
      title,
      JSON.stringify(ingredients),
      JSON.stringify(instructions),
      prep_time,
      cook_time,
      servings,
      difficulty,
      notes
    ]);

    return result.rows[0];
  }

  static async findById(id, userId) {
    const query = `
      SELECT r.*,
        COALESCE(
          json_agg(
            DISTINCT jsonb_build_object('id', ri.id, 'url', ri.image_url, 'isPrimary', ri.is_primary)
          ) FILTER (WHERE ri.id IS NOT NULL),
          '[]'
        ) as images,
        COALESCE(
          json_agg(
            DISTINCT jsonb_build_object('id', c.id, 'name', c.name, 'color', c.color, 'icon', c.icon)
          ) FILTER (WHERE c.id IS NOT NULL),
          '[]'
        ) as categories,
        COALESCE(
          json_agg(
            DISTINCT jsonb_build_object('id', f.id, 'name', f.name)
          ) FILTER (WHERE f.id IS NOT NULL),
          '[]'
        ) as folders
      FROM recipes r
      LEFT JOIN recipe_images ri ON r.id = ri.recipe_id
      LEFT JOIN recipe_categories rc ON r.id = rc.recipe_id
      LEFT JOIN categories c ON rc.category_id = c.id
      LEFT JOIN recipe_folders rf ON r.id = rf.recipe_id
      LEFT JOIN folders f ON rf.folder_id = f.id
      WHERE r.id = $1 AND r.user_id = $2
      GROUP BY r.id
    `;
    const result = await pool.query(query, [id, userId]);
    return result.rows[0];
  }

  static async findAll(userId, options = {}) {
    const { limit = 50, offset = 0, sortBy = 'created_at', order = 'DESC' } = options;

    const query = `
      SELECT r.*,
        (SELECT image_url FROM recipe_images WHERE recipe_id = r.id AND is_primary = true LIMIT 1) as primary_image
      FROM recipes r
      WHERE r.user_id = $1
      ORDER BY ${sortBy} ${order}
      LIMIT $2 OFFSET $3
    `;

    const result = await pool.query(query, [userId, limit, offset]);
    return result.rows;
  }

  static async update(id, userId, updateData) {
    const fields = [];
    const values = [];
    let paramCount = 1;

    Object.entries(updateData).forEach(([key, value]) => {
      if (key === 'ingredients' || key === 'instructions') {
        fields.push(`${key} = $${paramCount}`);
        values.push(JSON.stringify(value));
      } else if (value !== undefined) {
        fields.push(`${key} = $${paramCount}`);
        values.push(value);
      }
      paramCount++;
    });

    if (fields.length === 0) return null;

    values.push(id, userId);
    const query = `
      UPDATE recipes
      SET ${fields.join(', ')}
      WHERE id = $${paramCount} AND user_id = $${paramCount + 1}
      RETURNING *
    `;

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async delete(id, userId) {
    const query = 'DELETE FROM recipes WHERE id = $1 AND user_id = $2 RETURNING id';
    const result = await pool.query(query, [id, userId]);
    return result.rows[0];
  }

  static async search(userId, searchTerm) {
    const query = `
      SELECT r.*,
        (SELECT image_url FROM recipe_images WHERE recipe_id = r.id AND is_primary = true LIMIT 1) as primary_image,
        ts_rank(to_tsvector('english', r.title || ' ' || COALESCE(r.notes, '')), plainto_tsquery('english', $2)) as rank
      FROM recipes r
      WHERE r.user_id = $1
        AND (
          to_tsvector('english', r.title || ' ' || COALESCE(r.notes, '')) @@ plainto_tsquery('english', $2)
          OR r.ingredients::text ILIKE $3
        )
      ORDER BY rank DESC, r.created_at DESC
      LIMIT 50
    `;
    const result = await pool.query(query, [userId, searchTerm, `%${searchTerm}%`]);
    return result.rows;
  }

  static async toggleFavorite(id, userId) {
    const query = `
      UPDATE recipes
      SET is_favorite = NOT is_favorite
      WHERE id = $1 AND user_id = $2
      RETURNING *
    `;
    const result = await pool.query(query, [id, userId]);
    return result.rows[0];
  }
}

module.exports = Recipe;
