-- hybridomas

INSERT INTO hybridoma (hybridoma_id, clone_name, mouse_igg_subclass,
                        light_chain_subclass, project_code, seq_cro,
                        strain, cro_id, tissue, eln, note, created_by)
VALUES
  ('H-0000001', '4G7.B2', 'IgG1', 'kappa', 'PRJ-001', 'GenScript',
   'BALB/c', 'CRO-GS-001', 'spleen', 'ELN-2024-0011',
   'Original fusion, good titer', 'admin'),
  ('H-0000002', '12D9.A4', 'IgG2a', 'kappa', 'PRJ-001', 'GenScript',
   'BALB/c', 'CRO-GS-002', 'spleen', 'ELN-2024-0012',
   'Backup clone for CD19 program', 'admin'),
  ('H-0000003', '7F3.C11', 'IgG1', 'lambda', 'PRJ-002', 'Abmart',
   'C57BL/6', 'CRO-AB-014', 'lymph node', 'ELN-2024-0034',
   'PD1 program, high affinity', 'admin'),
  ('H-0000004', '9H6.D2', 'IgG2b', 'kappa', 'PRJ-003', 'GenScript',
   'BALB/c', 'CRO-GS-008', 'spleen', 'ELN-2024-0051',
   'HER2 binder, needs humanization', 'admin');

-- components

INSERT INTO component (component_id, hybridoma_id, subclass, type,
                        species, aa_sequence, component_name, mutation,
                        field, uniprot, parent, note, cdna_sequence,
                        ncbi_nm, ncbi_np, gene_fragment, gf_sequence,
                        gene_fragment_2, gf2_sequence, vendor, vendor2,
                        seq_eln, seq_id, project_code, common,
                        seq_method, germline, expression, created_by)
VALUES
  ('C-0000001', 'H-0000001', 'IgG1', 'Heavy chain variable',
   'Human', 'EVQLVESGGGLVQPGGSLRLSCAASGFTFSSYAMSWVRQAPGKGLEWVSAISGSGGSTYYADSVKGRFTISRDNSKNTLYLQMNSLRAEDTAVYYCAKDRGYSSGWYFDYWGQGTLVTVSS',
   'CD19-VH-01', 'none', NULL, 'Q5XXX1', NULL,
   'High homology to germline IGHV3-23', 'GAGGTGCAGCTGGTGGAGTCTGGG',
   'NM_001178098', 'NP_001171569', 'GF-VH-001', 'ATGGAGTTTGGG',
   NULL, NULL, 'GenScript', NULL, 'ELN-2024-0102', 'SEQ-VH-CD19-01',
   'PRJ-001', 'VH3', 'Sanger', 'IGHV3-23', 'Mammalian', 'admin'),

  ('C-0000002', 'H-0000001', 'kappa', 'Light chain variable',
   'Human', 'DIQMTQSPSSLSASVGDRVTITCRASQSISSYLNWYQQKPGKAPKLLIYAASSLQSGVPSRFSGSGSGTDFTLTISSLQPEDFATYYCQQSYSTPYTFGQGTKLEIK',
   'CD19-VK-01', 'none', NULL, 'Q5XXX2', NULL,
   'Standard kappa framework', 'GACATCCAGATGACCCAGTCT',
   'NM_001178099', 'NP_001171570', 'GF-VK-001', 'ATGAGTGTGCCC',
   NULL, NULL, 'GenScript', NULL, 'ELN-2024-0103', 'SEQ-VK-CD19-01',
   'PRJ-001', 'VK1', 'Sanger', 'IGKV1-39', 'Mammalian', 'admin'),

  ('C-0000003', 'H-0000003', 'IgG1', 'Heavy chain variable',
   'Human', 'QVQLVQSGAEVKKPGASVKVSCKASGYTFTSYWMHWVRQAPGQGLEWMGEINPSNGRTNYNEKFKSRVTMTRDTSTSTVYMELSSLRSEDTAVYYCARGGYYYGSGSYYFDYWGQGTLVTVSS',
   'PD1-VH-01', 'S52A', NULL, 'Q5XXX3', NULL,
   'Affinity-matured variant', 'CAGGTGCAGCTGGTGCAGTCT',
   'NM_001178100', 'NP_001171571', 'GF-VH-002', 'ATGGAGTTTGGG',
   NULL, NULL, 'Abmart', NULL, 'ELN-2024-0205', 'SEQ-VH-PD1-01',
   'PRJ-002', 'VH1', 'NGS', 'IGHV1-69', 'Mammalian', 'admin'),

  ('C-0000004', 'H-0000004', 'kappa', 'Light chain variable',
   'Human', 'EIVLTQSPATLSLSPGERATLSCRASQSVSSYLAWYQQKPGQAPRLLIYDASNRATGIPARFSGSGSGTDFTLTISSLEPEDFAVYYCQQRSNWPPYTFGQGTKVEIK',
   'HER2-VK-01', 'none', NULL, 'Q5XXX4', NULL,
   'Needs humanization before clinical use', 'GAAATTGTGTTGACGCAGTCT',
   'NM_001178101', 'NP_001171572', 'GF-VK-002', 'ATGAGTGTGCCC',
   NULL, NULL, 'GenScript', NULL, 'ELN-2024-0301', 'SEQ-VK-HER2-01',
   'PRJ-003', 'VK3', 'Sanger', 'IGKV3-20', 'Mammalian', 'admin');

