#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
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

df <- read.csv('data/311_filtered.csv')

shinyUI(
  navbarPage("What Do New Yorkers Like to Complain About",
             
             tabPanel(
               "Boroughs",
               titlePanel("Complaints By Borough"),
               "Exploring each borough and what they like to comlain about.",
               
               # Generate a row with a sidebar
               sidebarLayout(      
                 
                 # Define the sidebar with one input
                 sidebarPanel(
                   selectInput("borough", "Borough:", choices=colnames(df[-1])),
                   hr(),
                   helpText("Different types of complaints by borough"),
                   hr(),
                   h4('Code:'),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/311_bar_plot_borough.Rmd", "Bar Plot"),
                   p(),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/311_pcp_borough.Rmd", "Parallel Plot"),
                   p(),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/311_heat_map_borough.Rmd", "Heat Map Plot")
                 ),
                 
                 mainPanel(
                   tabsetPanel(
                     tabPanel("Complaint Types", plotOutput("complaintType")), 
                     tabPanel("Resolution Times", plotOutput("resolutionTime")),
                     tabPanel("Complaint Times", plotOutput("boroughPlot2")), 
                     tabPanel("Geo Plot", imageOutput("heatMap")),
                     tabPanel("Analysis", htmlOutput("analysis")), 
                     # tabPanel("Summary", verbatimTextOutput("summary")), 
                     tabPanel("Table", tableOutput("table"))
                   )
                 )
               )
             ),
             
             tabPanel(
               "Component 2",
                 sidebarLayout(
                   sidebarPanel(
                     selectizeInput(
                       'id', label="Year", choices=NULL, multiple=F, selected="X2015",
                       options = list(create = TRUE,placeholder = 'Choose the year')
                     ),
                     # Make a list of checkboxes
                     radioButtons("radio", label = h3("New Radio buttons"),
                                  choices = list("Choice 1" = 1, "Choice 2" = 2)
                     )
                   ),
                   mainPanel( plotOutput("distPlot") )
                 )
               ),
              tabPanel("Component 3")
  )
)

# rsconnect::deployApp('/Users/olehdubno/Documents/columbia/NYC311Project/nyc311app')
