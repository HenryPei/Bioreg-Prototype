library(shiny)
library(DBI)
library(RPostgres)
library(pool)
library(DT)
library(bslib)
library(plotly)
library(dplyr)

# Configuration
if (file.exists(".env")) {
  readRenviron(".env")
  Sys.setenv(DB_HOST = "localhost")
}

# Database connection pool
con <- dbPool(
  RPostgres::Postgres(),
  host     = Sys.getenv("DB_HOST"),
  port     = as.integer(Sys.getenv("DB_PORT", "5432")),
  dbname   = Sys.getenv("POSTGRES_DB"),
  user     = Sys.getenv("POSTGRES_USER"),
  password = Sys.getenv("POSTGRES_PASSWORD")
)

onStop(function() poolClose(con))

# App modules 
source("R/utils.R")
source("R/protein.R")
source("R/protein_batch.R")
source("R/plasmid.R")
source("R/plasmid_batch.R")
source("R/component.R")
source("R/hybridoma.R")
source("R/cell_line.R")
source("R/cell_batch.R")
source("R/join_tables.R")
source("R/analytics_funcs.R")