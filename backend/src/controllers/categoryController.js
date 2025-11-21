const Category = require('../models/Category');

const createCategory = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const category = await Category.create(userId, req.body);

    res.status(201).json({
      message: 'Category created successfully',
      category
    });
  } catch (error) {
    if (error.code === '23505') { // Unique constraint violation
      return res.status(409).json({ error: 'Category name already exists' });
    }
    next(error);
  }
};

const getCategories = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const categories = await Category.findAll(userId);

    res.json({ categories });
  } catch (error) {
    next(error);
  }
};

const getCategoryById = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const category = await Category.findById(id, userId);
    if (!category) {
      return res.status(404).json({ error: 'Category not found' });
    }

    res.json({ category });
  } catch (error) {
    next(error);
  }
};

const updateCategory = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const category = await Category.update(id, userId, req.body);
    if (!category) {
      return res.status(404).json({ error: 'Category not found' });
    }

    res.json({
      message: 'Category updated successfully',
      category
    });
  } catch (error) {
    next(error);
  }
};

const deleteCategory = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const deleted = await Category.delete(id, userId);
    if (!deleted) {
      return res.status(404).json({ error: 'Category not found' });
    }

    res.json({ message: 'Category deleted successfully' });
  } catch (error) {
    next(error);
  }
};

const addRecipeToCategory = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { categoryId, recipeId } = req.params;

    await Category.addRecipeToCategory(recipeId, categoryId, userId);

    res.json({ message: 'Recipe added to category successfully' });
  } catch (error) {
    next(error);
  }
};

const removeRecipeFromCategory = async (req, res, next) => {
  try {
    const { categoryId, recipeId } = req.params;

    await Category.removeRecipeFromCategory(recipeId, categoryId);

    res.json({ message: 'Recipe removed from category successfully' });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createCategory,
  getCategories,
  getCategoryById,
  updateCategory,
  deleteCategory,
  addRecipeToCategory,
  removeRecipeFromCategory
};
