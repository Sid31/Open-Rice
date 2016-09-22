library(shiny)
library(ggplot2)
library(leaflet)
library(RColorBrewer)
palette <- brewer.pal(5, 'Set2')
ui <- fluidPage(
	sliderInput(inputId = "size", label = "Choose a size", value = 2, min = 1, max = 6),
	#radioButtons(inputId = "size", label = "Choose a size", c('1'=1, '2'=2, '3'=3, '4'=4)),
	p(),
	#plotOutput("map", click="plot_click"), verbatimTextOutput("coordinates"),
	#radioButtons(inputId = "Pal", label = "Choose a color", c('Turquoise' = palette[1], 'Orange' = palette[2], 'Bluish'=palette[3], 'Pink'=palette[4], 'Lime Green' = palette[5])),
	radioButtons(inputId = "Pal", label = "Choose a Palette", c('Set1' = 'Set1', 'Set2' = 'Set2', 'Set3'= "Set3", 'Blues' = 'Blues', 'Reds' = 'Reds'), inline=T),
	leafletOutput("map", width = "80%", height = "500px"),
	p(),
	p()
)

openrice_data<-read.csv("~/Documents/CAL/openrice/TotAll.csv")
openrice_data<-subset(openrice_data, !is.na(lon)) #need to get rid of missing data, Shiny has issues otherwise
openrice_data$color_type <- as.numeric(openrice_data$simp_type)
server <- function(input, output, session) {
	output$map <- renderLeaflet( {
		leaflet(openrice_data) %>% addProviderTiles("CartoDB.Positron") %>%
		setView(114.1, 22.3, zoom = 11) #start off centered in HK with a far off zoom
		})
					
	observe({
	#pal<-brewer.pal(7, input$Pal)
	pal <- colorNumeric(input$Pal, domain = openrice_data$color_type)
	proxy <- leafletProxy("map", data=openrice_data)
	proxy %>% clearShapes() %>% addCircles(lng = ~lon, lat = ~lat, radius = ~(3*as.numeric(input$size))^2, color='black', weight=1, fillColor = ~pal(as.numeric(simp_type)),  fillOpacity=0.7, popup = ~restaurant_name) %>%
	addLegend("topright", pal=pal, values= ~simp_type, title= "Hong Kong Restaurant Types", opacity=1)
	})	
}
#fillColor=~pal(color_type),

shinyApp(ui = ui, server = server)
