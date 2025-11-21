const DailyRecipe = require('../models/DailyRecipe');

const getTodaysRecipe = async (req, res, next) => {
  try {
    let recipe = await DailyRecipe.getToday();

    // If no recipe for today, auto-select one
    if (!recipe) {
      recipe = await DailyRecipe.autoSelectDailyRecipe();
    }

    if (!recipe) {
      return res.status(404).json({ error: 'No recipe available for today' });
    }

    res.json({ recipe });
  } catch (error) {
    next(error);
  }
};

const getHistory = async (req, res, next) => {
  try {
    const { limit } = req.query;
    const history = await DailyRecipe.getHistory(parseInt(limit) || 30);

    res.json({ history });
  } catch (error) {
    next(error);
  }
};

const setDailyRecipe = async (req, res, next) => {
  try {
    const { recipeId } = req.body;
    const { date } = req.query;

    const dailyRecipe = await DailyRecipe.setDailyRecipe(recipeId, date);

    res.json({
      message: 'Daily recipe set successfully',
      dailyRecipe
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getTodaysRecipe,
  getHistory,
  setDailyRecipe
};
