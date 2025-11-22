-- Recipe forking/versions (for recipe remixes)
ALTER TABLE recipes
ADD COLUMN parent_recipe_id UUID REFERENCES recipes(id) ON DELETE SET NULL,
ADD COLUMN fork_count INTEGER DEFAULT 0,
ADD COLUMN is_fork BOOLEAN DEFAULT FALSE,
ADD COLUMN modifications_description TEXT;

-- Recipe tags (for better discovery)
CREATE TABLE recipe_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50), -- 'cuisine', 'diet', 'cooking_method', 'occasion', etc.
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Recipe-tag junction table
CREATE TABLE recipe_tag_relations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES recipe_tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(recipe_id, tag_id)
);

-- Recipe cooking logs (when users cook a recipe)
CREATE TABLE recipe_cooking_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    cooked_date DATE NOT NULL,
    servings_made INTEGER,
    time_taken_minutes INTEGER,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    notes TEXT,
    would_make_again BOOLEAN,
    photos TEXT[], -- Array of photo URLs
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User dietary preferences
CREATE TABLE user_preferences (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    dietary_restrictions VARCHAR(100)[], -- ['vegetarian', 'gluten-free', etc.]
    allergens VARCHAR(100)[], -- ['nuts', 'shellfish', 'dairy', etc.]
    disliked_ingredients VARCHAR(255)[],
    preferred_cuisines VARCHAR(100)[],
    max_prep_time INTEGER, -- in minutes
    max_cook_time INTEGER,
    preferred_difficulty VARCHAR(50)[],
    spice_preference VARCHAR(50), -- 'mild', 'medium', 'hot'
    daily_calorie_goal INTEGER,
    daily_protein_goal INTEGER,
    daily_carb_goal INTEGER,
    daily_fat_goal INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_recipes_parent_recipe ON recipes(parent_recipe_id);
CREATE INDEX idx_recipe_tags_name ON recipe_tags(name);
CREATE INDEX idx_recipe_tags_category ON recipe_tags(category);
CREATE INDEX idx_recipe_tag_relations_recipe ON recipe_tag_relations(recipe_id);
CREATE INDEX idx_recipe_tag_relations_tag ON recipe_tag_relations(tag_id);
CREATE INDEX idx_recipe_cooking_logs_recipe ON recipe_cooking_logs(recipe_id);
CREATE INDEX idx_recipe_cooking_logs_user ON recipe_cooking_logs(user_id);
CREATE INDEX idx_recipe_cooking_logs_date ON recipe_cooking_logs(cooked_date);

COMMENT ON TABLE recipe_tags IS 'Flexible tagging system for recipes';
COMMENT ON TABLE recipe_cooking_logs IS 'Track when users actually cook recipes';
COMMENT ON TABLE user_preferences IS 'User dietary preferences and cooking constraints';

-- Insert common tags
INSERT INTO recipe_tags (name, category) VALUES
-- Cuisines
('Italian', 'cuisine'),
('Mexican', 'cuisine'),
('Chinese', 'cuisine'),
('Indian', 'cuisine'),
('Thai', 'cuisine'),
('Japanese', 'cuisine'),
('French', 'cuisine'),
('Greek', 'cuisine'),
('Mediterranean', 'cuisine'),
('American', 'cuisine'),
-- Diets
('Vegan', 'diet'),
('Vegetarian', 'diet'),
('Gluten-Free', 'diet'),
('Keto', 'diet'),
('Paleo', 'diet'),
('Low-Carb', 'diet'),
('Dairy-Free', 'diet'),
('Nut-Free', 'diet'),
-- Cooking Methods
('Baking', 'cooking_method'),
('Grilling', 'cooking_method'),
('Slow Cooker', 'cooking_method'),
('Instant Pot', 'cooking_method'),
('Air Fryer', 'cooking_method'),
('No-Cook', 'cooking_method'),
('One-Pot', 'cooking_method'),
-- Occasions
('Weeknight Dinner', 'occasion'),
('Date Night', 'occasion'),
('Party Food', 'occasion'),
('Meal Prep', 'occasion'),
('Holiday', 'occasion'),
('Kid-Friendly', 'occasion'),
-- Meal Types
('Breakfast', 'meal_type'),
('Lunch', 'meal_type'),
('Dinner', 'meal_type'),
('Dessert', 'meal_type'),
('Snack', 'meal_type'),
('Appetizer', 'meal_type'),
('Side Dish', 'meal_type'),
('Salad', 'meal_type'),
('Soup', 'meal_type'),
('Beverage', 'meal_type');