-- plasmids

INSERT INTO plasmid (gf2_dna_sequence, orf_species, orf, basic,
                      codon_cai, plasmid_barcode_path, plasmid_id,
                      created_by, plasmid_name, parent_vector,
                      sequence_file_path, insert_seq, type,
                      vector_source, catalog_number, additional_info,
                      n_tag, c_tag, eln_number, selection, alias, pnr,
                      project_code, vector, antibiotic, orf1, orf2,
                      storage_room, storage_unit, shelf, rack,
                      storage_box, box_coordinate, vendor_doc_path,
                      gf1_dna_sequence, gf1, cro, gf2, cro2)
VALUES
  (NULL, 'Human', 'HC-CD19', 'pUC-derived', '0.82', NULL,
   'P-0000001', 'admin', 'pNR-CD19-HC', 'pcDNA3.1', NULL,
   'CD19-VH-01', 'Expression', 'Addgene', 'CAT-3.1-001',
   'Heavy chain expression construct for CD19 program', NULL, 'His6',
   'ELN-2024-0150', 'Ampicillin', 'pHC-CD19', 'pNR-1001', 'PRJ-001',
   'pcDNA3.1+', 'Ampicillin', 'HC-CD19', NULL, 'R201', 'Freezer-3',
   'B', '2', '14', 'A4', NULL, NULL, 'GF-VH-001', 'GenScript',
   NULL, NULL),

  (NULL, 'Human', NULL, 'pUC-derived', '0.79', NULL,
   'P-0000002', 'admin', 'pNR-CD19-LC', 'pcDNA3.1', NULL,
   'CD19-VK-01', 'Expression', 'Addgene', 'CAT-3.1-002',
   'Light chain expression construct for CD19 program', NULL, NULL,
   'ELN-2024-0151', 'Ampicillin', 'pLC-CD19', 'pNR-1002', 'PRJ-001',
   'pcDNA3.1+', 'Ampicillin', 'LC-CD19', NULL, 'R201', 'Freezer-3',
   'B', '2', '14', 'A5', NULL, NULL, 'GF-VK-001', 'GenScript',
   NULL, NULL),

  (NULL, 'Human', NULL, 'pUC-derived', '0.85', NULL,
   'P-0000003', 'admin', 'pNR-PD1-HC', 'pcDNA3.4', NULL,
   'PD1-VH-01', 'Expression', 'GenScript', 'CAT-3.4-001',
   'Affinity-matured PD1 heavy chain, IgG4', NULL, 'His6',
   'ELN-2024-0220', 'Kanamycin', 'pHC-PD1', 'pNR-1003', 'PRJ-002',
   'pcDNA3.4', 'Kanamycin', 'HC-PD1', NULL, 'R201', 'Freezer-3',
   'B', '3', '15', 'A1', NULL, NULL, 'GF-VH-002', 'Abmart',
   NULL, NULL),

  ('ATGGAGTTTGGGCTGAGCTGG', 'Human', NULL, 'pUC-derived', '0.81', NULL,
   'P-0000004', 'admin', 'pNR-Bispecific-Vector', 'pcDNA3.4', NULL,
   'CD19-VH-01_PD1-VH-01', 'Bispecific scaffold', 'Internal',
   'CAT-BSP-001', 'Knobs-into-holes bispecific scaffold, CD19xPD1',
   'His6', 'Flag', 'ELN-2024-0410', 'Kanamycin', 'pBispecific-01',
   'pNR-1004', 'PRJ-004', 'pcDNA3.4', 'Kanamycin', 'HC-CD19-knob',
   'HC-PD1-hole', 'R201', 'Freezer-3', 'C', '1', '20', 'A1', NULL,
   NULL, 'GF-VH-001', 'GenScript', 'GF-VH-002', NULL);

