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
library(plotly)

tabNum <- 1

ui <- fluidPage(
  
  # Application title
  titlePanel("Data Mahasiswa Kopertis III 2009-2018"),
  
  bootstrapPage(
    div( p("Di sini, Anda dapat melihat jumlah mahasiswa di jurusan yang terdapat pada perguruan tinggi yang berada di bawah Kopertis Wilayah III. Pilih perguruan tinggi, jurusan, dan tahun yang ingin dilihat. Arahkan kursor pada batang-batang di tabel untuk membaca rincian jumlah mahasiswa. Gunakan autoscale jika dibutuhkan."),

      HTML("Catatan : Data jumlah mahasiswa pada 2018 merupakan data hasil prediksi."), hr())
  ),
  
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
                  tabPanel("Overview Tahunan", br(),
                           tags$div(class="header", style = " horizontal-align: middle;", checked=NA, 
                                    tags$h4(style = "text-align: center;",textOutput("univ"))
                           ), plotlyOutput("totalStudent")),
                  
                  tabPanel("Overview Jurusan", br(),
                           tags$div(class="header", style = "horizontal-align: middle;", checked=NA, 
                                    tags$h4(style = "text-align: center;",textOutput("univ2"))),
                           plotlyOutput("spesificCourse")),
                  
                  tabPanel("Overview Jurusan/Tahun", br(),
                           tags$div(class="header", style = "horizontal-align: middle;", checked=NA, 
                                    tags$h4(style = "text-align: center;", textOutput("univ3"))),
                           plotlyOutput("yearsDetails"))
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
  output$totalStudent <- renderPlotly({
    graph1 <- ggplot(newdf2[newdf2$namaPT==input$univ,],aes(x=Tahun,y=Banyak))+geom_bar(aes(fill = Semester),stat="identity", position = "dodge") + 
      scale_x_continuous(breaks=c(2009:2018), labels=c(2009:2018),limits=c(2009,2019)) + xlab("Tahun")  + ylab("Jumlah Mahasiswa") +
      theme(axis.title.x = element_text( colour='#808080'), axis.title.y = element_text( colour='#808080'))+
      theme(plot.margin = unit(c(0,1,1,1), "cm")) + scale_fill_brewer(palette="Dark2")
    
    ggplotly(graph1) %>% layout(hoverlabel = list(font = list(family = "Calibri", 
                                                              size = 12, 
                                                              color = "white"),
                                                  bordercolor = "white"))
  })
  
  #Plot graph based on course taken
  output$spesificCourse <- renderPlotly({
    graph2 <- ggplot(newdf[newdf$namaPT==input$univ & newdf$namaProdi==input$course,],aes(x=Tahun,y=Banyak))+ geom_bar(aes(fill = Semester),stat="identity", position = "dodge") +
      scale_x_continuous(breaks=c(2009:2018), labels=c(2009:2018),limits=c(2009,2019)) + xlab("Tahun")  + ylab("Jumlah Mahasiswa") +
      theme(axis.title.x = element_text( colour='#808080'), axis.title.y = element_text( colour='#808080'))+
      theme(plot.margin = unit(c(0,1,1,1), "cm")) + scale_fill_brewer(palette="Dark2")
    
    ggplotly(graph2) %>% layout(hoverlabel = list(font = list(family = "Calibri", 
                                                              size = 12, 
                                                              color = "white"),
                                                  bordercolor = "white"))
    
  })
  
  #Plot graph based on years
  output$yearsDetails <- renderPlotly({
    ggplotly( 
      graph3 <- ggplot(newdf[newdf$namaPT==input$univ & newdf$Tahun==input$year,],aes(x=namaProdi,y=Banyak))+geom_bar(aes(fill = Semester),stat="identity", position = "dodge") +
        xlab("Nama Jurusan")  + ylab("Jumlah Mahasiswa") + coord_flip()  + theme(axis.title.x = element_text( colour='#808080'),
                                                                                 axis.title.y = element_text( colour='#808080'))+ theme(plot.margin = unit(c(0,1,1,1), "cm")) +
        scale_fill_brewer(palette="Dark2")) 
        
    ggplotly(graph3) %>% layout(hoverlabel = list(font = list( family = "Calibri", 
                                                               size = 12, 
                                                               color = "white"),
                                                  bordercolor = "white"))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)