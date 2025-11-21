const express = require('express');
const { body } = require('express-validator');
const categoryController = require('../controllers/categoryController');
const { authenticateToken } = require('../middleware/auth');
const { validate } = require('../middleware/validation');

const router = express.Router();

// Validation rules
const categoryValidation = [
  body('name').notEmpty().trim(),
  body('color').optional().matches(/^#[0-9A-Fa-f]{6}$/),
  body('icon').optional().isString(),
  validate
];

// All routes require authentication
router.use(authenticateToken);

// Category CRUD
router.post('/', categoryValidation, categoryController.createCategory);
router.get('/', categoryController.getCategories);
router.get('/:id', categoryController.getCategoryById);
router.put('/:id', categoryController.updateCategory);
router.delete('/:id', categoryController.deleteCategory);

// Recipe-Category associations
router.post('/:categoryId/recipes/:recipeId', categoryController.addRecipeToCategory);
router.delete('/:categoryId/recipes/:recipeId', categoryController.removeRecipeFromCategory);

module.exports = router;
