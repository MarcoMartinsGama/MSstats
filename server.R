library(shiny)

if (!requireNamespace("shinyjs", quietly = TRUE)) install.packages("shinyjs")
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("Biocmanager")
if (!requireNamespace(c("factoextra", "FactoMineR", "gProfileR", "PerformanceAnalytics"), quietly = TRUE)) install.packages(c("factoextra", "FactoMineR", "gProfileR", "PerformanceAnalytics"))
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("tidyr", quietly = TRUE)) install.packages("tidyr")
if (!requireNamespace("yaml", quietly = TRUE)) install.packages("yaml")
if (!requireNamespace("DT", quietly = TRUE)) install.packages("DT")


library(shinyjs)
library(yaml)
library(BiocManager)
library(artMS)
library(MSstats)
library(dplyr)
library(tidyr)
library(yaml)
library(DT)

options(shiny.maxRequestSize = 1000*1024^2)
shinyServer(function(input, output, session) {
  observeEvent(input$generate_msstats, {
    req(input$evidencefile, input$keysfile, input$contrastfile)
    # Copy and rename files
    file.copy(input$evidencefile$datapath, "evidence.txt")
    file.copy(input$keysfile$datapath, "keys.txt")
    file.copy(input$contrastfile$datapath, "contrast.txt")
    
    output$output_text <- renderText({"Working... Please Wait. (Might take a long time, be patient)"}) # Message for user patience 
    
    delay(1, { # Delay to display message correctly 
      if (input$method == "APMS")
        config <- yaml.load("config_APMS.yaml")
      if (input$method == "Phosphoproteomics")
        config <- yaml.load("config_phospho.yaml")
      
      artmsQuantification(config, display_msstats = TRUE)
      
      input_data <- read.delim("results/results-annotated.txt", header = TRUE, sep = "\t", quote = "", stringsAsFactors = FALSE)
      log2FC_data <- input_data %>%
        select(Protein, Label, log2FC) %>%
        pivot_wider(names_from = Label, values_from = log2FC) %>%
        rename_with(~ paste0(., "-log2FC"), -Protein)
      # Pivot the data to the wide format for adj.pvalue
      adj_pvalue_data <- input_data %>%
        select(Protein, Label, adj.pvalue) %>%
        pivot_wider(names_from = Label, values_from = adj.pvalue) %>%
        rename_with(~ paste0(., "-adj.pvalue"), -Protein)
      # Merge the log2FC and adj.pvalue data
      output_data <- full_join(log2FC_data, adj_pvalue_data, by = "Protein")
      
      write.table(output_data, file = "results/Cytoscape-msstats.txt", sep = "\t", row.names = FALSE, quote = FALSE)
      
      # Update UI to show the download button
      output$download_button <- renderUI({
        downloadButton("download_result", "Download results folder")
      })
      
      result_data <- read.table("./results/results-annotated.txt", header = TRUE, sep = "\t")
      output$result_table <- renderDT({datatable(result_data)})
    })
  })
  
  output$download_result <- downloadHandler(
    filename = function() {
      "results.zip"
    },
    content = function(file) {
      zip::zip(file, files = list.files("results", full.names = TRUE))
    }
  )
})