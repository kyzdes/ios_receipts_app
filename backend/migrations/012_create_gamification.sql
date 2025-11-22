-- Achievements definition
CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon_url VARCHAR(500),
    category VARCHAR(100),
    points INTEGER DEFAULT 0,
    tier VARCHAR(50), -- 'bronze', 'silver', 'gold', 'platinum'
    is_secret BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User achievements (unlocked achievements)
CREATE TABLE user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    progress INTEGER DEFAULT 100,
    UNIQUE(user_id, achievement_id)
);

-- Cooking activity tracking
CREATE TABLE cooking_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    activity_type VARCHAR(50) NOT NULL, -- 'cooked', 'viewed', 'shared', 'rated'
    activity_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User stats and progression
CREATE TABLE user_stats (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    total_recipes_cooked INTEGER DEFAULT 0,
    total_recipes_created INTEGER DEFAULT 0,
    total_recipes_shared INTEGER DEFAULT 0,
    current_streak_days INTEGER DEFAULT 0,
    longest_streak_days INTEGER DEFAULT 0,
    last_cooked_date DATE,
    total_cooking_time_minutes INTEGER DEFAULT 0,
    experience_points INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    achievement_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Challenges
CREATE TABLE challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    challenge_type VARCHAR(50), -- 'daily', 'weekly', 'monthly', 'special'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    requirements JSONB, -- Flexible challenge requirements
    reward_points INTEGER DEFAULT 0,
    reward_badge_id UUID REFERENCES achievements(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User challenge participation
CREATE TABLE user_challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    progress INTEGER DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, challenge_id)
);

-- Leaderboards (materialized view - updated daily)
CREATE TABLE leaderboard_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    leaderboard_type VARCHAR(100) NOT NULL, -- 'recipes_cooked', 'streak', 'likes_received', etc.
    period VARCHAR(50) NOT NULL, -- 'daily', 'weekly', 'monthly', 'all_time'
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    score INTEGER NOT NULL,
    rank INTEGER,
    period_start DATE,
    period_end DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(leaderboard_type, period, user_id, period_start)
);

-- Indexes
CREATE INDEX idx_user_achievements_user ON user_achievements(user_id);
CREATE INDEX idx_user_achievements_achievement ON user_achievements(achievement_id);
CREATE INDEX idx_cooking_activities_user ON cooking_activities(user_id);
CREATE INDEX idx_cooking_activities_date ON cooking_activities(activity_date);
CREATE INDEX idx_cooking_activities_recipe ON cooking_activities(recipe_id);
CREATE INDEX idx_user_challenges_user ON user_challenges(user_id);
CREATE INDEX idx_user_challenges_challenge ON user_challenges(challenge_id);
CREATE INDEX idx_leaderboard_type_period ON leaderboard_entries(leaderboard_type, period, period_start);
CREATE INDEX idx_leaderboard_rank ON leaderboard_entries(rank);

COMMENT ON TABLE achievements IS 'Defined achievements users can unlock';
COMMENT ON TABLE user_achievements IS 'Achievements unlocked by users';
COMMENT ON TABLE cooking_activities IS 'Log of all cooking-related user activities';
COMMENT ON TABLE user_stats IS 'Aggregated statistics and progression for each user';
COMMENT ON TABLE challenges IS 'Time-limited cooking challenges';
COMMENT ON TABLE leaderboard_entries IS 'Leaderboard rankings for various metrics';

-- Insert initial achievements
INSERT INTO achievements (code, name, description, category, points, tier) VALUES
('first_recipe', 'First Recipe', 'Create your first recipe', 'creation', 10, 'bronze'),
('chef_10', 'Rising Chef', 'Cook 10 recipes', 'cooking', 50, 'silver'),
('chef_50', 'Experienced Chef', 'Cook 50 recipes', 'cooking', 200, 'gold'),
('chef_100', 'Master Chef', 'Cook 100 recipes', 'cooking', 500, 'platinum'),
('week_streak', 'Week Warrior', 'Cook for 7 days straight', 'streak', 100, 'silver'),
('month_streak', 'Monthly Master', 'Cook for 30 days straight', 'streak', 500, 'gold'),
('social_butterfly', 'Social Butterfly', 'Share 10 recipes', 'social', 50, 'silver'),
('popular', 'Popular Chef', 'Get 100 likes on your recipes', 'social', 200, 'gold'),
('reviewer', 'Food Critic', 'Rate 25 recipes', 'engagement', 50, 'silver'),
('early_bird', 'Early Bird', 'Cook breakfast 7 days in a row', 'special', 100, 'silver'),
('globe_trotter', 'Globe Trotter', 'Cook recipes from 10 different cuisines', 'diversity', 150, 'gold'),
('healthy_eater', 'Healthy Eater', 'Cook 30 low-calorie meals', 'health', 200, 'gold'),
('speed_demon', 'Speed Demon', 'Cook 20 recipes under 30 minutes', 'efficiency', 100, 'silver'),
('influencer', 'Influencer', 'Get 50 followers', 'social', 300, 'gold');
