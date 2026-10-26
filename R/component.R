# TABLE OF CONTENTS
# component.R
# ─────────────────────────────────────────────────────
# get_components()                  — all components for display table
# get_component_by_id()             — single component for detail view
# get_next_component_id()           — generates next C-XXXXXXX ID
# insert_component()                — writes new component to database
# get_plasmids_for_component()      — plasmids containing this component
# delete_component_cascade()        — deletes component and all dependent links
# component_detail_ui()             — detail panel with sequences and plasmid portal
# add_component_modal()             — popup form for adding a new component
# delete_component_confirm_modal()  — confirmation popup before cascading delete

# ── Component - Database queries
get_components <- function() {
  dbGetQuery(con,
    "SELECT component_id, component_name, type, species,
             subclass, project_code, created_at
     FROM component
     ORDER BY created_at DESC")
}

get_component_by_id <- function(component_id) {
  dbGetQuery(con,
    "SELECT * FROM component WHERE component_id = $1",
    params = list(component_id))
}

get_next_component_id <- function() {
  last <- dbGetQuery(con,
    "SELECT component_id FROM component
     ORDER BY component_id DESC LIMIT 1")
  if (nrow(last) == 0) return("C-0000001")
  num <- as.integer(gsub("C-", "", last$component_id)) + 1
  sprintf("C-%07d", num)
}

insert_component <- function(component_name, type, species, subclass,
                              hybridoma_id, aa_sequence, cdna_sequence,
                              mutation, uniprot, parent, vendor,
                              project_code, germline, expression,
                              seq_method, note, created_by) {
  tryCatch({
    dbExecute(con,
      "INSERT INTO component (component_id, component_name, type,
                              species, subclass, hybridoma_id,
                              aa_sequence, cdna_sequence, mutation,
                              uniprot, parent, vendor, project_code,
                              germline, expression, seq_method, note,
                              created_by)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,
               $16,$17,$18)",
      params = list(get_next_component_id(), component_name, type,
                    species, subclass, hybridoma_id, aa_sequence,
                    cdna_sequence, mutation, uniprot, parent, vendor,
                    project_code, germline, expression, seq_method,
                    note, created_by))
  }, error = function(e) {
    showNotification(paste("Error saving component:", e$message), type = "error")
  })
}

get_plasmids_for_component <- function(component_id) {
  dbGetQuery(con,
    "SELECT pl.plasmid_id, pl.plasmid_name, pl.type, pl.vector,
             jcp.pnr
     FROM plasmid pl
     JOIN join_table_component_plasmid jcp ON pl.plasmid_id = jcp.plasmid_id
     WHERE jcp.component_id = $1",
    params = list(component_id))
}

delete_component_cascade <- function(component_id) {
  tryCatch({
    dbExecute(con, "DELETE FROM join_table_component_plasmid WHERE component_id = $1",
      params = list(component_id))
    dbExecute(con, "DELETE FROM component WHERE component_id = $1",
      params = list(component_id))
    showNotification("Component and all associated links deleted", type = "message")
  }, error = function(e) {
    showNotification(paste("Error deleting component:", e$message), type = "error")
  })
}

# ── Component - catalogue functions
component_detail_ui <- function(component_id) {
  comp <- get_component_by_id(component_id)
  
  tagList(
    hr(),
    card(
      card_header(h4(comp$component_name)),
      p(strong("Component ID: "), comp$component_id),
      p(strong("Type: "), comp$type),
      p(strong("Species: "), comp$species),
      p(strong("Subclass: "), comp$subclass),
      p(strong("Hybridoma ID: "), comp$hybridoma_id),
      p(strong("Uniprot: "), comp$uniprot),
      p(strong("Germline: "), comp$germline),
      p(strong("Seq Method: "), comp$seq_method),
      p(strong("Expression: "), comp$expression),
      p(strong("Vendor: "), comp$vendor),
      p(strong("Project Code: "), comp$project_code),
      p(strong("Note: "), comp$note),
      actionButton("delete_component_btn", "Delete Component",
        class = "btn-danger btn-sm")
    ),
    br(),
    
    card(
      card_header("Sequences"),
      h6("AA Sequence"),
      verbatimTextOutput("comp_aa_seq"),
      h6("cDNA Sequence"),
      verbatimTextOutput("comp_cdna_seq")
    ),
    br(),
    
    card(
      card_header("Plasmids containing this component"),
      actionButton("link_component_btn", "Link",
        class = "btn-primary btn-sm"),
      actionButton("view_plasmid_from_component_btn", "View Selected",
        class = "btn-outline-primary btn-sm"),
      actionButton("unlink_component_btn", "Unlink Selected",
        class = "btn-warning btn-sm"),
      DTOutput("component_plasmids_portal")
    )
  )
}

# ── Add component modal ───────────────────────────────
add_component_modal <- function() {
  modalDialog(
    title = "Add New Component",
    fluidRow(
      column(6, textInput("new_comp_name", "Component Name")),
      column(6, textInput("new_comp_type", "Type"))
    ),
    fluidRow(
      column(6, textInput("new_comp_species", "Species")),
      column(6, textInput("new_comp_subclass", "Subclass"))
    ),
    fluidRow(
      column(6, textInput("new_comp_hybridoma_id", "Hybridoma ID")),
      column(6, textInput("new_comp_parent", "Parent"))
    ),
    textAreaInput("new_comp_aa_seq", "AA Sequence"),
    textAreaInput("new_comp_cdna_seq", "cDNA Sequence"),
    fluidRow(
      column(6, textInput("new_comp_mutation", "Mutation")),
      column(6, textInput("new_comp_uniprot", "Uniprot"))
    ),
    fluidRow(
      column(6, textInput("new_comp_vendor", "Vendor")),
      column(6, textInput("new_comp_project_code", "Project Code"))
    ),
    fluidRow(
      column(6, textInput("new_comp_germline", "Germline")),
      column(6, textInput("new_comp_seq_method", "Seq Method"))
    ),
    textInput("new_comp_expression", "Expression"),
    textAreaInput("new_comp_note", "Note"),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("save_component_btn", "Save", class = "btn-primary")
    )
  )
}

# ── Delete confirmation modal ─────────────────────────
delete_component_confirm_modal <- function(component_id) {
  comp     <- get_component_by_id(component_id)
  plasmids <- get_plasmids_for_component(component_id)

  warning_text <- paste0("Delete ", comp$component_name, "? ")

  if (nrow(plasmids) > 0) {
    warning_text <- paste0(warning_text,
      "Unlinked from plasmids: ",
      format_relationship_list(plasmids$plasmid_name), ". ")
  }

  warning_text <- paste0(warning_text, "This cannot be undone.")

  modalDialog(
    title = "Confirm Delete",
    warning_text,
    footer = tagList(
      modalButton("Cancel"),
      actionButton("confirm_delete_component_btn", "Delete Everything",
        class = "btn-danger")
    )
  )
}