CREATE OR REPLACE FUNCTION update_modified_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.modified_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS protein (
    protein_id        TEXT PRIMARY KEY,
    protein_name      TEXT,
    clone_id          TEXT,
    component_id      TEXT,
    created_at        TIMESTAMP DEFAULT NOW(),
    created_by        TEXT,
    modified_at       TIMESTAMP DEFAULT NOW(),
    modified_by       TEXT,
    cro_id            TEXT,
    nbl_id            TEXT,
    reference_name    TEXT,
    vendor            TEXT,
    catalog_num       TEXT,
    type              TEXT,
    dotmatics_id      TEXT,
    cro               TEXT,
    stoichiometry     TEXT,
    project_code      TEXT,
    picture_path      TEXT,
    hc_type           TEXT,
    lc_type           TEXT,
    alias             TEXT,
    note              TEXT,
    pi                NUMERIC,  
    a280_1mgml        NUMERIC,  
    mw                NUMERIC, 
    source_cell       TEXT
);

CREATE TRIGGER set_modified_at_protein
BEFORE UPDATE ON protein
FOR EACH ROW
EXECUTE FUNCTION update_modified_at();

CREATE TABLE IF NOT EXISTS protein_batch (
    modified_by            TEXT,
    batch_id               TEXT,
    concentration          NUMERIC,
    buffer_solution        TEXT,
    yield_mg               NUMERIC, 
    source                 TEXT,
    unit                   TEXT,
    storage                TEXT,
    dispense_note          TEXT,
    batch_eln              TEXT,
    purification_date      DATE,
    batch_name             TEXT,
    qc_file_path           TEXT,
    room                   TEXT,
    storage_unit           TEXT,
    shelf                  TEXT,
    rack                   TEXT,
    box                    TEXT,
    qc_file_path_2         TEXT,
    sec_purity             NUMERIC,   
    page_purity            NUMERIC,  
    endotoxin_eu_mg        NUMERIC,  
    cro                    TEXT,
    qc_eln                 TEXT,
    protein_name           TEXT,
    culture_vol_ml         NUMERIC, 
    gator_titer_ug_ml      NUMERIC,  
    biointron_titer        NUMERIC,   
    assay                  TEXT,
    source_batch           TEXT,
    purification_vol_ml    NUMERIC,  
    trxn_date              DATE,
    column_used            TEXT,
    note                   TEXT,
    sec_hplc_file_path     TEXT,
    sds_page_file_path     TEXT,
    mw                     NUMERIC, 
    pi                     NUMERIC,  
    epsilon                NUMERIC,  
    starting_inventory     INTEGER, 
    current_inventory      INTEGER,   
    tube_volumes           TEXT,    
    cell_viability_harvest NUMERIC,   
    trxn_plasmids          TEXT,
    harvest_date           DATE,
    cro_id                 TEXT,
    primary_key            TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    created_at             TIMESTAMP DEFAULT NOW(),
    created_by             TEXT,
    modified_at            TIMESTAMP DEFAULT NOW(),
    protein_id             TEXT REFERENCES protein(protein_id)
);

CREATE TRIGGER set_modified_at_protein_batch
BEFORE UPDATE ON protein_batch
FOR EACH ROW
EXECUTE FUNCTION update_modified_at();

CREATE TABLE IF NOT EXISTS component (
    component_id      TEXT PRIMARY KEY,
    hybridoma_id      TEXT,
    subclass          TEXT,
    type              TEXT,
    created_at        TIMESTAMP DEFAULT NOW(),
    created_by        TEXT,
    modified_at       TIMESTAMP DEFAULT NOW(),
    modified_by       TEXT,
    species           TEXT,
    aa_sequence       TEXT,
    component_name    TEXT,
    mutation          TEXT,
    field             TEXT,
    uniprot           TEXT,
    parent            TEXT,
    note              TEXT,
    cdna_sequence     TEXT,
    ncbi_nm           TEXT,
    ncbi_np           TEXT,
    gene_fragment     TEXT,
    gf_sequence       TEXT,
    gene_fragment_2   TEXT,
    gf2_sequence      TEXT,
    vendor            TEXT,
    vendor2           TEXT,
    seq_eln           TEXT,
    seq_id            TEXT,
    project_code      TEXT,
    common            TEXT,
    seq_method        TEXT,
    germline          TEXT,
    expression        TEXT
);

