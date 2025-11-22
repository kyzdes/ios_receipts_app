// Recipe scaling and unit conversion utilities

const UNIT_CONVERSIONS = {
  // Volume conversions to ml
  volume: {
    'ml': 1,
    'l': 1000,
    'liter': 1000,
    'litre': 1000,
    'tsp': 4.92892,
    'teaspoon': 4.92892,
    'tbsp': 14.7868,
    'tablespoon': 14.7868,
    'cup': 236.588,
    'fl oz': 29.5735,
    'fluid ounce': 29.5735,
    'pint': 473.176,
    'quart': 946.353,
    'gallon': 3785.41,
  },
  // Weight conversions to grams
  weight: {
    'g': 1,
    'gram': 1,
    'kg': 1000,
    'kilogram': 1000,
    'oz': 28.3495,
    'ounce': 28.3495,
    'lb': 453.592,
    'pound': 453.592,
  }
};

// Common ingredient density (g/ml) for volume to weight conversion
const INGREDIENT_DENSITY = {
  'water': 1,
  'milk': 1.03,
  'flour': 0.593,
  'sugar': 0.845,
  'brown sugar': 0.72,
  'butter': 0.911,
  'oil': 0.92,
  'honey': 1.42,
  'salt': 1.2,
  'rice': 0.85,
  'oats': 0.41,
};

/**
 * Scale a recipe quantity
 * @param {string} quantity - Original quantity (e.g., "2", "1.5", "1/2", "2 1/4")
 * @param {number} scaleFactor - Multiplier (e.g., 2 for doubling)
 * @returns {string} - Scaled quantity
 */
function scaleQuantity(quantity, scaleFactor) {
  if (!quantity || scaleFactor === 1) return quantity;

  // Handle fractions like "1/2", "3/4"
  if (quantity.includes('/')) {
    const parts = quantity.split(' ');
    let whole = 0;
    let fraction = parts[parts.length - 1];

    if (parts.length > 1) {
      whole = parseInt(parts[0]);
      fraction = parts[1];
    }

    const [num, den] = fraction.split('/').map(Number);
    const decimal = whole + (num / den);
    const scaled = decimal * scaleFactor;

    return formatQuantity(scaled);
  }

  // Handle decimal numbers
  const num = parseFloat(quantity);
  if (!isNaN(num)) {
    const scaled = num * scaleFactor;
    return formatQuantity(scaled);
  }

  return quantity; // Return original if can't parse
}

/**
 * Format a decimal quantity to a user-friendly string
 * @param {number} value - Decimal value
 * @returns {string} - Formatted quantity (e.g., "1⅓", "2.5")
 */
function formatQuantity(value) {
  const whole = Math.floor(value);
  const decimal = value - whole;

  // Common fractions mapping
  const fractions = {
    0.125: '⅛',
    0.25: '¼',
    0.333: '⅓',
    0.375: '⅜',
    0.5: '½',
    0.625: '⅝',
    0.666: '⅔',
    0.75: '¾',
    0.875: '⅞',
  };

  // Find closest fraction
  if (decimal > 0) {
    let closestFraction = null;
    let minDiff = Infinity;

    for (const [dec, frac] of Object.entries(fractions)) {
      const diff = Math.abs(decimal - parseFloat(dec));
      if (diff < minDiff && diff < 0.05) { // Tolerance of 0.05
        minDiff = diff;
        closestFraction = frac;
      }
    }

    if (closestFraction) {
      return whole > 0 ? `${whole}${closestFraction}` : closestFraction;
    }
  }

  // Round to 2 decimal places
  return Math.round(value * 100) / 100;
}

/**
 * Convert between units
 * @param {number} amount - Amount to convert
 * @param {string} fromUnit - Source unit
 * @param {string} toUnit - Target unit
 * @param {string} ingredient - Ingredient name (for density-based conversion)
 * @returns {number|null} - Converted amount or null if incompatible
 */
