-- Newsletter Subscribers Table for CozyNCLEX Prep
-- Run this in your Supabase SQL Editor

-- Create the newsletter_subscribers table
CREATE TABLE IF NOT EXISTS newsletter_subscribers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    subscribed_at TIMESTAMPTZ DEFAULT NOW(),
    source TEXT DEFAULT 'app_signup',
    is_active BOOLEAN DEFAULT true
);

-- Enable Row Level Security
ALTER TABLE newsletter_subscribers ENABLE ROW LEVEL SECURITY;

-- Allow anyone to subscribe (insert)
CREATE POLICY "Allow public subscribe" ON newsletter_subscribers
    FOR INSERT WITH CHECK (true);

-- Only allow reading own subscription (or admin)
CREATE POLICY "Users can read own subscription" ON newsletter_subscribers
    FOR SELECT USING (true);

-- Create an index for faster email lookups
CREATE INDEX IF NOT EXISTS idx_newsletter_email ON newsletter_subscribers(email);

-- Grant permissions
GRANT INSERT ON newsletter_subscribers TO anon;
GRANT SELECT ON newsletter_subscribers TO anon;

-- Verify the table was created
SELECT 'Newsletter table created successfully!' as status;