CREATE TRIGGER set_modified_at_component
BEFORE UPDATE ON component
FOR EACH ROW
EXECUTE FUNCTION update_modified_at();

CREATE TABLE IF NOT EXISTS plasmid (
    gf2_dna_sequence   TEXT,
    orf_species        TEXT,
    orf                TEXT,
    basic              TEXT,
    codon_cai          NUMERIC, 
    plasmid_barcode_path TEXT,
    plasmid_id         TEXT PRIMARY KEY,
    created_at         TIMESTAMP DEFAULT NOW(),
    created_by         TEXT,
    modified_at        TIMESTAMP DEFAULT NOW(),
    modified_by        TEXT,
    plasmid_name       TEXT,
    parent_vector      TEXT,
    sequence_file_path TEXT,
    insert_seq         TEXT,
    type               TEXT,
    vector_source      TEXT,
    catalog_number     TEXT,
    additional_info    TEXT,
    n_tag              TEXT,
    c_tag              TEXT,
    eln_number         TEXT,
    selection          TEXT,
    alias              TEXT,
    pnr                TEXT,
    project_code       TEXT,
    vector             TEXT,
    antibiotic         TEXT,
    orf1               TEXT,
    orf2               TEXT,
    storage_room       TEXT,
    storage_unit       TEXT,
    shelf              TEXT,
    rack               TEXT,
    storage_box        TEXT,
    box_coordinate     TEXT,
    vendor_doc_path    TEXT,
    gf1_dna_sequence   TEXT,
    gf1                TEXT,
    cro                TEXT,
    gf2                TEXT,
    cro2               TEXT
);

CREATE TRIGGER set_modified_at_plasmid
BEFORE UPDATE ON plasmid
FOR EACH ROW
EXECUTE FUNCTION update_modified_at();

CREATE TABLE IF NOT EXISTS plasmid_batch (
    primary_key         TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    plasmid_id          TEXT REFERENCES plasmid(plasmid_id),
    created_at          TIMESTAMP DEFAULT NOW(),
    created_by          TEXT,
    modified_at         TIMESTAMP DEFAULT NOW(),
    modified_by         TEXT,
    batch_id            TEXT,
    concentration       NUMERIC,
    buffer_solution     TEXT,
    yield_ug            NUMERIC, 
    source              TEXT,
    unit                TEXT,
    storage             TEXT,
    note                TEXT,
    eln                 TEXT,
    production_date     DATE,
    batch_name          TEXT,
    qc_file_path        TEXT,
    room                TEXT,
    storage_unit        TEXT,
    shelf               TEXT,
    rack                TEXT,
    storage_box         TEXT,
    qc_file_path_2      TEXT,
    a260_to_280         NUMERIC, 
    a260_to_230         NUMERIC,   
    endotoxin           NUMERIC,  
    cro                 TEXT,
    cro_id              TEXT,
    prep                TEXT,
    seq_confirm         TEXT,
    plasmid_name        TEXT,
    vol_ml              NUMERIC,
    initial_vol_ul      NUMERIC, 
    media               NUMERIC,   
    starting_inventory  INTEGER,  
    current_inventory   INTEGER,  
    tube_volumes        TEXT,  
    confirmed_by        TEXT,
    qc_eln              TEXT
);

CREATE TRIGGER set_modified_at_plasmid_batch
BEFORE UPDATE ON plasmid_batch
FOR EACH ROW
EXECUTE FUNCTION update_modified_at();

CREATE TABLE IF NOT EXISTS hybridoma (
    hybridoma_id         TEXT PRIMARY KEY,
    clone_name           TEXT,
    created_at           TIMESTAMP DEFAULT NOW(),
    created_by           TEXT,
    modified_at          TIMESTAMP DEFAULT NOW(),
    modified_by          TEXT,
    mouse_igg_subclass   TEXT,
    light_chain_subclass TEXT,
    project_code         TEXT,
    seq_cro              TEXT,
    strain               TEXT,
    cro_id               TEXT,
    tissue               TEXT,
    eln                  TEXT,
    note                 TEXT
);

CREATE TRIGGER set_modified_at_hybridoma
BEFORE UPDATE ON hybridoma
FOR EACH ROW
EXECUTE FUNCTION update_modified_at();

