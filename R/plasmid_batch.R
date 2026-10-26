# TABLE OF CONTENTS
# plasmid_batch.R
# ─────────────────────────────────────────────────────
# get_plasmid_batches()                — all batches for a plasmid, for portal display
# get_plasmid_batch_by_id()            — single batch for detail view
# insert_plasmid_batch()               — writes new batch to database
# delete_plasmid_batch()               — deletes a plasmid batch record
# plasmid_batch_detail_ui()            — detail panel with batch fields and back button
# add_plasmid_batch_modal()            — popup form for adding a new batch
# delete_plasmid_batch_confirm_modal() — confirmation popup before delete

# ── Plasmid batch - Database queries
get_plasmid_batches <- function(plasmid_id) {
  dbGetQuery(con,
    "SELECT primary_key, batch_id, batch_name, concentration, unit,
             yield_ug, production_date, seq_confirm
     FROM plasmid_batch
     WHERE plasmid_id = $1
     ORDER BY production_date DESC",
    params = list(plasmid_id))
}

get_plasmid_batch_by_id <- function(primary_key) {
  dbGetQuery(con,
    "SELECT * FROM plasmid_batch WHERE primary_key = $1",
    params = list(primary_key))
}

insert_plasmid_batch <- function(plasmid_id, batch_id, batch_name,
                                  concentration, unit, yield_ug,
                                  buffer_solution, source, storage,
                                  room, storage_unit, shelf, rack,
                                  storage_box, production_date,
                                  a260_to_280, a260_to_230, endotoxin,
                                  cro, cro_id, prep, seq_confirm,
                                  vol_ml, initial_vol_ul,
                                  starting_inventory, current_inventory,
                                  tube_volumes, confirmed_by, qc_eln,
                                  note, created_by) {
  tryCatch({
  dbExecute(con,
    "INSERT INTO plasmid_batch (plasmid_id, batch_id, batch_name,
                                concentration, unit, yield_ug,
                                buffer_solution, source, storage,
                                room, storage_unit, shelf, rack,
                                storage_box, production_date,
                                a260_to_280, a260_to_230, endotoxin,
                                cro, cro_id, prep, seq_confirm,
                                vol_ml, initial_vol_ul,
                                starting_inventory, current_inventory,
                                tube_volumes, confirmed_by, qc_eln,
                                note, created_by)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,
             $16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,
             $29,$30,$31)",
    params = list(plasmid_id, batch_id, batch_name, concentration,
                  unit, yield_ug, buffer_solution, source, storage,
                  room, storage_unit, shelf, rack, storage_box,
                  production_date, a260_to_280, a260_to_230, endotoxin,
                  cro, cro_id, prep, seq_confirm, vol_ml, initial_vol_ul,
                  starting_inventory, current_inventory, tube_volumes,
                  confirmed_by, qc_eln, note, created_by))
  }, error = function(e) {
    showNotification(paste("Error saving plasmid batch:", e$message), type = "error")
  })
}

delete_plasmid_batch <- function(primary_key) {
  tryCatch({
    dbExecute(con, "DELETE FROM plasmid_batch WHERE primary_key = $1",
      params = list(primary_key))
    showNotification("Plasmid batch deleted", type = "message")
  }, error = function(e) {
    showNotification(paste("Error deleting plasmid batch:", e$message), type = "error")
  })
}

