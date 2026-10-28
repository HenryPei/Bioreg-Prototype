server <- function(input, output, session) {

  selected_protein   <- reactiveVal(NULL)
  selected_pb        <- reactiveVal(NULL)
  selected_plasmid   <- reactiveVal(NULL)
  selected_plb       <- reactiveVal(NULL)
  selected_component <- reactiveVal(NULL)
  selected_hybridoma <- reactiveVal(NULL)
  selected_cell_line <- reactiveVal(NULL)
  selected_cb        <- reactiveVal(NULL)

  refresh_trigger <- reactiveVal(0)
  refresh <- function() refresh_trigger(refresh_trigger() + 1)

  link_result <- function(rows, what) {
    if (rows == 0) {
      showNotification("Already linked", type = "warning")
    } else {
      showNotification(paste(what, "linked"), type = "message")
      removeModal()
      refresh()
    }
  }

  proteins_data   <- reactive({ refresh_trigger(); get_proteins() })
  plasmids_data   <- reactive({ refresh_trigger(); get_plasmids() })
  components_data <- reactive({ refresh_trigger(); get_components() })
  hybridomas_data <- reactive({ refresh_trigger(); get_hybridomas() })
  cell_lines_data <- reactive({ refresh_trigger(); get_cell_lines() })

  protein_batches_data  <- reactive({ refresh_trigger(); req(selected_protein()); get_protein_batches(selected_protein()) })
  protein_plasmids_data <- reactive({ refresh_trigger(); req(selected_protein()); get_plasmids_for_protein(selected_protein()) })

  plasmid_batches_data    <- reactive({ refresh_trigger(); req(selected_plasmid()); get_plasmid_batches(selected_plasmid()) })
  plasmid_proteins_data   <- reactive({ refresh_trigger(); req(selected_plasmid()); get_proteins_for_plasmid(selected_plasmid()) })
  plasmid_components_data <- reactive({ refresh_trigger(); req(selected_plasmid()); get_components_for_plasmid(selected_plasmid()) })
  plasmid_cell_lines_data <- reactive({ refresh_trigger(); req(selected_plasmid()); get_cell_lines_for_plasmid(selected_plasmid()) })

  component_plasmids_data   <- reactive({ refresh_trigger(); req(selected_component()); get_plasmids_for_component(selected_component()) })
  hybridoma_components_data <- reactive({ refresh_trigger(); req(selected_hybridoma()); get_components_for_hybridoma(selected_hybridoma()) })

  cell_batches_data       <- reactive({ refresh_trigger(); req(selected_cell_line()); get_cell_batches(selected_cell_line()) })
  cell_line_plasmids_data <- reactive({ refresh_trigger(); req(selected_cell_line()); get_plasmids_for_cell_line(selected_cell_line()) })

  output$proteins_table <- renderDT(proteins_data(), selection = "single", rownames = FALSE)

  observeEvent(input$proteins_table_rows_selected, {
    id <- selected_value(proteins_data(), input$proteins_table_rows_selected, "protein_id")
    if (!is.null(id)) {
      selected_protein(id)
      selected_pb(NULL)
    }
  })

  output$protein_detail <- renderUI({
    req(selected_protein())
    protein_detail_ui(selected_protein())
  })

  output$protein_batches_portal <- renderDT(protein_batches_data(), selection = "single", rownames = FALSE)

  observeEvent(input$protein_batches_portal_rows_selected, {
    id <- selected_value(protein_batches_data(), input$protein_batches_portal_rows_selected, "primary_key")
    if (!is.null(id)) selected_pb(id)
  })

  output$protein_batch_detail <- renderUI({
    req(selected_pb())
    protein_batch_detail_ui(selected_pb())
  })

  observeEvent(input$back_to_protein_btn, { selected_pb(NULL) })

  observeEvent(input$delete_protein_batch_btn, {
    req(selected_pb())
    showModal(delete_protein_batch_confirm_modal(selected_pb()))
  })

  observeEvent(input$confirm_delete_protein_batch_btn, {
    if (safe_db(delete_protein_batch(selected_pb()))) {
      showNotification("Batch deleted", type = "message")
      selected_pb(NULL)
      removeModal()
      refresh()
    }
  })

  output$protein_plasmids_portal <- renderDT(protein_plasmids_data(), selection = "single", rownames = FALSE)

  observeEvent(input$view_plasmid_btn, {
    id <- selected_value(protein_plasmids_data(), input$protein_plasmids_portal_rows_selected, "plasmid_id")
    if (is.null(id)) return(showNotification("Select a plasmid first", type = "warning"))
    selected_plasmid(id)
    updateNavbarPage(session, "navbar", selected = "Plasmids")
  })

  observeEvent(input$add_protein_btn, { showModal(add_protein_modal()) })

  observeEvent(input$save_protein_btn, {
    if (is.null(input$new_protein_name) || trimws(input$new_protein_name) == "") {
      return(showNotification("Protein name is required", type = "error"))
    }
    ok <- safe_db(insert_protein(
      protein_name   = input$new_protein_name,
      clone_id       = input$new_clone_id,
      type           = input$new_type,
      hc_type        = input$new_hc_type,
      lc_type        = input$new_lc_type,
      alias          = input$new_alias,
      project_code   = input$new_project_code,
      cro            = input$new_cro,
      cro_id         = input$new_cro_id,
      nbl_id         = input$new_nbl_id,
      reference_name = input$new_reference_name,
      vendor         = input$new_vendor,
      catalog_num    = input$new_catalog_num,
      dotmatics_id   = input$new_dotmatics_id,
      stoichiometry  = input$new_stoichiometry,
      pi             = input$new_pi,
      a280_1mgml     = input$new_a280,
      mw             = input$new_mw,
      source_cell    = input$new_source_cell,
      note           = input$new_protein_note,
      created_by     = "user"
    ))
    if (ok) { removeModal(); refresh() }
  })

  observeEvent(input$add_protein_batch_btn, { showModal(add_protein_batch_modal()) })

  observeEvent(input$save_protein_batch_btn, {
    req(selected_protein())
    if (is.null(input$new_pb_batch_name) || trimws(input$new_pb_batch_name) == "") {
      return(showNotification("Batch name is required", type = "error"))
    }
    if (!is.null(input$new_pb_concentration) &&
        !is.na(input$new_pb_concentration) && input$new_pb_concentration < 0) {
      return(showNotification("Concentration must be a positive number", type = "error"))
    }
    ok <- safe_db(insert_protein_batch(
      protein_id        = selected_protein(),
      batch_id          = input$new_pb_batch_id,
      batch_name        = input$new_pb_batch_name,
      concentration     = input$new_pb_concentration,
      unit              = input$new_pb_unit,
      yield_mg          = input$new_pb_yield,
      buffer_solution   = input$new_pb_buffer,
      source            = input$new_pb_source,
      storage           = input$new_pb_storage,
      room              = input$new_pb_room,
      storage_unit      = input$new_pb_storage_unit,
      shelf             = input$new_pb_shelf,
      rack              = input$new_pb_rack,
      box               = input$new_pb_box,
      purification_date = input$new_pb_purification_date,
      harvest_date      = input$new_pb_harvest_date,
      trxn_date         = input$new_pb_trxn_date,
      sec_purity        = input$new_pb_sec_purity,
      page_purity       = input$new_pb_page_purity,
      endotoxin_eu_mg   = input$new_pb_endotoxin,
      qc_eln            = input$new_pb_qc_eln,
      note              = input$new_pb_note,
      created_by        = "user"
    ))
    if (ok) { removeModal(); refresh() }
  })

  observeEvent(input$link_plasmid_btn, { showModal(link_plasmid_modal()) })

  observeEvent(input$save_plasmid_link_btn, {
    req(selected_protein())
    rows <- 0
    ok <- safe_db({
      plasmid <- get_plasmid_by_id(input$link_plasmid_id)
      protein <- get_protein_by_id(selected_protein())
      rows <- link_protein_plasmid(
        protein_id   = selected_protein(),
        plasmid_id   = input$link_plasmid_id,
        protein_name = protein$protein_name,
        plasmid_name = plasmid$plasmid_name,
        pnr_number   = plasmid$pnr,
        created_by   = "user"
      )
    })
    if (ok) link_result(rows, "Plasmid")
  })

  observeEvent(input$unlink_plasmid_btn, {
    req(selected_protein())
    id <- selected_value(protein_plasmids_data(), input$protein_plasmids_portal_rows_selected, "plasmid_id")
    if (is.null(id)) return(showNotification("Select a plasmid to unlink first", type = "warning"))
    if (safe_db(unlink_protein_plasmid(selected_protein(), id))) {
      showNotification("Plasmid unlinked", type = "message")
      refresh()
    }
  })

  observeEvent(input$delete_protein_btn, {
    req(selected_protein())
    showModal(delete_protein_confirm_modal(selected_protein()))
  })

  observeEvent(input$confirm_delete_protein_btn, {
    if (safe_db(delete_protein_cascade(selected_protein()))) {
      showNotification("Protein and its batches deleted", type = "message")
      selected_protein(NULL)
      removeModal()
      refresh()
    }
  })

  output$plasmids_table <- renderDT(plasmids_data(), selection = "single", rownames = FALSE)

  observeEvent(input$plasmids_table_rows_selected, {
    id <- selected_value(plasmids_data(), input$plasmids_table_rows_selected, "plasmid_id")
    if (!is.null(id)) {
      selected_plasmid(id)
      selected_plb(NULL)
    }
  })

  output$plasmid_detail <- renderUI({
    req(selected_plasmid())
    plasmid_detail_ui(selected_plasmid())
  })

  output$plasmid_batches_portal <- renderDT(plasmid_batches_data(), selection = "single", rownames = FALSE)

  observeEvent(input$plasmid_batches_portal_rows_selected, {
    id <- selected_value(plasmid_batches_data(), input$plasmid_batches_portal_rows_selected, "primary_key")
    if (!is.null(id)) selected_plb(id)
  })

  output$plasmid_batch_detail <- renderUI({
    req(selected_plb())
    plasmid_batch_detail_ui(selected_plb())
  })

  observeEvent(input$back_to_plasmid_btn, { selected_plb(NULL) })

  observeEvent(input$delete_plasmid_batch_btn, {
    req(selected_plb())
    showModal(delete_plasmid_batch_confirm_modal(selected_plb()))
  })

  observeEvent(input$confirm_delete_plasmid_batch_btn, {
    if (safe_db(delete_plasmid_batch(selected_plb()))) {
      showNotification("Batch deleted", type = "message")
      selected_plb(NULL)
      removeModal()
      refresh()
    }
  })

  output$plasmid_proteins_portal <- renderDT(plasmid_proteins_data(), selection = "single", rownames = FALSE)

  observeEvent(input$view_protein_btn, {
    id <- selected_value(plasmid_proteins_data(), input$plasmid_proteins_portal_rows_selected, "protein_id")
    if (is.null(id)) return(showNotification("Select a protein first", type = "warning"))
    selected_protein(id)
    updateNavbarPage(session, "navbar", selected = "Proteins")
  })

  observeEvent(input$link_protein_to_plasmid_btn, { showModal(link_protein_modal()) })

  observeEvent(input$save_protein_link_btn, {
    req(selected_plasmid())
    rows <- 0
    ok <- safe_db({
      protein <- get_protein_by_id(input$link_protein_id)
      plasmid <- get_plasmid_by_id(selected_plasmid())
      rows <- link_protein_plasmid(
        protein_id   = input$link_protein_id,
        plasmid_id   = selected_plasmid(),
        protein_name = protein$protein_name,
        plasmid_name = plasmid$plasmid_name,
        pnr_number   = plasmid$pnr,
        created_by   = "user"
      )
    })
    if (ok) link_result(rows, "Protein")
  })

  observeEvent(input$unlink_protein_from_plasmid_btn, {
    req(selected_plasmid())
    id <- selected_value(plasmid_proteins_data(), input$plasmid_proteins_portal_rows_selected, "protein_id")
    if (is.null(id)) return(showNotification("Select a protein to unlink first", type = "warning"))
    if (safe_db(unlink_protein_plasmid(id, selected_plasmid()))) {
      showNotification("Protein unlinked", type = "message")
      refresh()
    }
  })

  output$plasmid_components_portal <- renderDT(plasmid_components_data(), selection = "single", rownames = FALSE)

  observeEvent(input$view_component_btn, {
    id <- selected_value(plasmid_components_data(), input$plasmid_components_portal_rows_selected, "component_id")
    if (is.null(id)) return(showNotification("Select a component first", type = "warning"))
    selected_component(id)
    updateNavbarPage(session, "navbar", selected = "Components")
  })

  observeEvent(input$link_component_btn, { showModal(link_component_modal()) })

  observeEvent(input$save_component_link_btn, {
    req(selected_plasmid())
    rows <- 0
    ok <- safe_db({
      component <- get_component_by_id(input$link_component_id)
      plasmid   <- get_plasmid_by_id(selected_plasmid())
      rows <- link_component_plasmid(
        component_id   = input$link_component_id,
        plasmid_id     = selected_plasmid(),
        component_name = component$component_name,
        plasmid_name   = plasmid$plasmid_name,
        pnr            = plasmid$pnr,
        created_by     = "user"
      )
    })
    if (ok) link_result(rows, "Component")
  })

  observeEvent(input$unlink_component_btn, {
    req(selected_plasmid())
    id <- selected_value(plasmid_components_data(), input$plasmid_components_portal_rows_selected, "component_id")
    if (is.null(id)) return(showNotification("Select a component to unlink first", type = "warning"))
    if (safe_db(unlink_component_plasmid(id, selected_plasmid()))) {
      showNotification("Component unlinked", type = "message")
      refresh()
    }
  })

  output$plasmid_cell_lines_portal <- renderDT(plasmid_cell_lines_data(), selection = "single", rownames = FALSE)

  observeEvent(input$view_cell_line_btn, {
    id <- selected_value(plasmid_cell_lines_data(), input$plasmid_cell_lines_portal_rows_selected, "cell_line_id")
    if (is.null(id)) return(showNotification("Select a cell line first", type = "warning"))
    selected_cell_line(id)
    updateNavbarPage(session, "navbar", selected = "Cell Lines")
  })

  observeEvent(input$link_cell_line_btn, { showModal(link_cell_line_modal()) })

  observeEvent(input$save_cell_line_link_btn, {
    req(selected_plasmid())
    rows <- 0
    ok <- safe_db({
      cl      <- get_cell_line_by_id(input$link_cell_line_id)
      plasmid <- get_plasmid_by_id(selected_plasmid())
      rows <- link_cell_line_plasmid(
        cell_line_id   = input$link_cell_line_id,
        plasmid_id     = selected_plasmid(),
        cell_line_name = cl$cell_line_name,
        plasmid_name   = plasmid$plasmid_name,
        created_by     = "user"
      )
    })
    if (ok) link_result(rows, "Cell line")
  })

  observeEvent(input$unlink_cell_line_btn, {
    req(selected_plasmid())
    id <- selected_value(plasmid_cell_lines_data(), input$plasmid_cell_lines_portal_rows_selected, "cell_line_id")
    if (is.null(id)) return(showNotification("Select a cell line to unlink first", type = "warning"))
    if (safe_db(unlink_cell_line_plasmid(id, selected_plasmid()))) {
      showNotification("Cell line unlinked", type = "message")
      refresh()
    }
  })

  observeEvent(input$add_plasmid_btn, { showModal(add_plasmid_modal()) })

  observeEvent(input$save_plasmid_btn, {
    if (is.null(input$new_plasmid_name) || trimws(input$new_plasmid_name) == "") {
      return(showNotification("Plasmid name is required", type = "error"))
    }
    ok <- safe_db(insert_plasmid(
      plasmid_name   = input$new_plasmid_name,
      type           = input$new_plasmid_type,
      vector         = input$new_vector,
      insert_seq     = input$new_insert_seq,
      parent_vector  = input$new_parent_vector,
      alias          = input$new_plasmid_alias,
      pnr            = input$new_pnr,
      project_code   = input$new_plasmid_project_code,
      selection      = input$new_selection,
      antibiotic     = input$new_antibiotic,
      orf1           = input$new_orf1,
      orf2           = input$new_orf2,
      vector_source  = input$new_vector_source,
      catalog_number = input$new_catalog_number,
      cro            = input$new_plasmid_cro,
      cro2           = NULL,
      gf1            = NULL,
      gf2            = NULL,
      n_tag          = input$new_n_tag,
      c_tag          = input$new_c_tag,
      eln_number     = input$new_plasmid_eln,
      storage_room   = input$new_storage_room,
      storage_unit   = input$new_plasmid_storage_unit,
      shelf          = input$new_plasmid_shelf,
      rack           = input$new_plasmid_rack,
      storage_box    = input$new_plasmid_box,
      box_coordinate = input$new_box_coordinate,
      note           = input$new_plasmid_note,
      created_by     = "user"
    ))
    if (ok) { removeModal(); refresh() }
  })

  observeEvent(input$add_plasmid_batch_btn, { showModal(add_plasmid_batch_modal()) })

  observeEvent(input$save_plasmid_batch_btn, {
    req(selected_plasmid())
    if (is.null(input$new_plb_batch_name) || trimws(input$new_plb_batch_name) == "") {
      return(showNotification("Batch name is required", type = "error"))
    }
    if (!is.null(input$new_plb_concentration) &&
        !is.na(input$new_plb_concentration) && input$new_plb_concentration < 0) {
      return(showNotification("Concentration must be a positive number", type = "error"))
    }
    ok <- safe_db(insert_plasmid_batch(
      plasmid_id         = selected_plasmid(),
      batch_id           = input$new_plb_batch_id,
      batch_name         = input$new_plb_batch_name,
      concentration      = input$new_plb_concentration,
      unit               = input$new_plb_unit,
      yield_ug           = input$new_plb_yield,
      buffer_solution    = input$new_plb_buffer,
      source             = NULL,
      storage            = NULL,
      room               = input$new_plb_room,
      storage_unit       = input$new_plb_storage_unit,
      shelf              = input$new_plb_shelf,
      rack               = input$new_plb_rack,
      storage_box        = NULL,
      production_date    = input$new_plb_production_date,
      a260_to_280        = input$new_plb_a260_280,
      a260_to_230        = input$new_plb_a260_230,
      endotoxin          = input$new_plb_endotoxin,
      cro                = input$new_plb_cro,
      cro_id             = input$new_plb_cro_id,
      prep               = input$new_plb_prep,
      seq_confirm        = input$new_plb_seq_confirm,
      vol_ml             = input$new_plb_vol_ml,
      initial_vol_ul     = input$new_plb_initial_vol,
      starting_inventory = NULL,
      current_inventory  = NULL,
      tube_volumes       = NULL,
      confirmed_by       = input$new_plb_confirmed_by,
      qc_eln             = NULL,
      note               = input$new_plb_note,
      created_by         = "user"
    ))
    if (ok) { removeModal(); refresh() }
  })

  observeEvent(input$delete_plasmid_btn, {
    req(selected_plasmid())
    showModal(delete_plasmid_confirm_modal(selected_plasmid()))
  })

  observeEvent(input$confirm_delete_plasmid_btn, {
    if (safe_db(delete_plasmid_cascade(selected_plasmid()))) {
      showNotification("Plasmid and its batches deleted", type = "message")
      selected_plasmid(NULL)
      removeModal()
      refresh()
    }
  })

  output$components_table <- renderDT(components_data(), selection = "single", rownames = FALSE)

  observeEvent(input$components_table_rows_selected, {
    id <- selected_value(components_data(), input$components_table_rows_selected, "component_id")
    if (!is.null(id)) selected_component(id)
  })

  selected_component_row <- reactive({
    req(selected_component())
    get_component_by_id(selected_component())
  })

  output$component_detail <- renderUI({
    req(selected_component())
    component_detail_ui(selected_component())
  })

  output$comp_aa_seq   <- renderText(selected_component_row()$aa_sequence)
  output$comp_cdna_seq <- renderText(selected_component_row()$cdna_sequence)

  output$component_plasmids_portal <- renderDT(component_plasmids_data(), selection = "single", rownames = FALSE)

  observeEvent(input$view_plasmid_from_component_btn, {
    id <- selected_value(component_plasmids_data(), input$component_plasmids_portal_rows_selected, "plasmid_id")
    if (is.null(id)) return(showNotification("Select a plasmid first", type = "warning"))
    selected_plasmid(id)
    updateNavbarPage(session, "navbar", selected = "Plasmids")
  })

  observeEvent(input$add_component_btn, { showModal(add_component_modal()) })

  observeEvent(input$save_component_btn, {
    if (is.null(input$new_comp_name) || trimws(input$new_comp_name) == "") {
      return(showNotification("Component name is required", type = "error"))
    }
    ok <- safe_db(insert_component(
      component_name = input$new_comp_name,
      type           = input$new_comp_type,
      species        = input$new_comp_species,
      subclass       = input$new_comp_subclass,
      hybridoma_id   = input$new_comp_hybridoma_id,
      aa_sequence    = input$new_comp_aa_seq,
      cdna_sequence  = input$new_comp_cdna_seq,
      mutation       = input$new_comp_mutation,
      uniprot        = input$new_comp_uniprot,
      parent         = input$new_comp_parent,
      vendor         = input$new_comp_vendor,
      project_code   = input$new_comp_project_code,
      germline       = input$new_comp_germline,
      expression     = input$new_comp_expression,
      seq_method     = input$new_comp_seq_method,
      note           = input$new_comp_note,
      created_by     = "user"
    ))
    if (ok) { removeModal(); refresh() }
  })

  observeEvent(input$delete_component_btn, {
    req(selected_component())
    showModal(delete_component_confirm_modal(selected_component()))
  })

  observeEvent(input$confirm_delete_component_btn, {
    if (safe_db(delete_component_cascade(selected_component()))) {
      showNotification("Component deleted", type = "message")
      selected_component(NULL)
      removeModal()
      refresh()
    }
  })

  output$hybridomas_table <- renderDT(hybridomas_data(), selection = "single", rownames = FALSE)

  observeEvent(input$hybridomas_table_rows_selected, {
    id <- selected_value(hybridomas_data(), input$hybridomas_table_rows_selected, "hybridoma_id")
    if (!is.null(id)) selected_hybridoma(id)
  })

  output$hybridoma_detail <- renderUI({
    req(selected_hybridoma())
    hybridoma_detail_ui(selected_hybridoma())
  })

  output$hybridoma_components_portal <- renderDT(hybridoma_components_data(), selection = "single", rownames = FALSE)

  observeEvent(input$view_component_from_hybridoma_btn, {
    id <- selected_value(hybridoma_components_data(), input$hybridoma_components_portal_rows_selected, "component_id")
    if (is.null(id)) return(showNotification("Select a component first", type = "warning"))
    selected_component(id)
    updateNavbarPage(session, "navbar", selected = "Components")
  })

  observeEvent(input$add_hybridoma_btn, { showModal(add_hybridoma_modal()) })

  observeEvent(input$save_hybridoma_btn, {
    if (is.null(input$new_hyb_clone_name) || trimws(input$new_hyb_clone_name) == "") {
      return(showNotification("Clone name is required", type = "error"))
    }
    ok <- safe_db(insert_hybridoma(
      clone_name           = input$new_hyb_clone_name,
      mouse_igg_subclass   = input$new_hyb_subclass,
      light_chain_subclass = input$new_hyb_lc_subclass,
      project_code         = input$new_hyb_project_code,
      seq_cro              = input$new_hyb_seq_cro,
      strain               = input$new_hyb_strain,
      cro_id               = input$new_hyb_cro_id,
      tissue               = input$new_hyb_tissue,
      eln                  = input$new_hyb_eln,
      note                 = input$new_hyb_note,
      created_by           = "user"
    ))
    if (ok) { removeModal(); refresh() }
  })

  observeEvent(input$delete_hybridoma_btn, {
    req(selected_hybridoma())
    showModal(delete_hybridoma_confirm_modal(selected_hybridoma()))
  })

  observeEvent(input$confirm_delete_hybridoma_btn, {
    if (safe_db(delete_hybridoma(selected_hybridoma()))) {
      showNotification("Hybridoma deleted", type = "message")
      selected_hybridoma(NULL)
      removeModal()
      refresh()
    }
  })

  output$cell_lines_table <- renderDT(cell_lines_data(), selection = "single", rownames = FALSE)

  observeEvent(input$cell_lines_table_rows_selected, {
    id <- selected_value(cell_lines_data(), input$cell_lines_table_rows_selected, "cell_line_id")
    if (!is.null(id)) {
      selected_cell_line(id)
      selected_cb(NULL)
    }
  })

  output$cell_line_detail <- renderUI({
    req(selected_cell_line())
    cell_line_detail_ui(selected_cell_line())
  })

  output$cell_batches_portal <- renderDT(cell_batches_data(), selection = "single", rownames = FALSE)

  observeEvent(input$cell_batches_portal_rows_selected, {
    id <- selected_value(cell_batches_data(), input$cell_batches_portal_rows_selected, "primary_key")
    if (!is.null(id)) selected_cb(id)
  })

  output$cell_batch_detail <- renderUI({
    req(selected_cb())
    cell_batch_detail_ui(selected_cb())
  })

  observeEvent(input$back_to_cell_line_btn, { selected_cb(NULL) })

  observeEvent(input$delete_cell_batch_btn, {
    req(selected_cb())
    showModal(delete_cell_batch_confirm_modal(selected_cb()))
  })

  observeEvent(input$confirm_delete_cell_batch_btn, {
    if (safe_db(delete_cell_batch(selected_cb()))) {
      showNotification("Batch deleted", type = "message")
      selected_cb(NULL)
      removeModal()
      refresh()
    }
  })

  output$cell_line_plasmids_portal <- renderDT(cell_line_plasmids_data(), selection = "single", rownames = FALSE)

  observeEvent(input$view_plasmid_from_cell_line_btn, {
    id <- selected_value(cell_line_plasmids_data(), input$cell_line_plasmids_portal_rows_selected, "plasmid_id")
    if (is.null(id)) return(showNotification("Select a plasmid first", type = "warning"))
    selected_plasmid(id)
    updateNavbarPage(session, "navbar", selected = "Plasmids")
  })

  observeEvent(input$unlink_plasmid_from_cell_line_btn, {
    req(selected_cell_line())
    id <- selected_value(cell_line_plasmids_data(), input$cell_line_plasmids_portal_rows_selected, "plasmid_id")
    if (is.null(id)) return(showNotification("Select a plasmid to unlink first", type = "warning"))
    if (safe_db(unlink_cell_line_plasmid(selected_cell_line(), id))) {
      showNotification("Plasmid unlinked", type = "message")
      refresh()
    }
  })

  observeEvent(input$add_cell_line_btn, { showModal(add_cell_line_modal()) })

  observeEvent(input$save_cell_line_btn, {
    if (is.null(input$new_cl_name) || trimws(input$new_cl_name) == "") {
      return(showNotification("Cell line name is required", type = "error"))
    }
    ok <- safe_db(insert_cell_line(
      cell_line_name     = input$new_cl_name,
      expressed_orf      = input$new_cl_expressed_orf,
      cell_type          = input$new_cl_cell_type,
      organism           = input$new_cl_organism,
      parental_cell      = input$new_cl_parental,
      vendor             = input$new_cl_vendor,
      catalog_num        = input$new_cl_catalog_num,
      purchase_date      = input$new_cl_purchase_date,
      growth_media       = input$new_cl_growth_media,
      freezing_media     = input$new_cl_freezing_media,
      base_cell_line     = input$new_cl_base_cell_line,
      orf_species        = NULL,
      project_code       = input$new_cl_project_code,
      base_cell          = NULL,
      tissue_of_origin   = input$new_cl_tissue_of_origin,
      morphology         = input$new_cl_morphology,
      culture_properties = NULL,
      weblink            = NULL,
      alias              = input$new_cl_alias,
      reporter           = input$new_cl_reporter,
      knock_out          = input$new_cl_knock_out,
      knock_in           = input$new_cl_knock_in,
      shrna              = input$new_cl_shrna,
      dotmatics_id       = input$new_cl_dotmatics_id,
      clone_name         = NULL,
      eln                = input$new_cl_eln,
      note               = input$new_cl_note,
      created_by         = "user"
    ))
    if (ok) { removeModal(); refresh() }
  })

  observeEvent(input$add_cell_batch_btn, { showModal(add_cell_batch_modal()) })

  observeEvent(input$save_cell_batch_btn, {
    req(selected_cell_line())
    if (is.null(input$new_cb_batch_id) || trimws(input$new_cb_batch_id) == "") {
      return(showNotification("Batch ID is required", type = "error"))
    }
    if (!is.null(input$new_cb_vials) &&
        !is.na(input$new_cb_vials) && input$new_cb_vials < 0) {
      return(showNotification("Vials must be a positive number", type = "error"))
    }
    ok <- safe_db(insert_cell_batch(
      cell_line_id = selected_cell_line(),
      batch_id     = input$new_cb_batch_id,
      date         = input$new_cb_date,
      cell_density = input$new_cb_cell_density,
      vials        = input$new_cb_vials,
      room         = input$new_cb_room,
      storage_unit = input$new_cb_storage_unit,
      tower        = input$new_cb_tower,
      storage_box  = input$new_cb_storage_box,
      passage_num  = input$new_cb_passage_num,
      created_by   = "user"
    ))
    if (ok) { removeModal(); refresh() }
  })

  observeEvent(input$delete_cell_line_btn, {
    req(selected_cell_line())
    showModal(delete_cell_line_confirm_modal(selected_cell_line()))
  })

  observeEvent(input$confirm_delete_cell_line_btn, {
    if (safe_db(delete_cell_line_cascade(selected_cell_line()))) {
      showNotification("Cell line and its batches deleted", type = "message")
      selected_cell_line(NULL)
      removeModal()
      refresh()
    }
  })

  active_chart <- reactiveVal("concentration_trend")

  observe({
    proteins <- proteins_data()
    updateSelectInput(session, "analytics_protein_filter",
      choices = c("All" = "all", setNames(proteins$protein_id, proteins$protein_name)))
  })

  observeEvent(input$show_conc_trend,   { active_chart("concentration_trend") })
  observeEvent(input$show_purity_trend, { active_chart("purity_trend") })
  observeEvent(input$show_conc_purity,  { active_chart("conc_vs_purity") })
  observeEvent(input$show_yield_dist,   { active_chart("yield_distribution") })

  output$analytics_plot <- renderPlotly({
    refresh_trigger()
    pid <- input$analytics_protein_filter
    switch(active_chart(),
      "concentration_trend" = plot_concentration_trend(pid),
      "purity_trend"        = plot_purity_trend(pid),
      "conc_vs_purity"      = plot_concentration_vs_purity(pid),
      "yield_distribution"  = plot_yield_distribution(pid)
    )
  })

  stats <- reactive({ refresh_trigger(); get_overview_stats() })

  output$stat_proteins   <- renderText(stats()$total_proteins)
  output$stat_batches    <- renderText(stats()$total_batches)
  output$stat_avg_conc   <- renderText(paste(stats()$avg_concentration, "mg/mL"))
  output$stat_avg_purity <- renderText(paste(stats()$avg_purity, "%"))

  output$plot_batch_count       <- renderPlotly({ refresh_trigger(); plot_batch_count() })
  output$plot_source_comparison <- renderPlotly({ refresh_trigger(); plot_source_comparison() })

  output$recent_batches_table <- renderDT(stats()$recent_batches, rownames = FALSE, options = list(dom = "t"))
}