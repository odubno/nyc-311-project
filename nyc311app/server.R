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

df_complaints_when <- read.csv('data/311_complaints_when.csv', check.names = FALSE)
complaint_options <- df_complaints_when$Complaint.Type

df <- read.csv('data/311_filtered.csv')
borough_choices <- colnames(df[-1])

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
   
  df <- reactive(read.csv('data/311_filtered.csv'))
  df_boroughs_what <- read.csv('data/311_boroughs_what.csv')
  df_boroughs_when <- read.csv('data/311_boroughs_when.csv', check.names = FALSE)
  df_boroughs_how <- read.csv('data/311_boroughs_how.csv')

  my_theme <- theme(plot.title = element_text(colour = "grey28", family = "Helvetica", face = "bold", size = (25)), 
                    axis.text.x = element_text(angle = 0, hjust = .5),
                    legend.title = element_text(colour = "midnightblue",  face = "bold.italic", family = "Helvetica", size=20), 
                    legend.text = element_text(face = "italic", colour="mediumpurple4",family = "Helvetica", size=13), 
                    axis.title = element_text(family = "Helvetica", size = (20), colour = "purple4"),
                    axis.text = element_text(family = "Courier", colour = "mediumpurple2", size = (13)))
  
  default_plot <- ggplot(data.frame()) +
    geom_point() + 
    xlim(0, 23) + 
    ylim(0, 1000) +
    my_theme
  
  observe({
    updateCheckboxGroupInput(
      session, 
      'complaint_type', 
      choices = complaint_options,
      selected = if (input$bar_complaint) complaint_options
    )
  })
  
  observe({
    updateCheckboxGroupInput(
      session, 
      'select_borough', 
      choices = borough_choices,
      selected = if (input$bar_borough) borough_choices
    )
  })
  
  output$plot_boroughs_what <- renderPlot({
    
    df_boroughs_what_reactive <- reactive({ 
      df_boroughs_what[df_boroughs_what$Borough %in% input$select_borough, ]
    })
    
    ggplot(df_boroughs_what_reactive(), aes(x=factor(Complaint.Type), y=n, fill=Borough)) +
      geom_bar(stat='identity', position='dodge') +
      labs(
        title = "What Does Each Borough Complain About",
        subtitle = "TOTAL COMPLAINTS BY BOROUGH",
        x = "Complaint Type", 
        y = "Number of Complaints"
      ) +
      my_theme +
      coord_flip()
    
  })
  
  output$plot_boroughs_how <- renderPlot({
    
    df_boroughs_how_reactive <- reactive({ 
      df_boroughs_how[df_boroughs_how$Borough %in% input$select_borough, ]
    })
    
    ggplot(df_boroughs_how_reactive(), aes(x=factor(Complaint.Type), y=Resolution.Mean, fill=Borough)) +
      geom_bar(stat='identity', position='dodge') +
      my_theme + 
      labs(
        title = "How Long Does It Take To Resolve A Complaint", 
        subtitle = "THE TIME IT TAKES TO RESOLVE A COMPLAINT FOR EACH BOROUGH",
        x = "Complaint Type", 
        y = "Minutes"
      ) + 
      coord_flip()
    
  })
  
  output$plot_boroughs_when <- renderPlot({
    
    my_titles <- labs(
      title = "When Does Each Borough Complain", 
      subtitle = "COMPLAINTS OVER THE COURSE OF A FULL DAY",
      x = "Hours", 
      y = "Number of Complaints"
    )
    
    if(length(input$select_borough) > 0) {
      
      df_boroughs_when_reactive <- reactive({ 
        df_boroughs_when[df_boroughs_when$Borough %in% input$select_borough, ]
      })
      
      ggparcoord(df_boroughs_when_reactive(), columns = 2:25, groupColumn = "Borough", scale = "globalminmax") + 
        my_theme + 
        my_titles
      
    } else {
       default_plot + my_titles
    }
  
  })

  output$boroughs_analysis <- renderText({
    paste(readLines("templates/boroughs_analysis.html"), collapse = "\n")
  })
  
  output$complaints_analysis <- renderText({
    paste(readLines("templates/complaints_analysis.html"), collapse = "\n")
  })
  
  output$table <- renderTable({
    df_boroughs_what()
  })
  
  output$plot_boroughs_where <- renderPlot({
       
      output$plot_boroughs_where <- renderImage({
        
        list(
          src = "images/311_heat_map.png",
          contentType = "image/png",
          alt = "Borough Heat Map"
        )
        
      }, deleteFile = FALSE)
    
  })
  
  output$plot_complaints_when <- renderPlot({
    
    my_titles <- labs(
      title = "When Do Complaints Occur", 
      subtitle = "THE TIME COMPLAINTS HAPPEN OVER THE COURSE OF A DAY",
      x = "Hours", 
      y = "Complaint Type"
    )
    
    if(length(input$complaint_type) > 0) {
      
      df_complaints_pcp <- reactive({ 
        df_complaints_when[df_complaints_when$Complaint.Type %in% input$complaint_type, ]
      })
      
      ggparcoord(df_complaints_pcp(), columns = 2:25, groupColumn = "Complaint.Type", scale = "globalminmax") + 
        my_theme + 
        my_titles
      
    } else {
      default_plot + my_titles
    }
    
  })
  
})
