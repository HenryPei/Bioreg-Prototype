# protein_batch.R
# get_protein_batches()                 batches for a protein
# get_protein_batch_by_id()             one batch for the detail view
# insert_protein_batch()                add a batch
# delete_protein_batch()                delete a batch
# protein_batch_detail_ui()             batch detail panel
# add_protein_batch_modal()             add batch form
# delete_protein_batch_confirm_modal()  confirm before delete

get_protein_batches <- function(protein_id) {
  dbGetQuery(con,
    "SELECT primary_key, batch_id, batch_name, concentration, unit,
            yield_mg, sec_purity, page_purity, purification_date
     FROM protein_batch
     WHERE protein_id = $1
     ORDER BY purification_date DESC",
    params = list(protein_id))
}

get_protein_batch_by_id <- function(primary_key) {
  dbGetQuery(con,
    "SELECT * FROM protein_batch WHERE primary_key = $1",
    params = list(primary_key))
}

insert_protein_batch <- function(protein_id, batch_id, batch_name,
                                 concentration, unit, yield_mg,
                                 buffer_solution, source, storage,
                                 room, storage_unit, shelf, rack, box,
                                 purification_date, harvest_date,
                                 trxn_date, sec_purity, page_purity,
                                 endotoxin_eu_mg, qc_eln, note,
                                 created_by) {
  dbExecute(con,
    "INSERT INTO protein_batch (protein_id, batch_id, batch_name,
                                concentration, unit, yield_mg,
                                buffer_solution, source, storage,
                                room, storage_unit, shelf, rack, box,
                                purification_date, harvest_date,
                                trxn_date, sec_purity, page_purity,
                                endotoxin_eu_mg, qc_eln, note,
                                created_by)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,
             $16,$17,$18,$19,$20,$21,$22,$23)",
    params = lapply(list(protein_id, batch_id, batch_name, concentration,
                         unit, yield_mg, buffer_solution, source, storage,
                         room, storage_unit, shelf, rack, box,
                         purification_date, harvest_date, trxn_date,
                         sec_purity, page_purity, endotoxin_eu_mg, qc_eln,
                         note, created_by), blank_to_na))
}

delete_protein_batch <- function(primary_key) {
  dbExecute(con, "DELETE FROM protein_batch WHERE primary_key = $1",
    params = list(primary_key))
}

protein_batch_detail_ui <- function(primary_key) {
  batch <- get_protein_batch_by_id(primary_key)

  tagList(
    hr(),
    h5(paste("Batch:", batch$batch_name)),
    p(strong("Batch ID: "), batch$batch_id),
    p(strong("Concentration: "), paste(batch$concentration, batch$unit)),
    p(strong("Yield (mg): "), batch$yield_mg),
    p(strong("SEC Purity: "), batch$sec_purity),
    p(strong("PAGE Purity: "), batch$page_purity),
    p(strong("Endotoxin: "), batch$endotoxin_eu_mg),
    p(strong("Buffer: "), batch$buffer_solution),
    p(strong("Storage: "), paste(batch$room, batch$storage_unit,
                                 batch$shelf, batch$rack, batch$box)),
    p(strong("Purification Date: "), as.character(batch$purification_date)),
    p(strong("Harvest Date: "), as.character(batch$harvest_date)),
    p(strong("Note: "), batch$note),
    br(),
    actionButton("delete_protein_batch_btn", "Delete Batch",
      class = "btn-danger btn-sm"),
    br(), br(),
    actionButton("back_to_protein_btn", "← Back to protein",
      class = "btn-secondary btn-sm")
  )
}

add_protein_batch_modal <- function() {
  modalDialog(
    title = "Add Protein Batch",
    fluidRow(
      column(6, textInput("new_pb_batch_id", "Batch ID")),
      column(6, textInput("new_pb_batch_name", "Batch Name"))
    ),
    fluidRow(
      column(6, numericInput("new_pb_concentration", "Concentration", value = NULL)),
      column(6, selectInput("new_pb_unit", "Unit",
        choices = c("mg/mL", "ug/mL", "nM", "uM")))
    ),
    fluidRow(
      column(6, textInput("new_pb_yield", "Yield (mg)")),
      column(6, textInput("new_pb_buffer", "Buffer"))
    ),
    fluidRow(
      column(6, textInput("new_pb_sec_purity", "SEC Purity %")),
      column(6, textInput("new_pb_page_purity", "PAGE Purity %"))
    ),
    fluidRow(
      column(6, textInput("new_pb_endotoxin", "Endotoxin (EU/mg)")),
      column(6, textInput("new_pb_source", "Source"))
    ),
    fluidRow(
      column(6, dateInput("new_pb_purification_date", "Purification Date", value = NA)),
      column(6, dateInput("new_pb_harvest_date", "Harvest Date", value = NA))
    ),
    fluidRow(
      column(6, dateInput("new_pb_trxn_date", "Transfection Date", value = NA)),
      column(6, textInput("new_pb_storage", "Storage"))
    ),
    fluidRow(
      column(3, textInput("new_pb_room", "Room")),
      column(3, textInput("new_pb_storage_unit", "Unit")),
      column(3, textInput("new_pb_shelf", "Shelf")),
      column(3, textInput("new_pb_rack", "Rack"))
    ),
    fluidRow(
      column(6, textInput("new_pb_box", "Box")),
      column(6, textInput("new_pb_qc_eln", "QC ELN"))
    ),
    textAreaInput("new_pb_note", "Note"),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("save_protein_batch_btn", "Save", class = "btn-success")
    )
  )
}

delete_protein_batch_confirm_modal <- function(primary_key) {
  batch <- get_protein_batch_by_id(primary_key)

  modalDialog(
    title = "Confirm Delete",
    paste0("Delete batch ", batch$batch_id, "? This cannot be undone."),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("confirm_delete_protein_batch_btn", "Delete", class = "btn-danger")
    )
  )
}