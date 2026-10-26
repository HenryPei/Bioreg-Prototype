ui <- navbarPage(
  id = "navbar",
  title = "Bioregistration Prototype",
  theme = bs_theme(version = 5, bootswatch = "flatly"),

  # Catalogue
  navbarMenu("Catalogue",
    tabPanel("Proteins",
      fluidRow(
        column(12,
          br(),
          actionButton("add_protein_btn", "Add Protein",
            class = "btn-primary btn-sm"),
          br(), br(),
          DTOutput("proteins_table"),
          hr(),
          uiOutput("protein_detail"),
          uiOutput("protein_batch_detail")
        )
      )
    ),

    tabPanel("Components",
      fluidRow(
        column(12,
          br(),
          actionButton("add_component_btn", "Add Component",
            class = "btn-primary btn-sm"),
          br(), br(),
          DTOutput("components_table"),
          hr(),
          uiOutput("component_detail")
        )
      )
    ),

    tabPanel("Plasmids",
      fluidRow(
        column(12,
          br(),
          actionButton("add_plasmid_btn", "Add Plasmid",
            class = "btn-primary btn-sm"),
          br(), br(),
          DTOutput("plasmids_table"),
          hr(),
          uiOutput("plasmid_detail")
        )
      )
    ),

    tabPanel("Hybridomas",
      fluidRow(
        column(12,
          br(),
          actionButton("add_hybridoma_btn", "Add Hybridoma",
            class = "btn-primary btn-sm"),
          br(), br(),
          DTOutput("hybridomas_table"),
          hr(),
          uiOutput("hybridoma_detail")
        )
      )
    ),

    tabPanel("Cell Lines",
      fluidRow(
        column(12,
          br(),
          actionButton("add_cell_line_btn", "Add Cell Line",
            class = "btn-primary btn-sm"),
          br(), br(),
          DTOutput("cell_lines_table"),
          hr(),
          uiOutput("cell_line_detail")
        )
      )
    )
  ),

  # ── Analytics ─────────────────────────────────────
  navbarMenu("Analytics",

    tabPanel("Overview",
      br(),
      fluidRow(
        column(3, wellPanel(
          h3(textOutput("stat_proteins")),
          p("Total proteins", style = "color:gray")
        )),
        column(3, wellPanel(
          h3(textOutput("stat_batches")),
          p("Total batches", style = "color:gray")
        )),
        column(3, wellPanel(
          h3(textOutput("stat_avg_conc")),
          p("Avg concentration mg/mL", style = "color:gray")
        )),
        column(3, wellPanel(
          h3(textOutput("stat_avg_purity")),
          p("Avg SEC purity %", style = "color:gray")
        ))
      ),
      fluidRow(
        column(6, plotlyOutput("plot_batch_count", height = "350px")),
        column(6, plotlyOutput("plot_source_comparison", height = "350px"))
      ),
      br(),
      fluidRow(
        column(12,
          h5("Recent batches"),
          DTOutput("recent_batches_table")
        )
      )
    ),

    tabPanel("Batch Analytics",
      br(),
      fluidRow(
        column(3,
          selectInput("analytics_protein_filter", "Filter by protein",
            choices = NULL),
          hr(),
          h6("Select a chart:"),
          actionButton("show_conc_trend", "Concentration trend",
            class = "btn-outline-primary btn-sm btn-block"),
          br(),
          actionButton("show_purity_trend", "Purity trend",
            class = "btn-outline-primary btn-sm btn-block"),
          br(),
          actionButton("show_conc_purity", "Concentration vs purity",
            class = "btn-outline-primary btn-sm btn-block"),
          br(),
          actionButton("show_yield_dist", "Yield distribution",
            class = "btn-outline-primary btn-sm btn-block")
        ),
        column(9,
          plotlyOutput("analytics_plot", height = "500px")
        )
      )
    )
  )
)