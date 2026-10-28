# plasmid.R
# get_plasmids()                  all plasmids for the table
# get_plasmid_by_id()             one plasmid for the detail view
# get_next_plasmid_id()           next P-XXXXXXX id
# insert_plasmid()                add a plasmid
# delete_plasmid_cascade()        delete a plasmid, its batches and links
# get_proteins_for_plasmid()      proteins linked to a plasmid
# get_components_for_plasmid()    components linked to a plasmid
# get_cell_lines_for_plasmid()    cell lines linked to a plasmid
# plasmid_detail_ui()             detail panel with batch and link portals
# add_plasmid_modal()             add plasmid form
# delete_plasmid_confirm_modal()  confirm before delete

get_plasmids <- function() {
  dbGetQuery(con,
    "SELECT plasmid_id, plasmid_name, type, vector, insert_seq,
            alias, project_code, cro, created_at
     FROM plasmid
     ORDER BY created_at DESC")
}

get_plasmid_by_id <- function(plasmid_id) {
  dbGetQuery(con,
    "SELECT * FROM plasmid WHERE plasmid_id = $1",
    params = list(plasmid_id))
}

get_next_plasmid_id <- function() {
  last <- dbGetQuery(con,
    "SELECT plasmid_id FROM plasmid ORDER BY plasmid_id DESC LIMIT 1")
  if (nrow(last) == 0) return("P-0000001")
  num <- as.integer(sub("P-", "", last$plasmid_id)) + 1
  sprintf("P-%07d", num)
}

insert_plasmid <- function(plasmid_name, type, vector, insert_seq,
                           parent_vector, alias, pnr, project_code,
                           selection, antibiotic, orf1, orf2,
                           vector_source, catalog_number, cro, cro2,
                           gf1, gf2, n_tag, c_tag, eln_number,
                           storage_room, storage_unit, shelf, rack,
                           storage_box, box_coordinate, note,
                           created_by) {
  dbExecute(con,
    "INSERT INTO plasmid (plasmid_id, plasmid_name, type, vector,
                          insert_seq, parent_vector, alias, pnr,
                          project_code, selection, antibiotic, orf1,
                          orf2, vector_source, catalog_number, cro,
                          cro2, gf1, gf2, n_tag, c_tag, eln_number,
                          storage_room, storage_unit, shelf, rack,
                          storage_box, box_coordinate, note, created_by)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,
             $16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,
             $29,$30)",
    params = lapply(list(get_next_plasmid_id(), plasmid_name, type, vector,
                         insert_seq, parent_vector, alias, pnr, project_code,
                         selection, antibiotic, orf1, orf2, vector_source,
                         catalog_number, cro, cro2, gf1, gf2, n_tag, c_tag,
                         eln_number, storage_room, storage_unit, shelf, rack,
                         storage_box, box_coordinate, note, created_by),
                    blank_to_na))
}

delete_plasmid_cascade <- function(plasmid_id) {
  poolWithTransaction(con, function(conn) {
    dbExecute(conn, "DELETE FROM plasmid_batch WHERE plasmid_id = $1",
      params = list(plasmid_id))
    dbExecute(conn, "DELETE FROM join_table_protein_plasmid WHERE plasmid_id = $1",
      params = list(plasmid_id))
    dbExecute(conn, "DELETE FROM join_table_component_plasmid WHERE plasmid_id = $1",
      params = list(plasmid_id))
    dbExecute(conn, "DELETE FROM join_table_cell_line_plasmid WHERE plasmid_id = $1",
      params = list(plasmid_id))
    dbExecute(conn, "DELETE FROM plasmid WHERE plasmid_id = $1",
      params = list(plasmid_id))
  })
}

get_proteins_for_plasmid <- function(plasmid_id) {
  dbGetQuery(con,
    "SELECT p.protein_id, p.protein_name, p.type, p.hc_type, p.lc_type,
            jpp.pnr_number
     FROM protein p
     JOIN join_table_protein_plasmid jpp ON p.protein_id = jpp.protein_id
     WHERE jpp.plasmid_id = $1",
    params = list(plasmid_id))
}

get_components_for_plasmid <- function(plasmid_id) {
  dbGetQuery(con,
    "SELECT c.component_id, c.component_name, c.type, c.species, jcp.pnr
     FROM component c
     JOIN join_table_component_plasmid jcp ON c.component_id = jcp.component_id
     WHERE jcp.plasmid_id = $1",
    params = list(plasmid_id))
}

get_cell_lines_for_plasmid <- function(plasmid_id) {
  dbGetQuery(con,
    "SELECT cl.cell_line_id, cl.cell_line_name, cl.cell_type, cl.organism
     FROM cell_line cl
     JOIN join_table_cell_line_plasmid jclp ON cl.cell_line_id = jclp.cell_line_id
     WHERE jclp.plasmid_id = $1",
    params = list(plasmid_id))
}

