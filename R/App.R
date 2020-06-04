library('shinydashboard')
library('shiny')
library('DT')
library('ggplot2')
library('shinycssloaders')
library('data.table')
library('dplyr')
library('formattable')
library('tidyr')
library('ggpubr')
library('caTools')
library('knitr')
library('shinyjs')

source('PSAfunc.R',local=TRUE)

ui <- dashboardPage(
  dashboardHeader(title = "PSAresp"),
  
  dashboardSidebar(
    sidebarMenu(id="tab",
                menuItem("Home", tabName = "home", icon = icon("home")),
                menuItem("Analysis", tabName = "Analysis", icon = icon("chart-bar")),
                menuItem("Source code", icon = icon("file-code"),href="https://github.com/martinamcm/PSAresp")
    )
  ),
  
  dashboardBody(
    useShinyjs(),
    tabItems(
      tabItem(tabName = "home",
              fluidRow(
                includeHTML("PSAHomePage.html")
              )),
      
      tabItem(tabName="Analysis",
              fluidRow(
                
                box(title="Upload PSA Data",width=4,solidHeader = TRUE,status="primary",
                    
                           # Input: Select a file ----
                           fileInput("file1", "Choose CSV File",
                                     multiple = FALSE,
                                     accept = c("text/csv",
                                                "text/comma-separated-values,text/plain",
                                                ".csv")),
                           # Horizontal line ----
                           tags$hr(),
                           
                           # Input: Checkbox if file has header ----
                           checkboxInput("header", "Header", TRUE),
                           
                           # Input: Select separator ----
                           radioButtons("sep", "Separator",
                                        choices = c(Comma = ",",
                                                    Semicolon = ";",
                                                    Tab = "\t"),
                                        selected = ",")),
                
                
                
                box(title="Waterfall Plot",width=7,solidHeader = TRUE,status="primary",    
                    uiOutput("plotPSA")),
                
                box(title="Analysis", width=11,solidHeader = TRUE,status="primary",
                    
                    column(width=3,
                           numericInput("Thres", "Response threshold (%)",value=30,min=-100,max=100),
                           numericInput("TruncValue","Truncation Value (%)",value=100,min=0,max=100000),
                           actionButton("Run","Run Analysis")
                           ),
                    
                    column(width=8,align="center",
                           uiOutput("ResultsTable"),
                           uiOutput("plot")
                           )
                    )
                
                )
              )
              
              
      )
    ))



server <- function(input, output) {
  
  InputData <- eventReactive(input$file1,{
    read.csv(input$file1$datapath)
  })
  
  DataInf <- reactive(
    rawData <- InputData()
  )
  
  output$ggwaterfall<-renderPlot({
    
    req(DataInf())
    
    PSAscore<-DataInf()[,1]
    PSAdat <- data.frame(id=seq(1,length(PSAscore)) ,PSA=PSAscore[order(PSAscore)])
    
    ggplot(PSAdat, aes(x=id, y=PSA))+geom_hline(yintercept=input$Thres, linetype="dashed", color = "black")+
      xlab("Patient ID") + ylab("Change from baseline (%) in PSA score")+
      theme_bw() + theme(axis.text=element_text(size=12),
            axis.title.y = element_text(face="bold",angle=90,size=14), axis.title.x=element_text(size=14)) +
      coord_cartesian(ylim = c(-100,100))+
      geom_bar(stat="identity",width=0.7,position=position_dodge(width=0.4),fill="salmon1")
    
  })
  
  output$plotPSA <- renderUI(
    plotOutput("ggwaterfall",width="100%",height="350px")
  )
  
  Analysis <- eventReactive(input$Run,{
    
    applyaugbin(DataInf()[,1],input$Thres,input$TruncValue)
    
  })
  
  
  output$ResultsTable <- renderUI({
    formattableOutput("Results")%>% withSpinner(color="#0dc5c1")
  })
  
  output$Results <- renderFormattable({
    
    Method <- c("Augmented","Binary")
    PointEst <- Analysis()[c(1,4)]
    CIlower <- Analysis()[c(2,5)]
    CIupper <- Analysis()[c(3,6)]
    
    dataresultstable <- data.frame(Method,PointEst,CIlower,CIupper)
    formattable(dataresultstable,col.names=(c("Method","Point Estimate","95% CI lower","95% CI upper")),digits=3)
    
  })
  
  output$plot <- renderUI({
    plotOutput("p",width="75%",height="150px")
  })
  
  
  output$p<-renderPlot({
    
    Method <- c("Augmented","Binary")
    PointEst <- Analysis()[c(1,4)]
    CIlower <- Analysis()[c(2,5)]
    CIupper <- Analysis()[c(3,6)]
    
    dataplot <- data.frame(Method,PointEst,CIlower,CIupper)

    ggplot(dataplot,aes(x=as.factor(Method), y=PointEst, ymin=CIlower, ymax=CIupper, group=Method, 
                               color=Method))+
      geom_pointrange()+
      #geom_hline(yintercept = 0, linetype=3)+
      coord_flip()+
      ylab("Response")+
      xlab("")+
      scale_x_discrete(breaks = NULL)+
      scale_color_brewer(palette="Dark2")+theme_bw()+
      theme(legend.title = element_text(size = 14,face="bold"),legend.text = element_text(size = 12),
            axis.text=element_text(size=12),
            axis.title=element_text(size=14))
  
    })
  
  
}


# Run the application 
shinyApp(ui = ui, server = server)



