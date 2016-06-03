
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(
        
        # Application title
        titlePanel("Classification using Iris data set"),
        p("This application allows studying the performance of three different\
          classification algorithms, and vary the number of resampling iterations\
                and the split between training and testing sets."),
        p("The outputs consist on the confusion matrix, prediction accuracy, and \
          a plot of the predicted values by the two most important variables \
          considered by the algorithm."),
        p(" "),
        # Sidebar with control inputs
        sidebarLayout(
                sidebarPanel(
                        h4("Classification controls"),
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
                                                        5,35,25),
                                         sliderInput("pct.training", "% Of data used for training",
                                                     1,90,70, step = 1, post="%")
                                         ),
                        # Go button to kick of calculations
                        actionButton("goButton", "Calculate")
                ),
                
                # Show a plot of the generated distribution
                mainPanel(
                        h4("Results"),
                        c("Confusion matrix (predicted(row) vs. actual(column)): "),
                        tableOutput("predTable"),
                        c("Prediction accuracy: "),
                        textOutput("accuracy"),
                        plotOutput("plot")
                )
        )
))
