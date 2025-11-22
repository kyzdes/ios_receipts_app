-- User follows table
CREATE TABLE user_follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(follower_id, following_id),
    CHECK (follower_id != following_id)
);

-- Recipe ratings and reviews
CREATE TABLE recipe_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(recipe_id, user_id)
);

-- Recipe comments
CREATE TABLE recipe_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES recipe_comments(id) ON DELETE CASCADE,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Recipe likes
CREATE TABLE recipe_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(recipe_id, user_id)
);

-- Recipe views/analytics
CREATE TABLE recipe_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Recipe sharing
ALTER TABLE recipes
ADD COLUMN is_public BOOLEAN DEFAULT FALSE,
ADD COLUMN share_code VARCHAR(50) UNIQUE,
ADD COLUMN view_count INTEGER DEFAULT 0,
ADD COLUMN like_count INTEGER DEFAULT 0,
ADD COLUMN comment_count INTEGER DEFAULT 0,
ADD COLUMN rating_average DECIMAL(3, 2),
ADD COLUMN rating_count INTEGER DEFAULT 0;

-- User profile enhancements
ALTER TABLE users
ADD COLUMN bio TEXT,
ADD COLUMN profile_image_url TEXT,
ADD COLUMN location VARCHAR(255),
ADD COLUMN website VARCHAR(500),
ADD COLUMN instagram_handle VARCHAR(100),
ADD COLUMN follower_count INTEGER DEFAULT 0,
ADD COLUMN following_count INTEGER DEFAULT 0,
ADD COLUMN recipe_count INTEGER DEFAULT 0;

-- Indexes
CREATE INDEX idx_user_follows_follower ON user_follows(follower_id);
CREATE INDEX idx_user_follows_following ON user_follows(following_id);
CREATE INDEX idx_recipe_ratings_recipe ON recipe_ratings(recipe_id);
CREATE INDEX idx_recipe_ratings_user ON recipe_ratings(user_id);
CREATE INDEX idx_recipe_comments_recipe ON recipe_comments(recipe_id);
CREATE INDEX idx_recipe_comments_user ON recipe_comments(user_id);
CREATE INDEX idx_recipe_comments_parent ON recipe_comments(parent_comment_id);
CREATE INDEX idx_recipe_likes_recipe ON recipe_likes(recipe_id);
CREATE INDEX idx_recipe_likes_user ON recipe_likes(user_id);
CREATE INDEX idx_recipe_views_recipe ON recipe_views(recipe_id);
CREATE INDEX idx_recipe_views_created_at ON recipe_views(created_at);
CREATE INDEX idx_recipes_is_public ON recipes(is_public);

COMMENT ON TABLE user_follows IS 'Social following relationships between users';
COMMENT ON TABLE recipe_ratings IS 'User ratings (1-5 stars) and reviews for recipes';
COMMENT ON TABLE recipe_comments IS 'Comments on recipes with threading support';
COMMENT ON TABLE recipe_likes IS 'Quick likes for recipes';
COMMENT ON TABLE recipe_views IS 'Analytics tracking for recipe views';
