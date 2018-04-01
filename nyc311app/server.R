#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(GGally)
library(ggplot2)
library(gridExtra)
library(ggmap)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  df <- reactive(read.csv('data/311_filtered.csv'))
  df_filtered_top <- reactive(read.csv('data/311_filtered_top.csv'))
  df_borough <- reactive(read.csv('data/311_borough.csv'))

  my_theme <- theme(plot.title = element_text(colour = "grey28", family = "Helvetica", face = "bold", size = (25)), 
                    legend.title = element_text(colour = "midnightblue",  face = "bold.italic", family = "Helvetica", size=20), 
                    legend.text = element_text(face = "italic", colour="mediumpurple4",family = "Helvetica", size=13), 
                    axis.title = element_text(family = "Helvetica", size = (20), colour = "purple4"),
                    axis.text = element_text(family = "Courier", colour = "mediumpurple2", size = (13)))
  
  output$boroughPlot <- renderPlot({
    
    p <- ggplot(df_filtered_top(), aes_string(x="Complaint.Type", y=input$borough)) +
      labs(
        title = "Top 15 Complaint Types", 
        x = "Complaint Type", 
        y = "Number of Complaints for February"
      ) +
      my_theme +
      geom_bar(stat="identity") +
      scale_y_continuous(limits=c(0,7000)) +  
      coord_flip()
    p
  })
  
  output$boroughPlot2 <- renderPlot({
    
    p2 <- ggparcoord(df_borough(), columns = 2:25, groupColumn = "Borough", scale = "globalminmax")
    p2 + labs(
      title = "24 Hour Complaints", 
      x = "Hours", 
      y = "Number of Complaints"
    ) +
      my_theme
  })
  
  output$analysis <- renderText({
    paste(readLines("templates/analysis.html"), collapse = "\n")
  })
  
  # output$summary <- renderPrint({
  #   summary(df_filtered_top())
  # })
  
  output$table <- renderTable({
    df_filtered_top()
  })
  
  output$heatMap <- renderImage({
    
    list(
      src = "images/311_heat_map.png",
      contentType = "image/png",
      alt = "Borough Heat Map"
    )
    
  }, deleteFile = FALSE)
  
})
