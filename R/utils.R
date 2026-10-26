# utils.R
# ─────────────────────────────────────────────────────
# format_relationship_list() — caps a named list at N items, summarizes the rest

# ── Formatting helpers ────────────────────────────────
format_relationship_list <- function(names, max_show = 5) {
  if (length(names) == 0) return("")
  if (length(names) <= max_show) {
    return(paste(names, collapse = ", "))
  }
  shown <- paste(names[1:max_show], collapse = ", ")
  remaining <- length(names) - max_show
  paste0(shown, ", and ", remaining, " more")
}