# ── Plasmid batch - catalogue functions
plasmid_batch_detail_ui <- function(primary_key) {
  batch <- get_plasmid_batch_by_id(primary_key)
  
  tagList(
    hr(),
    h5(paste("Plasmid Batch:", batch$batch_name)),
    p(strong("Batch ID: "), batch$batch_id),
    p(strong("Concentration: "), paste(batch$concentration, batch$unit)),
    p(strong("Yield (ug): "), batch$yield_ug),
    p(strong("Buffer: "), batch$buffer_solution),
    p(strong("Source: "), batch$source),
    p(strong("A260/A280: "), batch$a260_to_280),
    p(strong("A260/A230: "), batch$a260_to_230),
    p(strong("Endotoxin: "), batch$endotoxin),
    p(strong("CRO: "), batch$cro),
    p(strong("CRO ID: "), batch$cro_id),
    p(strong("Prep: "), batch$prep),
    p(strong("Seq Confirm: "), batch$seq_confirm),
    p(strong("Volume (mL): "), batch$vol_ml),
    p(strong("Initial Volume (ul): "), batch$initial_vol_ul),
    p(strong("Production Date: "), as.character(batch$production_date)),
    p(strong("Storage: "), paste(batch$room, batch$storage_unit,
                                  batch$shelf, batch$rack, batch$storage_box)),
    p(strong("Starting Inventory: "), batch$starting_inventory),
    p(strong("Current Inventory: "), batch$current_inventory),
    p(strong("Tube Volumes: "), batch$tube_volumes),
    p(strong("Confirmed By: "), batch$confirmed_by),
    p(strong("QC ELN: "), batch$qc_eln),
    p(strong("Note: "), batch$note),
    br(),
    actionButton("delete_plasmid_batch_btn", "Delete Batch",
      class = "btn-danger btn-sm"),
    br(), br(),
    actionButton("back_to_plasmid_btn", "← Back to plasmid",
      class = "btn-secondary btn-sm")
  )
}

# ── Add plasmid batch modal ───────────────────────────
add_plasmid_batch_modal <- function() {
  modalDialog(
    title = "Add Plasmid Batch",
    fluidRow(
      column(6, textInput("new_plb_batch_id", "Batch ID")),
      column(6, textInput("new_plb_batch_name", "Batch Name"))
    ),
    fluidRow(
      column(6, numericInput("new_plb_concentration", "Concentration", value = NULL)),
      column(6, selectInput("new_plb_unit", "Unit",
        choices = c("ng/uL", "ug/mL", "nM")))
    ),
    fluidRow(
      column(6, textInput("new_plb_yield", "Yield (ug)")),
      column(6, textInput("new_plb_buffer", "Buffer"))
    ),
    fluidRow(
      column(6, textInput("new_plb_a260_280", "A260/A280")),
      column(6, textInput("new_plb_a260_230", "A260/A230"))
    ),
    fluidRow(
      column(6, textInput("new_plb_endotoxin", "Endotoxin")),
      column(6, textInput("new_plb_seq_confirm", "Seq Confirm"))
    ),
    fluidRow(
      column(6, dateInput("new_plb_production_date", "Production Date")),
      column(6, textInput("new_plb_prep", "Prep"))
    ),
    fluidRow(
      column(6, numericInput("new_plb_vol_ml", "Vol (mL)", value = NULL)),
      column(6, textInput("new_plb_initial_vol", "Initial Vol (ul)"))
    ),
    fluidRow(
      column(6, textInput("new_plb_cro", "CRO")),
      column(6, textInput("new_plb_cro_id", "CRO ID"))
    ),
    fluidRow(
      column(3, textInput("new_plb_room", "Room")),
      column(3, textInput("new_plb_storage_unit", "Unit")),
      column(3, textInput("new_plb_shelf", "Shelf")),
      column(3, textInput("new_plb_rack", "Rack"))
    ),
    textInput("new_plb_confirmed_by", "Confirmed By"),
    textAreaInput("new_plb_note", "Note"),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("save_plasmid_batch_btn", "Save", class = "btn-success")
    )
  )
}

# ── Delete confirmation modal ─────────────────────────
delete_plasmid_batch_confirm_modal <- function(primary_key) {
  batch <- get_plasmid_batch_by_id(primary_key)
  
  modalDialog(
    title = "Confirm Delete",
    paste0("Delete batch ", batch$batch_id, "? This cannot be undone."),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("confirm_delete_plasmid_batch_btn", "Delete",
        class = "btn-danger")
    )
  )
}