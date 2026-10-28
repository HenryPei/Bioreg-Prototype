# protein.R
# get_proteins()                  all proteins for the table
# get_protein_by_id()             one protein for the detail view
# get_next_protein_id()           next B-XXXXXXX id
# insert_protein()                add a protein
# update_protein()                edit a protein
# delete_protein_cascade()        delete a protein, its batches and links
# get_plasmids_for_protein()      plasmids linked to a protein
# protein_detail_ui()             detail panel with batch and plasmid portals
# protein_modal()                 add or edit protein form
# delete_protein_confirm_modal()  confirm before delete

get_proteins <- function() {
  dbGetQuery(con,
    "SELECT protein_id, protein_name, type, hc_type, lc_type,
            alias, project_code, cro, created_at
     FROM protein
     ORDER BY created_at DESC")
}

get_protein_by_id <- function(protein_id) {
  dbGetQuery(con,
    "SELECT * FROM protein WHERE protein_id = $1",
    params = list(protein_id))
}

get_next_protein_id <- function() {
  last <- dbGetQuery(con,
    "SELECT protein_id FROM protein ORDER BY protein_id DESC LIMIT 1")
  if (nrow(last) == 0) return("B-0000001")
  num <- as.integer(sub("B-", "", last$protein_id)) + 1
  sprintf("B-%07d", num)
}

insert_protein <- function(protein_name, clone_id, type, hc_type,
                           lc_type, alias, project_code, cro, cro_id,
                           nbl_id, reference_name, vendor, catalog_num,
                           dotmatics_id, stoichiometry, pi, a280_1mgml,
                           mw, source_cell, note, created_by) {
  dbExecute(con,
    "INSERT INTO protein (protein_id, protein_name, clone_id, type,
                          hc_type, lc_type, alias, project_code, cro,
                          cro_id, nbl_id, reference_name, vendor,
                          catalog_num, dotmatics_id, stoichiometry,
                          pi, a280_1mgml, mw, source_cell, note, created_by)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,
             $16,$17,$18,$19,$20,$21,$22)",
    params = lapply(list(get_next_protein_id(), protein_name, clone_id, type,
                         hc_type, lc_type, alias, project_code, cro, cro_id,
                         nbl_id, reference_name, vendor, catalog_num,
                         dotmatics_id, stoichiometry, pi, a280_1mgml, mw,
                         source_cell, note, created_by),
                    blank_to_na))
}

update_protein <- function(protein_id, protein_name, clone_id, type, hc_type,
                           lc_type, alias, project_code, cro, cro_id,
                           nbl_id, vendor, catalog_num, stoichiometry,
                           pi, a280_1mgml, mw, source_cell, note) {
  dbExecute(con,
    "UPDATE protein
     SET protein_name = $2, clone_id = $3, type = $4, hc_type = $5,
         lc_type = $6, alias = $7, project_code = $8, cro = $9,
         cro_id = $10, nbl_id = $11, vendor = $12, catalog_num = $13,
         stoichiometry = $14, pi = $15, a280_1mgml = $16, mw = $17,
         source_cell = $18, note = $19
     WHERE protein_id = $1",
    params = lapply(list(protein_id, protein_name, clone_id, type, hc_type,
                         lc_type, alias, project_code, cro, cro_id, nbl_id,
                         vendor, catalog_num, stoichiometry, pi, a280_1mgml,
                         mw, source_cell, note),
                    blank_to_na))
}

delete_protein_cascade <- function(protein_id) {
  poolWithTransaction(con, function(conn) {
    dbExecute(conn, "DELETE FROM protein_batch WHERE protein_id = $1",
      params = list(protein_id))
    dbExecute(conn, "DELETE FROM join_table_protein_plasmid WHERE protein_id = $1",
      params = list(protein_id))
    dbExecute(conn, "DELETE FROM protein WHERE protein_id = $1",
      params = list(protein_id))
  })
}

get_plasmids_for_protein <- function(protein_id) {
  dbGetQuery(con,
    "SELECT p.plasmid_id, p.plasmid_name, p.type, p.vector, jpp.pnr_number
     FROM plasmid p
     JOIN join_table_protein_plasmid jpp ON p.plasmid_id = jpp.plasmid_id
     WHERE jpp.protein_id = $1",
    params = list(protein_id))
}

