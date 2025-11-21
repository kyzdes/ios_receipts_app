const express = require('express');
const dailyRecipeController = require('../controllers/dailyRecipeController');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Public routes (no authentication required)
router.get('/', dailyRecipeController.getTodaysRecipe);
router.get('/history', dailyRecipeController.getHistory);

// Admin route (would need admin middleware in production)
router.post('/', authenticateToken, dailyRecipeController.setDailyRecipe);

module.exports = router;