plasmid_detail_ui <- function(plasmid_id) {
  plasmid <- get_plasmid_by_id(plasmid_id)

  tagList(
    hr(),
    card(
      card_header(h4(plasmid$plasmid_name)),
      p(strong("Plasmid ID: "), plasmid$plasmid_id),
      p(strong("Type: "), plasmid$type),
      p(strong("Vector: "), plasmid$vector),
      p(strong("Insert: "), plasmid$insert_seq),
      p(strong("Alias: "), plasmid$alias),
      p(strong("pNR: "), plasmid$pnr),
      p(strong("Selection: "), plasmid$selection),
      p(strong("Antibiotic: "), plasmid$antibiotic),
      p(strong("ORF1: "), plasmid$orf1),
      p(strong("ORF2: "), plasmid$orf2),
      p(strong("Project Code: "), plasmid$project_code),
      p(strong("Storage: "), paste(plasmid$storage_room, plasmid$storage_unit,
                                   plasmid$shelf, plasmid$rack, plasmid$storage_box)),
      p(strong("Note: "), plasmid$note),
      actionButton("delete_plasmid_btn", "Delete Plasmid", class = "btn-danger btn-sm")
    ),
    br(),

    card(
      card_header("Batches"),
      actionButton("add_plasmid_batch_btn", "Add Batch", class = "btn-success btn-sm"),
      DTOutput("plasmid_batches_portal")
    ),
    br(),

    card(
      card_header("Proteins using this plasmid"),
      actionButton("link_protein_to_plasmid_btn", "Link", class = "btn-primary btn-sm"),
      actionButton("view_protein_btn", "View Selected", class = "btn-outline-primary btn-sm"),
      actionButton("unlink_protein_from_plasmid_btn", "Unlink Selected", class = "btn-warning btn-sm"),
      DTOutput("plasmid_proteins_portal")
    ),
    br(),

    card(
      card_header("Components in this plasmid"),
      actionButton("link_component_btn", "Link", class = "btn-primary btn-sm"),
      actionButton("view_component_btn", "View Selected", class = "btn-outline-primary btn-sm"),
      actionButton("unlink_component_btn", "Unlink Selected", class = "btn-warning btn-sm"),
      DTOutput("plasmid_components_portal")
    ),
    br(),

    card(
      card_header("Cell lines using this plasmid"),
      actionButton("link_cell_line_btn", "Link", class = "btn-primary btn-sm"),
      actionButton("view_cell_line_btn", "View Selected", class = "btn-outline-primary btn-sm"),
      actionButton("unlink_cell_line_btn", "Unlink Selected", class = "btn-warning btn-sm"),
      DTOutput("plasmid_cell_lines_portal")
    ),
    br(),

    uiOutput("plasmid_batch_detail")
  )
}

add_plasmid_modal <- function() {
  modalDialog(
    title = "Add New Plasmid",
    fluidRow(
      column(6, textInput("new_plasmid_name", "Plasmid Name")),
      column(6, textInput("new_plasmid_type", "Type"))
    ),
    fluidRow(
      column(6, textInput("new_vector", "Vector")),
      column(6, textInput("new_insert_seq", "Insert"))
    ),
    fluidRow(
      column(6, textInput("new_parent_vector", "Parent Vector")),
      column(6, textInput("new_plasmid_alias", "Alias"))
    ),
    fluidRow(
      column(6, textInput("new_pnr", "pNR")),
      column(6, textInput("new_plasmid_project_code", "Project Code"))
    ),
    fluidRow(
      column(6, textInput("new_selection", "Selection")),
      column(6, textInput("new_antibiotic", "Antibiotic"))
    ),
    fluidRow(
      column(6, textInput("new_orf1", "ORF1")),
      column(6, textInput("new_orf2", "ORF2"))
    ),
    fluidRow(
      column(6, textInput("new_vector_source", "Vector Source")),
      column(6, textInput("new_catalog_number", "Catalog Number"))
    ),
    fluidRow(
      column(6, textInput("new_n_tag", "N-Tag")),
      column(6, textInput("new_c_tag", "C-Tag"))
    ),
    fluidRow(
      column(6, textInput("new_plasmid_cro", "CRO")),
      column(6, textInput("new_plasmid_eln", "ELN #"))
    ),
    fluidRow(
      column(3, textInput("new_storage_room", "Room")),
      column(3, textInput("new_plasmid_storage_unit", "Unit")),
      column(3, textInput("new_plasmid_shelf", "Shelf")),
      column(3, textInput("new_plasmid_rack", "Rack"))
    ),
    fluidRow(
      column(6, textInput("new_plasmid_box", "Box")),
      column(6, textInput("new_box_coordinate", "Box Coordinate"))
    ),
    textAreaInput("new_plasmid_note", "Note"),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("save_plasmid_btn", "Save", class = "btn-primary")
    )
  )
}

delete_plasmid_confirm_modal <- function(plasmid_id) {
  plasmid    <- get_plasmid_by_id(plasmid_id)
  batches    <- get_plasmid_batches(plasmid_id)
  proteins   <- get_proteins_for_plasmid(plasmid_id)
  components <- get_components_for_plasmid(plasmid_id)
  cell_lines <- get_cell_lines_for_plasmid(plasmid_id)

  warning_text <- paste0("Delete ", plasmid$plasmid_name,
    "? This will also delete ", nrow(batches), " batch(es). ")

  if (nrow(proteins) > 0) {
    warning_text <- paste0(warning_text, "Unlinked from proteins: ",
      format_relationship_list(proteins$protein_name), ". ")
  }
  if (nrow(components) > 0) {
    warning_text <- paste0(warning_text, "Unlinked from components: ",
      format_relationship_list(components$component_name), ". ")
  }
  if (nrow(cell_lines) > 0) {
    warning_text <- paste0(warning_text, "Unlinked from cell lines: ",
      format_relationship_list(cell_lines$cell_line_name), ". ")
  }

  total_links <- nrow(proteins) + nrow(components) + nrow(cell_lines)
  if (total_links > 10) {
    warning_text <- paste0("⚠ This plasmid is widely used. ", warning_text)
  }

  warning_text <- paste0(warning_text, "This cannot be undone.")

  modalDialog(
    title = "Confirm Delete",
    warning_text,
    footer = tagList(
      modalButton("Cancel"),
      actionButton("confirm_delete_plasmid_btn", "Delete Everything", class = "btn-danger")
    )
  )
}