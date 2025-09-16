#' Update der JSON-Datei fuer eine STATcube-Abfrage mit aktuellsten Daten
#'
#' @import STATcubeR
#' @import jsonlite
#' @import tools
#'
#' @param json_path Pfad der originalen JSON-Datei
#' @param time_valueset_id ID des time_valueset
#' @param time_field_id ID des time_field
#' @param new_file Neue JSON-Datei erstellen oder alte ueberschreiben
#' @param from_id (Optional) ID der Zeitperiode, ab der alle folgenden Perioden uebernommen werden (inklusive).
#'   Empfohlen: zuerst \code{sc_list_time_periods()} verwenden und daraus eine ID waehlen.
#' @param latest_n (Optional) nur die letzten n Zeitperioden behalten (nachdem \code{from_id} angewendet wurde)
#'
#' @return Pfad der neuen JSON-Datei falls new_file = TRUE, sonst NULL (invisible)
#' @export
sc_update_json_abfrage <- function(json_path,
                                   time_valueset_id,
                                   time_field_id,
                                   new_file = TRUE,
                                   from_id = NULL,
                                   latest_n = NULL) {
  if (sc_key_exists() == FALSE) {
    stop("Error: STATcube-Schluessel festlegen mit 'sc_key_set()'.")
  }

  # JSON-Datei einlesen
  json_data <- fromJSON(json_path, simplifyVector = FALSE)

  # Grundvalidierung
  if (is.null(json_data$recodes[[time_field_id]])) {
    stop(sprintf("Error: time_field_id '%s' nicht in JSON 'recodes' gefunden.", time_field_id))
  }

  # Zeit-Schema laden
  time_schema <- sc_schema_db(time_valueset_id)

  # IDs in gelieferter Reihenfolge extrahieren
  time_period_ids <- vapply(
    X = time_schema,
    FUN = function(x) if (is.list(x) && !is.null(x$id)) x$id else NA_character_,
    FUN.VALUE = character(1),
    USE.NAMES = FALSE
  )
  time_period_ids <- stats::na.omit(time_period_ids)

  if (length(time_period_ids) == 0) {
    stop("Error: Keine Zeitperioden im Schema gefunden.")
  }

  # Optional: ab bestimmter ID starten (inklusive)
  if (!is.null(from_id)) {
    start_i <- match(from_id, time_period_ids)
    if (is.na(start_i)) {
      stop(sprintf(
        "from_id '%s' nicht gefunden. Tipp: erst sc_list_time_periods(%s) aufrufen und eine gueltige ID waehlen.",
        from_id, deparse(substitute(time_valueset_id))
      ))
    }
    time_period_ids <- time_period_ids[start_i:length(time_period_ids)]
  }

  # Optional: nur die letzten n behalten
  if (!is.null(latest_n)) {
    if (!is.numeric(latest_n) || latest_n <= 0) {
      stop("Error: 'latest_n' muss eine positive ganze Zahl sein.")
    }
    latest_n <- min(latest_n, length(time_period_ids))
    time_period_ids <- tail(time_period_ids, latest_n)
  }

  # JSON aktualisieren (STATcube erwartet Liste von Einzellisten)
  updated_json_data <- json_data
  updated_json_data$recodes[[time_field_id]]$map <- lapply(time_period_ids, function(id) list(id))

  # Schreiben
  if (isTRUE(new_file)) {
    updated_json_path <- paste0(file_path_sans_ext(json_path), "_", Sys.Date(), ".json")
    write_json(updated_json_data, path = updated_json_path, auto_unbox = TRUE, pretty = TRUE)
    return(updated_json_path)
  } else {
    write_json(updated_json_data, path = json_path, auto_unbox = TRUE, pretty = TRUE)
    return(invisible(NULL))
  }
}
