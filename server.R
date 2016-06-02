
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(caret)
library(dplyr)

modelFit <- function(classif.method, boost.number = 25, pct.train = 70) {
        ret <- list()
        
        set.seed(1234567)
        
        inTrain <- createDataPartition(iris$Species, p = (pct.train / 100))[[1]]
        training <- iris[inTrain, ]
        testing <- iris[-inTrain, ]
        
        m <- isolate(classif.method)
        
        tc <- trainControl(savePredictions = "final", number = boost.number)
        
        fit <- train(Species ~ ., data = training, method = m, trControl = tc)
        
        preds <- predict(fit, newdata = testing)
        d <- data.frame(Prediction = preds, Actual = testing$Species)
        
        ret$preds <- preds
        ret$actual <- testing
        ret$model <- fit
        ret$resTable <- table(d)
        ret$confMatrix <- confusionMatrix(preds, testing$Species)
        
        ret
} 

# gets the two most important variables of the currently calculated model
getMostImportantVars <- function(currModel) {
        importance <- varImp(currModel$model)$importance
        col.desc <- paste0("desc(", colnames(importance), ")")
        
        imp <- add_rownames(importance, var = "varname") %>% 
                arrange_(.dots = col.desc) %>%
                filter(row_number() <= 2)
        
        imp
}

# Plot predictions vs. actual values; plot is made by the two most important
# classification variables.
accuracyPlot <- function(impVars, predictions, actual) {
        
        d <- cbind(actual, prediction = predictions)
        d <- mutate(d, Correct = Species == prediction)
        
        ggplot(d, aes_string(x = impVars$varname[1], y = impVars$varname[2])) + 
                geom_point(aes(shape = Correct, color = Species, size = 50)) +
                guides(shape = "legend", color = "legend", size = "none")
}

# render plot predictions based on currently calculated model
makePlot <- function(currModel) {
        if (! is.null(currModel)) {
                iv <- getMostImportantVars(currModel)
                accuracyPlot(iv, currModel$preds, currModel$actual)
        }
}


shinyServer(function(input, output) {
        
        currentModel <- reactive({ 
                if (input$goButton >= 1) {
                        isolate({modelFit(input$predAlg, 
                                          input$boot.number,
                                          input$pct.training)})
                }
        })
                
        output$predTable <- renderTable({ currentModel()$resTable })
        
        output$accuracy <- renderText({ currentModel()$confMatrix$overall[1] })
        
        output$plot <- renderPlot({ makePlot(currentModel()) })
})