CREATE TABLE IF NOT EXISTS cell_line (
    cell_line_id          TEXT PRIMARY KEY,
    cell_line_name        TEXT,
    expressed_orf         TEXT,
    created_at            TIMESTAMP DEFAULT NOW(),
    created_by            TEXT,
    modified_at           TIMESTAMP DEFAULT NOW(),
    modified_by           TEXT,
    parental_cell         TEXT,
    vendor                TEXT,
    catalog_num           TEXT,
    purchase_date         DATE,
    growth_media          TEXT,
    product_sheet_path    TEXT,
    freezing_media        TEXT,
    batch                 TEXT,
    dotmatics_id          TEXT,
    clone_name            TEXT,
    eln                   TEXT,
    base_cell_line        TEXT,
    orf_species           TEXT,
    project_code          TEXT,
    base_cell             TEXT,
    tissue_of_origin      TEXT,
    organism              TEXT,
    morphology            TEXT,
    culture_properties    TEXT,
    culture_document_path TEXT,
    weblink               TEXT,
    note                  TEXT,
    alias                 TEXT,
    reporter              TEXT,
    cell_type             TEXT,
    knock_out             TEXT,
    knock_in              TEXT,
    shrna                 TEXT
);

CREATE TRIGGER set_modified_at_cell_line
BEFORE UPDATE ON cell_line
FOR EACH ROW
EXECUTE FUNCTION update_modified_at();

CREATE TABLE IF NOT EXISTS cell_batch (
    primary_key       TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    cell_line_id      TEXT REFERENCES cell_line(cell_line_id),
    created_at        TIMESTAMP DEFAULT NOW(),
    created_by        TEXT,
    modified_at       TIMESTAMP DEFAULT NOW(),
    modified_by       TEXT,
    batch_id          TEXT,
    date              DATE,
    cell_density      TEXT,
    vials             INTEGER,
    room              TEXT,
    storage_unit      TEXT,
    tower             TEXT,
    storage_box       TEXT,
    cell_line_name    TEXT,
    passage_num       INTEGER
);

CREATE TRIGGER set_modified_at_cell_batch
BEFORE UPDATE ON cell_batch
FOR EACH ROW
EXECUTE FUNCTION update_modified_at();

CREATE TABLE IF NOT EXISTS join_table_protein_plasmid (
    primary_key   TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    created_at    TIMESTAMP DEFAULT NOW(),
    created_by    TEXT,
    modified_at   TIMESTAMP DEFAULT NOW(),
    modified_by   TEXT,
    protein_id    TEXT REFERENCES protein(protein_id),
    protein_name  TEXT,
    plasmid_id    TEXT REFERENCES plasmid(plasmid_id),
    plasmid_name  TEXT,
    pnr_number    TEXT,
    UNIQUE (protein_id, plasmid_id)
);

CREATE TRIGGER set_modified_at_join_table_protein_plasmid
BEFORE UPDATE ON join_table_protein_plasmid
FOR EACH ROW
EXECUTE FUNCTION update_modified_at();

CREATE TABLE IF NOT EXISTS join_table_component_plasmid (
    primary_key    TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    component_id   TEXT REFERENCES component(component_id),
    plasmid_id     TEXT REFERENCES plasmid(plasmid_id),
    component_name TEXT,
    plasmid_name   TEXT,
    created_at     TIMESTAMP DEFAULT NOW(),
    created_by     TEXT,
    modified_at    TIMESTAMP DEFAULT NOW(),
    modified_by    TEXT,
    pnr            TEXT,
    UNIQUE (component_id, plasmid_id)
);

CREATE TRIGGER set_modified_at_join_table_component_plasmid
BEFORE UPDATE ON join_table_component_plasmid
FOR EACH ROW
EXECUTE FUNCTION update_modified_at();

CREATE TABLE IF NOT EXISTS join_table_cell_line_plasmid (
    primary_key    TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    plasmid_id     TEXT REFERENCES plasmid(plasmid_id),
    cell_line_id   TEXT REFERENCES cell_line(cell_line_id),
    cell_line_name TEXT,
    plasmid_name   TEXT,
    created_at     TIMESTAMP DEFAULT NOW(),
    created_by     TEXT,
    modified_at    TIMESTAMP DEFAULT NOW(),
    modified_by    TEXT,
    UNIQUE (cell_line_id, plasmid_id)
);

CREATE TRIGGER set_modified_at_join_table_cell_line_plasmid
BEFORE UPDATE ON join_table_cell_line_plasmid
FOR EACH ROW
EXECUTE FUNCTION update_modified_at();