# TABLE OF CONTENTS
# cell_batch.R
# ─────────────────────────────────────────────────────
# get_cell_batches()              — all batches for a cell line, for portal display
# get_cell_batch_by_id()          — single batch for detail view
# insert_cell_batch()             — writes new cell batch to database
# delete_cell_batch()             — deletes a cell batch record
# cell_batch_detail_ui()          — detail panel with batch fields and back button
# add_cell_batch_modal()          — popup form for adding a new cell batch
# delete_cell_batch_confirm_modal() — confirmation popup before delete

# ── Cell batch - Database queries
get_cell_batches <- function(cell_line_id) {
  dbGetQuery(con,
    "SELECT primary_key, batch_id, date, cell_density,
             vials, passage_num, storage_unit, storage_box
     FROM cell_batch
     WHERE cell_line_id = $1
     ORDER BY date DESC",
    params = list(cell_line_id))
}

get_cell_batch_by_id <- function(primary_key) {
  dbGetQuery(con,
    "SELECT * FROM cell_batch WHERE primary_key = $1",
    params = list(primary_key))
}

insert_cell_batch <- function(cell_line_id, batch_id, date,
                               cell_density, vials, room, storage_unit,
                               tower, storage_box, passage_num,
                               created_by) {
  tryCatch({
    dbExecute(con,
      "INSERT INTO cell_batch (cell_line_id, batch_id, date, cell_density,
                               vials, room, storage_unit, tower,
                               storage_box, passage_num, created_by)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)",
      params = list(cell_line_id, batch_id, date, cell_density, vials,
                    room, storage_unit, tower, storage_box, passage_num,
                    created_by))
  }, error = function(e) {
    showNotification(paste("Error saving cell batch:", e$message), type = "error")
  })
}

delete_cell_batch <- function(primary_key) {
  tryCatch({
    dbExecute(con, "DELETE FROM cell_batch WHERE primary_key = $1",
      params = list(primary_key))
    showNotification("Cell batch deleted", type = "message")
  }, error = function(e) {
    showNotification(paste("Error deleting cell batch:", e$message), type = "error")
  })
}

# ── Cell batch - catalogue functions
cell_batch_detail_ui <- function(primary_key) {
  batch <- get_cell_batch_by_id(primary_key)
  
  tagList(
    hr(),
    h5(paste("Cell Batch:", batch$batch_id)),
    p(strong("Date: "), as.character(batch$date)),
    p(strong("Cell Density: "), batch$cell_density),
    p(strong("Vials: "), batch$vials),
    p(strong("Passage Number: "), batch$passage_num),
    p(strong("Storage: "), paste(batch$room, batch$storage_unit,
                                  batch$tower, batch$storage_box)),
    br(),
    actionButton("delete_cell_batch_btn", "Delete Batch",
      class = "btn-danger btn-sm"),
    br(), br(),
    actionButton("back_to_cell_line_btn", "← Back to cell line",
      class = "btn-secondary btn-sm")
  )
}

# ── Add cell batch modal ──────────────────────────────
add_cell_batch_modal <- function() {
  modalDialog(
    title = "Add Cell Batch",
    fluidRow(
      column(6, textInput("new_cb_batch_id", "Batch ID")),
      column(6, dateInput("new_cb_date", "Date"))
    ),
    fluidRow(
      column(6, textInput("new_cb_cell_density", "Cell Density")),
      column(6, numericInput("new_cb_vials", "Vials", value = NULL))
    ),
    fluidRow(
      column(6, textInput("new_cb_passage_num", "Passage Number")),
      column(6, textInput("new_cb_room", "Room"))
    ),
    fluidRow(
      column(6, textInput("new_cb_storage_unit", "Storage Unit")),
      column(6, textInput("new_cb_tower", "Tower"))
    ),
    textInput("new_cb_storage_box", "Box"),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("save_cell_batch_btn", "Save", class = "btn-success")
    )
  )
}

# ── Delete confirmation modal ─────────────────────────
delete_cell_batch_confirm_modal <- function(primary_key) {
  batch <- get_cell_batch_by_id(primary_key)
  
  modalDialog(
    title = "Confirm Delete",
    paste0("Delete batch ", batch$batch_id, "? This cannot be undone."),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("confirm_delete_cell_batch_btn", "Delete",
        class = "btn-danger")
    )
  )
}