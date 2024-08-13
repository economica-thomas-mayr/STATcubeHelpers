#' Update der JSON-Datei für eine STATcube-Abfrage mit aktuellsten Daten
#'
#' @import STATcubeR
#' @import jsonlite
#' @import tools
#'
#' @param json_path Pfad der originalen JSON-Datei
#' @param time_valueset_id ID des time_valueset
#' @param time_field_id ID des time_field
#' @param new_file Neue JSON-Datei erstellen oder alte überschreiben
#'
#' @return Pfad der neuen JSON-Datei falls new_file = TRUE
#' @export
#'
sc_update_json_abfrage <- function(json_path, time_valueset_id, time_field_id, new_file = TRUE) {
  if (sc_key_exists() == FALSE) {
    stop("Error: STATcube-Schluessel festlegen mit 'sc_key_set()'. Der Schluessel ist ersichtlich nach Login und Oeffnen des STATcube-Portals im Menue 'Benutzerkonto' unter der Ueberschrift 'Open Data API-Schluessel'.")
  }
  # JSON-Datei einlesen
  json_data <- fromJSON(json_path, simplifyVector = FALSE)

  # Schema/Struktur des Zeitfelds einlesen
  time_schema <- sc_schema_db(time_valueset_id)

  # IDs aller verfügbarer Zeitperioden finden und abspeichern
  time_period_ids <- c()
  for (time_period in time_schema) {
    if (is.list(time_period)) {
      time_period_ids <- c(time_period_ids, time_period[["id"]])
    }
  }

  # Kopie der JSON-Daten erstellen
  updated_json_data <- json_data

  # JSON-Daten updaten
  updated_json_data$recodes[[time_field_id]]$map <- array(time_period_ids, c(length(time_period_ids), 1))

  # JSON-Daten updaten
  updated_json_data$recodes[[time_field_id]]$map <- array(time_period_ids, c(length(time_period_ids), 1))

  i = 0
  for (id in time_period_ids) {
    i = i + 1
    updated_json_data$recodes[[time_field_id]]$map[[i]] <- list(id)
  }

  # Neue JSON-Datei oder alte überschreiben?

  if (new_file) {
    # Neue JSON-Datei erstellen
    updated_json_path <- paste0(
      file_path_sans_ext(json_path),
      "_",
      Sys.Date(),
      ".json"
    )

    # Abspeichern
    write_json(
      updated_json_data,
      path = updated_json_path,
      auto_unbox = TRUE,
      pretty = TRUE
    )

    return(updated_json_path)
  } else {
    # Alte Datei überschreiben und abspeichern
    write_json(
      updated_json_data,
      path = json_path,
      auto_unbox = TRUE,
      pretty = TRUE
    )
  }

}
