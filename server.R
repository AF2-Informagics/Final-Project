# setwd("~/Documents/info201_sp17/Final-Project")
source(file = "scripts/dataframe.R")
source(file = "scripts/classroom.R")
source(file = "plot.R")

# mutate the dataframe to include breaks according to the desired number of available classrooms and add 
# corresponding icons to indicate the number
mutate(available.df.num.new, group = cut(num, breaks = c(0, 2, 5, Inf), labels = c("orange", "blue", "green"))) -> available.df.num.new
quakeIcons <- iconList(orange = makeIcon("markers-soft2.png", iconHeight = 32, iconWidth = 24),
                  blue = makeIcon("markers-soft4.png", iconHeight = 32, iconWidth = 24),
                  green = makeIcon("markers-soft3.png", iconHeight = 32, iconWidth = 24))

shinyServer(function(input, output) {
  # Handle and set the data to react in the visualization tree
  m <- reactive({
    a <- get(input$in4)
    x <-
      a %>% data.frame %>% mutate(Prereq = replace(Prereq, is.na(Prereq), "None")) %>%
      mutate(NEWCOL = NA) %>% distinct
  })
  
  # Render a plotly object that return a pie graph
  output$pie <- renderPlotly({
    return(BuildPie(data))
  })
  
  
  output$Hierarchy <- renderUI({
    Hierarchy = names(m())
    Hierarchy = head(Hierarchy, -1)
    selectizeInput(
      "Hierarchy",
      "Tree Hierarchy",
      choices = Hierarchy,
      multiple = T,
      selected = Hierarchy,
      options = list(plugins = list('drag_drop', 'remove_button'))
    )
  })
  
  network <- reactiveValues()
  
  observeEvent(input$d3_update, {
    network$nodes <- unlist(input$d3_update$.nodesData)
    activeNode <- input$d3_update$.activeNode
    if (!is.null(activeNode))
      network$click <- jsonlite::fromJSON(activeNode)
  })
  
  observeEvent(network$click, {
    output$clickView <- renderTable({
      as.data.frame(network$click)
    }, caption = 'Last Clicked Node', caption.placement = 'top')
  })
  
  
  TreeStruct = eventReactive(network$nodes, {
    df = m()
    if (is.null(network$nodes)) {
      df = m()
    } else{
      x.filter = tree.filter(network$nodes, m())
      df = ddply(x.filter, .(ID), function(a.x) {
        m() %>% filter_(.dots = list(a.x$FILTER)) %>% distinct
      })
    }
    df
  })
  
  observeEvent(input$Hierarchy, {
    output$d3 <- renderD3tree({
      if (is.null(input$Hierarchy)) {
        p = m()
      } else{
        p = m() %>% select(one_of(c(input$Hierarchy, "NEWCOL"))) %>% unique
      }
      
      d3tree(
        data = list(
          root = df2tree(struct = p, rootname = input$in4),
          layout = 'collapse'
        ),
        activeReturn = c('name', 'value', 'depth', 'id'),
        height = 18
      )
    })
  })
  
  observeEvent(network$nodes, {
    output$results <- renderPrint({
      str.out = ''
      if (!is.null(network$nodes))
        str.out = tree.filter(network$nodes, m())
      return(str.out)
    })
  })
  
  output$table <- renderTable(expr = {
    TreeStruct() %>% select(-NEWCOL)
  })
  
  # Render a map with setted position and zoom levels, add markers with pop-up information and
  # different colors to indicate the number of available rooms inside the building
  output$map <- renderLeaflet({
    leaflet(data = available.df.num.new) %>%
      addProviderTiles(providers$Esri.NatGeoWorldMap) %>%
      setView(lat = 47.656721,
              lng = -122.309054,
              zoom = 16) %>%
      addMarkers(
        icon = ~quakeIcons[group],
        lng = building$long,
        lat = building$lat,
        popup = paste0(
          "<strong>",
          building$full_name,
          " (",
          building$abbr,
          ") ",
          "</strong>", "<br />", "number of classroom available: ", available.df.num.new$num,
          "<br />", available.df.new$Room
        ))
  })
  
  # Render a table including all the buildings and rooms within them that are currently available
  output$maptable <- DT::renderDataTable(DT::datatable({
    data <- available.df.new
  }, rownames = FALSE, options = list(pageLength = 100)))
  
  # Render a table including all the classes and filter data based on selections
  output$vtable <- DT::renderDataTable(DT::datatable({
    data <- df_for_table
    if (input$building != "All") {
      data <- data[data$Building == input$building, ]
    }
    if (input$course != "All") {
      data <- data[data$Course == input$course, ]
    }
    if (input$lecturer != "All") {
      data <- data[data$Lecturer == input$lecturer, ]
    }
    data
  },rownames = FALSE))
})