-- proteins

INSERT INTO protein (protein_id, protein_name, clone_id, component_id,
                      cro_id, nbl_id, reference_name, vendor,
                      catalog_num, type, dotmatics_id, cro,
                      stoichiometry, project_code, picture_path,
                      hc_type, lc_type, alias, note, pi, a280_1mgml,
                      mw, source_cell, created_by)
VALUES
  ('B-0000001', 'Anti-CD19 IgG1', '4G7.B2', 'C-0000001',
   'CRO-GS-001', 'NBL-1001', 'CD19-Ref-01', 'Internal', 'CAT-AB-001',
   'IgG1', 'DM-10001', 'GenScript', '2:2', 'PRJ-001', NULL,
   'IgG1', 'kappa', 'CD19-001', 'Lead candidate, CD19 program',
   '8.2', '1.42', '148000', 'HEK293', 'admin'),

  ('B-0000002', 'Anti-CD19 IgG1 Backup', '12D9.A4', NULL,
   'CRO-GS-002', 'NBL-1002', 'CD19-Ref-02', 'Internal', 'CAT-AB-002',
   'IgG1', 'DM-10002', 'GenScript', '2:2', 'PRJ-001', NULL,
   'IgG1', 'kappa', 'CD19-002', 'Backup clone, lower titer',
   '8.0', '1.40', '147500', 'HEK293', 'admin'),

  ('B-0000003', 'Anti-PD1 IgG4', '7F3.C11', 'C-0000003',
   'CRO-AB-014', 'NBL-1003', 'PD1-Ref-01', 'Internal', 'CAT-AB-003',
   'IgG4', 'DM-10003', 'Abmart', '2:2', 'PRJ-002', NULL,
   'IgG4', 'lambda', 'PD1-001', 'High affinity, checkpoint inhibitor',
   '7.6', '1.38', '146200', 'CHO', 'admin'),

  ('B-0000004', 'Anti-HER2 IgG1', '9H6.D2', 'C-0000004',
   'CRO-GS-008', 'NBL-1004', 'HER2-Ref-01', 'Internal', 'CAT-AB-004',
   'IgG1', 'DM-10004', 'GenScript', '2:2', 'PRJ-003', NULL,
   'IgG1', 'kappa', 'HER2-001', 'Needs humanization before IND',
   '8.4', '1.45', '148300', 'HEK293', 'admin'),

  ('B-0000005', 'CD19xPD1 Bispecific', NULL, NULL,
   NULL, 'NBL-1005', 'BSP-Ref-01', 'Internal', 'CAT-AB-005',
   'Bispecific IgG1', 'DM-10005', 'Internal', '1:1:1:1', 'PRJ-004',
   NULL, 'IgG1 knob/hole', 'kappa/lambda', 'BSP-001',
   'Knobs-into-holes bispecific, early stage', '7.9', '1.36',
   '149800', 'HEK293', 'admin');

-- protein batches

INSERT INTO protein_batch (modified_by, batch_id, concentration,
                            buffer_solution, yield_mg, source, unit,
                            storage, dispense_note, batch_eln,
                            purification_date, batch_name,
                            qc_file_path, room, storage_unit, shelf,
                            rack, box, qc_file_path_2, sec_purity,
                            page_purity, endotoxin_eu_mg, cro, qc_eln,
                            protein_name, culture_vol_ml,
                            gator_titer_ug_ml, biointron_titer, assay,
                            source_batch, purification_vol_ml,
                            trxn_date, column_used, note,
                            sec_hplc_file_path, sds_page_file_path,
                            mw, pi, epsilon, starting_inventory,
                            current_inventory, tube_volumes,
                            cell_viability_harvest, trxn_plasmids,
                            harvest_date, cro_id, created_by,
                            protein_id)
