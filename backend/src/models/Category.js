const pool = require('../config/database');

class Category {
  static async create(userId, { name, color, icon }) {
    const query = `
      INSERT INTO categories (user_id, name, color, icon)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `;
    const result = await pool.query(query, [userId, name, color, icon]);
    return result.rows[0];
  }

  static async findAll(userId) {
    const query = `
      SELECT c.*,
        COUNT(rc.recipe_id) as recipe_count
      FROM categories c
      LEFT JOIN recipe_categories rc ON c.id = rc.category_id
      WHERE c.user_id = $1
      GROUP BY c.id
      ORDER BY c.name
    `;
    const result = await pool.query(query, [userId]);
    return result.rows;
  }

  static async findById(id, userId) {
    const query = 'SELECT * FROM categories WHERE id = $1 AND user_id = $2';
    const result = await pool.query(query, [id, userId]);
    return result.rows[0];
  }

  static async update(id, userId, { name, color, icon }) {
    const query = `
      UPDATE categories
      SET name = COALESCE($1, name),
          color = COALESCE($2, color),
          icon = COALESCE($3, icon)
      WHERE id = $4 AND user_id = $5
      RETURNING *
    `;
    const result = await pool.query(query, [name, color, icon, id, userId]);
    return result.rows[0];
  }

  static async delete(id, userId) {
    const query = 'DELETE FROM categories WHERE id = $1 AND user_id = $2 RETURNING id';
    const result = await pool.query(query, [id, userId]);
    return result.rows[0];
  }

  static async addRecipeToCategory(recipeId, categoryId, userId) {
    // Verify ownership
    const recipeCheck = await pool.query('SELECT id FROM recipes WHERE id = $1 AND user_id = $2', [recipeId, userId]);
    const categoryCheck = await pool.query('SELECT id FROM categories WHERE id = $1 AND user_id = $2', [categoryId, userId]);

    if (!recipeCheck.rows[0] || !categoryCheck.rows[0]) {
      throw new Error('Recipe or category not found');
    }

    const query = `
      INSERT INTO recipe_categories (recipe_id, category_id)
      VALUES ($1, $2)
      ON CONFLICT DO NOTHING
      RETURNING *
    `;
    const result = await pool.query(query, [recipeId, categoryId]);
    return result.rows[0];
  }

  static async removeRecipeFromCategory(recipeId, categoryId) {
    const query = 'DELETE FROM recipe_categories WHERE recipe_id = $1 AND category_id = $2';
    await pool.query(query, [recipeId, categoryId]);
  }
}

module.exports = Category;
