```
# Network Meta-Analysis with netmeta for Fertility Outcomes

This application allows you to conduct a network meta-analysis on fertility outcomes using data from Google Sheets. The analysis results are displayed as PDF files and can also be downloaded as Excel files.

## Preparation

1. Clone this repository to your local machine using `git clone <repository_url>`.
2. Open an R session in the cloned repository's directory.
3. Install the required R packages with the following commands:

```r
install.packages("shiny")
install.packages("shinyServer")
install.packages("sass")
install.packages("netmeta")
install.packages("writexl")
install.packages("purrr")
```

## Usage

1. Run the Shiny app with `shiny::runApp()`.
2. Authenticate with Google in a browser. You'll need to set up a token in `.gstoken` or use an interactive session.
3. Enter the GID of a Google Sheets workbook in the "Google Sheets URL" field.
4. Select a sheet from the workbook.
5. Depending on how you formatted the sheet, select either "Continuous" or "Dichotomous" outcome. Make sure to select the correct analysis type, as choosing the wrong one may cause the app to crash.
6. Wait for the network meta-analysis to run. The analysis will generate PDF files in a folder named after the sheet and display them in the app. It will also generate league tables in the same folder and serve them to you with a download button. Both random and fixed effects models will be included in the Excel spreadsheet.

## Google Sheet Preparation

For continuous outcomes (Sperm count, sperm motility, sperm morphology, semen volume), use `conduct_nma_cont`. The required columns are Study ID, Grouped intervention, Control, Intervention Mean, Intervention SD, Intervention N, Control Mean, Control SD, Control N.

For dichotomous outcomes (Pregnancy live birth, pregnancy correlations), use `conduct_nma_disc`. The required columns are Study ID, Grouped intervention, Event, N total. Note: Each arm gets its own row, unlike continuous outcomes. Note: Inconsistency analysis is not included, as there were no closed loops in the network graph.