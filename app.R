library(shiny)

# Declare global dfs and variables
words <- data.frame()
score <- data.frame()
names <- character()
currentWord <- 0

# Functions to create a new game based on inputed Google Form URL
fetchData <- function (url) {
  words <- read.csv(url,stringsAsFactors = FALSE)
}

createTeams <- function (words) {
  # Randomize teams
  # Set seed based on time
  set.seed(as.integer(paste0(strsplit(format(Sys.time(), "%X"), ":")[[1]], collapse = "")))
  
  names <- words$Player.Name
  names <- sample(names) # Select sample in random order
  score <- data.frame(num = seq(1, length(names), 1),
                      player = names,
                      team = as.character(NA),
                      score = 0L,
                      stringsAsFactors = FALSE)
  score$team <- ifelse(score$num %% 2 != 0 , "A", "B")
  return (score)
}

createNamelist <- function(score) {
  names <- score$player
  names(names) <- names
  return (names)
}

createWordlist <- function (words) {
  # Create list of words
  words$Player.Name <- NULL
  words <- unname(unlist(words[1:nrow(words),2:ncol(words)]))
  words <- data.frame(id = 1:length(words),
                      words = words,
                      complete = 0,
                      stringsAsFactors = FALSE)
}

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
             tableOutput("teamB")), # end tabPanel2
    
    # Fucntionality to add:
    #   - Add Google Form URL to input new words and names
    #   - Reset game (keep current word list, reset score)
    tabPanel("Configure Game",
             textInput("url", "Enter Google Form URL (CSV):"),
             actionButton("configureGame", "Submit")) # end tabPanel3 
  )
)

server <- function(input, output, session) {
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
  
  # Update Player List
  observe({
    updateSelectInput(session, "currentPlayer", label = "Player Select", choices = names)
  })
  
  
  # GAME CONFIGURE ACTIONS
  observeEvent(input$configureGame, {
    words <<- fetchData(input$url)
    score <<- createTeams(words)
    names <<- createNamelist(score)
    words <<- createWordlist(words)
  })
}

shinyApp(ui = ui, server = server)
