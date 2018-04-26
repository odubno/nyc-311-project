#
# This is the server logic of the NYC 311 Shiny web app. You can run the 
# application by clicking 'Run App' above.
#

library(shiny)
library(dplyr)
library(GGally)
library(ggplot2)
library(gridExtra)
library(ggmap)
library(scales)
library(viridis)
library(lubridate)

df_live_select <- NULL
nyc_map <- ggmap(readRDS('data/nyc_map.rds'))
df_complaints_when <- read.csv('data/311_complaints_when.csv', check.names = FALSE)
complaint_choices <- df_complaints_when$Complaint.Type
df <- read.csv('data/311_filtered.csv')
borough_choices <- colnames(df[-1])

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
   
  df <- reactive(read.csv('data/311_filtered.csv'))
  df_boroughs_complaints_what <- read.csv('data/311_boroughs_what.csv')
  df_boroughs_when <- read.csv('data/311_boroughs_when.csv', check.names = FALSE)
  df_boroughs_complaints_how <- read.csv('data/311_boroughs_complaints_how.csv')
  df_complaints_where <- read.csv('data/311_complaints_where.csv')

  my_theme <- theme(plot.title = element_text(family = "Helvetica", face = "bold", size = (25)), 
                    plot.subtitle=element_text(family = "Helvetica", face = "bold", size = (25)),
                    axis.text.x = element_text(angle = 0, hjust = .5),
                    legend.title = element_text(face = "bold.italic", family = "Helvetica", size=20), 
                    legend.text = element_text(face = "italic", family = "Helvetica", size=13), 
                    axis.title = element_text(family = "Helvetica", size = (20)),
                    axis.text = element_text(family = "Courier", size = (13)))
  
  default_plot <- ggplot(data.frame()) +
    geom_point() + 
    xlim(0, 23) + 
    ylim(0, 1000) +
    my_theme
  
  observe({
    updateCheckboxGroupInput(
      session, 
      'complaint_type', 
      choices = complaint_choices,
      selected = if (input$bar_complaint) complaint_choices
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
  
  observe({
    updateCheckboxGroupInput(
      session, 
      'extra_live', 
      choices = complaint_choices,
      selected = if (input$bar_extra_live) complaint_choices
    )
  })

  
  output$plot_boroughs_what <- renderPlot({
    
    df_boroughs_complaints_what_reactive <- reactive({ 
      df_boroughs_complaints_what[df_boroughs_complaints_what$Borough %in% input$select_borough, ]
    })
    
    ggplot(df_boroughs_complaints_what_reactive(), aes(x=factor(Complaint.Type), y=n, fill=Borough)) +
      geom_bar(stat='identity', position='dodge') +
      labs(
        title = "What Does Each Borough Complain About",
        x = "Complaint Type", 
        y = "Number of Complaints"
      ) +
      scale_fill_viridis(discrete=TRUE) + 
      theme_bw() + 
      my_theme +
      coord_flip()
    
  })
  
  output$plot_boroughs_how <- renderPlot({
    
    df_boroughs_complaints_how_reactive <- reactive({ 
      df_boroughs_complaints_how[df_boroughs_complaints_how$Borough %in% input$select_borough, ]
    })
    
    ggplot(df_boroughs_complaints_how_reactive(), aes(x=factor(Complaint.Type), y=Resolution.Mean, fill=Borough)) +
      geom_bar(stat='identity', position='dodge') +
      scale_fill_viridis(discrete=TRUE) + 
      theme_bw() + 
      my_theme + 
      labs(
        title = "How Long Does It Take", 
        subtitle = "For A Complaint To Get Resolved",
        x = "Complaint Type", 
        y = "Complaint Resolution (Hours)"
      ) + 
      coord_flip()
    
  })
  
  output$plot_boroughs_when <- renderPlot({
    
    my_titles <- labs(
      title = "When Does Each Borough Complain", 
      x = "Hours (00=Midnight)", 
      y = "Number of Complaints"
    )
    
    if(length(input$select_borough) > 0) {
      
      df_boroughs_when_reactive <- reactive({ 
        df_boroughs_when[df_boroughs_when$Borough %in% input$select_borough, ]
      })
      
      ggparcoord(df_boroughs_when_reactive(), columns = 2:25, groupColumn = "Borough", scale = "globalminmax") + 
        scale_fill_viridis(discrete=TRUE) + 
        theme_bw() + 
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
  
  
  output$plot_boroughs_where <- renderPlot({
    h <- 700
    w <- 700
    output$plot_boroughs_where <- renderImage({ 
      if(length(input$select_borough) == 1){
          if(input$select_borough == "BROOKLYN"){            
            list(src = "www/boroughs_where_brooklyn.png", contentType = "image/png", height = h, width = w)
          }                                        
          else if(input$select_borough == "BRONX"){
            list(src = "www/boroughs_where_bronx.png", contentType = "image/png", height = h, width = w)
          }
          else if(input$select_borough == "QUEENS"){
            
            list(src = "www/boroughs_where_queens.png", contentType = "image/png", height = h, width = w)
          }
          else if(input$select_borough == "STATEN.ISLAND"){
            list(src = "www/boroughs_where_staten_island.png", contentType = "image/png", height = h, width = w)
          }
          else if(input$select_borough == "MANHATTAN"){
            list(src = "www/boroughs_where_manhattan.png", contentType = "image/png", height = h, width = w)
          }else if(input$select_borough == "Unspecified"){
            validate(
              need(FALSE, "'Unspecified' refers to information requests and does not require a location."
              )
            )
          }
      } else if(length(input$select_borough) == 6){
        list(src = "www/boroughs_where_nyc.png", contentType = "image/png", height = h, width = w)
      }
      else {
        validate(
          need(FALSE, label="It's a lot of data! Please select only one check box at a time."
          )
        )
      }
    }, deleteFile = FALSE)
    
  })
  
  output$plot_complaints_what <- renderPlot({
    
    df_boroughs_complaints_what_reactive <- reactive({ 
      df_boroughs_complaints_what[df_boroughs_complaints_what$Complaint.Type %in% input$complaint_type, ]
    })
    
    ggplot(df_boroughs_complaints_what_reactive(), aes(x=factor(Borough), y=n, fill=Complaint.Type)) +
      geom_bar(stat='identity', position='dodge') +
      scale_fill_viridis(discrete=TRUE) + 
      theme_bw() + 
      labs(
        title = "What Does Each Borough Complain About",
        x = "Borough", 
        y = "Number of Complaints"
      ) +
      my_theme +
      coord_flip()
    
  })
  
  
  output$plot_complaints_how <- renderPlot({
    
    df_boroughs_complaints_how_reactive <- reactive({ 
      df_boroughs_complaints_how[df_boroughs_complaints_how$Complaint.Type %in% input$complaint_type, ]
    })
    
    ggplot(df_boroughs_complaints_how_reactive(), aes(x=factor(Borough), y=Resolution.Mean, fill=Complaint.Type)) +
      geom_bar(stat='identity', position='dodge') +
      scale_fill_viridis(discrete=TRUE) + 
      theme_bw() + 
      my_theme + 
      labs(
        title = "How Long Does It Take", 
        subtitle = "Each Borough To Resolve A Complaint",
        x = "Borough", 
        y = "Complaint Resolution (Hours)"
      ) + 
      coord_flip()
    
  })
  
  output$plot_complaints_when <- renderPlot({
    
    my_titles <- labs(
      title = "When Do Complaints Occur", 
      x = "Hours (00=Midnight)", 
      y = "Number Of Complaints"
    )
    
    if(length(input$complaint_type) > 0) {
      
      df_complaints_pcp <- reactive({ 
        df_complaints_when[df_complaints_when$Complaint.Type %in% input$complaint_type, ]
      })
      
      ggparcoord(df_complaints_pcp(), columns = 2:25, groupColumn = "Complaint.Type", scale = "globalminmax") + 
        scale_fill_viridis() + 
        theme_bw() + 
        my_theme + 
        my_titles
      
    } else {
      default_plot + my_titles
    }
    
  })
  
  

  output$plot_complaints_where <- renderPlot({
    
    if(length(input$complaint_type) > 0) {
      
      my_titles <- labs(
        title = "Where Do Complaints Occur", 
        subtitle = "",
        x = "", 
        y = ""
      )
      
      df_complaints_where_reactive <- reactive({ 
        df_complaints_where[df_complaints_where$Complaint.Type %in% input$complaint_type, ]
      })
    
      nyc_map +
        geom_point(data = df_complaints_where_reactive(), aes(x = Longitude, y = Latitude, colour = Complaint.Type), alpha=input$complaints_alpha) +
        scale_fill_viridis(discrete=TRUE) + 
        theme_bw() + 
        my_theme + 
        my_titles
      
    } else {
      return(NULL)
    }
    
  }, height = 800, width = 800)
  
  
  # initializing variables to use later
  start_date <- ""
  end_date <- ""
  
  output$plot_extra_live <- renderPlot({

    # API Call
    get_311_data <- function(start_date, end_date){
      withProgress(message="thinking",
                   detail="this will take a while...", value=0, {
                    setProgress(.2)
                    path_1 <- 'https://nycopendata.socrata.com/api/views/fhrw-4uyv/rows.csv?accessType=DOWNLOAD&query=select+*+where+%60created_date%60+%3E%3D+%27'
                    path_2 <- 'T00%3A00%3A00%27+AND+%60created_date%60+%3C+%27'
                    path_3 <- 'T23%3A59%3A59%27'
                    setProgress(.4)
                    live_url <- paste(path_1, start_date, path_2, end_date, path_3, sep='')
                    setProgress(.8)
                    live_data = read.csv(live_url)
                    setProgress(1)
                   })
      return(live_data)
    }
    
    input_start_date <- input$dateRange[1]
    input_end_date <- input$dateRange[2] # as.character(
    different_range <- start_date != as.character(input_start_date) | end_date != as.character(input_end_date)
    if (different_range){
      # only if the date range is different will we get 311 data again.
      live_data = get_311_data(input_start_date, input_end_date)
      start_date <<- as.character(input_start_date)
      end_date <<- as.character(input_end_date)
    }
    
    # Select Columns and remove NAs
    df_live_select <- live_data[c('Complaint.Type','Created.Date', 'Longitude', 'Latitude')]
    df_live_select <- na.omit(df_live_select)
    
    
    # Render Plot
    if(length(input$extra_live) > 0) {
      
      my_titles <- labs(
        title = "Where Do Complaints Occur", 
        subtitle = "",
        x = '', 
        y = ''
      )
      
      if (input$single_handle == FALSE){
        hour_range <- c(input$extra_live_hour_range[1]:input$extra_live_hour_range[2])
      } else {
        hour_range <- c(0:input$extra_live_hour_range_single_handle)
      }
      
      # cleaning and prepping data
      df_complaint_select <- df_live_select[df_live_select$Complaint.Type %in% input$extra_live, ]
      df_complaint_select$Complaint.Date <- as.Date(as.POSIXct(df_complaint_select$Created.Date, format="%m/%d/%Y"))
      df_complaint_select$Complaint.Hour <- hour(as.POSIXct(df_complaint_select$Created.Date, format="%m/%d/%Y %I:%M:%S %p"))
      df_hour_select <- df_complaint_select[df_complaint_select$Complaint.Hour %in% hour_range, ]
      
      df_live_select_reactive <- reactive({ 
        df_hour_select
      })
      
      nyc_map +
        geom_point(data = df_live_select_reactive(), aes(x = Longitude, y = Latitude, colour = Complaint.Type), alpha=input$extra_live_alpha) +
        scale_fill_viridis(discrete=TRUE) + 
        theme_bw() + 
        my_theme + 
        my_titles
      
      } else {
        return(NULL)
      }
      
    }, height = 800, width = 800)
  
  output$live_analysis <- renderText({
    paste(readLines("templates/live_analysis.html"), collapse = "\n")
  })
  
})
