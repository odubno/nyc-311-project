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
df_complaints_when <- read.csv('data/311_complaints_when.csv')
complaint_options <- df_complaints_when$Complaint.Type

shinyUI(
  navbarPage("Do New Yorkers Like To Complain?",
             
             tabPanel(
               "Boroughs",
               titlePanel("311 Borough Analysis Of February 2018"),
               "Exploring each borough and what they like to complain about for only February 2018",
               
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
                   a(href="https://github.com/odubno/NYC311Project/blob/master/borough_plots/311_boroughs_what_bar_plot.Rmd", "What"),
                   p(),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/borough_plots/311_boroughs_how_bar_plot.Rmd", "How"),
                   p(),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/borough_plots/311_boroughs_when_pcp.Rmd", "When"),
                   p(),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/borough_plots/311_boroughs_where_heat_map.Rmd", "Where")
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
               titlePanel("311 Complaint Analysis Of February 2018"),
               "Exploring each complaint and why they matter for only February 2018.",
               
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
                   a(href="https://github.com/odubno/NYC311Project/blob/master/complaints/311_complaints_how_bar_plot.Rmd.Rmd", "How"),
                   p(),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/complaints/311_complaints_when_pcp.Rmd", "When"),
                   p(),
                   a(href="https://github.com/odubno/NYC311Project/blob/master/complaints/311_complaints_where_geo_map.Rmd", "Where")
                 ),
                 
                 mainPanel(
                   tabsetPanel(
                     tabPanel("How", plotOutput("plot_complaints_how")),
                     tabPanel("When", plotOutput("plot_complaints_when")),
                     tabPanel("Where", imageOutput("plot_complaints_where")),
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
            )
  )
)


# rsconnect::deployApp('/Users/olehdubno/Documents/columbia/NYC311Project/nyc311app')
