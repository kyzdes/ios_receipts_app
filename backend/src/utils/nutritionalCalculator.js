// Nutritional calculation utilities

// USDA FoodData Central common ingredients (per 100g)
// This is a simplified database - in production, use USDA API
const NUTRITIONAL_DATABASE = {
  // Proteins
  'chicken breast': { calories: 165, protein: 31, carbs: 0, fat: 3.6, fiber: 0 },
  'ground beef': { calories: 250, protein: 26, carbs: 0, fat: 17, fiber: 0 },
  'salmon': { calories: 208, protein: 20, carbs: 0, fat: 13, fiber: 0 },
  'eggs': { calories: 143, protein: 13, carbs: 1, fat: 10, fiber: 0 },
  'tofu': { calories: 76, protein: 8, carbs: 1.9, fat: 4.8, fiber: 0.3 },

  // Grains
  'white rice': { calories: 130, protein: 2.7, carbs: 28, fat: 0.3, fiber: 0.4 },
  'brown rice': { calories: 123, protein: 2.6, carbs: 26, fat: 1, fiber: 1.6 },
  'pasta': { calories: 131, protein: 5, carbs: 25, fat: 1.1, fiber: 1.8 },
  'bread': { calories: 265, protein: 9, carbs: 49, fat: 3.2, fiber: 2.7 },
  'flour': { calories: 364, protein: 10, carbs: 76, fat: 1, fiber: 2.7 },
  'oats': { calories: 389, protein: 17, carbs: 66, fat: 7, fiber: 11 },

  // Vegetables
  'broccoli': { calories: 34, protein: 2.8, carbs: 7, fat: 0.4, fiber: 2.6 },
  'spinach': { calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4, fiber: 2.2 },
  'tomato': { calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2 },
  'carrots': { calories: 41, protein: 0.9, carbs: 10, fat: 0.2, fiber: 2.8 },
  'onion': { calories: 40, protein: 1.1, carbs: 9, fat: 0.1, fiber: 1.7 },
  'garlic': { calories: 149, protein: 6.4, carbs: 33, fat: 0.5, fiber: 2.1 },
  'potato': { calories: 77, protein: 2, carbs: 17, fat: 0.1, fiber: 2.2 },

  // Fruits
  'banana': { calories: 89, protein: 1.1, carbs: 23, fat: 0.3, fiber: 2.6 },
  'apple': { calories: 52, protein: 0.3, carbs: 14, fat: 0.2, fiber: 2.4 },
  'strawberry': { calories: 32, protein: 0.7, carbs: 7.7, fat: 0.3, fiber: 2 },
  'lemon': { calories: 29, protein: 1.1, carbs: 9, fat: 0.3, fiber: 2.8 },

  // Dairy
  'milk': { calories: 61, protein: 3.2, carbs: 4.8, fat: 3.3, fiber: 0 },
  'cheese': { calories: 402, protein: 25, carbs: 1.3, fat: 33, fiber: 0 },
  'yogurt': { calories: 59, protein: 10, carbs: 3.6, fat: 0.4, fiber: 0 },
  'butter': { calories: 717, protein: 0.9, carbs: 0.1, fat: 81, fiber: 0 },
  'cream': { calories: 340, protein: 2.1, carbs: 2.7, fat: 36, fiber: 0 },

  // Fats & Oils
  'olive oil': { calories: 884, protein: 0, carbs: 0, fat: 100, fiber: 0 },
  'vegetable oil': { calories: 884, protein: 0, carbs: 0, fat: 100, fiber: 0 },
  'coconut oil': { calories: 862, protein: 0, carbs: 0, fat: 99, fiber: 0 },

  // Sweeteners
  'sugar': { calories: 387, protein: 0, carbs: 100, fat: 0, fiber: 0 },
  'honey': { calories: 304, protein: 0.3, carbs: 82, fat: 0, fiber: 0.2 },

  // Legumes
  'beans': { calories: 127, protein: 8.7, carbs: 23, fat: 0.5, fiber: 6.4 },
  'lentils': { calories: 116, protein: 9, carbs: 20, fat: 0.4, fiber: 7.9 },
  'chickpeas': { calories: 164, protein: 8.9, carbs: 27, fat: 2.6, fiber: 7.6 },
};

// Standard serving size assumptions
const STANDARD_PORTIONS = {
  'g': 1,
  'gram': 1,
  'kg': 1000,
  'oz': 28.35,
  'lb': 453.59,
  'cup': 200, // Approximate average for calculation
  'tbsp': 15,
  'tsp': 5,
  'piece': 100,
  'slice': 30,
  'clove': 3, // garlic
};

/**
 * Parse quantity string to grams
 * @param {string} quantity - Quantity string
 * @param {string} unit - Unit
 * @param {string} ingredient - Ingredient name
 * @returns {number} - Estimated grams
 */
