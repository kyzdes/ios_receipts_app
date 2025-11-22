-- Pantry inventory tracking
CREATE TABLE pantry_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    ingredient_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    quantity VARCHAR(100),
    unit VARCHAR(50),
    purchase_date DATE,
    expiration_date DATE,
    location VARCHAR(100), -- 'pantry', 'fridge', 'freezer'
    notes TEXT,
    is_running_low BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shopping list templates (frequently bought items)
CREATE TABLE shopping_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    items JSONB NOT NULL, -- Array of template items
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Recipe ingredient substitutions
CREATE TABLE ingredient_substitutions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    original_ingredient VARCHAR(255) NOT NULL,
    substitute_ingredient VARCHAR(255) NOT NULL,
    ratio VARCHAR(100), -- e.g., "1:1", "2:1"
    notes TEXT,
    dietary_tags VARCHAR(255)[], -- e.g., ['vegan', 'gluten-free']
    is_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_pantry_items_user ON pantry_items(user_id);
CREATE INDEX idx_pantry_items_expiration ON pantry_items(expiration_date);
CREATE INDEX idx_pantry_items_location ON pantry_items(location);
CREATE INDEX idx_shopping_templates_user ON shopping_templates(user_id);
CREATE INDEX idx_ingredient_substitutions_original ON ingredient_substitutions(original_ingredient);

COMMENT ON TABLE pantry_items IS 'User pantry inventory for tracking available ingredients';
COMMENT ON TABLE shopping_templates IS 'Reusable shopping list templates';
COMMENT ON TABLE ingredient_substitutions IS 'Database of ingredient substitutions';

-- Insert common substitutions
INSERT INTO ingredient_substitutions (original_ingredient, substitute_ingredient, ratio, dietary_tags, is_approved) VALUES
('butter', 'coconut oil', '1:1', ARRAY['vegan', 'dairy-free'], true),
('butter', 'margarine', '1:1', ARRAY['dairy-free'], true),
('milk', 'almond milk', '1:1', ARRAY['vegan', 'dairy-free'], true),
('milk', 'oat milk', '1:1', ARRAY['vegan', 'dairy-free'], true),
('egg', 'flax egg', '1:1', ARRAY['vegan'], true),
('egg', 'applesauce', '1 egg = 1/4 cup', ARRAY['vegan'], true),
('all-purpose flour', 'almond flour', '1:1', ARRAY['gluten-free', 'low-carb'], true),
('sugar', 'honey', '1:1', ARRAY[], true),
('sugar', 'maple syrup', '1:1', ARRAY['vegan'], true),
('sour cream', 'greek yogurt', '1:1', ARRAY[], true),
('heavy cream', 'coconut cream', '1:1', ARRAY['vegan', 'dairy-free'], true),
('bread crumbs', 'panko', '1:1', ARRAY[], true),
('bread crumbs', 'crushed cornflakes', '1:1', ARRAY['gluten-free'], true);
