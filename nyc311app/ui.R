library(shiny)
library(dplyr)
library(GGally)
library(ggplot2)
library(gridExtra)
library(ggmap)
library(scales)
library(viridis)
library(lubridate)

df <- read.csv('data/311_filtered.csv')
df_complaints_when <- read.csv('data/311_complaints_when.csv')
complaint_options <- df_complaints_when$Complaint.Type
nav_bar_html = '.navbar { background-color: #2D708EFF }
                .navbar-default
                .navbar-brand{color: #f4f142;}
                .navbar-nav li a, .navbar-nav > .active > a {
                    color: #f4f142 !important;
                    background-image: #fff !important;
                }
                .navbar-nav li a:hover, .navbar-nav > .active > a {
                    color: #2D708EFF !important;
                    background-color: #f4f142 !important;
                    background-image: #fff !important;
                }
                .navbar-default .navbar-nav > .active > a, 
                .navbar-default .navbar-nav > .active > a:hover {
                    color: #2D708EFF;
                    background-color: #f4f142;
                }
                .nav-tabs li a:hover, .nav-tabs > .active > a {
                  background-color: #f4f142 !important;
                }'

shinyUI(
  navbarPage("311 Data & Life in NYC",
             position="fixed-top",
             collapsible=TRUE,
             
             tabPanel(
               "Boroughs",
               tags$style(type = 'text/css', 
                          'body {padding-top: 70px;}',
                          HTML(nav_bar_html)
               ),

               titlePanel("Plots by Borough"),
               p("Analysis of 311 complaint calls for New York City during the month of February 2018."),
               helpText("In this tab we have provided the ability for experimentation on the data by anchoring on the complaint type and filtering on boroughs. The value here is to be able to understand commonalities and differences between the different boroughs."),
               HTML(paste('<b style="font-size:22px">Instructions:</b>', 
                          '1. In the main panel at the top, the "Boroughs" tab and the "Complaints" tab each contain exploratory plots.', 
                          '2. In the panel below, click "What", "How", "When" and "Where" to view different type of plots.',
                          '3. In the main panel at the top, click the "Summary" tab to read the summary of the research.',
                          '4. In the side panel at the bottom, click the links to view the respective code.',
                          sep="<br/>")),
               
               hr(),
               
               # Generate a row with a sidebar
               sidebarLayout(      
                 
                 # Define the sidebar with one input
                 sidebarPanel(
                   checkboxGroupInput(inputId='select_borough', label='Select Borough:', selected="BROOKLYN", choices=colnames(df[-1])),
                   checkboxInput('bar_borough', 'All/None'),
                   hr(),
                   tags$b("The data is only for the month of February 2018 and is filtered by the top 15 most frequent complaints."),
                   hr(),
                   h4('See Code:'),
                   HTML(paste('<a href="https://github.com/odubno/NYC311Project/blob/master/borough_plots/311_boroughs_what_bar_plot.Rmd" target="_blank">What (boroughs)</a>', 
                              '<a href="https://github.com/odubno/NYC311Project/blob/master/borough_plots/311_boroughs_how_bar_plot.Rmd" target="_blank">How (boroughs)</a>', 
                              '<a href="https://github.com/odubno/NYC311Project/blob/master/borough_plots/311_boroughs_when_pcp.Rmd" target="_blank">When (boroughs)</a>', 
                              '<a href="https://github.com/odubno/NYC311Project/blob/master/borough_plots/311_boroughs_where_heat_map.Rmd" target="_blank">Where (boroughs)</a>', 
                              sep="<br/>"))
                 ),
                 
                 mainPanel(
                   tabsetPanel(
                     tabPanel("What", plotOutput("plot_boroughs_what")), 
                     tabPanel("How", plotOutput("plot_boroughs_how")),
                     tabPanel("When", plotOutput("plot_boroughs_when")), 
                     tabPanel("Where", imageOutput("plot_boroughs_where"))
                   )
                 )
               )
             ),
             
             tabPanel(
               "Complaints",
               titlePanel("Plots by Analysis"),
               p("Analysis of 311 complaint calls for New York City during the month of February 2018."),
               helpText("In this tab we have provided the ability for experimentation on the data by anchoring on the borough and filtering on complaint type. The value here is to be able to understand commonalities and differences between the different complaints submitted."),
               HTML(paste('<b style="font-size:22px">Instructions:</b>', 
                          '1. In the main panel at the top, the "Boroughs" tab and the "Complaints" tab each contain exploratory plots.', 
                          '2. In the panel below, click "What", "How", "When" and "Where" to view different type of plots.',
                          '3. In the main panel at the top, click the "Summary" tab to read the summary of the research.',
                          '4. In the side panel at the bottom, click the links to view the respective code.',
                          sep="<br/>")),
               
               hr(),
               
               # Generate a row with a sidebar
               sidebarLayout(      
                 
                 # Define the sidebar with one input
                 sidebarPanel(
                   checkboxGroupInput('complaint_type', 'Select Complaint', complaint_options, selected="BROOKLYN"),
                   checkboxInput('bar_complaint', 'All/None'),
                   sliderInput(
                     "complaints_alpha",
                     "Alpha (See The 'Where' Tab):",
                     min = 0,
                     max = 1,
                     value = .5
                   ),
                   hr(),
                   tags$b("The data is only for the month of February 2018 and is filtered by the top 15 most frequent complaints."),
                   hr(),
                   h4('See Code:'),
                   HTML(paste('<a href="https://github.com/odubno/NYC311Project/blob/master/complaint_plots/311_complaints_what_bar_plot.Rmd" target="_blank">What (complaints)</a>', 
                              '<a href="https://github.com/odubno/NYC311Project/blob/master/complaint_plots/311_complaints_how_bar_plot.Rmd" target="_blank">How (complaints)</a>', 
                              '<a href="https://github.com/odubno/NYC311Project/blob/master/complaint_plots/311_complaints_when_pcp.Rmd" target="_blank">When (complaints)</a>', 
                              '<a href="https://github.com/odubno/NYC311Project/blob/master/complaint_plots/311_complaints_where_geo_map.Rmd" target="_blank">Where (complaints)</a>', 
                              sep="<br/>"))
                 ),
                 
                 mainPanel(
                   tabsetPanel(
                     tabPanel("What", plotOutput("plot_complaints_what")),
                     tabPanel("How", plotOutput("plot_complaints_how")),
                     tabPanel("When", plotOutput("plot_complaints_when")),
                     tabPanel("Where", plotOutput("plot_complaints_where"))
                   )
                 )
               )
             ),
             
            tabPanel(
                "Summary", includeHTML("templates/executive_summary.html")
            ),
            tabPanel(
              "Interactive Map",
              titlePanel("NYC Open Data API"),
              HTML(paste('<b style="font-size:22px">Instructions:</b>', 
                         '1. Select the date range to query data.', 
                         '2. If the date range is greater than 30 days, then the query will take some time.',
                         '3. Always select the end date first before selecting the start date.',
                         '4. Select the alpha (opacity) level.',
                         '5. Animate The Date: Choose between "Double Handle" and "Single Handle" hour range.',
                         '5. See "About Open Data API" to get more info.',
                         sep="<br/>")),
              hr(),
              
              # Generate a row with a sidebar
              sidebarLayout(      
                
                # Define the sidebar with one input
                sidebarPanel(
                  dateRangeInput('dateRange',
                                 label = 'Date range input: yyyy-mm-dd',
                                 start = Sys.Date() - 7, end = Sys.Date()
                  ),
                  helpText("The data is filtered according to the top 15 most frequent complaints."),
                  column(6, verbatimTextOutput("dateRangeText")),
                  checkboxGroupInput('extra_live', 'Select Complaint:', complaint_options),
                  checkboxInput('bar_extra_live', 'All/None'),
                  sliderInput(
                    "extra_live_alpha",
                    "Alpha",
                    min = 0,
                    max = 1,
                    value = .5
                  ),
                  helpText("Control the opacity of points."),
                  hr(),
                  h3("Animate The Day"),
                  checkboxInput("single_handle", "Single Handle/Double Handle", FALSE),
                  helpText('Default is "Double Handle".'),
                  helpText('"Double Handle" controls a window of time while "Single Handle" only controls the right handle.'),
                  helpText('Use the above checkbox to go between the "Double Handle" and the "Single Handle".'),
                  hr(),
                  sliderInput("extra_live_hour_range", 
                              "Double Handle. Select hour range:",
                              min = 0, 
                              max = 23, 
                              value = c(0, 23),
                              animate = animationOptions(interval = 3000, playButton = icon("play", "fa-3x"), pauseButton = icon("pause", "fa-3x"))
                              ),
                  helpText("Select an hour range and press the play button to animate the range."),
                  hr(),
                  sliderInput("extra_live_hour_range_single_handle", 
                              "Single Handle. Select hour:",
                              min = 0, 
                              max = 23, 
                              value = 12,
                              animate = animationOptions(interval = 3000, playButton = icon("play", "fa-3x"), pauseButton = icon("pause", "fa-3x"))
                  ),
                  helpText("Select a single hour and press the play button to animate the rest of the day."),
                  hr(),
                  
                  h4('See Code:'),
                  HTML(paste('<a href="https://github.com/odubno/NYC311Project/blob/master/live_311.Rmd" target="_blank">NYC Open Data API</a>'))
                ),
                
                mainPanel(
                  tabsetPanel(
                    tabPanel("Where", plotOutput("plot_extra_live")),
                    tabPanel("About Open Data API", htmlOutput("live_analysis"))
                  )
                )
              )
            ),
            tabPanel(
              "Resources", includeHTML("templates/resources.html")
            ),
            tabPanel(
                "About", includeHTML("templates/about.html")
            )
            
  )
)


# rsconnect::deployApp('/Users/olehdubno/Documents/columbia/NYC311Project/nyc311app')