function parseToGrams(quantity, unit, ingredient) {
  if (!quantity) return 0;

  // Extract numeric value from quantity (handle fractions)
  let numericValue = 0;

  if (quantity.includes('/')) {
    const parts = quantity.split(' ');
    let whole = 0;
    let fraction = parts[parts.length - 1];

    if (parts.length > 1) {
      whole = parseInt(parts[0]) || 0;
      fraction = parts[1];
    }

    const [num, den] = fraction.split('/').map(Number);
    numericValue = whole + (num / den);
  } else {
    numericValue = parseFloat(quantity) || 0;
  }

  // Convert to grams based on unit
  const unitLower = (unit || 'piece').toLowerCase();
  const conversionFactor = STANDARD_PORTIONS[unitLower] || 100;

  return numericValue * conversionFactor;
}

/**
 * Find nutritional data for an ingredient
 * @param {string} ingredientName - Name of ingredient
 * @returns {Object|null} - Nutritional data or null
 */
function findNutritionalData(ingredientName) {
  const name = ingredientName.toLowerCase().trim();

  // Direct match
  if (NUTRITIONAL_DATABASE[name]) {
    return NUTRITIONAL_DATABASE[name];
  }

  // Partial match (e.g., "boneless chicken breast" matches "chicken breast")
  for (const [key, value] of Object.entries(NUTRITIONAL_DATABASE)) {
    if (name.includes(key) || key.includes(name)) {
      return value;
    }
  }

  return null;
}

/**
 * Calculate nutritional information for a recipe
 * @param {Array} ingredients - Array of ingredient objects with name, quantity, unit
 * @param {number} servings - Number of servings
 * @returns {Object} - Nutritional information per serving
 */
function calculateNutrition(ingredients, servings = 1) {
  const totals = {
    calories: 0,
    protein: 0,
    carbohydrates: 0,
    fat: 0,
    fiber: 0,
    foundIngredients: 0,
    totalIngredients: ingredients.length,
  };

  for (const ingredient of ingredients) {
    const nutritionData = findNutritionalData(ingredient.name);

    if (nutritionData) {
      const grams = parseToGrams(ingredient.quantity, ingredient.unit, ingredient.name);
      const multiplier = grams / 100; // Nutritional data is per 100g

      totals.calories += nutritionData.calories * multiplier;
      totals.protein += nutritionData.protein * multiplier;
      totals.carbohydrates += nutritionData.carbs * multiplier;
      totals.fat += nutritionData.fat * multiplier;
      totals.fiber += nutritionData.fiber * multiplier;
      totals.foundIngredients++;
    }
  }

  // Calculate per serving
  const perServing = {
    calories: Math.round(totals.calories / servings),
    protein: Math.round(totals.protein / servings * 10) / 10,
    carbohydrates: Math.round(totals.carbohydrates / servings * 10) / 10,
    fat: Math.round(totals.fat / servings * 10) / 10,
    fiber: Math.round(totals.fiber / servings * 10) / 10,
    nutritional_info_complete: totals.foundIngredients === totals.totalIngredients,
    coverage_percentage: Math.round((totals.foundIngredients / totals.totalIngredients) * 100),
  };

  return perServing;
}

/**
 * Calculate macronutrient percentages
 * @param {Object} nutrition - Nutrition object with protein, carbs, fat
 * @returns {Object} - Macro percentages
 */
function calculateMacros(nutrition) {
  const proteinCals = nutrition.protein * 4;
  const carbCals = nutrition.carbohydrates * 4;
  const fatCals = nutrition.fat * 9;
  const totalCals = proteinCals + carbCals + fatCals;

  if (totalCals === 0) {
    return { protein: 0, carbs: 0, fat: 0 };
  }

  return {
    protein_percent: Math.round((proteinCals / totalCals) * 100),
    carbs_percent: Math.round((carbCals / totalCals) * 100),
    fat_percent: Math.round((fatCals / totalCals) * 100),
  };
}

/**
 * Check if recipe meets dietary requirements
 * @param {Object} recipe - Recipe object
 * @param {Array} dietaryPreferences - Array of dietary preferences
 * @returns {Object} - Compliance check result
 */
function checkDietaryCompliance(recipe, dietaryPreferences = []) {
  const checks = {
    vegetarian: recipe.is_vegetarian || false,
    vegan: recipe.is_vegan || false,
    gluten_free: recipe.is_gluten_free || false,
    dairy_free: recipe.is_dairy_free || false,
    nut_free: recipe.is_nut_free || false,
    low_carb: recipe.is_low_carb || (recipe.carbohydrates && recipe.carbohydrates < 20),
    keto: recipe.is_keto || (recipe.carbohydrates && recipe.carbohydrates < 10),
  };

  const compliant = dietaryPreferences.every(pref => checks[pref]);

  return {
    compliant,
    checks,
    violations: dietaryPreferences.filter(pref => !checks[pref]),
  };
}

module.exports = {
  calculateNutrition,
  calculateMacros,
  checkDietaryCompliance,
  findNutritionalData,
  NUTRITIONAL_DATABASE,
};
