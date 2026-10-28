# hybridoma.R
# get_hybridomas()                  all hybridomas for the table
# get_hybridoma_by_id()             one hybridoma for the detail view
# get_next_hybridoma_id()           next H-XXXXXXX id
# insert_hybridoma()                add a hybridoma
# delete_hybridoma()                delete a hybridoma, unlink its components
# get_components_for_hybridoma()    components derived from a hybridoma
# hybridoma_detail_ui()             detail panel with components portal
# add_hybridoma_modal()             add hybridoma form
# delete_hybridoma_confirm_modal()  confirm before delete

get_hybridomas <- function() {
  dbGetQuery(con,
    "SELECT hybridoma_id, clone_name, mouse_igg_subclass,
            light_chain_subclass, project_code, created_at
     FROM hybridoma
     ORDER BY created_at DESC")
}

get_hybridoma_by_id <- function(hybridoma_id) {
  dbGetQuery(con,
    "SELECT * FROM hybridoma WHERE hybridoma_id = $1",
    params = list(hybridoma_id))
}

get_next_hybridoma_id <- function() {
  last <- dbGetQuery(con,
    "SELECT hybridoma_id FROM hybridoma ORDER BY hybridoma_id DESC LIMIT 1")
  if (nrow(last) == 0) return("H-0000001")
  num <- as.integer(sub("H-", "", last$hybridoma_id)) + 1
  sprintf("H-%07d", num)
}

insert_hybridoma <- function(clone_name, mouse_igg_subclass,
                             light_chain_subclass, project_code,
                             seq_cro, strain, cro_id, tissue,
                             eln, note, created_by) {
  dbExecute(con,
    "INSERT INTO hybridoma (hybridoma_id, clone_name, mouse_igg_subclass,
                            light_chain_subclass, project_code, seq_cro,
                            strain, cro_id, tissue, eln, note, created_by)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)",
    params = lapply(list(get_next_hybridoma_id(), clone_name, mouse_igg_subclass,
                         light_chain_subclass, project_code, seq_cro, strain,
                         cro_id, tissue, eln, note, created_by),
                    blank_to_na))
}

delete_hybridoma <- function(hybridoma_id) {
  poolWithTransaction(con, function(conn) {
    dbExecute(conn, "UPDATE component SET hybridoma_id = NULL WHERE hybridoma_id = $1",
      params = list(hybridoma_id))
    dbExecute(conn, "DELETE FROM hybridoma WHERE hybridoma_id = $1",
      params = list(hybridoma_id))
  })
}

get_components_for_hybridoma <- function(hybridoma_id) {
  dbGetQuery(con,
    "SELECT component_id, component_name, type, species, subclass
     FROM component
     WHERE hybridoma_id = $1",
    params = list(hybridoma_id))
}

hybridoma_detail_ui <- function(hybridoma_id) {
  hyb <- get_hybridoma_by_id(hybridoma_id)

  tagList(
    hr(),
    card(
      card_header(h4(hyb$clone_name)),
      p(strong("Hybridoma ID: "), hyb$hybridoma_id),
      p(strong("Mouse IgG Subclass: "), hyb$mouse_igg_subclass),
      p(strong("Light Chain Subclass: "), hyb$light_chain_subclass),
      p(strong("Strain: "), hyb$strain),
      p(strong("Tissue: "), hyb$tissue),
      p(strong("Seq CRO: "), hyb$seq_cro),
      p(strong("CRO ID: "), hyb$cro_id),
      p(strong("Project Code: "), hyb$project_code),
      p(strong("ELN: "), hyb$eln),
      p(strong("Note: "), hyb$note),
      actionButton("delete_hybridoma_btn", "Delete Hybridoma", class = "btn-danger btn-sm")
    ),
    br(),

    card(
      card_header("Components derived from this hybridoma"),
      actionButton("view_component_from_hybridoma_btn", "View Selected", class = "btn-outline-primary btn-sm"),
      DTOutput("hybridoma_components_portal")
    )
  )
}

add_hybridoma_modal <- function() {
  modalDialog(
    title = "Add New Hybridoma",
    fluidRow(
      column(6, textInput("new_hyb_clone_name", "Clone Name")),
      column(6, textInput("new_hyb_subclass", "Mouse IgG Subclass"))
    ),
    fluidRow(
      column(6, textInput("new_hyb_lc_subclass", "Light Chain Subclass")),
      column(6, textInput("new_hyb_project_code", "Project Code"))
    ),
    fluidRow(
      column(6, textInput("new_hyb_seq_cro", "Seq CRO")),
      column(6, textInput("new_hyb_strain", "Strain"))
    ),
    fluidRow(
      column(6, textInput("new_hyb_cro_id", "CRO ID")),
      column(6, textInput("new_hyb_tissue", "Tissue"))
    ),
    textInput("new_hyb_eln", "ELN"),
    textAreaInput("new_hyb_note", "Note"),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("save_hybridoma_btn", "Save", class = "btn-primary")
    )
  )
}

delete_hybridoma_confirm_modal <- function(hybridoma_id) {
  hyb        <- get_hybridoma_by_id(hybridoma_id)
  components <- get_components_for_hybridoma(hybridoma_id)

  warning_text <- paste0("Delete ", hyb$clone_name, "? ")

  if (nrow(components) > 0) {
    warning_text <- paste0(warning_text, nrow(components),
      " component(s) will be unlinked from this hybridoma but kept: ",
      format_relationship_list(components$component_name), ". ")
  }

  warning_text <- paste0(warning_text, "This cannot be undone.")

  modalDialog(
    title = "Confirm Delete",
    warning_text,
    footer = tagList(
      modalButton("Cancel"),
      actionButton("confirm_delete_hybridoma_btn", "Delete", class = "btn-danger")
    )
  )
}