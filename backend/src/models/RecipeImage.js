const pool = require('../config/database');

class RecipeImage {
  static async create(recipeId, imageUrl, isPrimary = false) {
    // If this is set as primary, unset other primary images for this recipe
    if (isPrimary) {
      await pool.query(
        'UPDATE recipe_images SET is_primary = false WHERE recipe_id = $1',
        [recipeId]
      );
    }

    const query = `
      INSERT INTO recipe_images (recipe_id, image_url, is_primary)
      VALUES ($1, $2, $3)
      RETURNING *
    `;
    const result = await pool.query(query, [recipeId, imageUrl, isPrimary]);
    return result.rows[0];
  }

  static async findByRecipeId(recipeId) {
    const query = `
      SELECT * FROM recipe_images
      WHERE recipe_id = $1
      ORDER BY is_primary DESC, created_at ASC
    `;
    const result = await pool.query(query, [recipeId]);
    return result.rows;
  }

  static async setPrimary(imageId, recipeId) {
    // Unset all primary flags for this recipe
    await pool.query(
      'UPDATE recipe_images SET is_primary = false WHERE recipe_id = $1',
      [recipeId]
    );

    // Set this image as primary
    const query = `
      UPDATE recipe_images
      SET is_primary = true
      WHERE id = $1 AND recipe_id = $2
      RETURNING *
    `;
    const result = await pool.query(query, [imageId, recipeId]);
    return result.rows[0];
  }

  static async delete(imageId, recipeId) {
    const query = 'DELETE FROM recipe_images WHERE id = $1 AND recipe_id = $2 RETURNING *';
    const result = await pool.query(query, [imageId, recipeId]);
    return result.rows[0];
  }
}

module.exports = RecipeImage;
