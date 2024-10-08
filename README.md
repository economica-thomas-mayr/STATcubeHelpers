
# STATcubeHelpers

Hilfsfunktionen für das `{STATcubeR}` Package. Dient im Moment dazu API-Abfragen im JSON-Format für STATcube Tabellen mit den zeitlich neuesten Daten zu aktualisieren.

## Installation

Dieses Package kann mit Hilfe des `{remotes}` Package installiert werden. Dazu einfach folgenden Befehl ausführen:

```r
remotes::install_github("economica-thomas-mayr/STATcubeHelpers")
```

## Anleitung

Nachdem die gewünschte Tabelle auf der STATcube-Plattform erstellt wurde, die Tabelle als API-Abfrage im JSON-Format downloaden.

<img width="1721" alt="statcube_api_abfrage" src="https://github.com/user-attachments/assets/70724e68-6166-4d44-9210-c6a6df55c953">

Um die Abfrage zu ermöglichen müssen zuerst die notwendigen Packages geladen werden und dann der STATcube-API-Schlüssel festgelegt werden. Der Schlüssel im Beispiel ("abc") ist nicht real und muss mit einem echten Schlüssel ersetzt werden. Der Schlüssel ist ersichtlich nach Login und Öffnen des STATcube-Portals im Menü 'Benutzerkonto' unter der Überschrift 'Open Data API-Schlüssel'.

```r
# Packages laden
library(STATcubeR)
library(STATcubeHelpers)
library(jsonlite)

# STATcube-API-Schlüssel festlegen
sc_key_set("abc")
```

Nun müssen IDs für das Zeit-valueset und Zeit-field identifiziert werden, um die Aktualisierung zu ermöglichen.

Hier kann folgendermaßen vorgegangen werden:

```r
# Pfad der JSON-Datei
json_path <- "/Users/thomasmayr/R/packages/sc_abfrage_brp.json"

# JSON-Datei einlesen
json_data <- fromJSON(json_path, simplifyVector = FALSE)

# Schema der Datenbank einlesen
schema <- sc_schema_db(json_data$database, language = "de")

# Um dem Beispiel zu folgen kann folgender, equivalenter Befehl eingegeben werden
schema <- sc_schema_db("str:database:devgrrgr104", language = "de")

# Schema ansehen 
View(schema)
```

Das Schema sollte nun als aufklappbare, verschachtelte Liste aufscheinen. Typischerweise ist das Zeitfeld zu finden etwa unter dem Namen "Zeit (Mussfeld)" (kann möglicherweise auch anders heißen, ist im Normalfall aber leicht eindeutig identifizierbar).

Nun muss gesucht werden nach den IDs für das Zeit-valueset und für das Zeit-field.

<img width="958" alt="zeit_field" src="https://github.com/user-attachments/assets/bc970cd2-1a59-4e3b-ae95-d51389bf3f04">

<img width="958" alt="zeit_valueset" src="https://github.com/user-attachments/assets/25c7b968-c599-437b-b675-2fb6050c1d4a">

Im Beispiel wären das: `"str:valueset:devgrrgr104:F-DATA:C-A10-0:C-A10-0"` und `"str:field:devgrrgr104:F-DATA:C-A10-0"`.

Die Identifikation dieser IDs muss nur einmal gemacht werden.

Die Aktualisierung der Abfrage kann nun erfolgen:

```r
# Pfad der von STATcube heruntergeladenen JSON-Abfrage
json_path <- "/Users/thomasmayr/R/packages/sc_abfrage_brp.json"

# Updaten der JSON-Datei mit der neuen STATcube-API-Abfrage
updated_json_path <- sc_update_json_abfrage(
  json_path = "/Users/thomasmayr/R/packages/sc_abfrage_brp.json",
  time_valueset_id = "str:valueset:devgrrgr104:F-DATA:C-A10-0:C-A10-0",
  time_field_id = "str:field:devgrrgr104:F-DATA:C-A10-0"
)

# Es wurde eine neue JSON-Datei erstellt mit der aktualisierten Abfrage
# Der Dateipfad der neuen Abfrage wurde abgespeichert

# API-Abfrage durchführen und als Dataframe einlesen
new_data <- sc_table(
  json = updated_json_path,
  language = "de"
) |> sc_tabulate()

# Die neuen Daten wurden erfolgreich eingelesen
```

Der vorangegange Code kann bei Bedarf einfach wieder ausgeführt werden falls eine Aktualisierung der Daten gecheckt werden soll. Die Daten können nun bearbeitet werden oder etwa in eine Excel-Datei geschrieben werden.

Zu beachten ist, dass aktualisierte Abfragen im Moment den gesamten verfügbaren Zeitraum abrufen, also auch ältere Daten, die möglicherweise in der originalen Abfrage nicht enthalten waren.

Die aktualisierte Abfrage wird im Ordner der originalen Abfrage abgespeichert mit Datum an den Dateinamen angehängt im Format JJJJ-MM-TT. Es ist auch möglich die Abfrage-Datei zu überschreiben, statt eine neue erstellen. Dazu einfach das Argument `new_file = FALSE` setzen. Also im Beispiel:

```r
updated_json_path <- sc_update_json_abfrage(
  json_path = "/Users/thomasmayr/R/packages/sc_abfrage_brp.json",
  time_valueset_id = "str:valueset:devgrrgr104:F-DATA:C-A10-0:C-A10-0",
  time_field_id = "str:field:devgrrgr104:F-DATA:C-A10-0",
  new_file = FALSE
)
```