VALUES
  ('admin', 'PB-CD19-001', 2.4, 'PBS pH7.4', '24', 'Internal',
   'mg/mL', '-80C', NULL, 'ELN-B-1001', '2025-01-15', 'CD19-B001',
   NULL, 'R101', 'F1', '2', '3', 'C12', NULL, '96.2', '95.8', '0.12',
   'Internal', 'ELN-QC-1001', 'Anti-CD19 IgG1', '500', '1850',
   NULL, 'ELISA', NULL, '12', '2025-01-10', 'ProteinA', NULL, NULL, NULL,
   '148000', '8.2', NULL, '15', '12', '5x3mL', '94', 'P-0000001,P-0000002',
   '2025-01-12', 'CRO-GS-001', 'admin', 'B-0000001'),

  ('admin', 'PB-CD19-002', 1.8, 'PBS pH7.4', '18', 'Internal',
   'mg/mL', '-80C', NULL, 'ELN-B-1002', '2025-02-20', 'CD19-B002',
   NULL, 'R101', 'F1', '2', '3', 'C13', NULL, '94.1', '93.5', '0.08',
   'Internal', 'ELN-QC-1002', 'Anti-CD19 IgG1', '500', '1620',
   NULL, 'ELISA', NULL, '12', '2025-02-15', 'ProteinA', NULL, NULL, NULL,
   '148000', '8.2', NULL, '12', '9', '4x3mL', '92', 'P-0000001,P-0000002',
   '2025-02-17', 'CRO-GS-001', 'admin', 'B-0000001'),

  ('admin', 'PB-CD19-003', 3.1, 'PBS pH7.4', '31', 'Internal',
   'mg/mL', '-80C', NULL, 'ELN-B-1003', '2025-04-10', 'CD19-B003',
   NULL, 'R101', 'F2', '1', '1', 'C01', NULL, '97.4', '96.9', '0.05',
   'Internal', 'ELN-QC-1003', 'Anti-CD19 IgG1', '500', '2100',
   NULL, 'ELISA', NULL, '12', '2025-04-05', 'ProteinA', 'Process improvement',
   NULL, NULL, '148000', '8.2', NULL, '20', '18', '6x3mL', '96',
   'P-0000001,P-0000002', '2025-04-07', 'CRO-GS-001', 'admin',
   'B-0000001'),

  ('admin', 'PB-CD19BK-001', 1.2, 'PBS pH7.4', '12', 'CRO-A',
   'mg/mL', '-80C', NULL, 'ELN-B-1010', '2025-03-05', 'CD19BK-B001',
   NULL, 'R102', 'F1', '1', '1', 'C05', NULL, '88.3', '87.1', '0.45',
   'CRO-A', 'ELN-QC-1010', 'Anti-CD19 IgG1 Backup', '500', '980',
   NULL, 'ELISA', NULL, '12', '2025-02-28', 'ProteinA', 'CRO batch, lower yield',
   NULL, NULL, '147500', '8.0', NULL, '8', '6', '4x3mL', '85',
   'P-0000001,P-0000002', '2025-03-01', 'CRO-AB-022', 'admin',
   'B-0000002'),

  ('admin', 'PB-PD1-001', 0.9, 'PBS pH7.4', '9', 'CRO-A',
   'mg/mL', '-80C', NULL, 'ELN-B-1020', '2025-02-10', 'PD1-B001',
   NULL, 'R101', 'F3', '2', '2', 'C20', NULL, '91.2', '90.8', '0.22',
   'CRO-A', 'ELN-QC-1020', 'Anti-PD1 IgG4', '500', '1100',
   NULL, 'ELISA', NULL, '12', '2025-02-05', 'ProteinA', NULL, NULL, NULL,
   '146200', '7.6', NULL, '6', '4', '3x3mL', '88', 'P-0000003',
   '2025-02-07', 'CRO-AB-014', 'admin', 'B-0000003'),

  ('admin', 'PB-PD1-002', 2.1, 'PBS pH7.4', '21', 'CRO-B',
   'mg/mL', '-80C', NULL, 'ELN-B-1021', '2025-04-20', 'PD1-B002',
   NULL, 'R101', 'F3', '2', '2', 'C21', NULL, '93.7', '92.4', '0.15',
   'CRO-B', 'ELN-QC-1021', 'Anti-PD1 IgG4', '500', '1650',
   NULL, 'ELISA', NULL, '12', '2025-04-15', 'ProteinA', 'Improved CRO process',
   NULL, NULL, '146200', '7.6', NULL, '10', '9', '5x3mL', '91',
   'P-0000003', '2025-04-17', 'CRO-AB-031', 'admin', 'B-0000003'),

  ('admin', 'PB-HER2-001', 3.5, 'Acetate pH5', '35', 'Internal',
   'mg/mL', '-80C', NULL, 'ELN-B-1030', '2025-03-15', 'HER2-B001',
   NULL, 'R102', 'F2', '1', '1', 'C08', NULL, '98.1', '97.6', '0.04',
   'Internal', 'ELN-QC-1030', 'Anti-HER2 IgG1', '500', '2400',
   NULL, 'ELISA', NULL, '12', '2025-03-10', 'ProteinA', 'Best yield to date',
   NULL, NULL, '148300', '8.4', NULL, '18', '15', '6x3mL', '97',
   'P-0000001', '2025-03-12', 'CRO-GS-008', 'admin', 'B-0000004'),

  ('admin', 'PB-BSP-001', 0.6, 'PBS pH7.4', '6', 'Internal',
   'mg/mL', '-80C', NULL, 'ELN-B-1040', '2025-05-01', 'BSP-B001',
   NULL, 'R103', 'F1', '1', '1', 'C01', NULL, '78.4', '75.2', '0.65',
   'Internal', 'ELN-QC-1040', 'CD19xPD1 Bispecific', '500', '420',
   NULL, 'ELISA', NULL, '12', '2025-04-25', 'ProteinA',
   'First bispecific batch, low yield as expected', NULL, NULL,
   '149800', '7.9', NULL, '3', '2', '2x3mL', '79', 'P-0000004',
   '2025-04-27', NULL, 'admin', 'B-0000005');

