FROM rocker/shiny:4.4.1

# System library needed to compile RPostgres
RUN apt-get update && apt-get install -y --no-install-recommends \
      libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# R packages (shiny is already in the base image)
RUN install2.r --error --skipinstalled \
      DBI RPostgres DT bslib plotly dplyr pool

# Copy the app into the container
WORKDIR /app
COPY global.R ui.R server.R ./
COPY R/ ./R/

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]