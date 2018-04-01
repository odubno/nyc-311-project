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
  df_complaint_type <- reactive(read.csv('data/311_borough.csv'))
  df_resolution_time <- reactive(read.csv('data/311_resolution_time.csv'))
  df_heat_map <- reactive(read.csv('data/311_geo_data.csv'))
  
  
  my_theme <- theme(plot.title = element_text(colour = "grey28", family = "Helvetica", face = "bold", size = (25)), 
                    axis.text.x = element_text(angle = 0, hjust = .5),
                    legend.title = element_text(colour = "midnightblue",  face = "bold.italic", family = "Helvetica", size=20), 
                    legend.text = element_text(face = "italic", colour="mediumpurple4",family = "Helvetica", size=13), 
                    axis.title = element_text(family = "Helvetica", size = (20), colour = "purple4"),
                    axis.text = element_text(family = "Courier", colour = "mediumpurple2", size = (13)))
  
  output$complaintType <- renderPlot({
    
    p <- ggplot(df_filtered_top(), aes_string(x="Complaint.Type", y=input$borough)) +
      labs(
        title = "What Does Each Borough Complain About",
        subtitle = "TOTAL COMPLAINTS BY BOROUGH",
        x = "Complaint Type", 
        y = "Number of Complaints"
      ) +
      my_theme +
      geom_bar(stat="identity") +
      scale_y_continuous(limits=c(0,7000)) +  
      coord_flip()
    p
  })
  
  output$boroughPlot2 <- renderPlot({
    
    p2 <- ggparcoord(df_complaint_type(), columns = 2:25, groupColumn = "Borough", scale = "globalminmax")
    
    p2 + labs(
      title = "When Does Each Borough Complain", 
      subtitle = "COMPLAINTS OVER THE COURSE OF A FULL DAY",
      x = "Hours", 
      y = "Number of Complaints"
    ) +
      my_theme
  })
  
  output$boroughs_analysis <- renderText({
    paste(readLines("templates/boroughs_analysis.html"), collapse = "\n")
  })
  
  output$table <- renderTable({
    df_filtered_top()
  })
  
  output$heatMap <- renderPlot({
    
    style <- isolate(input$style)
    
    withProgress(message = 'Please Wait ~20 seconds... Generating the heat map.', style=style, value = 0, {
      
      # Initializing expensive commands
      
      ny_plot <- ggmap(get_map('New York City', zoom=11, maptype='terrain'))
      incProgress(0.25)
      
      ny_stat_density <- stat_density2d(data=df_heat_map(), aes(x = df$Longitude, y = df$Latitude, alpha=.6, fill=..level..), bins = 10, geom = 'polygon', na.rm=TRUE)
      incProgress(0.5)
      
      p <- ny_plot +
            ny_stat_density + 
            guides(fill = guide_colorbar(barwidth = 2, barheight = 20)) +
            scale_fill_gradient(low = "green", high = "red") +
            scale_alpha(range = c(0, 0.5), guide = FALSE) + 
            xlab('') +
            ylab('') +
            theme_bw() +
            theme(
              plot.title = element_text(colour = "grey28", family = "Helvetica", face = "bold", size = (20))
            ) + 
            ggtitle(
              expression(
                atop("Where Do Complaints Occur", 
                     atop("EXPLORING THE FREQUENCY OF COMPLAINTS GEOGRAPHICALLY", ""))
              )
            )
        setProgress(.75)
        Sys.sleep(2)
        setProgress(1)
      })
    
      p
    
  }, height=550, width=550)
  
  output$resolutionTime <- renderPlot({
    
    style <- isolate(input$style)
    
    withProgress(message = 'Runing GSVA', value = 0, {

      df_borough <- filter(df_resolution_time(), Borough == input$borough)
      ggplot(df_borough, aes(x=factor(Complaint.Type), y=Resolution.Minutes)) +
        labs(
          title = "How Long Does It Take To Resolve A Complaint", 
          subtitle = "THE TIME IT TAKES TO RESOLVE A COMPLAINT FOR EACH BOROUGH",
          x = "Complaint Type", 
          y = "Minutes"
        ) + 
        scale_y_continuous(limits=c(0, 5000)) +
        my_theme + 
        stat_summary(fun.y="mean", geom="bar") + 
        coord_flip()
      
    })
    
    
    
  })
  
})
