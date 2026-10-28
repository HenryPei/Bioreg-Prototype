# Bioregistration Prototype

A registry for antibody discovery work: proteins, plasmids, sequence components, hybridomas and cell lines, plus their batches and how they connect. Built as a prototype for a biotech that was tracking all of this in FileMaker.

## What it does

- Add, view, edit and delete records across five linked entity types
- Track production batches for proteins, plasmids and cell lines
- Link plasmids to the proteins, components and cell lines they relate to, and move between linked records
- Delete a record and its dependents together, with a confirmation that lists what will be removed
- Analytics: batch concentration and purity over time, yield distribution, internal vs. CRO comparison

## Stack

- R Shiny (UI and server logic)
- PostgreSQL 16
- Docker Compose (app + database)

## Run it

Requires Docker.

```
cp .env.example .env      # then set a password in .env
docker compose up --build
```

Open http://localhost:3838. The database is created and loaded with demo data on first start.

To reset the database to the demo data:

```
docker compose down -v
docker compose up --build
```

## Data model

```
hybridoma ──< component >──< plasmid >──< protein ──< protein_batch
                               │   │
                               │   └──< plasmid_batch
                               └──< cell_line ──< cell_batch
```

`──<` is one-to-many. Plasmid links to proteins, components and cell lines are many-to-many through join tables.

## Design decisions

- **Constraints live in the database.** Foreign keys, numeric column types and UNIQUE constraints on the join tables mean bad data is rejected even if the UI misses it.
- **Multi-step deletes run in a transaction.** Deleting a plasmid removes its batches and links, then the plasmid. If any step fails, nothing is deleted.
- **One place for error handling.** Database functions don't catch their own errors; the server catches them and shows a message instead of crashing the session.
- **Parameterized queries everywhere.** No SQL is built by pasting strings together.
- **Separate data layer.** All SQL lives in `R/`, one file per entity. The UI and server never touch the database directly.
- **Edits only touch fields in the form.** Columns the form doesn't expose are left alone instead of being overwritten with blanks.

## Project structure

```
global.R            packages, database pool, sources R/
ui.R                layout
server.R            reactive logic and event handlers
R/                  data access and UI pieces, one file per entity
schema.sql          tables, constraints, triggers
seed.sql            demo data
docker-compose.yml
Dockerfile
```

## Known limitations

- Concentrations are stored in mixed units (mg/mL, µg/mL, nM), so averages across units are not meaningful.
- IDs are generated as max + 1, which can collide if two users save at the same moment. A database sequence would fix this.
- No authentication or user accounts.
- Batches can be added and deleted but not edited.

## Next steps

- REST API over the same data layer
- Automated tests for the data layer
- Index benchmark on a large synthetic dataset