# cell_line.R
# get_cell_lines()                  all cell lines for the table
# get_cell_line_by_id()             one cell line for the detail view
# get_next_cell_line_id()           next L-XXXXXXX id
# insert_cell_line()                add a cell line
# delete_cell_line_cascade()        delete a cell line, its batches and links
# get_plasmids_for_cell_line()      plasmids linked to a cell line
# cell_line_detail_ui()             detail panel with batch and plasmid portals
# add_cell_line_modal()             add cell line form
# delete_cell_line_confirm_modal()  confirm before delete

get_cell_lines <- function() {
  dbGetQuery(con,
    "SELECT cell_line_id, cell_line_name, expressed_orf, cell_type,
            organism, project_code, created_at
     FROM cell_line
     ORDER BY created_at DESC")
}

get_cell_line_by_id <- function(cell_line_id) {
  dbGetQuery(con,
    "SELECT * FROM cell_line WHERE cell_line_id = $1",
    params = list(cell_line_id))
}

get_next_cell_line_id <- function() {
  last <- dbGetQuery(con,
    "SELECT cell_line_id FROM cell_line ORDER BY cell_line_id DESC LIMIT 1")
  if (nrow(last) == 0) return("L-0000001")
  num <- as.integer(sub("L-", "", last$cell_line_id)) + 1
  sprintf("L-%07d", num)
}

insert_cell_line <- function(cell_line_name, expressed_orf, cell_type,
                             organism, parental_cell, vendor,
                             catalog_num, purchase_date, growth_media,
                             freezing_media, base_cell_line, orf_species,
                             project_code, base_cell, tissue_of_origin,
                             morphology, culture_properties, weblink,
                             alias, reporter, knock_out, knock_in,
                             shrna, dotmatics_id, clone_name, eln,
                             note, created_by) {
  dbExecute(con,
    "INSERT INTO cell_line (cell_line_id, cell_line_name, expressed_orf,
                            cell_type, organism, parental_cell, vendor,
                            catalog_num, purchase_date, growth_media,
                            freezing_media, base_cell_line, orf_species,
                            project_code, base_cell, tissue_of_origin,
                            morphology, culture_properties, weblink,
                            alias, reporter, knock_out, knock_in,
                            shrna, dotmatics_id, clone_name, eln,
                            note, created_by)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,
             $16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29)",
    params = lapply(list(get_next_cell_line_id(), cell_line_name, expressed_orf,
                         cell_type, organism, parental_cell, vendor, catalog_num,
                         purchase_date, growth_media, freezing_media,
                         base_cell_line, orf_species, project_code, base_cell,
                         tissue_of_origin, morphology, culture_properties,
                         weblink, alias, reporter, knock_out, knock_in, shrna,
                         dotmatics_id, clone_name, eln, note, created_by),
                    blank_to_na))
}

delete_cell_line_cascade <- function(cell_line_id) {
  poolWithTransaction(con, function(conn) {
    dbExecute(conn, "DELETE FROM cell_batch WHERE cell_line_id = $1",
      params = list(cell_line_id))
    dbExecute(conn, "DELETE FROM join_table_cell_line_plasmid WHERE cell_line_id = $1",
      params = list(cell_line_id))
    dbExecute(conn, "DELETE FROM cell_line WHERE cell_line_id = $1",
      params = list(cell_line_id))
  })
}

get_plasmids_for_cell_line <- function(cell_line_id) {
  dbGetQuery(con,
    "SELECT pl.plasmid_id, pl.plasmid_name, pl.type, pl.vector
     FROM plasmid pl
     JOIN join_table_cell_line_plasmid jclp ON pl.plasmid_id = jclp.plasmid_id
     WHERE jclp.cell_line_id = $1",
    params = list(cell_line_id))
}

