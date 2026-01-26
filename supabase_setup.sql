-- CozyNCLEX Prep - Supabase Database Setup
-- Run this SQL in your Supabase SQL Editor to create the required tables

-- ============================================
-- AUTHENTICATION SETUP (Configure in Supabase Dashboard)
-- ============================================
-- 1. Go to Authentication > Providers in Supabase Dashboard
-- 2. Enable the following providers:
--    - Email (enabled by default)
--    - Apple: Add your Apple Services ID and Team ID
--    - Google: Add your Google Client ID and Secret
-- 3. Configure Site URL and Redirect URLs in Authentication > URL Configuration

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Create trigger function for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- ============================================
-- USER PROFILES TABLE
-- ============================================

CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    avatar_url TEXT,
    is_premium BOOLEAN NOT NULL DEFAULT false,
    total_xp INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on user_profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile
CREATE POLICY "Users can read own profile"
ON user_profiles FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile"
ON user_profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
ON user_profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Users can delete their own profile
CREATE POLICY "Users can delete own profile"
ON user_profiles FOR DELETE
TO authenticated
USING (auth.uid() = id);

-- Create trigger to update updated_at timestamp
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- USER SYNC DATA TABLE (for iCloud alternative/backup)
-- ============================================

CREATE TABLE user_sync_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    data_type TEXT NOT NULL, -- 'progress', 'cards', 'stats', etc.
    data JSONB NOT NULL,
    last_modified TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, data_type)
);

-- Enable RLS on user_sync_data
ALTER TABLE user_sync_data ENABLE ROW LEVEL SECURITY;

-- Users can only access their own sync data
CREATE POLICY "Users can manage own sync data"
ON user_sync_data FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ============================================

-- NCLEX Questions Table
CREATE TABLE nclex_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    wrong_answers JSONB NOT NULL DEFAULT '[]',
    rationale TEXT,
    content_category TEXT NOT NULL,
    nclex_category TEXT NOT NULL,
    difficulty TEXT NOT NULL DEFAULT 'Medium',
    question_type TEXT NOT NULL DEFAULT 'Multiple Choice',
    is_premium BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    version TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Content Versions Table
CREATE TABLE content_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version TEXT NOT NULL UNIQUE,
    published_at TIMESTAMPTZ DEFAULT NOW(),
    is_current BOOLEAN DEFAULT false
);

-- Create indexes for faster queries
CREATE INDEX idx_questions_active ON nclex_questions(is_active);
CREATE INDEX idx_questions_version ON nclex_questions(version);
CREATE INDEX idx_questions_category ON nclex_questions(content_category);
CREATE INDEX idx_questions_premium ON nclex_questions(is_premium);
CREATE INDEX idx_versions_current ON content_versions(is_current);

-- Row Level Security (RLS)
ALTER TABLE nclex_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_versions ENABLE ROW LEVEL SECURITY;

-- Allow anonymous read access to active questions
CREATE POLICY "Allow anonymous read access to questions"
ON nclex_questions FOR SELECT
TO anon
USING (is_active = true);

-- Allow anonymous read access to versions
CREATE POLICY "Allow anonymous read access to versions"
ON content_versions FOR SELECT
TO anon
USING (true);

CREATE TRIGGER update_nclex_questions_updated_at
    BEFORE UPDATE ON nclex_questions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insert initial version
INSERT INTO content_versions (version, is_current) VALUES ('1.0.0', true);

-- Example: Insert a sample question
-- INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, version)
-- VALUES (
--     'What is the FIRST action a nurse should take when a patient falls?',
--     'Assess the patient for injuries',
--     '["Call the physician", "Complete an incident report", "Help the patient back to bed"]'::jsonb,
--     'Patient safety is the priority. Before any other action, the nurse must assess for injuries.',
--     'Fundamentals',
--     'Safe & Effective Care',
--     'Easy',
--     'Priority/Order',
--     false,
--     '1.0.0'
-- );
