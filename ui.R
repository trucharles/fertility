shinyUI(fluidPage(
    titlePanel("Network Meta-Analysis"),
    sidebarLayout(
        sidebarPanel(
            actionButton("auth", "Authenticate"),
            conditionalPanel(condition = "output.authenticated",
                            textInput("gid", "Google Sheets URL",
                            value = "1TriGg9Dn56UVxYvukL0sc1m93yXR_HSKYGxEzs5Hx_E")),
            uiOutput("sheet_selector"),
            actionButton("run_cont", "Run Continuous Analysis"),
            actionButton("run_disc", "Run Dichotomous Analysis")
        ),
        mainPanel(
            downloadButton("download_excel", "Download Excel File"),
            uiOutput("pdf_viewer")
        )
    )
))