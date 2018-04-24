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
               titlePanel("Borough Analysis"),
               HTML(paste('<b style="font-size:22px">Instructions:</b>', 
                          '1. In the main panel at the top, click the "Boroughs" and "Complaints" tab to view graphs and the their "Main Analysis".', 
                          '2. In the main panel at the top, click the "Executive Summary" tab to read the summary of the research.',
                          '3. In the side panel at the bottom, click the links to view the respective code.',
                          sep="<br/>")),
               
               hr(),
               
               # Generate a row with a sidebar
               sidebarLayout(      
                 
                 # Define the sidebar with one input
                 sidebarPanel(
                   checkboxGroupInput('select_borough', 'Select Borough:', colnames(df[-1])),
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
                     tabPanel("Where", imageOutput("plot_boroughs_where")),
                     tabPanel("Main Analysis", htmlOutput("boroughs_analysis"))
                   )
                 )
               )
             ),
             
             tabPanel(
               "Complaints",
               titlePanel("Complaint Analysis"),
               HTML(paste('<b style="font-size:22px">Instructions:</b>', 
                          '1. In the main panel at the top, click the "Boroughs" and "Complaints" tab to view graphs and the their "Main Analysis".', 
                          '2. In the main panel at the top, click the "Executive Summary" tab to read the summary of the research.',
                          '3. In the side panel at the bottom, click the links to view the respective code.',
                          sep="<br/>")),
               
               hr(),
               
               # Generate a row with a sidebar
               sidebarLayout(      
                 
                 # Define the sidebar with one input
                 sidebarPanel(
                   checkboxGroupInput('complaint_type', 'Select Complaint', complaint_options),
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
                     tabPanel("Where", plotOutput("plot_complaints_where")),
                     tabPanel("Main Analysis", htmlOutput("complaints_analysis"))
                   )
                 )
               )
             ),
             
            tabPanel(
                "Executive Summary", includeHTML("templates/executive_summary.html")
            ),
            tabPanel(
              "Resources", includeHTML("templates/resources.html")
            ),
            tabPanel(
              "Open Data API",
              titlePanel("NYC Open Data API"),
              HTML(paste('<b style="font-size:22px">Instructions:</b>', 
                         '1. Select the date range to query data.', 
                         '2. Select the alpha (opacity) level.',
                         '3. Select the range of hours.',
                         "4. If the date range is greater than 30 days, the query will take some time.",
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
                  column(6,
                         verbatimTextOutput("dateRangeText")
                  ),
                  checkboxGroupInput('extra_live', 'Select Complaint:', complaint_options),
                  checkboxInput('bar_extra_live', 'All/None'),
                  helpText("Use alpha to control the opacity of points."),
                  sliderInput(
                    "extra_live_alpha",
                    "Alpha",
                    min = 0,
                    max = 1,
                    value = .5
                  ),
                  helpText("Select the range of hours for when complaints occur."),
                  sliderInput("extra_live_hour_range", "Select hour range:", min = 0, 
                              max = 23, value = c(0, 23))
                ),
                
                mainPanel(
                  tabsetPanel(
                    tabPanel("Where", plotOutput("plot_extra_live")),
                    tabPanel("About Live", htmlOutput("live_analysis"))
                  )
                )
              )
            ),
            tabPanel(
                "About", includeHTML("templates/about.html")
            )
            
  )
)


# rsconnect::deployApp('/Users/olehdubno/Documents/columbia/NYC311Project/nyc311app')