function convertUnit(amount, fromUnit, toUnit, ingredient = null) {
  fromUnit = fromUnit.toLowerCase().trim();
  toUnit = toUnit.toLowerCase().trim();

  if (fromUnit === toUnit) return amount;

  // Try volume conversion
  if (UNIT_CONVERSIONS.volume[fromUnit] && UNIT_CONVERSIONS.volume[toUnit]) {
    const ml = amount * UNIT_CONVERSIONS.volume[fromUnit];
    return ml / UNIT_CONVERSIONS.volume[toUnit];
  }

  // Try weight conversion
  if (UNIT_CONVERSIONS.weight[fromUnit] && UNIT_CONVERSIONS.weight[toUnit]) {
    const grams = amount * UNIT_CONVERSIONS.weight[fromUnit];
    return grams / UNIT_CONVERSIONS.weight[toUnit];
  }

  // Try volume to weight (requires ingredient density)
  if (ingredient && UNIT_CONVERSIONS.volume[fromUnit] && UNIT_CONVERSIONS.weight[toUnit]) {
    const density = INGREDIENT_DENSITY[ingredient.toLowerCase()] || 1;
    const ml = amount * UNIT_CONVERSIONS.volume[fromUnit];
    const grams = ml * density;
    return grams / UNIT_CONVERSIONS.weight[toUnit];
  }

  // Try weight to volume (requires ingredient density)
  if (ingredient && UNIT_CONVERSIONS.weight[fromUnit] && UNIT_CONVERSIONS.volume[toUnit]) {
    const density = INGREDIENT_DENSITY[ingredient.toLowerCase()] || 1;
    const grams = amount * UNIT_CONVERSIONS.weight[fromUnit];
    const ml = grams / density;
    return ml / UNIT_CONVERSIONS.volume[toUnit];
  }

  return null; // Cannot convert
}

/**
 * Scale an entire recipe
 * @param {Object} recipe - Recipe object with ingredients
 * @param {number} newServings - Desired number of servings
 * @returns {Object} - Scaled recipe
 */
function scaleRecipe(recipe, newServings) {
  const originalServings = recipe.servings || 1;
  const scaleFactor = newServings / originalServings;

  return {
    ...recipe,
    servings: newServings,
    ingredients: recipe.ingredients.map(ingredient => ({
      ...ingredient,
      quantity: scaleQuantity(ingredient.quantity, scaleFactor)
    })),
    // Scale time estimations (but not linearly - cooking time doesn't scale proportionally)
    prep_time: recipe.prep_time ? Math.ceil(recipe.prep_time * Math.pow(scaleFactor, 0.6)) : null,
    cook_time: recipe.cook_time ? Math.ceil(recipe.cook_time * Math.pow(scaleFactor, 0.4)) : null,
  };
}

/**
 * Convert recipe to different unit system (metric/imperial)
 * @param {Object} recipe - Recipe object
 * @param {string} system - 'metric' or 'imperial'
 * @returns {Object} - Converted recipe
 */
function convertRecipeUnits(recipe, system) {
  const conversions = system === 'metric' ? {
    'cup': { to: 'ml', factor: 236.588 },
    'tbsp': { to: 'ml', factor: 14.7868 },
    'tsp': { to: 'ml', factor: 4.92892 },
    'oz': { to: 'g', factor: 28.3495 },
    'lb': { to: 'g', factor: 453.592 },
    'fl oz': { to: 'ml', factor: 29.5735 },
  } : {
    'ml': { to: 'tbsp', factor: 1/14.7868 },
    'l': { to: 'cup', factor: 1000/236.588 },
    'g': { to: 'oz', factor: 1/28.3495 },
    'kg': { to: 'lb', factor: 1000/453.592 },
  };

  return {
    ...recipe,
    ingredients: recipe.ingredients.map(ingredient => {
      const unit = ingredient.unit?.toLowerCase();
      const conversion = conversions[unit];

      if (conversion && ingredient.quantity) {
        const numQuantity = parseFloat(ingredient.quantity);
        if (!isNaN(numQuantity)) {
          return {
            ...ingredient,
            quantity: formatQuantity(numQuantity * conversion.factor),
            unit: conversion.to
          };
        }
      }

      return ingredient;
    })
  };
}

module.exports = {
  scaleQuantity,
  formatQuantity,
  convertUnit,
  scaleRecipe,
  convertRecipeUnits,
  UNIT_CONVERSIONS,
  INGREDIENT_DENSITY,
};
