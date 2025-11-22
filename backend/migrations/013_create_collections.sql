-- Recipe collections (cookbooks, themed collections)
CREATE TABLE recipe_collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    cover_image_url TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    is_collaborative BOOLEAN DEFAULT FALSE,
    recipe_count INTEGER DEFAULT 0,
    follower_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Recipes in collections (many-to-many)
CREATE TABLE collection_recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    collection_id UUID NOT NULL REFERENCES recipe_collections(id) ON DELETE CASCADE,
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    added_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    sort_order INTEGER DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(collection_id, recipe_id)
);

-- Collection collaborators
CREATE TABLE collection_collaborators (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    collection_id UUID NOT NULL REFERENCES recipe_collections(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    permission_level VARCHAR(50) DEFAULT 'edit', -- 'view', 'edit', 'admin'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(collection_id, user_id)
);

-- Collection followers
CREATE TABLE collection_followers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    collection_id UUID NOT NULL REFERENCES recipe_collections(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(collection_id, user_id)
);

-- Indexes
CREATE INDEX idx_recipe_collections_user ON recipe_collections(user_id);
CREATE INDEX idx_recipe_collections_public ON recipe_collections(is_public);
CREATE INDEX idx_collection_recipes_collection ON collection_recipes(collection_id);
CREATE INDEX idx_collection_recipes_recipe ON collection_recipes(recipe_id);
CREATE INDEX idx_collection_collaborators_collection ON collection_collaborators(collection_id);
CREATE INDEX idx_collection_collaborators_user ON collection_collaborators(user_id);
CREATE INDEX idx_collection_followers_collection ON collection_followers(collection_id);
CREATE INDEX idx_collection_followers_user ON collection_followers(user_id);

COMMENT ON TABLE recipe_collections IS 'User-created collections of recipes (cookbooks)';
COMMENT ON TABLE collection_recipes IS 'Recipes belonging to collections';
COMMENT ON TABLE collection_collaborators IS 'Users who can edit a collection';
COMMENT ON TABLE collection_followers IS 'Users following a public collection';
