-- CozyNCLEX Prep - Supabase Database Schema
-- Run this in Supabase SQL Editor

-- ============================================
-- 1. USER CARD PROGRESS (mastered, saved, streaks)
-- ============================================
CREATE TABLE IF NOT EXISTS user_card_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    card_id UUID NOT NULL,
    consecutive_correct INT DEFAULT 0,
    is_mastered BOOLEAN DEFAULT FALSE,
    is_saved BOOLEAN DEFAULT FALSE,
    is_flagged BOOLEAN DEFAULT FALSE,
    times_studied INT DEFAULT 0,
    times_correct INT DEFAULT 0,
    last_studied_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, card_id)
);

-- Index for fast lookups
CREATE INDEX IF NOT EXISTS idx_user_card_progress_user_id ON user_card_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_card_progress_card_id ON user_card_progress(card_id);
CREATE INDEX IF NOT EXISTS idx_user_card_progress_mastered ON user_card_progress(user_id, is_mastered) WHERE is_mastered = TRUE;
CREATE INDEX IF NOT EXISTS idx_user_card_progress_saved ON user_card_progress(user_id, is_saved) WHERE is_saved = TRUE;

-- ============================================
-- 2. USER STATS (overall statistics)
-- ============================================
CREATE TABLE IF NOT EXISTS user_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    total_cards_studied INT DEFAULT 0,
    total_correct INT DEFAULT 0,
    total_incorrect INT DEFAULT 0,
    current_streak INT DEFAULT 0,
    longest_streak INT DEFAULT 0,
    last_study_date DATE,
    total_xp INT DEFAULT 0,
    current_level INT DEFAULT 1,
    study_sessions_completed INT DEFAULT 0,
    tests_completed INT DEFAULT 0,
    perfect_sessions INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 3. USER CREATED CARDS
-- ============================================
CREATE TABLE IF NOT EXISTS user_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    wrong_answers JSONB DEFAULT '[]',
    rationale TEXT DEFAULT '',
    content_category TEXT NOT NULL,
    nclex_category TEXT DEFAULT 'physiological',
    difficulty TEXT DEFAULT 'medium',
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_cards_user_id ON user_cards(user_id);

-- ============================================
-- 4. STUDY SETS
-- ============================================
CREATE TABLE IF NOT EXISTS study_sets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    card_ids JSONB DEFAULT '[]',
    color TEXT DEFAULT 'blue',
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_study_sets_user_id ON study_sets(user_id);

-- ============================================
-- 5. DAILY GOALS / ACTIVITY LOG
-- ============================================
CREATE TABLE IF NOT EXISTS daily_activity (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    activity_date DATE NOT NULL,
    cards_studied INT DEFAULT 0,
    correct_answers INT DEFAULT 0,
    xp_earned INT DEFAULT 0,
    minutes_studied INT DEFAULT 0,
    goals_completed JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, activity_date)
);

CREATE INDEX IF NOT EXISTS idx_daily_activity_user_date ON daily_activity(user_id, activity_date);

-- ============================================
-- 6. TEST RESULTS
-- ============================================
CREATE TABLE IF NOT EXISTS test_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    test_date TIMESTAMPTZ DEFAULT NOW(),
    question_count INT NOT NULL,
    correct_count INT NOT NULL,
    time_taken_seconds INT,
    category_breakdown JSONB DEFAULT '{}',
    difficulty TEXT DEFAULT 'mixed',
    test_type TEXT DEFAULT 'practice',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_test_results_user_id ON test_results(user_id);
CREATE INDEX IF NOT EXISTS idx_test_results_date ON test_results(user_id, test_date);

-- ============================================
-- 7. CARD NOTES (user notes on cards)
-- ============================================
CREATE TABLE IF NOT EXISTS card_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    card_id UUID NOT NULL,
    note TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, card_id)
);

CREATE INDEX IF NOT EXISTS idx_card_notes_user_card ON card_notes(user_id, card_id);

-- ============================================
-- 8. ACHIEVEMENTS
-- ============================================
CREATE TABLE IF NOT EXISTS user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    achievement_id TEXT NOT NULL,
    unlocked_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE user_card_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE test_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE card_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

-- Policies: Users can only access their own data
CREATE POLICY "Users can view own card progress" ON user_card_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own card progress" ON user_card_progress FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own card progress" ON user_card_progress FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own card progress" ON user_card_progress FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own stats" ON user_stats FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own stats" ON user_stats FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own stats" ON user_stats FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own cards" ON user_cards FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own cards" ON user_cards FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own cards" ON user_cards FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own cards" ON user_cards FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own study sets" ON study_sets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own study sets" ON study_sets FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own study sets" ON study_sets FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own study sets" ON study_sets FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own daily activity" ON daily_activity FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own daily activity" ON daily_activity FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own daily activity" ON daily_activity FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own test results" ON test_results FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own test results" ON test_results FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own card notes" ON card_notes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own card notes" ON card_notes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own card notes" ON card_notes FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own card notes" ON card_notes FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own achievements" ON user_achievements FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own achievements" ON user_achievements FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- FUNCTIONS FOR AUTO-UPDATING TIMESTAMPS
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for auto-updating timestamps
CREATE TRIGGER update_user_card_progress_updated_at BEFORE UPDATE ON user_card_progress FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_stats_updated_at BEFORE UPDATE ON user_stats FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_cards_updated_at BEFORE UPDATE ON user_cards FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_study_sets_updated_at BEFORE UPDATE ON study_sets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_daily_activity_updated_at BEFORE UPDATE ON daily_activity FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_card_notes_updated_at BEFORE UPDATE ON card_notes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- HELPER FUNCTION: Initialize user stats on signup
-- ============================================
CREATE OR REPLACE FUNCTION handle_new_user_stats()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_stats (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$ language 'plpgsql' SECURITY DEFINER;

-- Trigger to auto-create user_stats when user signs up
CREATE TRIGGER on_auth_user_created_stats
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user_stats();
