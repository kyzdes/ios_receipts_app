-- Add nutritional information to recipes
ALTER TABLE recipes
ADD COLUMN calories INTEGER,
ADD COLUMN protein DECIMAL(10, 2),
ADD COLUMN carbohydrates DECIMAL(10, 2),
ADD COLUMN fat DECIMAL(10, 2),
ADD COLUMN fiber DECIMAL(10, 2),
ADD COLUMN sugar DECIMAL(10, 2),
ADD COLUMN sodium INTEGER,
ADD COLUMN cholesterol INTEGER,
ADD COLUMN saturated_fat DECIMAL(10, 2),
ADD COLUMN trans_fat DECIMAL(10, 2),
ADD COLUMN vitamin_a INTEGER,
ADD COLUMN vitamin_c INTEGER,
ADD COLUMN calcium INTEGER,
ADD COLUMN iron INTEGER,
ADD COLUMN nutritional_info_complete BOOLEAN DEFAULT FALSE;

-- Add dietary information
ALTER TABLE recipes
ADD COLUMN is_vegetarian BOOLEAN DEFAULT FALSE,
ADD COLUMN is_vegan BOOLEAN DEFAULT FALSE,
ADD COLUMN is_gluten_free BOOLEAN DEFAULT FALSE,
ADD COLUMN is_dairy_free BOOLEAN DEFAULT FALSE,
ADD COLUMN is_nut_free BOOLEAN DEFAULT FALSE,
ADD COLUMN is_low_carb BOOLEAN DEFAULT FALSE,
ADD COLUMN is_keto BOOLEAN DEFAULT FALSE,
ADD COLUMN is_paleo BOOLEAN DEFAULT FALSE;

-- Add recipe metadata
ALTER TABLE recipes
ADD COLUMN total_time INTEGER,
ADD COLUMN skill_level VARCHAR(50),
ADD COLUMN cost_estimate VARCHAR(50),
ADD COLUMN cuisine VARCHAR(100),
ADD COLUMN meal_type VARCHAR(50),
ADD COLUMN spice_level VARCHAR(50);

COMMENT ON COLUMN recipes.calories IS 'Calories per serving';
COMMENT ON COLUMN recipes.protein IS 'Protein in grams per serving';
COMMENT ON COLUMN recipes.carbohydrates IS 'Carbohydrates in grams per serving';
COMMENT ON COLUMN recipes.fat IS 'Fat in grams per serving';
COMMENT ON COLUMN recipes.total_time IS 'Total time in minutes (prep + cook)';
