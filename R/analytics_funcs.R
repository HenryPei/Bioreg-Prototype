# analytics.R
# ─────────────────────────────────────────────────────
# plot_concentration_trend()    — batch concentration over time, optional protein filter
# plot_purity_trend()           — SEC purity over time, optional protein filter
# plot_concentration_vs_purity() — scatter of concentration vs purity, optional protein filter
# plot_yield_distribution()     — histogram of yield across batches, optional protein filter
# plot_batch_count()            — bar chart of batches per protein
# plot_source_comparison()      — internal vs CRO average concentration and purity
# get_overview_stats()          — VP overview summary stats and recent batches

# ── Concentration over time per protein ───────────────
plot_concentration_trend <- function(protein_id = NULL) {
  tryCatch({
    if (!is.null(protein_id) && protein_id != "all") {
      data <- dbGetQuery(con,
        "SELECT pb.purification_date, pb.concentration, pb.unit,
                pb.batch_name, pb.sec_purity, pb.page_purity,
                p.protein_name, p.protein_id
         FROM protein_batch pb
         JOIN protein p ON pb.protein_id = p.protein_id
         WHERE pb.concentration IS NOT NULL
         AND pb.purification_date IS NOT NULL
         AND pb.protein_id = $1
         ORDER BY pb.purification_date",
        params = list(protein_id))
    } else {
      data <- dbGetQuery(con,
        "SELECT pb.purification_date, pb.concentration, pb.unit,
                pb.batch_name, pb.sec_purity, pb.page_purity,
                p.protein_name, p.protein_id
         FROM protein_batch pb
         JOIN protein p ON pb.protein_id = p.protein_id
         WHERE pb.concentration IS NOT NULL
         AND pb.purification_date IS NOT NULL
         ORDER BY pb.purification_date")
    }

    if (nrow(data) == 0) {
      return(plotly_empty() %>% layout(title = "No batch data yet"))
    }

    plot_ly(data,
      x = ~purification_date,
      y = ~concentration,
      color = ~protein_name,
      text = ~paste("Batch:", batch_name,
                    "<br>Concentration:", concentration, unit,
                    "<br>SEC Purity:", sec_purity,
                    "<br>PAGE Purity:", page_purity),
      hoverinfo = "text+x",
      type = "scatter",
      mode = "lines+markers"
    ) %>%
      layout(
        title = "Batch concentration over time",
        xaxis = list(title = "Purification date"),
        yaxis = list(title = "Concentration (mg/mL)")
      )
  }, error = function(e) {
    plotly_empty() %>% layout(title = paste("Error loading chart:", e$message))
  })
}

# ── Purity over time ──────────────────────────────────
plot_purity_trend <- function(protein_id = NULL) {
  tryCatch({
    if (!is.null(protein_id) && protein_id != "all") {
      data <- dbGetQuery(con,
        "SELECT pb.purification_date,
                CAST(pb.sec_purity AS NUMERIC) as sec_purity,
                pb.batch_name, p.protein_name
         FROM protein_batch pb
         JOIN protein p ON pb.protein_id = p.protein_id
         WHERE pb.sec_purity IS NOT NULL
         AND pb.purification_date IS NOT NULL
         AND pb.protein_id = $1
         ORDER BY pb.purification_date",
        params = list(protein_id))
    } else {
      data <- dbGetQuery(con,
        "SELECT pb.purification_date,
                CAST(pb.sec_purity AS NUMERIC) as sec_purity,
                pb.batch_name, p.protein_name
         FROM protein_batch pb
         JOIN protein p ON pb.protein_id = p.protein_id
         WHERE pb.sec_purity IS NOT NULL
         AND pb.purification_date IS NOT NULL
         ORDER BY pb.purification_date")
    }

    if (nrow(data) == 0) {
      return(plotly_empty() %>% layout(title = "No purity data yet"))
    }

    plot_ly(data,
      x = ~purification_date,
      y = ~sec_purity,
      color = ~protein_name,
      text = ~paste("Batch:", batch_name,
                    "<br>SEC Purity:", sec_purity, "%"),
      hoverinfo = "text+x",
      type = "scatter",
      mode = "lines+markers"
    ) %>%
      layout(
        title = "SEC purity over time",
        xaxis = list(title = "Purification date"),
        yaxis = list(title = "SEC Purity (%)", range = c(0, 100))
      )
  }, error = function(e) {
    plotly_empty() %>% layout(title = paste("Error loading chart:", e$message))
  })
}

# ── Concentration vs purity scatter ───────────────────
plot_concentration_vs_purity <- function(protein_id = NULL) {
  tryCatch({
    if (!is.null(protein_id) && protein_id != "all") {
      data <- dbGetQuery(con,
        "SELECT pb.concentration,
                CAST(pb.sec_purity AS NUMERIC) as sec_purity,
                pb.batch_name, pb.unit, p.protein_name,
                pb.source
         FROM protein_batch pb
         JOIN protein p ON pb.protein_id = p.protein_id
         WHERE pb.concentration IS NOT NULL
         AND pb.sec_purity IS NOT NULL
         AND pb.protein_id = $1",
        params = list(protein_id))
    } else {
      data <- dbGetQuery(con,
        "SELECT pb.concentration,
                CAST(pb.sec_purity AS NUMERIC) as sec_purity,
                pb.batch_name, pb.unit, p.protein_name,
                pb.source
         FROM protein_batch pb
         JOIN protein p ON pb.protein_id = p.protein_id
         WHERE pb.concentration IS NOT NULL
         AND pb.sec_purity IS NOT NULL")
    }

    if (nrow(data) == 0) {
      return(plotly_empty() %>% layout(title = "No data yet"))
    }

    plot_ly(data,
      x = ~concentration,
      y = ~sec_purity,
      color = ~protein_name,
      symbol = ~source,
      text = ~paste("Batch:", batch_name,
                    "<br>Concentration:", concentration, unit,
                    "<br>SEC Purity:", sec_purity, "%",
                    "<br>Source:", source),
      hoverinfo = "text",
      type = "scatter",
      mode = "markers",
      marker = list(size = 10)
    ) %>%
      layout(
        title = "Concentration vs purity",
        xaxis = list(title = "Concentration (mg/mL)"),
        yaxis = list(title = "SEC Purity (%)")
      )
  }, error = function(e) {
    plotly_empty() %>% layout(title = paste("Error loading chart:", e$message))
  })
}

# ── Yield distribution ────────────────────────────────
plot_yield_distribution <- function(protein_id = NULL) {
  tryCatch({
    if (!is.null(protein_id) && protein_id != "all") {
      data <- dbGetQuery(con,
        "SELECT pb.yield_mg, p.protein_name, pb.source
         FROM protein_batch pb
         JOIN protein p ON pb.protein_id = p.protein_id
         WHERE pb.yield_mg IS NOT NULL
         AND pb.protein_id = $1",
        params = list(protein_id))
    } else {
      data <- dbGetQuery(con,
        "SELECT pb.yield_mg, p.protein_name, pb.source
         FROM protein_batch pb
         JOIN protein p ON pb.protein_id = p.protein_id
         WHERE pb.yield_mg IS NOT NULL")
    }

    if (nrow(data) == 0) {
      return(plotly_empty() %>% layout(title = "No yield data yet"))
    }

    data$yield_mg_num <- suppressWarnings(as.numeric(data$yield_mg))
    data <- data[!is.na(data$yield_mg_num), ]

    plot_ly(data,
      x = ~yield_mg_num,
      color = ~protein_name,
      type = "histogram",
      nbinsx = 15,
      opacity = 0.7
    ) %>%
      layout(
        title = "Yield distribution across batches",
        xaxis = list(title = "Yield (mg)"),
        yaxis = list(title = "Count"),
        barmode = "overlay"
      )
  }, error = function(e) {
    plotly_empty() %>% layout(title = paste("Error loading chart:", e$message))
  })
}

# ── Batch count per protein ───────────────────────────
plot_batch_count <- function() {
  tryCatch({
    data <- dbGetQuery(con,
      "SELECT p.protein_name, COUNT(pb.primary_key) as batch_count,
              p.protein_id
       FROM protein p
       LEFT JOIN protein_batch pb ON p.protein_id = pb.protein_id
       GROUP BY p.protein_id, p.protein_name
       ORDER BY batch_count DESC")

    if (nrow(data) == 0) {
      return(plotly_empty() %>% layout(title = "No proteins yet"))
    }

    plot_ly(data,
      x = ~reorder(protein_name, -batch_count),
      y = ~batch_count,
      type = "bar",
      marker = list(color = "#1D9E75")
    ) %>%
      layout(
        title = "Batches per protein",
        xaxis = list(title = "Protein", tickangle = -45),
        yaxis = list(title = "Number of batches")
      )
  }, error = function(e) {
    plotly_empty() %>% layout(title = paste("Error loading chart:", e$message))
  })
}

# ── Internal vs CRO comparison ────────────────────────
plot_source_comparison <- function() {
  tryCatch({
    data <- dbGetQuery(con,
      "SELECT pb.source,
              AVG(pb.concentration) as avg_concentration,
              AVG(CAST(pb.sec_purity AS NUMERIC)) as avg_purity,
              COUNT(*) as batch_count
       FROM protein_batch pb
       WHERE pb.source IS NOT NULL
       GROUP BY pb.source")

    if (nrow(data) == 0) {
      return(plotly_empty() %>% layout(title = "No source data yet"))
    }

    plot_ly(data,
      x = ~source,
      y = ~avg_concentration,
      type = "bar",
      name = "Avg concentration",
      marker = list(color = "#1D9E75")
    ) %>%
      add_trace(
        y = ~avg_purity,
        name = "Avg SEC purity %",
        marker = list(color = "#185FA5")
      ) %>%
      layout(
        title = "Internal vs CRO batch performance",
        xaxis = list(title = "Source"),
        yaxis = list(title = "Value"),
        barmode = "group"
      )
  }, error = function(e) {
    plotly_empty() %>% layout(title = paste("Error loading chart:", e$message))
  })
}

# ── VP overview summary stats ─────────────────────────
get_overview_stats <- function() {
  tryCatch({
    list(
      total_proteins  = dbGetQuery(con,
        "SELECT COUNT(*) FROM protein")[[1]],
      total_batches   = dbGetQuery(con,
        "SELECT COUNT(*) FROM protein_batch")[[1]],
      total_plasmids  = dbGetQuery(con,
        "SELECT COUNT(*) FROM plasmid")[[1]],
      total_cell_lines = dbGetQuery(con,
        "SELECT COUNT(*) FROM cell_line")[[1]],
      avg_concentration = dbGetQuery(con,
        "SELECT ROUND(AVG(concentration)::NUMERIC, 2)
         FROM protein_batch
         WHERE concentration IS NOT NULL")[[1]],
      avg_purity = dbGetQuery(con,
        "SELECT ROUND(AVG(CAST(sec_purity AS NUMERIC))::NUMERIC, 2)
         FROM protein_batch
         WHERE sec_purity IS NOT NULL AND sec_purity != ''")[[1]],
      recent_batches = dbGetQuery(con,
        "SELECT pb.batch_name, p.protein_name, pb.concentration,
                pb.purification_date
         FROM protein_batch pb
         JOIN protein p ON pb.protein_id = p.protein_id
         ORDER BY pb.created_at DESC
         LIMIT 5")
    )
  }, error = function(e) {
    list(
      total_proteins = 0, total_batches = 0, total_plasmids = 0,
      total_cell_lines = 0, avg_concentration = 0, avg_purity = 0,
      recent_batches = data.frame()
    )
  })
}