-- plasmid batches

INSERT INTO plasmid_batch (plasmid_id, created_by, modified_by,
                            batch_id, concentration, buffer_solution,
                            yield_ug, source, unit, storage, note,
                            eln, production_date, batch_name,
                            qc_file_path, room, storage_unit, shelf,
                            rack, storage_box, qc_file_path_2,
                            a260_to_280, a260_to_230, endotoxin, cro,
                            cro_id, prep, seq_confirm, plasmid_name,
                            vol_ml, initial_vol_ul, media,
                            starting_inventory, current_inventory,
                            tube_volumes, confirmed_by, qc_eln)
VALUES
  ('P-0000001', 'admin', 'admin',
   'PLB-CD19HC-001', 850, 'TE buffer', '4250', 'Maxiprep', 'ng/uL',
   '-20C', NULL, 'ELN-P-2001', '2024-12-01', 'CD19HC-B001', NULL, 'R201',
   'F1', '1', '1', 'C01', NULL, '1.88', '2.15', '0.01', 'Internal',
   NULL, 'Maxiprep', 'Confirmed', 'pNR-CD19-HC', 5, '500', 1, '10', '8',
   '4x1.25mL', 'admin', 'ELN-QC-2001'),

  ('P-0000002', 'admin', 'admin',
   'PLB-CD19LC-001', 920, 'TE buffer', '4600', 'Maxiprep', 'ng/uL',
   '-20C', NULL, 'ELN-P-2002', '2024-12-01', 'CD19LC-B001', NULL, 'R201',
   'F1', '1', '1', 'C02', NULL, '1.91', '2.20', '0.01', 'Internal',
   NULL, 'Maxiprep', 'Confirmed', 'pNR-CD19-LC', 5, '500', 1, '10', '7',
   '4x1.25mL', 'admin', 'ELN-QC-2002'),

  ('P-0000003', 'admin', 'admin',
   'PLB-PD1HC-001', 780, 'TE buffer', '3900', 'Maxiprep', 'ng/uL',
   '-20C', NULL, 'ELN-P-2003', '2025-01-10', 'PD1HC-B001', NULL, 'R201',
   'F1', '2', '1', 'C03', NULL, '1.85', '2.10', '0.02', 'Internal',
   NULL, 'Maxiprep', 'Confirmed', 'pNR-PD1-HC', 5, '500', 1, '8', '6',
   '4x1.25mL', 'admin', 'ELN-QC-2003'),

  ('P-0000004', 'admin', 'admin',
   'PLB-BSP-001', 650, 'TE buffer', '3250', 'Maxiprep', 'ng/uL',
   '-20C', 'Lower yield, complex construct', 'ELN-P-2010',
   '2025-03-01', 'BSP-B001', NULL, 'R201', 'F2', '1', '1', 'C10', NULL,
   '1.79', '1.95', '0.03', 'Internal', NULL, 'Maxiprep', 'Confirmed',
   'pNR-Bispecific-Vector', 5, '500', 1, '6', '4', '3x1.25mL',
   'admin', 'ELN-QC-2010');

