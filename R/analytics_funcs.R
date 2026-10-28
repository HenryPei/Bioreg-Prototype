# analytics_funcs.R
# protein_filter()                 NULL for "all", otherwise the protein id
# plot_concentration_trend()       batch concentration over time
# plot_purity_trend()              SEC purity over time
# plot_concentration_vs_purity()   concentration vs purity scatter
# plot_yield_distribution()        yield histogram
# plot_batch_count()               batches per protein
# plot_source_comparison()         internal vs CRO averages
# get_overview_stats()             summary stats and recent batches

protein_filter <- function(protein_id) {
  if (is.null(protein_id) || protein_id == "all") NA else protein_id
}

empty_plot <- function(msg) {
  plotly_empty() %>% layout(title = msg)
}

plot_concentration_trend <- function(protein_id = NULL) {
  data <- dbGetQuery(con,
    "SELECT pb.purification_date, pb.concentration, pb.unit,
            pb.batch_name, pb.sec_purity, pb.page_purity, p.protein_name
     FROM protein_batch pb
     JOIN protein p ON pb.protein_id = p.protein_id
     WHERE pb.concentration IS NOT NULL
       AND pb.purification_date IS NOT NULL
       AND ($1::text IS NULL OR pb.protein_id = $1)
     ORDER BY pb.purification_date",
    params = list(protein_filter(protein_id)))

  if (nrow(data) == 0) return(empty_plot("No batch data yet"))

  plot_ly(data,
    x = ~purification_date, y = ~concentration, color = ~protein_name,
    text = ~paste("Batch:", batch_name,
                  "<br>Concentration:", concentration, unit,
                  "<br>SEC Purity:", sec_purity,
                  "<br>PAGE Purity:", page_purity),
    hoverinfo = "text+x", type = "scatter", mode = "lines+markers"
  ) %>%
    layout(title = "Batch concentration over time",
           xaxis = list(title = "Purification date"),
           yaxis = list(title = "Concentration"))
}

plot_purity_trend <- function(protein_id = NULL) {
  data <- dbGetQuery(con,
    "SELECT pb.purification_date, pb.sec_purity, pb.batch_name, p.protein_name
     FROM protein_batch pb
     JOIN protein p ON pb.protein_id = p.protein_id
     WHERE pb.sec_purity IS NOT NULL
       AND pb.purification_date IS NOT NULL
       AND ($1::text IS NULL OR pb.protein_id = $1)
     ORDER BY pb.purification_date",
    params = list(protein_filter(protein_id)))

  if (nrow(data) == 0) return(empty_plot("No purity data yet"))

  plot_ly(data,
    x = ~purification_date, y = ~sec_purity, color = ~protein_name,
    text = ~paste("Batch:", batch_name, "<br>SEC Purity:", sec_purity, "%"),
    hoverinfo = "text+x", type = "scatter", mode = "lines+markers"
  ) %>%
    layout(title = "SEC purity over time",
           xaxis = list(title = "Purification date"),
           yaxis = list(title = "SEC Purity (%)", range = c(0, 100)))
}

plot_concentration_vs_purity <- function(protein_id = NULL) {
  data <- dbGetQuery(con,
    "SELECT pb.concentration, pb.sec_purity, pb.batch_name, pb.unit,
            p.protein_name, pb.source
     FROM protein_batch pb
     JOIN protein p ON pb.protein_id = p.protein_id
     WHERE pb.concentration IS NOT NULL
       AND pb.sec_purity IS NOT NULL
       AND ($1::text IS NULL OR pb.protein_id = $1)",
    params = list(protein_filter(protein_id)))

  if (nrow(data) == 0) return(empty_plot("No data yet"))

  plot_ly(data,
    x = ~concentration, y = ~sec_purity, color = ~protein_name, symbol = ~source,
    text = ~paste("Batch:", batch_name,
                  "<br>Concentration:", concentration, unit,
                  "<br>SEC Purity:", sec_purity, "%",
                  "<br>Source:", source),
    hoverinfo = "text", type = "scatter", mode = "markers",
    marker = list(size = 10)
  ) %>%
    layout(title = "Concentration vs purity",
           xaxis = list(title = "Concentration"),
           yaxis = list(title = "SEC Purity (%)"))
}

