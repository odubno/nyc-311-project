library(shiny)
library(dplyr)
library(ggplot2)
library(gridExtra)

df <- read.csv('data/311_filtered.csv')

# Define UI for application that draws a histogram
ui <- fluidPage(    
  
  # Give the page a title
  titlePanel("Complaints By Borough"),
  "Exploring each borough and what they like to comlain about.",
  
  # Generate a row with a sidebar
  sidebarLayout(      
    
    # Define the sidebar with one input
    sidebarPanel(
      selectInput("borough", "Borough:", choices=colnames(df[-1])),
      hr(),
      helpText("Different types of complaints by borough")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Bar Plot", plotOutput("boroughPlot")), 
        tabPanel("Parallel Plot", plotOutput("boroughPlot2")), 
        tabPanel("Description", htmlOutput("description")), 
        tabPanel("Summary", verbatimTextOutput("summary")), 
        tabPanel("Table", tableOutput("table"))
      )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  df <- reactive(read.csv('data/311_filtered.csv'))
  df_filtered_top <- reactive(read.csv('data/311_filtered_top.csv'))
  df_borough <- read.csv('data/311_borough.csv')
  
  output$boroughPlot <- renderPlot({
    
    p <- ggplot(df_filtered_top(), aes_string(x="Complaint.Type", y=input$borough)) +
          labs(
            title = "There are 170+ complaint types. These are the top 15 complaint types", 
            x = "Complaint Type", 
            y = "Number of Complaints for February",
            caption="See code here: "
          ) +
          geom_bar(stat="identity") +
          scale_y_continuous(limits=c(0,7000)) +  
          coord_flip()
    p
  })
  
  output$boroughPlot2 <- renderPlot({
    
    p2 <- ggparcoord(df_borough, 
                     columns = 2:25, 
                     groupColumn = "Borough", 
                     scale = "globalminmax")
    p2
  })
  
  output$description <- renderText({
    paste(readLines("templates/description.html"), collapse = "\n")
  })
  
  output$summary <- renderPrint({
    summary(df_filtered_top())
  })
  
  output$table <- renderTable({
    df_filtered_top()
  })
}
# Run the application 
shinyApp(ui = ui, server = server)

# rsconnect::deployApp('/Users/olehdubno/Documents/columbia/NYC311Project/nyc311_shiny')

