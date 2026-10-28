# component.R
# get_components()                  all components for the table
# get_component_by_id()             one component for the detail view
# get_next_component_id()           next C-XXXXXXX id
# insert_component()                add a component
# update_component()                edit a component
# get_plasmids_for_component()      plasmids containing a component
# delete_component_cascade()        delete a component and its links
# component_detail_ui()             detail panel with sequences and plasmid portal
# component_modal()                 add or edit component form
# delete_component_confirm_modal()  confirm before delete

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
    "SELECT component_id FROM component ORDER BY component_id DESC LIMIT 1")
  if (nrow(last) == 0) return("C-0000001")
  num <- as.integer(sub("C-", "", last$component_id)) + 1
  sprintf("C-%07d", num)
}

insert_component <- function(component_name, type, species, subclass,
                             hybridoma_id, aa_sequence, cdna_sequence,
                             mutation, uniprot, parent, vendor,
                             project_code, germline, expression,
                             seq_method, note, created_by) {
  dbExecute(con,
    "INSERT INTO component (component_id, component_name, type,
                            species, subclass, hybridoma_id,
                            aa_sequence, cdna_sequence, mutation,
                            uniprot, parent, vendor, project_code,
                            germline, expression, seq_method, note,
                            created_by)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,
             $16,$17,$18)",
    params = lapply(list(get_next_component_id(), component_name, type,
                         species, subclass, hybridoma_id, aa_sequence,
                         cdna_sequence, mutation, uniprot, parent, vendor,
                         project_code, germline, expression, seq_method,
                         note, created_by),
                    blank_to_na))
}

update_component <- function(component_id, component_name, type, species,
                             subclass, hybridoma_id, aa_sequence,
                             cdna_sequence, mutation, uniprot, parent,
                             vendor, project_code, germline, expression,
                             seq_method, note) {
  dbExecute(con,
    "UPDATE component
     SET component_name = $2, type = $3, species = $4, subclass = $5,
         hybridoma_id = $6, aa_sequence = $7, cdna_sequence = $8,
         mutation = $9, uniprot = $10, parent = $11, vendor = $12,
         project_code = $13, germline = $14, expression = $15,
         seq_method = $16, note = $17
     WHERE component_id = $1",
    params = lapply(list(component_id, component_name, type, species,
                         subclass, hybridoma_id, aa_sequence, cdna_sequence,
                         mutation, uniprot, parent, vendor, project_code,
                         germline, expression, seq_method, note),
                    blank_to_na))
}

get_plasmids_for_component <- function(component_id) {
  dbGetQuery(con,
    "SELECT pl.plasmid_id, pl.plasmid_name, pl.type, pl.vector, jcp.pnr
     FROM plasmid pl
     JOIN join_table_component_plasmid jcp ON pl.plasmid_id = jcp.plasmid_id
     WHERE jcp.component_id = $1",
    params = list(component_id))
}

delete_component_cascade <- function(component_id) {
  poolWithTransaction(con, function(conn) {
    dbExecute(conn, "UPDATE protein SET component_id = NULL WHERE component_id = $1",
      params = list(component_id))
    dbExecute(conn, "DELETE FROM component WHERE component_id = $1",
      params = list(component_id))
  })
}

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
      div(
        actionButton("edit_component_btn", "Edit Component", class = "btn-primary btn-sm"),
        actionButton("delete_component_btn", "Delete Component", class = "btn-danger btn-sm")
      )
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
      actionButton("view_plasmid_from_component_btn", "View Selected", class = "btn-outline-primary btn-sm"),
      DTOutput("component_plasmids_portal")
    )
  )
}

component_modal <- function(row = NULL) {
  editing <- !is.null(row)
  v <- function(col) form_value(row, col)
  hybridomas <- get_hybridomas()

  modalDialog(
    title = if (editing) "Edit Component" else "Add New Component",
    fluidRow(
      column(6, textInput("new_comp_name", "Component Name", value = v("component_name"))),
      column(6, textInput("new_comp_type", "Type", value = v("type")))
    ),
    fluidRow(
      column(6, textInput("new_comp_species", "Species", value = v("species"))),
      column(6, textInput("new_comp_subclass", "Subclass", value = v("subclass")))
    ),
    fluidRow(
      column(6, selectInput("new_comp_hybridoma_id", "Hybridoma",
        choices = c("None" = "",
                    setNames(hybridomas$hybridoma_id,
                             paste(hybridomas$hybridoma_id, hybridomas$clone_name))),
        selected = v("hybridoma_id"))),
      column(6, textInput("new_comp_parent", "Parent", value = v("parent")))
    ),
    textAreaInput("new_comp_aa_seq", "AA Sequence", value = v("aa_sequence")),
    textAreaInput("new_comp_cdna_seq", "cDNA Sequence", value = v("cdna_sequence")),
    fluidRow(
      column(6, textInput("new_comp_mutation", "Mutation", value = v("mutation"))),
      column(6, textInput("new_comp_uniprot", "Uniprot", value = v("uniprot")))
    ),
    fluidRow(
      column(6, textInput("new_comp_vendor", "Vendor", value = v("vendor"))),
      column(6, textInput("new_comp_project_code", "Project Code", value = v("project_code")))
    ),
    fluidRow(
      column(6, textInput("new_comp_germline", "Germline", value = v("germline"))),
      column(6, textInput("new_comp_seq_method", "Seq Method", value = v("seq_method")))
    ),
    textInput("new_comp_expression", "Expression", value = v("expression")),
    textAreaInput("new_comp_note", "Note", value = v("note")),
    footer = tagList(
      modalButton("Cancel"),
      actionButton(if (editing) "update_component_btn" else "save_component_btn",
                   "Save", class = "btn-primary")
    )
  )
}

delete_component_confirm_modal <- function(component_id) {
  comp     <- get_component_by_id(component_id)
  plasmids <- get_plasmids_for_component(component_id)

  warning_text <- paste0("Delete ", comp$component_name, "? ")

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
      actionButton("confirm_delete_component_btn", "Delete Everything", class = "btn-danger")
    )
  )
}