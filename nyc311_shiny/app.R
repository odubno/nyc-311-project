#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(datasets)

d <- read.csv('data/311_filtered.csv')
df <- d[-1]
row.names(df) <- d$Complaint.New
df

# Define UI for application that draws a histogram
ui <- fluidPage(    
  
  # Give the page a title
  titlePanel("Complaints By Borough"),
  
  # Generate a row with a sidebar
  sidebarLayout(      
    
    # Define the sidebar with one input
    sidebarPanel(
      selectInput("region", "Borough:", 
                  choices=colnames(df)),
      hr(),
      helpText("Different types of complaints by borough")
    ),
    
    # Create a spot for the barplot
    mainPanel(
      plotOutput("phonePlot")  
    )
    
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
  output$phonePlot <- renderPlot({
    
    # Render a barplot
    barplot(df[,input$region], 
            main=input$region,
            ylab="Number of Complaints",
            xlab="February 2018")
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

# rsconnect::deployApp('/Users/olehdubno/Documents/columbia/NYC311Project/nyc311_shiny')