-- cell lines

INSERT INTO cell_line (cell_line_id, cell_line_name, expressed_orf,
                        created_by, parental_cell, vendor,
                        catalog_num, purchase_date, growth_media,
                        product_sheet_path, freezing_media, batch,
                        dotmatics_id, clone_name, eln, base_cell_line,
                        orf_species, project_code, base_cell,
                        tissue_of_origin, organism, morphology,
                        culture_properties, culture_document_path,
                        weblink, note, alias, reporter, cell_type,
                        knock_out, knock_in, shrna)
VALUES
  ('L-0000001', 'HEK293/CD19-HC+LC', 'HC-CD19+LC-CD19',
   'admin', 'HEK293', 'ATCC', 'CRL-1573', '2024-11-01',
   'DMEM+10%FBS+P/S', NULL, '10% DMSO in FBS', 'B01', 'DM-CL-001',
   NULL, 'ELN-CL-001', 'HEK293', 'Human', 'PRJ-001', 'HEK293',
   'kidney', 'Human', 'epithelial', 'Adherent, transfects well',
   NULL, NULL, 'Stable pool for CD19 production', 'CD19-Pool-01',
   NULL, 'HEK293', NULL, NULL, NULL),

  ('L-0000002', 'CHO-K1/PD1-HC', 'HC-PD1', 'admin',
   'CHO-K1', 'ATCC', 'CCL-61', '2024-12-05', 'CD CHO + supplements',
   NULL, '10% DMSO in FBS', 'B01', 'DM-CL-002', NULL, 'ELN-CL-002',
   'CHO-K1', 'Hamster', 'PRJ-002', 'CHO-K1', 'ovary', 'Chinese hamster',
   'epithelial', 'Suspension adapted', NULL, NULL,
   'Suspension culture for PD1 production', 'PD1-Pool-01', NULL,
   'CHO', NULL, NULL, NULL),

  ('L-0000003', 'HEK293/Bispecific', 'HC-CD19-knob+HC-PD1-hole',
   'admin', 'HEK293', 'ATCC', 'CRL-1573', '2025-02-15',
   'DMEM+10%FBS+P/S', NULL, '10% DMSO in FBS', 'B01', 'DM-CL-003',
   NULL, 'ELN-CL-003', 'HEK293', 'Human', 'PRJ-004', 'HEK293',
   'kidney', 'Human', 'epithelial', 'Co-transfection, early stage',
   NULL, NULL, 'Bispecific co-expression pool', 'BSP-Pool-01', NULL,
   'HEK293', NULL, NULL, NULL);

-- cell batches

INSERT INTO cell_batch (cell_line_id, created_by, modified_by,
                         batch_id, date, cell_density, vials, room,
                         storage_unit, tower, storage_box,
                         cell_line_name, passage_num)
VALUES
  ('L-0000001', 'admin', 'admin',
   'CB-CD19-001', '2025-01-05', '2.5e6 cells/mL', 20, 'LN2 Room',
   'Tank-1', 'Rack-A', 'Box-3', 'HEK293/CD19-HC+LC', '8'),

  ('L-0000001', 'admin', 'admin',
   'CB-CD19-002', '2025-03-10', '2.8e6 cells/mL', 15, 'LN2 Room',
   'Tank-1', 'Rack-A', 'Box-4', 'HEK293/CD19-HC+LC', '12'),

  ('L-0000002', 'admin', 'admin',
   'CB-PD1-001', '2025-01-20', '3.1e6 cells/mL', 18, 'LN2 Room',
   'Tank-2', 'Rack-B', 'Box-1', 'CHO-K1/PD1-HC', '6'),

  ('L-0000003', 'admin', 'admin',
   'CB-BSP-001', '2025-02-20', '2.2e6 cells/mL', 10, 'LN2 Room',
   'Tank-1', 'Rack-C', 'Box-1', 'HEK293/Bispecific', '4');

