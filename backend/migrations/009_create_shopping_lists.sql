-- Shopping lists table
CREATE TABLE shopping_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shopping list items
CREATE TABLE shopping_list_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shopping_list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
    recipe_id UUID REFERENCES recipes(id) ON DELETE SET NULL,
    ingredient_name VARCHAR(255) NOT NULL,
    quantity VARCHAR(100),
    unit VARCHAR(50),
    category VARCHAR(100),
    is_checked BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shared shopping lists (for households)
CREATE TABLE shopping_list_shares (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shopping_list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
    shared_with_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    permission_level VARCHAR(50) DEFAULT 'edit', -- 'view' or 'edit'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(shopping_list_id, shared_with_user_id)
);

-- Indexes
CREATE INDEX idx_shopping_lists_user_id ON shopping_lists(user_id);
CREATE INDEX idx_shopping_list_items_list_id ON shopping_list_items(shopping_list_id);
CREATE INDEX idx_shopping_list_items_recipe_id ON shopping_list_items(recipe_id);
CREATE INDEX idx_shopping_list_shares_list_id ON shopping_list_shares(shopping_list_id);
CREATE INDEX idx_shopping_list_shares_user_id ON shopping_list_shares(shared_with_user_id);

COMMENT ON TABLE shopping_lists IS 'User shopping lists for recipes and general groceries';
COMMENT ON TABLE shopping_list_items IS 'Individual items in shopping lists';
COMMENT ON COLUMN shopping_list_items.category IS 'Grocery store section: produce, dairy, meat, etc.';
