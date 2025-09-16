#' Liste der verfuegbaren Zeitperioden fuer ein STATcube time_valueset
#'
#' @import STATcubeR
#'
#' @param time_valueset_id ID des time_valueset
#' @return data.frame mit Spalten: id, label, position, start, end (falls vorhanden)
#' @export
sc_list_time_periods <- function(time_valueset_id) {
  if (sc_key_exists() == FALSE) {
    stop("Error: STATcube-Schluessel festlegen mit 'sc_key_set()'.")
  }

  schema <- sc_schema_db(time_valueset_id)
  if (is.null(schema) || length(schema) == 0) {
    stop("Keine Zeitperioden im Schema gefunden.")
  }

  get_or_na <- function(x, nm) if (!is.null(x[[nm]])) x[[nm]] else NA

  rows <- lapply(schema, function(x) {
    if (!is.list(x)) {
      return(NULL)
    }
    list(
      id       = get_or_na(x, "id"),
      label    = get_or_na(x, "label"),
      position = get_or_na(x, "position"),
      start    = get_or_na(x, "start"),
      end      = get_or_na(x, "end")
    )
  })
  rows <- Filter(Negate(is.null), rows)
  df <- do.call(rbind.data.frame, c(rows, list(stringsAsFactors = FALSE)))

  # Sinnvolle Grundsortierung: wenn position vorhanden ist
  if (!all(is.na(df$position))) {
    df <- df[order(df$position, na.last = TRUE), , drop = FALSE]
  }

  rownames(df) <- NULL
  df
}
