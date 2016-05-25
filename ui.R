
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(
        
        # Application title
        titlePanel("Classification using Iris data set"),
        
        # Sidebar with control inputs
        sidebarLayout(
                sidebarPanel(
                        h4("Prediction controls:"),
                        # Choice of prediction algorithm
                        selectizeInput("predAlg", "Prediction Algorithm:",
                                       c("Logistic Regression" = "multinom",
                                         "Random Forest" = "rf",
                                         "K Nearest Neighbors" = "knn")),
                        # Optional boost iteration number
                        radioButtons("trainPars", "Training Parameters", 
                                     c("Default" = "def",
                                       "Custom" = "cus"),
                                     selected = "def"),
                        conditionalPanel(condition = "input.trainPars == 'cus'",
                                         sliderInput("boot.number", "Nr. Resampling Iterations",
                                                        5,35,25)),
                        # Go button to kick of calculations
                        actionButton("goButton", "Go")
                ),
                
                # Show a plot of the generated distribution
                mainPanel(
                        h4("Results"),
                        c("Prediction table: "),
                        tableOutput("predTable"),
                        c("Prediction accuracy: "),
                        textOutput("accuracy"),
                        h5("Prediction Render over the two most important variables:")
                )
        )
))
