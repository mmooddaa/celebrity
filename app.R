library(shiny)

words <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vSyoEdooMQN5RU2JwzChzDdfJrqwGGBmcWoVGhBAcsnFclSvDlDrQWNoH2XZBE0f3919QBGX5mU_Y8-/pub?output=csv",
                  stringsAsFactors = FALSE)

# Create teams
names <- words$Player.Name
names(names) <- names
score <- data.frame(num = seq(1, length(names), 1),
                    player = names,
                    team = as.character(NA),
                    score = 0L,
                    stringsAsFactors = FALSE)
score$team <- ifelse(score$num %% 2 != 0 , "A", "B")

# Create list of words
words <- unname(unlist(words[1:nrow(words),2:6]))
words <- data.frame(id = 1:length(words),
                    words = words,
                    complete = 0,
                    stringsAsFactors = FALSE)

currentWord <- 0

scoreData <- data.frame(round = rep(1:10, 2),
                        team = c(rep("A", 10), rep("B", 10)),
                        score = round(rnorm(20, 5, 1), 0))
scoreData$score[scoreData$team == "A"] <- cumsum(scoreData$score[scoreData$team == "A"])
scoreData$score[scoreData$team == "B"] <- cumsum(scoreData$score[scoreData$team == "B"])

ui <- fluidPage(
  titlePanel("WELCOME TO MALLEN'S HOUSE OF FUN!"),
  tabsetPanel(
    tabPanel("Gameplay", sidebarLayout(
      sidebarPanel(
        HTML(paste("","<b/>INSTRUCTIONS:</b>",
                   "SELECT the correct player name.",
                   "Click PLAYER START to begin your turn.",
                   "Click NEXT when your team guesses correctly.",
                   "Click SKIP to skip word (and keep it in the pool).",
                   "", "",
                   sep = "<br/>")),
        
        selectInput("currentPlayer", h4("Player Select"), 
                    choices = names),
        actionButton("skipWord", "Player Start")), # end sidebarPanel
      
      mainPanel(
        h1(htmlOutput("word")),
        actionButton("nextWord", "Next"),
        actionButton("skipWord2", "Skip (really? Skip?)")
      ))), # endmainPanel, sidebarLayout and tabPanel1
    
    tabPanel("Score", 
             h4(htmlOutput("teamA_total")),
             tableOutput("teamA"),
             h4(htmlOutput("teamB_total")),
             tableOutput("teamB")) # end tabPanel2
  )
)

server <- function(input, output) {
  # NEXT WORD ACTION
  observeEvent(input$nextWord, {
    # Register that the current word was succesfully guessed
    if (currentWord != 0) {
      words$complete[words$id == currentWord] <<- 1L
      # Record player score
      score$score[score$player == input$currentPlayer] <<- 
        score$score[score$player == input$currentPlayer] + 1L
    }
    
    # Check if all words have been guessed
    if (sum(words$complete) == nrow(words)) {
      output$word <- renderUI(HTML(paste("NOW WOULD BE A GOOD TIME TO RUN TO THE BATHROOM.",
                                         "BUT BE FAST BECAUSE IT'S TIME FOR.......",
                                         "A NEW ROUND!",
                                         sep = "<br/>")))
      words$complete <<- 0
      currentWord <<- 0
    } else {
      # Randomly select word from those left
      wordsLeft <- as.character(words$id[words$complete == 0])
      currentWord <<- sample(wordsLeft, 1)
      word <- words$words[words$id == currentWord]
      output$word <- renderText(word)
    }
  })
  
  # PLAYER START
  observeEvent(input$skipWord, {
    wordsLeft <- as.character(words$id[words$complete == 0])
    currentWord <<- sample(wordsLeft, 1)
    word <- words$words[words$id == currentWord]
    output$word <- renderText(word)
  })
  
  # SKIP WORD
  observeEvent(input$skipWord2, {
    wordsLeft <- as.character(words$id[words$complete == 0])
    currentWord <<- sample(wordsLeft, 1)
    word <- words$words[words$id == currentWord]
    output$word <- renderText(word)
  })
  
  output$teamA <- renderTable({
    score[score$team == "A", c("player", "score")]})
  
  output$teamA_total <- renderText({
    paste("Team A:", sum(score$score[score$team == "A"]), "points")
  })
  
  output$teamB <- renderTable({
    score[score$team == "B", c("player", "score")]})
  
  output$teamB_total <- renderText({
    paste("Team B:", sum(score$score[score$team == "B"]), "points")
  })
}

shinyApp(ui = ui, server = server)
