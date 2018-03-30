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

d <- read.csv('data/WorldPhones.csv')
df <- d[-1]
row.names(result) <- d$X
df

# Define UI for application that draws a histogram
ui <- fluidPage(    
  
  # Give the page a title
  titlePanel("Telephones by region"),
  
  # Generate a row with a sidebar
  sidebarLayout(      
    
    # Define the sidebar with one input
    sidebarPanel(
      selectInput("region", "Region:", 
                  choices=colnames(df)),
      hr(),
      helpText("Data from AT&T (1961) The World's Telephones.")
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
            ylab="Number of Telephones",
            xlab="Year")
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

