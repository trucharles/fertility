library(googlesheets4)
library(shiny)
library(purrr)

source("fertility.R")

shinyServer(function(input, output) {
    authenticated <- reactiveVal(FALSE)

    observeEvent(input$auth, {
        googlesheets4::gs4_auth(cache = ".gstoken", email = "cdb2169@columbia.edu")
        authenticated(TRUE)
    })

    output$authenticated <- reactive({
        authenticated()
    })
    outputOptions(output, "authenticated", suspendWhenHidden = FALSE)

    # Reactive expression to fetch sheet names
    sheet_names <- reactive({
        if (!authenticated()){
            return(NULL)
        } else {
            result <- tryCatch({
                googlesheets4::sheet_names(input$gid)
            }, error = function(e) {
                return("Invalid Sheet, Check GID and Permissions")
            })
            return(result)
        }
    })
    
    # Dynamic UI for sheet selection
    output$sheet_selector <- renderUI({
        if (is.null(sheet_names())) {
            return(p("Please authenticate and enter GID"))
        } else {
            selectInput("sheet", "Select Sheet", choices = sheet_names())
        }
    })
    
    # Reactive expressions to run analyses
    cont_results <- observeEvent(input$run_cont, {
        conduct_nma_cont(input$gid, input$sheet)
    })
    
    disc_results <- observeEvent(input$run_disc, {
        conduct_nma_disc(input$gid, input$sheet)
    })
    
    # Reactive expression to get the list of PDFs
    pdf_files <- reactive({
        req(input$sheet)
        list.files(path = input$sheet, pattern = "\\.pdf$", full.names = TRUE)
    })

    # Add a resource path for the PDF files
    observe({
        if (!is.null(input$sheet) && input$sheet != "Invalid Sheet, Check GID and Permissions" && dir.exists(input$sheet)) {
            addResourcePath("pdfs", input$sheet)
        }
    })

    # UI output to display the PDFs
    output$pdf_viewer <- renderUI({
        req(input$sheet)
        pdf_files <- list.files(path = input$sheet, pattern = "\\.pdf$")
        lapply(pdf_files, function(file) {
            tags$embed(src = paste0("pdfs/", file), type = "application/pdf", height = "600px", width = "100%")
        })
    })

    # Reactive expression to get the list of Excel files
    excel_files <- reactive({
        req(input$sheet)
        list.files(path = input$sheet, pattern = "\\.xlsx$", full.names = TRUE)
    })

    # Download handler for the Excel files
    output$download_excel <- downloadHandler(
        filename = function() {
            req(excel_files())
            basename(excel_files()[1])
        },
        content = function(file) {
            file.copy(excel_files()[1], file)
        }
    )
})