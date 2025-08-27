-- Migration: Add AI Enhancement and OCR fields to documents table
-- This migration supports Stories 2-3 implementation
-- Date: 2025-08-27
-- Author: Claude Code (Story 3 Implementation)

-- Add AI Enhancement fields (Story 2: AI-Enhanced Document Processing)
ALTER TABLE documents 
ADD COLUMN IF NOT EXISTS is_enhanced BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS enhancement_metadata JSONB,
ADD COLUMN IF NOT EXISTS original_file_path TEXT;

-- Add OCR fields (Story 3: Handwriting to Text Conversion)
ALTER TABLE documents
ADD COLUMN IF NOT EXISTS extracted_text TEXT,
ADD COLUMN IF NOT EXISTS has_ocr_text BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS ocr_confidence NUMERIC,
ADD COLUMN IF NOT EXISTS ocr_metadata JSONB;

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_documents_is_enhanced ON documents(is_enhanced);
CREATE INDEX IF NOT EXISTS idx_documents_has_ocr_text ON documents(has_ocr_text);
CREATE INDEX IF NOT EXISTS idx_documents_user_id_created_at ON documents(user_id, created_at DESC);

-- Add column comments for documentation
COMMENT ON COLUMN documents.is_enhanced IS 'Story 2: Indicates if document was processed with AI enhancement';
COMMENT ON COLUMN documents.enhancement_metadata IS 'Story 2: JSON metadata from AI enhancement processing';
COMMENT ON COLUMN documents.original_file_path IS 'Story 2: Path to original file before AI enhancement';
COMMENT ON COLUMN documents.extracted_text IS 'Story 3: OCR extracted text content';
COMMENT ON COLUMN documents.has_ocr_text IS 'Story 3: Boolean flag for OCR text availability';
COMMENT ON COLUMN documents.ocr_confidence IS 'Story 3: OCR confidence score (0-1)';
COMMENT ON COLUMN documents.ocr_metadata IS 'Story 3: JSON metadata from OCR processing';