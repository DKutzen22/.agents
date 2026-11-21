-- ============================================================================
-- Canonical Phage Annotation SQLite Schema
-- Single Source of Truth for Snakemake/Python pipelines and R Shiny frontend
-- ============================================================================

PRAGMA foreign_keys = ON;

-- ----------------------------------------------------------------------------
-- 1. Genomes: Genome-level metadata and physical assembly properties
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS genomes (
    genome_id     TEXT PRIMARY KEY,                     -- Identifier / FASTA record ID (e.g., 'phage_isolate_01')
    accession     TEXT,                                  -- INSDC / GenBank accession if deposited
    organism      TEXT,                                  -- Host / phage organism name
    length_bp     INTEGER NOT NULL CHECK(length_bp > 0), -- Total genome length in base pairs
    gc_content    REAL NOT NULL CHECK(gc_content >= 0.0 AND gc_content <= 1.0), -- GC fraction (0.0000 - 1.0000)
    topology      TEXT NOT NULL DEFAULT 'linear' CHECK(topology IN ('linear', 'circular')),
    source_file   TEXT,                                  -- Source .gbk or .fasta path
    created_at    TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_genomes_accession ON genomes(accession);

-- ----------------------------------------------------------------------------
-- 2. Features: Structural genomic elements (genes, CDS, structural RNAs)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS features (
    feature_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    genome_id     TEXT NOT NULL,
    locus_tag     TEXT NOT NULL,                         -- Immutable identifier (e.g., 'PHI_CDS_0001')
    feature_type  TEXT NOT NULL CHECK(feature_type IN ('CDS', 'tRNA', 'tmRNA', 'CRISPR', 'repeat_region')),
    start_pos     INTEGER NOT NULL CHECK(start_pos >= 0), -- 0-based coordinate, inclusive
    end_pos       INTEGER NOT NULL CHECK(end_pos > start_pos), -- 0-based coordinate, exclusive
    strand        INTEGER NOT NULL CHECK(strand IN (1, -1)),  -- 1: positive/forward, -1: reverse/complement
    is_partial    INTEGER NOT NULL DEFAULT 0 CHECK(is_partial IN (0, 1)), -- 1 if start/end is incomplete (<1 or >length)
    nt_seq        TEXT,                                  -- Nucleotide sequence of feature
    aa_seq        TEXT,                                  -- Translated amino acid sequence (for CDS)
    FOREIGN KEY (genome_id) REFERENCES genomes(genome_id) ON DELETE CASCADE,
    UNIQUE (genome_id, locus_tag)
);

CREATE INDEX IF NOT EXISTS idx_features_genome_id ON features(genome_id);
CREATE INDEX IF NOT EXISTS idx_features_locus_tag ON features(locus_tag);
CREATE INDEX IF NOT EXISTS idx_features_coords ON features(genome_id, start_pos, end_pos);
CREATE INDEX IF NOT EXISTS idx_features_type ON features(feature_type);

-- ----------------------------------------------------------------------------
-- 3. PHROG Categories Lookup Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS phrog_categories (
    category_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    category_name TEXT NOT NULL UNIQUE,
    color_hex     TEXT NOT NULL CHECK(length(color_hex) = 7 AND substr(color_hex, 1, 1) = '#'),
    description   TEXT
);

-- Seed standard 10 PHROG functional categories with canonical color palette
INSERT OR IGNORE INTO phrog_categories (category_id, category_name, color_hex, description) VALUES
(1,  'connector',                                      '#1f77b4', 'Connector and head-to-tail interface proteins'),
(2,  'DNA, RNA and nucleotide metabolism',             '#aec7e8', 'Replication, recombination, repair, and synthesis machinery'),
(3,  'head and packaging',                             '#ff7f0e', 'Capsid structural proteins and terminase packaging complex'),
(4,  'integration and excision',                       '#ffbb78', 'Integrases, excisionases, and site-specific recombinases'),
(5,  'lysis',                                          '#2ca02c', 'Endolysins, holins, spanins, and peptidoglycan hydrolases'),
(6,  'moron, auxiliary metabolic gene and host takeover','#98df8a', 'AMGs, host immunity inhibitors, and toxin/antitoxin modules'),
(7,  'other',                                          '#d62728', 'Characterized phage proteins outside standard structural classes'),
(8,  'tail',                                           '#ff9896', 'Tail tube, fibers, baseplate, and receptor-binding proteins'),
(9,  'transcription regulation',                       '#9467bd', 'Sigma factors, repressors, antiterminators, and promoters'),
(10, 'unknown function',                               '#c5b0d5', 'Hypothetical proteins without verified functional assignment');

-- ----------------------------------------------------------------------------
-- 4. Annotations: Functional calls from tools (Pharokka, Phold, Phynteny, GenBank)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS annotations (
    annotation_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    feature_id       INTEGER NOT NULL,
    tool_source      TEXT NOT NULL CHECK(tool_source IN ('pharokka', 'phold', 'phynteny', 'genbank')),
    product          TEXT NOT NULL DEFAULT 'hypothetical protein',
    phrog_id         TEXT,                               -- e.g., 'phrog_1234'
    phrog_category   TEXT,                               -- Functional category name
    evalue           REAL,                               -- Search e-value (Foldseek/MMseqs/BLAST)
    bitscore         REAL,                               -- Alignment bitscore
    confidence_score REAL CHECK(confidence_score IS NULL OR (confidence_score >= 0.0 AND confidence_score <= 1.0)), -- e.g., Phynteny synteny probability
    is_primary       INTEGER NOT NULL DEFAULT 0 CHECK(is_primary IN (0, 1)), -- 1 if chosen as consensus/curated call
    FOREIGN KEY (feature_id) REFERENCES features(feature_id) ON DELETE CASCADE,
    FOREIGN KEY (phrog_category) REFERENCES phrog_categories(category_name) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_annotations_feature ON annotations(feature_id);
CREATE INDEX IF NOT EXISTS idx_annotations_tool ON annotations(tool_source);
CREATE INDEX IF NOT EXISTS idx_annotations_phrog_id ON annotations(phrog_id);
CREATE INDEX IF NOT EXISTS idx_annotations_product ON annotations(product);
CREATE INDEX IF NOT EXISTS idx_annotations_primary ON annotations(feature_id, is_primary);
