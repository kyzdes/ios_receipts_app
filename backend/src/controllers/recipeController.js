const Recipe = require('../models/Recipe');
const RecipeImage = require('../models/RecipeImage');

const createRecipe = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const recipe = await Recipe.create(userId, req.body);

    res.status(201).json({
      message: 'Recipe created successfully',
      recipe
    });
  } catch (error) {
    next(error);
  }
};

const getRecipes = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { limit, offset, sortBy, order } = req.query;

    const recipes = await Recipe.findAll(userId, {
      limit: parseInt(limit) || 50,
      offset: parseInt(offset) || 0,
      sortBy: sortBy || 'created_at',
      order: order || 'DESC'
    });

    res.json({ recipes, count: recipes.length });
  } catch (error) {
    next(error);
  }
};

const getRecipeById = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const recipe = await Recipe.findById(id, userId);
    if (!recipe) {
      return res.status(404).json({ error: 'Recipe not found' });
    }

    res.json({ recipe });
  } catch (error) {
    next(error);
  }
};

const updateRecipe = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const recipe = await Recipe.update(id, userId, req.body);
    if (!recipe) {
      return res.status(404).json({ error: 'Recipe not found' });
    }

    res.json({
      message: 'Recipe updated successfully',
      recipe
    });
  } catch (error) {
    next(error);
  }
};

const deleteRecipe = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const deleted = await Recipe.delete(id, userId);
    if (!deleted) {
      return res.status(404).json({ error: 'Recipe not found' });
    }

    res.json({ message: 'Recipe deleted successfully' });
  } catch (error) {
    next(error);
  }
};

const searchRecipes = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { q } = req.query;

    if (!q) {
      return res.status(400).json({ error: 'Search query required' });
    }

    const recipes = await Recipe.search(userId, q);
    res.json({ recipes, count: recipes.length });
  } catch (error) {
    next(error);
  }
};

const toggleFavorite = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const recipe = await Recipe.toggleFavorite(id, userId);
    if (!recipe) {
      return res.status(404).json({ error: 'Recipe not found' });
    }

    res.json({
      message: 'Favorite status updated',
      recipe
    });
  } catch (error) {
    next(error);
  }
};

const uploadImages = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    // Verify recipe ownership
    const recipe = await Recipe.findById(id, userId);
    if (!recipe) {
      return res.status(404).json({ error: 'Recipe not found' });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ error: 'No images uploaded' });
    }

    const images = [];
    for (let i = 0; i < req.files.length; i++) {
      const file = req.files[i];
      const imageUrl = `/uploads/${file.filename}`;
      const isPrimary = i === 0 && recipe.images.length === 0;

      const image = await RecipeImage.create(id, imageUrl, isPrimary);
      images.push(image);
    }

    res.status(201).json({
      message: 'Images uploaded successfully',
      images
    });
  } catch (error) {
    next(error);
  }
};

const deleteImage = async (req, res, next) => {
  try {
    const { id, imageId } = req.params;
    const userId = req.user.userId;

    // Verify recipe ownership
    const recipe = await Recipe.findById(id, userId);
    if (!recipe) {
      return res.status(404).json({ error: 'Recipe not found' });
    }

    const deleted = await RecipeImage.delete(imageId, id);
    if (!deleted) {
      return res.status(404).json({ error: 'Image not found' });
    }

    res.json({ message: 'Image deleted successfully' });
  } catch (error) {
    next(error);
  }
};

const setPrimaryImage = async (req, res, next) => {
  try {
    const { id, imageId } = req.params;
    const userId = req.user.userId;

    // Verify recipe ownership
    const recipe = await Recipe.findById(id, userId);
    if (!recipe) {
      return res.status(404).json({ error: 'Recipe not found' });
    }

    const image = await RecipeImage.setPrimary(imageId, id);
    if (!image) {
      return res.status(404).json({ error: 'Image not found' });
    }

    res.json({
      message: 'Primary image updated',
      image
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createRecipe,
  getRecipes,
  getRecipeById,
  updateRecipe,
  deleteRecipe,
  searchRecipes,
  toggleFavorite,
  uploadImages,
  deleteImage,
  setPrimaryImage
};