cell_line_detail_ui <- function(cell_line_id) {
  cl <- get_cell_line_by_id(cell_line_id)

  tagList(
    hr(),
    card(
      card_header(h4(cl$cell_line_name)),
      p(strong("Cell Line ID: "), cl$cell_line_id),
      p(strong("Expressed ORF: "), cl$expressed_orf),
      p(strong("Cell Type: "), cl$cell_type),
      p(strong("Organism: "), cl$organism),
      p(strong("Parental Cell: "), cl$parental_cell),
      p(strong("Base Cell Line: "), cl$base_cell_line),
      p(strong("Vendor: "), cl$vendor),
      p(strong("Growth Media: "), cl$growth_media),
      p(strong("Project Code: "), cl$project_code),
      p(strong("Note: "), cl$note),
      actionButton("delete_cell_line_btn", "Delete Cell Line", class = "btn-danger btn-sm")
    ),
    br(),

    card(
      card_header("Cell Batches"),
      actionButton("add_cell_batch_btn", "Add Batch", class = "btn-success btn-sm"),
      DTOutput("cell_batches_portal")
    ),
    br(),

    card(
      card_header("Plasmids linked to this cell line"),
      actionButton("view_plasmid_from_cell_line_btn", "View Selected", class = "btn-outline-primary btn-sm"),
      actionButton("unlink_plasmid_from_cell_line_btn", "Unlink Selected", class = "btn-warning btn-sm"),
      DTOutput("cell_line_plasmids_portal")
    ),
    br(),

    uiOutput("cell_batch_detail")
  )
}

add_cell_line_modal <- function() {
  modalDialog(
    title = "Add New Cell Line",
    fluidRow(
      column(6, textInput("new_cl_name", "Cell Line Name")),
      column(6, textInput("new_cl_expressed_orf", "Expressed ORF"))
    ),
    fluidRow(
      column(6, textInput("new_cl_cell_type", "Cell Type")),
      column(6, textInput("new_cl_organism", "Organism"))
    ),
    fluidRow(
      column(6, textInput("new_cl_parental", "Parental Cell")),
      column(6, textInput("new_cl_base_cell_line", "Base Cell Line"))
    ),
    fluidRow(
      column(6, textInput("new_cl_vendor", "Vendor")),
      column(6, textInput("new_cl_catalog_num", "Catalog Number"))
    ),
    fluidRow(
      column(6, dateInput("new_cl_purchase_date", "Purchase Date", value = NA)),
      column(6, textInput("new_cl_growth_media", "Growth Media"))
    ),
    fluidRow(
      column(6, textInput("new_cl_freezing_media", "Freezing Media")),
      column(6, textInput("new_cl_project_code", "Project Code"))
    ),
    fluidRow(
      column(6, textInput("new_cl_tissue_of_origin", "Tissue of Origin")),
      column(6, textInput("new_cl_morphology", "Morphology"))
    ),
    fluidRow(
      column(6, textInput("new_cl_knock_out", "Knock Out")),
      column(6, textInput("new_cl_knock_in", "Knock In"))
    ),
    fluidRow(
      column(6, textInput("new_cl_shrna", "shRNA")),
      column(6, textInput("new_cl_reporter", "Reporter"))
    ),
    fluidRow(
      column(6, textInput("new_cl_alias", "Alias")),
      column(6, textInput("new_cl_dotmatics_id", "Dotmatics ID"))
    ),
    textInput("new_cl_eln", "ELN"),
    textAreaInput("new_cl_note", "Note"),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("save_cell_line_btn", "Save", class = "btn-primary")
    )
  )
}

delete_cell_line_confirm_modal <- function(cell_line_id) {
  cl       <- get_cell_line_by_id(cell_line_id)
  batches  <- get_cell_batches(cell_line_id)
  plasmids <- get_plasmids_for_cell_line(cell_line_id)

  warning_text <- paste0("Delete ", cl$cell_line_name,
    "? This will also delete ", nrow(batches), " batch(es). ")

  if (nrow(plasmids) > 0) {
    warning_text <- paste0(warning_text, "Unlinked from plasmids: ",
      format_relationship_list(plasmids$plasmid_name), ". ")
  }

  warning_text <- paste0(warning_text, "This cannot be undone.")

  modalDialog(
    title = "Confirm Delete",
    warning_text,
    footer = tagList(
      modalButton("Cancel"),
      actionButton("confirm_delete_cell_line_btn", "Delete Everything", class = "btn-danger")
    )
  )
}