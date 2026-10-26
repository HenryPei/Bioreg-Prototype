# TABLE OF CONTENTS
# join_tables.R
# ─────────────────────────────────────────────────────
# link_protein_plasmid()      — creates protein-plasmid association
# unlink_protein_plasmid()    — removes protein-plasmid association
# link_component_plasmid()    — creates component-plasmid association
# unlink_component_plasmid()  — removes component-plasmid association
# link_cell_line_plasmid()    — creates cell line-plasmid association
# unlink_cell_line_plasmid()  — removes cell line-plasmid association
# link_plasmid_modal()        — popup for linking existing plasmid to protein
# link_component_modal()      — popup for linking existing component to plasmid
# link_cell_line_modal()      — popup for linking existing cell line to plasmid

# ── Join tables - Database queries
link_protein_plasmid <- function(protein_id, plasmid_id,
                                  protein_name, plasmid_name,
                                  pnr_number, created_by) {
  tryCatch({
    dbExecute(con,
      "INSERT INTO join_table_protein_plasmid (protein_id, plasmid_id,
                                               protein_name, plasmid_name,
                                               pnr_number, created_by)
       VALUES ($1,$2,$3,$4,$5,$6)
       ON CONFLICT DO NOTHING",
      params = list(protein_id, plasmid_id, protein_name, plasmid_name,
                    pnr_number, created_by))
    showNotification("Plasmid linked", type = "message")
  }, error = function(e) {
    showNotification(paste("Error linking plasmid:", e$message), type = "error")
  })
}

unlink_protein_plasmid <- function(protein_id, plasmid_id) {
  tryCatch({
    dbExecute(con,
      "DELETE FROM join_table_protein_plasmid
       WHERE protein_id = $1 AND plasmid_id = $2",
      params = list(protein_id, plasmid_id))
    showNotification("Plasmid unlinked", type = "message")
  }, error = function(e) {
    showNotification(paste("Error unlinking:", e$message), type = "error")
  })
}

link_component_plasmid <- function(component_id, plasmid_id,
                                    component_name, plasmid_name,
                                    pnr, created_by) {
  tryCatch({
    dbExecute(con,
      "INSERT INTO join_table_component_plasmid (component_id, plasmid_id,
                                                 component_name, plasmid_name,
                                                 pnr, created_by)
       VALUES ($1,$2,$3,$4,$5,$6)
       ON CONFLICT DO NOTHING",
      params = list(component_id, plasmid_id, component_name, plasmid_name,
                    pnr, created_by))
    showNotification("Component linked", type = "message")
  }, error = function(e) {
    showNotification(paste("Error linking component:", e$message), type = "error")
  })
}

unlink_component_plasmid <- function(component_id, plasmid_id) {
  tryCatch({
    dbExecute(con,
      "DELETE FROM join_table_component_plasmid
       WHERE component_id = $1 AND plasmid_id = $2",
      params = list(component_id, plasmid_id))
    showNotification("Component unlinked", type = "message")
  }, error = function(e) {
    showNotification(paste("Error unlinking:", e$message), type = "error")
  })
}

link_cell_line_plasmid <- function(cell_line_id, plasmid_id,
                                    cell_line_name, plasmid_name,
                                    created_by) {
  tryCatch({
    dbExecute(con,
      "INSERT INTO join_table_cell_line_plasmid (cell_line_id, plasmid_id,
                                                 cell_line_name, plasmid_name,
                                                 created_by)
       VALUES ($1,$2,$3,$4,$5)
       ON CONFLICT DO NOTHING",
      params = list(cell_line_id, plasmid_id, cell_line_name, plasmid_name,
                    created_by))
    showNotification("Cell line linked", type = "message")
  }, error = function(e) {
    showNotification(paste("Error linking cell line:", e$message), type = "error")
  })
}

unlink_cell_line_plasmid <- function(cell_line_id, plasmid_id) {
  tryCatch({
    dbExecute(con,
      "DELETE FROM join_table_cell_line_plasmid
       WHERE cell_line_id = $1 AND plasmid_id = $2",
      params = list(cell_line_id, plasmid_id))
    showNotification("Cell line unlinked", type = "message")
  }, error = function(e) {
    showNotification(paste("Error unlinking:", e$message), type = "error")
  })
}

# ── Link plasmid to protein modal ─────────────────────
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

# ── Link component to plasmid modal ───────────────────
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

# ── Link cell line to plasmid modal ───────────────────
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