plot_yield_distribution <- function(protein_id = NULL) {
  data <- dbGetQuery(con,
    "SELECT pb.yield_mg, p.protein_name
     FROM protein_batch pb
     JOIN protein p ON pb.protein_id = p.protein_id
     WHERE pb.yield_mg IS NOT NULL
       AND ($1::text IS NULL OR pb.protein_id = $1)",
    params = list(protein_filter(protein_id)))

  if (nrow(data) == 0) return(empty_plot("No yield data yet"))

  plot_ly(data,
    x = ~yield_mg, color = ~protein_name,
    type = "histogram", nbinsx = 15, opacity = 0.7
  ) %>%
    layout(title = "Yield distribution across batches",
           xaxis = list(title = "Yield (mg)"),
           yaxis = list(title = "Count"),
           barmode = "overlay")
}

plot_batch_count <- function() {
  data <- dbGetQuery(con,
    "SELECT p.protein_name, COUNT(pb.primary_key) AS batch_count
     FROM protein p
     LEFT JOIN protein_batch pb ON p.protein_id = pb.protein_id
     GROUP BY p.protein_id, p.protein_name
     ORDER BY batch_count DESC")

  if (nrow(data) == 0) return(empty_plot("No proteins yet"))

  plot_ly(data,
    x = ~reorder(protein_name, -batch_count), y = ~batch_count,
    type = "bar", marker = list(color = "#1D9E75")
  ) %>%
    layout(title = "Batches per protein",
           xaxis = list(title = "Protein", tickangle = -45),
           yaxis = list(title = "Number of batches"))
}

plot_source_comparison <- function() {
  data <- dbGetQuery(con,
    "SELECT source,
            AVG(concentration) AS avg_concentration,
            AVG(sec_purity) AS avg_purity,
            COUNT(*) AS batch_count
     FROM protein_batch
     WHERE source IS NOT NULL
     GROUP BY source")

  if (nrow(data) == 0) return(empty_plot("No source data yet"))

  plot_ly(data,
    x = ~source, y = ~avg_concentration, type = "bar",
    name = "Avg concentration", marker = list(color = "#1D9E75")
  ) %>%
    add_trace(y = ~avg_purity, name = "Avg SEC purity %",
              marker = list(color = "#185FA5")) %>%
    layout(title = "Internal vs CRO batch performance",
           xaxis = list(title = "Source"),
           yaxis = list(title = "Value"),
           barmode = "group")
}

get_overview_stats <- function() {
  list(
    total_proteins    = dbGetQuery(con, "SELECT COUNT(*) FROM protein")[[1]],
    total_batches     = dbGetQuery(con, "SELECT COUNT(*) FROM protein_batch")[[1]],
    total_plasmids    = dbGetQuery(con, "SELECT COUNT(*) FROM plasmid")[[1]],
    total_cell_lines  = dbGetQuery(con, "SELECT COUNT(*) FROM cell_line")[[1]],
    avg_concentration = dbGetQuery(con,
      "SELECT ROUND(AVG(concentration), 2) FROM protein_batch")[[1]],
    avg_purity        = dbGetQuery(con,
      "SELECT ROUND(AVG(sec_purity), 2) FROM protein_batch")[[1]],
    recent_batches    = dbGetQuery(con,
      "SELECT pb.batch_name, p.protein_name, pb.concentration, pb.purification_date
       FROM protein_batch pb
       JOIN protein p ON pb.protein_id = p.protein_id
       ORDER BY pb.created_at DESC
       LIMIT 5")
  )
}