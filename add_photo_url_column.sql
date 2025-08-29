-- SQL script to add photo_url column to pet_profile table
-- Run this in your Supabase SQL editor

ALTER TABLE pet_profile 
ADD COLUMN IF NOT EXISTS photo_url TEXT;

-- Optional: Add a comment to describe the column
COMMENT ON COLUMN pet_profile.photo_url IS 'URL of the pet profile photo stored in Supabase Storage';