-- links: protein ↔ plasmid

INSERT INTO join_table_protein_plasmid (created_by, protein_id,
                                         protein_name, plasmid_id,
                                         plasmid_name, pnr_number)
VALUES
  ('admin', 'B-0000001', 'Anti-CD19 IgG1', 'P-0000001', 'pNR-CD19-HC', 'pNR-1001'),
  ('admin', 'B-0000001', 'Anti-CD19 IgG1', 'P-0000002', 'pNR-CD19-LC', 'pNR-1002'),
  ('admin', 'B-0000002', 'Anti-CD19 IgG1 Backup', 'P-0000001', 'pNR-CD19-HC', 'pNR-1001'),
  ('admin', 'B-0000002', 'Anti-CD19 IgG1 Backup', 'P-0000002', 'pNR-CD19-LC', 'pNR-1002'),
  ('admin', 'B-0000003', 'Anti-PD1 IgG4', 'P-0000003', 'pNR-PD1-HC', 'pNR-1003'),
  ('admin', 'B-0000005', 'CD19xPD1 Bispecific', 'P-0000004', 'pNR-Bispecific-Vector', 'pNR-1004');

-- links: component ↔ plasmid

INSERT INTO join_table_component_plasmid (component_id, plasmid_id,
                                           component_name, plasmid_name,
                                           created_by, pnr)
VALUES
  ('C-0000001', 'P-0000001', 'CD19-VH-01', 'pNR-CD19-HC', 'admin', 'pNR-1001'),
  ('C-0000002', 'P-0000002', 'CD19-VK-01', 'pNR-CD19-LC', 'admin', 'pNR-1002'),
  ('C-0000003', 'P-0000003', 'PD1-VH-01', 'pNR-PD1-HC', 'admin', 'pNR-1003'),
  ('C-0000001', 'P-0000004', 'CD19-VH-01', 'pNR-Bispecific-Vector', 'admin', 'pNR-1004'),
  ('C-0000003', 'P-0000004', 'PD1-VH-01', 'pNR-Bispecific-Vector', 'admin', 'pNR-1004');

-- links: cell line ↔ plasmid

INSERT INTO join_table_cell_line_plasmid (plasmid_id, cell_line_id,
                                           cell_line_name, created_by,
                                           plasmid_name)
VALUES
  ('P-0000001', 'L-0000001', 'HEK293/CD19-HC+LC', 'admin', 'pNR-CD19-HC'),
  ('P-0000002', 'L-0000001', 'HEK293/CD19-HC+LC', 'admin', 'pNR-CD19-LC'),
  ('P-0000003', 'L-0000002', 'CHO-K1/PD1-HC', 'admin', 'pNR-PD1-HC'),
  ('P-0000004', 'L-0000003', 'HEK293/Bispecific', 'admin', 'pNR-Bispecific-Vector');

-- generated demo batches

SELECT setseed(0.42);

INSERT INTO protein_batch (batch_id, batch_name, protein_id, protein_name,
                           concentration, unit, yield_mg, source,
                           sec_purity, page_purity, endotoxin_eu_mg,
                           purification_date, created_by)
SELECT
  'PB-GEN-' || lpad(g::text, 3, '0'),
  p.alias || '-G' || g,
  p.protein_id,
  p.protein_name,
  round((0.8 + random() * 2.7)::numeric, 2),
  'mg/mL',
  round((8 + random() * 30)::numeric, 1),
  (ARRAY['Internal', 'CRO-A', 'CRO-B'])[1 + floor(random() * 3)::int],
  round((88 + random() * 11)::numeric, 1),
  round((86 + random() * 12)::numeric, 1),
  round((0.02 + random() * 0.4)::numeric, 2),
  DATE '2025-01-06' + g * 6,
  'seed'
FROM generate_series(1, 48) AS g
JOIN (
  SELECT protein_id, protein_name, alias,
         row_number() OVER (ORDER BY protein_id) AS rn
  FROM protein
  WHERE protein_id <> 'B-0000005'
) p ON p.rn = (g % 4) + 1;