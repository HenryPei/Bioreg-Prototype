# utils.R
# format_relationship_list()      shorten a long list of names
# safe_db()                       run a db write, show errors instead of crashing
# selected_value()                get an id from the selected table row
# blank_to_na()                   turn empty inputs into NA
# form_value()                    a row's field as form text, "" if empty

format_relationship_list <- function(names, max_show = 5) {
  if (length(names) == 0) return("")
  if (length(names) <= max_show) {
    return(paste(names, collapse = ", "))
  }
  shown <- paste(names[1:max_show], collapse = ", ")
  remaining <- length(names) - max_show
  paste0(shown, ", and ", remaining, " more")
}

safe_db <- function(expr) {
  tryCatch({
    force(expr)
    TRUE
  }, error = function(e) {
    showNotification(paste("Database error:", conditionMessage(e)),
                     type = "error", duration = 8)
    FALSE
  })
}

selected_value <- function(data, rows, col) {
  if (length(rows)) data[[col]][rows] else NULL
}

blank_to_na <- function(x) {
  if (is.null(x) || length(x) == 0 || is.na(x) || trimws(x) == "") NA else x
}

form_value <- function(row, col) {
  if (is.null(row) || is.null(row[[col]] || is.na(row[[col]]))) "" else as.character(row[[col]])
}