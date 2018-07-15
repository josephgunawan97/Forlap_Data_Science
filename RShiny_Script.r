#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)

tabNum <- 1

ui <- fluidPage(
  
  # Application title
  titlePanel("Data Mahasiswa Kopertis III 2009-2018"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      
      
      #Select university
      selectInput("univ",
                  "Nama Perguruan Tinggi",
                  choices = unique(newdf$namaPT)),
      
      #Select course by using function
      uiOutput("choice"),
      
      #Select year 
      numericInput("year",
                   "Tahun masuk",
                   value = 2009,
                   min = 2009, 
                   max = 2018
      )
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      
      # Output: Tabset w/ plot, summary, and table ----
      tabsetPanel(type = "tabs",
                  tabPanel("College student", 
                           tags$div(class="header", style = " horizontal-align: middle;", checked=NA, 
                              tags$h4(style = "text-align: center;",textOutput("univ"))
                           ), plotOutput("totalStudent")),
                  
                  tabPanel("Degree Student",
                           tags$div(class="header", style = "horizontal-align: middle;", checked=NA, 
                                    tags$h4(style = "text-align: center;",textOutput("univ2"))),
                            plotOutput("spesificCourse")),
                  
                  tabPanel("University Student Details", tags$div(class="header", style = "horizontal-align: middle;", checked=NA, 
                                                                  tags$h4(style = "text-align: center;", textOutput("univ3"))),
                           plotOutput("yearsDetails"))
      )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$univ <- renderText(paste("Jumlah mahasiswa" ,{input$univ}, "per tahun" ))
  output$univ2 <- renderText(paste("Jumlah mahasiswa ", {input$univ}, " jurusan ",{input$course}, "per tahun"))
  output$univ3 <- renderText(paste("Jumlah mahasiswa ", {input$univ}, "per jurusan pada tahun ",{input$year}) )

  
  #Function for create dynamic selectInput
  output$choice <- renderUI({
    selectInput("course",
                "Jurusan",
                choices =unique(newdf$namaProdi[newdf$namaPT==input$univ]) )
    
  })
  
  #Plot graph based on University
  output$totalStudent <- renderPlot({
    ggplot(newdf[newdf$namaPT==input$univ,],aes(x=Tahun,y=Banyak))+geom_bar(stat="identity") + 
      scale_x_continuous(breaks=c(2009:2018), labels=c(2009:2018),limits=c(2009,2019))
  })
  
  #Plot graph based on course taken
  output$spesificCourse <- renderPlot({
    ggplot(newdf[newdf$namaPT==input$univ & newdf$namaProdi==input$course,],aes(x=Tahun,y=Banyak))+geom_bar(stat="identity") 
     })
  
  #Plot graph based on years
  output$yearsDetails <- renderPlot({
    ggplot(newdf[newdf$namaPT==input$univ & newdf$Tahun==input$year,],aes(x=namaProdi,y=Banyak))+geom_bar(stat="identity") + coord_flip() 
    })
}

# Run the application 
shinyApp(ui = ui, server = server)