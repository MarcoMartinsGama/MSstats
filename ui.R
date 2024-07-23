library(shiny)
library(shinyjs)
library(DT)

shinyUI(fluidPage(
  titlePanel("MSstats"),
  useShinyjs(),
  sidebarLayout(
    sidebarPanel(
      # Upload necessary files and choose which proteomics method
      fileInput("evidencefile", "Upload evidence.txt", accept = c("text/plain", ".txt")),
      fileInput("keysfile", "Upload keys.txt", accept = c("text/plain", ".txt")),
      fileInput("contrastfile", "Upload contrast.txt", accept = c("text/plain", ".txt")),
        radioButtons("method", "Which method?", choices = c("APMS", "Phosphoproteomics")),
      
      # Button to generate MSstats and message confirming the work is in progress
      actionButton("generate_msstats", "Start MSstats"),
      textOutput("output_text")
    ),
    
    mainPanel(
      fluidRow(DTOutput("result_table"),
      uiOutput("download_button"))
      
      
      
    )
  )
))