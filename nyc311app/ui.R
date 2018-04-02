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
  navbarPage("Do New Yorkers Like To Complain?",
             
             tabPanel(
               "Boroughs",
               titlePanel("Complaints By Borough For February 2018"),
               "Exploring each borough and what they like to complain about for only February 2018.",
               
               # Generate a row with a sidebar
               sidebarLayout(      
                 
                 # Define the sidebar with one input
                 sidebarPanel(
                   selectInput("borough", "Borough:", choices=colnames(df[-1])),
                   hr(),
                   helpText("We filtered the data by the top 15 most frequent complaints. Please use the drop down to filter by Borough."),
                   hr(),
                   h4('See Code:'),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/311_bar_plot_borough.Rmd", "What"),
                   p(),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/311_pcp_borough.Rmd", "How"),
                   p(),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/311_created_time.Rmd", "When"),
                   p(),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/311_geo_plot.Rmd", "Where")
                 ),
                 
                 mainPanel(
                   tabsetPanel(
                     tabPanel("What", plotOutput("complaintType")), 
                     tabPanel("How", plotOutput("resolutionTime")),
                     tabPanel("When", plotOutput("boroughPlot2")), 
                     tabPanel("Where", imageOutput("heatMap")),
                     tabPanel("Main Analysis", htmlOutput("boroughs_analysis")), 
                     tabPanel("Table", tableOutput("table"))
                   )
                 )
               )
             ),
             
             tabPanel(
               "Agencies",
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
              tabPanel(
                "Executive Summary", includeHTML("templates/executive_summary.html")
                ),
              tabPanel(
                "About", includeHTML("templates/about.html"))
  )
)

# rsconnect::deployApp('/Users/olehdubno/Documents/columbia/NYC311Project/nyc311app')
