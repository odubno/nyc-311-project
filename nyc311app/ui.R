library(shiny)
library(dplyr)
library(GGally)
library(ggplot2)
library(gridExtra)
library(ggmap)

df <- read.csv('data/311_filtered.csv')
df_complaints_when <- read.csv('data/311_complaints_when.csv')
complaint_options <- df_complaints_when$Complaint.Type

shinyUI(
  navbarPage("Life In NYC During February",
             
             tabPanel(
               "Boroughs",
               titlePanel("Borough Analysis"),
               "We explore what each borough offers or lacks and what New Yorkers like to complain about.",
               
               hr(),
               
               # Generate a row with a sidebar
               sidebarLayout(      
                 
                 # Define the sidebar with one input
                 sidebarPanel(
                   checkboxGroupInput('select_borough', 'Select Borough', colnames(df[-1])),
                   checkboxInput('bar_borough', 'All/None'),
                   hr(),
                   helpText("The data is filtered according to the top 15 most frequent complaints."),
                   hr(),
                   h4('See Code:'),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/borough_plots/311_boroughs_what_bar_plot.Rmd", "What (boroughs)"),
                   p(),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/borough_plots/311_boroughs_how_bar_plot.Rmd", "How (boroughs)"),
                   p(),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/borough_plots/311_boroughs_when_pcp.Rmd", "When (boroughs)"),
                   p(),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/borough_plots/311_boroughs_where_heat_map.Rmd", "Where (boroughs)")
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
               # "WE EXPLORE THE TOP 15 MOST FREQUENT COMPLAINTS AND WHAT THEY MEAN FOR EACH BOROUGH",
               "We explore the top 15 most frequent complaints and what they mean for each borough.",
               
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
                   helpText("The data is filtered according to the top 15 most frequent complaints."),
                   hr(),
                   h4('See Code:'),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/complaints/311_complaints_what_bar_plot.Rmd", "What (complaints)"),
                   p(),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/complaints/311_complaints_how_bar_plot.Rmd.Rmd", "How (complaints)"),
                   p(),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/complaints/311_complaints_when_pcp.Rmd", "When (complaints)"),
                   p(),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/complaints/311_complaints_where_geo_map.Rmd", "Where (complaints)")
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
                "About", includeHTML("templates/about.html")
            ),
            tabPanel(
                "Resources", includeHTML("templates/resources.html")
            ),
            tabPanel(
              "Extra",
              titlePanel("Live 311 Complaints"),
              "Depending on the day there may be between 4,000 and 10,000 complaints per day.",
              
              hr(),
              
              # Generate a row with a sidebar
              sidebarLayout(      
                
                # Define the sidebar with one input
                sidebarPanel(
                  dateRangeInput('dateRange',
                                 label = 'Date range input: yyyy-mm-dd',
                                 start = Sys.Date() - 2, end = Sys.Date()
                  ),
                  column(6,
                         verbatimTextOutput("dateRangeText")
                  ),
                  checkboxGroupInput('extra_live', 'Select Complaint', complaint_options),
                  checkboxInput('bar_extra_live', 'All/None'),
                  sliderInput(
                    "extra_live_alpha",
                    "Alpha",
                    min = 0,
                    max = 1,
                    value = .5
                  )
                ),
                
                mainPanel(
                  tabsetPanel(
                    tabPanel("Where", plotOutput("plot_extra_live")),
                    tabPanel("About Live", htmlOutput("live_analysis"))
                  )
                )
              )
            )
  )
)


# TODO change minutes to hours for how long it takes to resolve a complaint
# rsconnect::deployApp('/Users/olehdubno/Documents/columbia/NYC311Project/nyc311app')
