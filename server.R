
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(caret)

modelFit <- function(classif.method, boost.number = 25) {
        ret <- list()
        
        inTrain <- createDataPartition(iris$Species, p = 0.7)[[1]]
        training <- iris[inTrain, ]
        testing <- iris[-inTrain, ]
        
        m <- isolate(classif.method)
        
        tc <- trainControl(savePredictions = "final", number = boost.number)
        
        fit <- train(Species ~ ., data = training, method = m, trControl = tc)
        
        preds <- predict(fit, newdata = testing)
        d <- data.frame(Prediction = preds, Actual = testing$Species)
        
        ret$preds <- preds
        ret$model <- fit
        ret$resTable <- table(d)
        ret$confMatrix <- confusionMatrix(preds, testing$Species)
        
        ret
} 


shinyServer(function(input, output) {
        
        currentModel <- reactive({ 
                if (input$goButton >= 1) {
                        isolate({modelFit(input$predAlg, input$boot.number)})
                }
        })
                
        output$predTable <- renderTable({ currentModel()$resTable })
        
        output$accuracy <- renderText({ currentModel()$confMatrix$overall[1] })
})
