# plasmid.R
# get_plasmids()                  all plasmids for the table
# get_plasmid_by_id()             one plasmid for the detail view
# get_next_plasmid_id()           next P-XXXXXXX id
# insert_plasmid()                add a plasmid
# update_plasmid()                edit a plasmid
# delete_plasmid_cascade()        delete a plasmid, its batches and links
# get_proteins_for_plasmid()      proteins linked to a plasmid
# get_components_for_plasmid()    components linked to a plasmid
# get_cell_lines_for_plasmid()    cell lines linked to a plasmid
# plasmid_detail_ui()             detail panel with batch and link portals
# plasmid_modal()                 add or edit plasmid form
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

update_plasmid <- function(plasmid_id, plasmid_name, type, vector, insert_seq,
                           parent_vector, alias, pnr, project_code,
                           selection, antibiotic, orf1, orf2,
                           vector_source, catalog_number, cro,
                           n_tag, c_tag, eln_number,
                           storage_room, storage_unit, shelf, rack,
                           storage_box, box_coordinate, note) {
  dbExecute(con,
    "UPDATE plasmid
     SET plasmid_name = $2, type = $3, vector = $4, insert_seq = $5,
         parent_vector = $6, alias = $7, pnr = $8, project_code = $9,
         selection = $10, antibiotic = $11, orf1 = $12, orf2 = $13,
         vector_source = $14, catalog_number = $15, cro = $16,
         n_tag = $17, c_tag = $18, eln_number = $19,
         storage_room = $20, storage_unit = $21, shelf = $22, rack = $23,
         storage_box = $24, box_coordinate = $25, note = $26
     WHERE plasmid_id = $1",
    params = lapply(list(plasmid_id, plasmid_name, type, vector, insert_seq,
                         parent_vector, alias, pnr, project_code, selection,
                         antibiotic, orf1, orf2, vector_source, catalog_number,
                         cro, n_tag, c_tag, eln_number, storage_room,
                         storage_unit, shelf, rack, storage_box,
                         box_coordinate, note),
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
      div(
        actionButton("edit_plasmid_btn", "Edit Plasmid", class = "btn-primary btn-sm"),
        actionButton("delete_plasmid_btn", "Delete Plasmid", class = "btn-danger btn-sm")
      )
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

plasmid_modal <- function(row = NULL) {
  editing <- !is.null(row)
  v <- function(col) form_value(row, col)

  modalDialog(
    title = if (editing) "Edit Plasmid" else "Add New Plasmid",
    fluidRow(
      column(6, textInput("new_plasmid_name", "Plasmid Name", value = v("plasmid_name"))),
      column(6, textInput("new_plasmid_type", "Type", value = v("type")))
    ),
    fluidRow(
      column(6, textInput("new_vector", "Vector", value = v("vector"))),
      column(6, textInput("new_insert_seq", "Insert", value = v("insert_seq")))
    ),
    fluidRow(
      column(6, textInput("new_parent_vector", "Parent Vector", value = v("parent_vector"))),
      column(6, textInput("new_plasmid_alias", "Alias", value = v("alias")))
    ),
    fluidRow(
      column(6, textInput("new_pnr", "pNR", value = v("pnr"))),
      column(6, textInput("new_plasmid_project_code", "Project Code", value = v("project_code")))
    ),
    fluidRow(
      column(6, textInput("new_selection", "Selection", value = v("selection"))),
      column(6, textInput("new_antibiotic", "Antibiotic", value = v("antibiotic")))
    ),
    fluidRow(
      column(6, textInput("new_orf1", "ORF1", value = v("orf1"))),
      column(6, textInput("new_orf2", "ORF2", value = v("orf2")))
    ),
    fluidRow(
      column(6, textInput("new_vector_source", "Vector Source", value = v("vector_source"))),
      column(6, textInput("new_catalog_number", "Catalog Number", value = v("catalog_number")))
    ),
    fluidRow(
      column(6, textInput("new_n_tag", "N-Tag", value = v("n_tag"))),
      column(6, textInput("new_c_tag", "C-Tag", value = v("c_tag")))
    ),
    fluidRow(
      column(6, textInput("new_plasmid_cro", "CRO", value = v("cro"))),
      column(6, textInput("new_plasmid_eln", "ELN #", value = v("eln_number")))
    ),
    fluidRow(
      column(3, textInput("new_storage_room", "Room", value = v("storage_room"))),
      column(3, textInput("new_plasmid_storage_unit", "Unit", value = v("storage_unit"))),
      column(3, textInput("new_plasmid_shelf", "Shelf", value = v("shelf"))),
      column(3, textInput("new_plasmid_rack", "Rack", value = v("rack")))
    ),
    fluidRow(
      column(6, textInput("new_plasmid_box", "Box", value = v("storage_box"))),
      column(6, textInput("new_box_coordinate", "Box Coordinate", value = v("box_coordinate")))
    ),
    textAreaInput("new_plasmid_note", "Note", value = v("note")),
    footer = tagList(
      modalButton("Cancel"),
      actionButton(if (editing) "update_plasmid_btn" else "save_plasmid_btn",
                   "Save", class = "btn-primary")
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