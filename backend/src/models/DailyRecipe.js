const pool = require('../config/database');

class DailyRecipe {
  static async getToday() {
    const query = `
      SELECT dr.*, r.*,
        (SELECT image_url FROM recipe_images WHERE recipe_id = r.id AND is_primary = true LIMIT 1) as primary_image
      FROM daily_recipes dr
      JOIN recipes r ON dr.recipe_id = r.id
      WHERE dr.featured_date = CURRENT_DATE
    `;
    const result = await pool.query(query);
    return result.rows[0];
  }

  static async getHistory(limit = 30) {
    const query = `
      SELECT dr.featured_date, r.id, r.title, r.user_id,
        (SELECT image_url FROM recipe_images WHERE recipe_id = r.id AND is_primary = true LIMIT 1) as primary_image
      FROM daily_recipes dr
      JOIN recipes r ON dr.recipe_id = r.id
      WHERE dr.featured_date < CURRENT_DATE
      ORDER BY dr.featured_date DESC
      LIMIT $1
    `;
    const result = await pool.query(query, [limit]);
    return result.rows;
  }

  static async setDailyRecipe(recipeId, date = null) {
    const featuredDate = date || new Date().toISOString().split('T')[0];

    // Delete existing entry for this date if exists
    await pool.query('DELETE FROM daily_recipes WHERE featured_date = $1', [featuredDate]);

    const query = `
      INSERT INTO daily_recipes (recipe_id, featured_date)
      VALUES ($1, $2)
      RETURNING *
    `;
    const result = await pool.query(query, [recipeId, featuredDate]);
    return result.rows[0];
  }

  static async selectRandomRecipe() {
    // Select a random recipe that hasn't been featured in the last 30 days
    const query = `
      SELECT r.* FROM recipes r
      WHERE r.id NOT IN (
        SELECT recipe_id FROM daily_recipes
        WHERE featured_date > CURRENT_DATE - INTERVAL '30 days'
      )
      ORDER BY RANDOM()
      LIMIT 1
    `;
    const result = await pool.query(query);
    return result.rows[0];
  }

  static async autoSelectDailyRecipe() {
    // Check if today already has a recipe
    const existing = await this.getToday();
    if (existing) {
      return existing;
    }

    // Select a random recipe
    const recipe = await this.selectRandomRecipe();
    if (!recipe) {
      return null;
    }

    // Set it as today's recipe
    await this.setDailyRecipe(recipe.id);
    return recipe;
  }
}

module.exports = DailyRecipe;