protein_detail_ui <- function(protein_id) {
  protein <- get_protein_by_id(protein_id)

  tagList(
    hr(),
    card(
      card_header(h4(protein$protein_name)),
      p(strong("Protein ID: "), protein$protein_id),
      p(strong("Type: "), protein$type),
      p(strong("HC Type: "), protein$hc_type),
      p(strong("LC Type: "), protein$lc_type),
      p(strong("Alias: "), protein$alias),
      p(strong("Project Code: "), protein$project_code),
      p(strong("CRO: "), protein$cro),
      p(strong("MW: "), protein$mw),
      p(strong("pI: "), protein$pi),
      p(strong("A280: "), protein$a280_1mgml),
      p(strong("Source Cell: "), protein$source_cell),
      p(strong("Note: "), protein$note),
      div(
        actionButton("edit_protein_btn", "Edit Protein", class = "btn-primary btn-sm"),
        actionButton("delete_protein_btn", "Delete Protein", class = "btn-danger btn-sm")
      )
    ),
    br(),

    card(
      card_header("Batches"),
      actionButton("add_protein_batch_btn", "Add Batch", class = "btn-success btn-sm"),
      DTOutput("protein_batches_portal")
    ),
    br(),

    card(
      card_header("Plasmids"),
      actionButton("link_plasmid_btn", "Link", class = "btn-primary btn-sm"),
      actionButton("view_plasmid_btn", "View Selected", class = "btn-outline-primary btn-sm"),
      actionButton("unlink_plasmid_btn", "Unlink Selected", class = "btn-warning btn-sm"),
      DTOutput("protein_plasmids_portal")
    ),
    br(),

    uiOutput("protein_batch_detail")
  )
}

protein_modal <- function(row = NULL) {
  editing <- !is.null(row)
  v <- function(col) form_value(row, col)

  modalDialog(
    title = if (editing) "Edit Protein" else "Add New Protein",
    fluidRow(
      column(6, textInput("new_protein_name", "Protein Name", value = v("protein_name"))),
      column(6, textInput("new_clone_id", "Clone ID", value = v("clone_id")))
    ),
    fluidRow(
      column(6, textInput("new_type", "Type", value = v("type"))),
      column(6, textInput("new_hc_type", "HC Type", value = v("hc_type")))
    ),
    fluidRow(
      column(6, textInput("new_lc_type", "LC Type", value = v("lc_type"))),
      column(6, textInput("new_alias", "Alias", value = v("alias")))
    ),
    fluidRow(
      column(6, textInput("new_project_code", "Project Code", value = v("project_code"))),
      column(6, textInput("new_cro", "CRO", value = v("cro")))
    ),
    fluidRow(
      column(6, textInput("new_cro_id", "CRO ID", value = v("cro_id"))),
      column(6, textInput("new_nbl_id", "NBL ID", value = v("nbl_id")))
    ),
    fluidRow(
      column(6, textInput("new_vendor", "Vendor", value = v("vendor"))),
      column(6, textInput("new_catalog_num", "Catalog Number", value = v("catalog_num")))
    ),
    fluidRow(
      column(4, textInput("new_mw", "MW", value = v("mw"))),
      column(4, textInput("new_pi", "pI", value = v("pi"))),
      column(4, textInput("new_a280", "A280 (1mg/ml)", value = v("a280_1mgml")))
    ),
    fluidRow(
      column(6, textInput("new_source_cell", "Source Cell", value = v("source_cell"))),
      column(6, textInput("new_stoichiometry", "Stoichiometry", value = v("stoichiometry")))
    ),
    textAreaInput("new_protein_note", "Note", value = v("note")),
    footer = tagList(
      modalButton("Cancel"),
      actionButton(if (editing) "update_protein_btn" else "save_protein_btn",
                   "Save", class = "btn-primary")
    )
  )
}

delete_protein_confirm_modal <- function(protein_id) {
  protein  <- get_protein_by_id(protein_id)
  batches  <- get_protein_batches(protein_id)
  plasmids <- get_plasmids_for_protein(protein_id)

  warning_text <- paste0("Delete ", protein$protein_name,
    "? This will also delete ", nrow(batches), " batch(es). ")

  if (nrow(plasmids) > 0) {
    warning_text <- paste0(warning_text, "This protein will be unlinked from: ",
      format_relationship_list(plasmids$plasmid_name), ". ")
  }

  warning_text <- paste0(warning_text, "This cannot be undone.")

  modalDialog(
    title = "Confirm Delete",
    warning_text,
    footer = tagList(
      modalButton("Cancel"),
      actionButton("confirm_delete_protein_btn", "Delete Everything", class = "btn-danger")
    )
  )
}