# join_tables.R
# link_protein_plasmid()      link a protein and plasmid
# unlink_protein_plasmid()    remove that link
# link_component_plasmid()    link a component and plasmid
# unlink_component_plasmid()  remove that link
# link_cell_line_plasmid()    link a cell line and plasmid
# unlink_cell_line_plasmid()  remove that link
# link_plasmid_modal()        pick a plasmid to link
# link_protein_modal()        pick a protein to link
# link_component_modal()      pick a component to link
# link_cell_line_modal()      pick a cell line to link

link_protein_plasmid <- function(protein_id, plasmid_id,
                                 protein_name, plasmid_name,
                                 pnr_number, created_by) {
  dbExecute(con,
    "INSERT INTO join_table_protein_plasmid (protein_id, plasmid_id,
                                             protein_name, plasmid_name,
                                             pnr_number, created_by)
     VALUES ($1,$2,$3,$4,$5,$6)
     ON CONFLICT DO NOTHING",
    params = list(protein_id, plasmid_id, protein_name, plasmid_name,
                  pnr_number, created_by))
}

unlink_protein_plasmid <- function(protein_id, plasmid_id) {
  dbExecute(con,
    "DELETE FROM join_table_protein_plasmid
     WHERE protein_id = $1 AND plasmid_id = $2",
    params = list(protein_id, plasmid_id))
}

link_component_plasmid <- function(component_id, plasmid_id,
                                   component_name, plasmid_name,
                                   pnr, created_by) {
  dbExecute(con,
    "INSERT INTO join_table_component_plasmid (component_id, plasmid_id,
                                               component_name, plasmid_name,
                                               pnr, created_by)
     VALUES ($1,$2,$3,$4,$5,$6)
     ON CONFLICT DO NOTHING",
    params = list(component_id, plasmid_id, component_name, plasmid_name,
                  pnr, created_by))
}

unlink_component_plasmid <- function(component_id, plasmid_id) {
  dbExecute(con,
    "DELETE FROM join_table_component_plasmid
     WHERE component_id = $1 AND plasmid_id = $2",
    params = list(component_id, plasmid_id))
}

link_cell_line_plasmid <- function(cell_line_id, plasmid_id,
                                   cell_line_name, plasmid_name,
                                   created_by) {
  dbExecute(con,
    "INSERT INTO join_table_cell_line_plasmid (cell_line_id, plasmid_id,
                                               cell_line_name, plasmid_name,
                                               created_by)
     VALUES ($1,$2,$3,$4,$5)
     ON CONFLICT DO NOTHING",
    params = list(cell_line_id, plasmid_id, cell_line_name, plasmid_name,
                  created_by))
}

unlink_cell_line_plasmid <- function(cell_line_id, plasmid_id) {
  dbExecute(con,
    "DELETE FROM join_table_cell_line_plasmid
     WHERE cell_line_id = $1 AND plasmid_id = $2",
    params = list(cell_line_id, plasmid_id))
}

link_plasmid_modal <- function() {
  plasmids <- get_plasmids()
  modalDialog(
    title = "Link Plasmid to Protein",
    selectInput("link_plasmid_id", "Select Plasmid",
      choices = setNames(plasmids$plasmid_id,
                         paste(plasmids$plasmid_id, plasmids$plasmid_name))),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("save_plasmid_link_btn", "Link", class = "btn-primary")
    )
  )
}

link_protein_modal <- function() {
  proteins <- get_proteins()
  modalDialog(
    title = "Link Protein to Plasmid",
    selectInput("link_protein_id", "Select Protein",
      choices = setNames(proteins$protein_id,
                         paste(proteins$protein_id, proteins$protein_name))),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("save_protein_link_btn", "Link", class = "btn-primary")
    )
  )
}

link_component_modal <- function() {
  components <- get_components()
  modalDialog(
    title = "Link Component to Plasmid",
    selectInput("link_component_id", "Select Component",
      choices = setNames(components$component_id,
                         paste(components$component_id, components$component_name))),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("save_component_link_btn", "Link", class = "btn-primary")
    )
  )
}

link_cell_line_modal <- function() {
  cell_lines <- get_cell_lines()
  modalDialog(
    title = "Link Cell Line to Plasmid",
    selectInput("link_cell_line_id", "Select Cell Line",
      choices = setNames(cell_lines$cell_line_id,
                         paste(cell_lines$cell_line_id, cell_lines$cell_line_name))),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("save_cell_line_link_btn", "Link", class = "btn-primary")
    )
  )
}