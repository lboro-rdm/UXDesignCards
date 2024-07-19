library(shiny)
library(bslib)
library(shinythemes)
library(readr)

# Define UI for application
ui <- fluidPage(theme = shinytheme("lumen"),
                titlePanel("Action Learning Bot"),
                
                tags$style(HTML("
    .image-container {
      text-align: center;
      margin-bottom: 10px;
    }
    .alt-text {
      margin-top: 10px;
      font-size: 16px;
      font-style: italic;
      text-align: center;
    }
    .container {
      display: flex;
      flex-direction: column;
      align-items: center;
    }
    .image {
      width: 100%;
      max-width: 800px;
    }
  ")),
                
                p("Welcome to the Action Learning Bot!"),
                p("Take a moment for yourself. Block out your calendar and close your email."),
                p("Think about a challenge or opportunity that you would like to reflect on."),
                p("Spend a few minutes journaling about each question. Even if a question seems irrelevant, it might spark unexpected insights. Keep writing for 3-5 minutes."),
                p("Embrace the journey of discovery and enjoy the process!"),
                
                sidebarLayout(
                  sidebarPanel(
                    p("Click the button below to get a new question."),
                    actionButton("showImage", "Question"),
                    p(),
                    p("This bot was created by Lara Skelly (Loughborough University). The code is shared on ", a("GitHub", href = "https://github.com/lboro-rdm/AuroaActionLearning.git"), " under a CC-BY-NC licence."),
                    p(),
                    p("It was created with the questions which were part of the ", a("AdvancedHE Aurora programme.", href = "https://www.advance-he.ac.uk/programmes-events/developing-leadership/aurora")),
                    p(),
                    h3("If you are new to Action learning..."),
                    p("Action learning is a reflective exercise usually done in a small group. One person discusses a particular situation that they would like more insight on, while the others pose questions as this bot is doing.")
                  ),
                  mainPanel(
                    div(class = "container", 
                        div(class = "image", imageOutput("randomImage")),
                        div(class = "alt-text", textOutput("imageAltText"))
                    )
                  )
                )
)

# Define server logic
server <- function(input, output, session) {
  # Path to the image directory
  img_path <- "images/"
  
  # List all images in the directory
  img_files <- list.files(img_path, full.names = TRUE)
  
  # Read the CSV file containing the alt text
  alt_text <- read_csv("questions.csv", col_names = FALSE, show_col_types = FALSE)
  
  # Function to get a random image and corresponding alt text
  get_random_image <- function() {
    random_img <- sample(img_files, 1)
    img_index <- as.numeric(gsub(".*-(\\d+)\\.jpeg", "\\1", basename(random_img)))
    list(img = random_img, alt = as.character(alt_text[img_index, 1]))
  }
  
  # Initialize with a random image and alt text
  initial_image <- get_random_image()
  selected_img <- reactiveVal(initial_image$img)
  selected_alt_text <- reactiveVal(initial_image$alt)
  
  # Observe the button click event
  observeEvent(input$showImage, {
    random_image <- get_random_image()
    selected_img(random_image$img)
    selected_alt_text(random_image$alt)
  })
  
  # Render the selected image
  output$randomImage <- renderImage({
    list(src = selected_img(), alt = selected_alt_text(), width = "100%")
  }, deleteFile = FALSE)
  
  # Render the alt text
  output$imageAltText <- renderText({
    selected_alt_text()
  })
}

# Run the application
shinyApp(ui = ui, server = server)