const express = require('express');
const { body } = require('express-validator');
const recipeController = require('../controllers/recipeController');
const { authenticateToken } = require('../middleware/auth');
const { validate } = require('../middleware/validation');
const { upload, optimizeImage } = require('../utils/upload');

const router = express.Router();

// Validation rules
const recipeValidation = [
  body('title').notEmpty().trim(),
  body('ingredients').isArray({ min: 1 }),
  body('instructions').isArray({ min: 1 }),
  body('servings').optional().isInt({ min: 1 }),
  body('prep_time').optional().isInt({ min: 0 }),
  body('cook_time').optional().isInt({ min: 0 }),
  body('difficulty').optional().isIn(['easy', 'medium', 'hard']),
  validate
];

// All routes require authentication
router.use(authenticateToken);

// Recipe CRUD
router.post('/', recipeValidation, recipeController.createRecipe);
router.get('/', recipeController.getRecipes);
router.get('/search', recipeController.searchRecipes);
router.get('/:id', recipeController.getRecipeById);
router.put('/:id', recipeController.updateRecipe);
router.delete('/:id', recipeController.deleteRecipe);

// Favorite
router.post('/:id/favorite', recipeController.toggleFavorite);

// Images
router.post('/:id/images', upload.array('images', 10), optimizeImage, recipeController.uploadImages);
router.delete('/:id/images/:imageId', recipeController.deleteImage);
router.put('/:id/images/:imageId/primary', recipeController.setPrimaryImage);

module.exports = router;
