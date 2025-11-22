-- Meal plans table
CREATE TABLE meal_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Meal plan entries (individual meals)
CREATE TABLE meal_plan_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meal_plan_id UUID NOT NULL REFERENCES meal_plans(id) ON DELETE CASCADE,
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    meal_date DATE NOT NULL,
    meal_type VARCHAR(50) NOT NULL, -- 'breakfast', 'lunch', 'dinner', 'snack'
    servings INTEGER DEFAULT 1,
    notes TEXT,
    is_cooked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_meal_plans_user_id ON meal_plans(user_id);
CREATE INDEX idx_meal_plans_dates ON meal_plans(start_date, end_date);
CREATE INDEX idx_meal_plan_entries_plan_id ON meal_plan_entries(meal_plan_id);
CREATE INDEX idx_meal_plan_entries_date ON meal_plan_entries(meal_date);
CREATE INDEX idx_meal_plan_entries_recipe_id ON meal_plan_entries(recipe_id);

COMMENT ON TABLE meal_plans IS 'User meal planning for weeks/months';
COMMENT ON TABLE meal_plan_entries IS 'Individual meals scheduled in meal plans';
COMMENT ON COLUMN meal_plan_entries.meal_type IS 'Type of meal: breakfast, lunch, dinner, snack';
COMMENT ON COLUMN meal_plan_entries.is_cooked IS 'Whether the meal has been cooked yet';
