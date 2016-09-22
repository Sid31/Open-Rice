library(shiny)
library(ggplot2)
library(leaflet)
library(RColorBrewer)

openrice_data<-read.csv("~/Documents/CAL/openrice/TotAll.csv", stringsAsFactors=F)
openrice_data<-subset(openrice_data, !is.na(lon)) #need to get rid of missing data, Shiny has issues otherwise
openrice_data$color_type <- as.numeric(as.factor(openrice_data$simp_type))


ui <- fluidPage(
	sliderInput(inputId = "size", label = "Choose a size", value = 2, min = 1, max = 6, width='300px'),
	radioButtons(inputId = "Pal", label = "Choose a Palette", c('Set1' = 'Set1', 'Set2' = 'Set2', 'Set3'= "Set3", 'Blues' = 'Blues', 'Reds' = 'Reds', 'Custom' = 'Custom'), inline=T),
	p(),
	#radioButtons(inputId = "Pal", label = "Choose a color", c('Turquoise' = palette[1], 'Orange' = palette[2], 'Bluish'=palette[3], 'Pink'=palette[4], 'Lime Green' = palette[5])),
	
	leafletOutput("map", width = "80%", height = "500px"),
	p(),
	p()
)

server <- function(input, output, session) {
	output$map <- renderLeaflet( {
		leaflet(openrice_data) %>% addProviderTiles("CartoDB.Positron") %>%
		setView(114.1, 22.3, zoom = 11) #start off centered in HK with a far off zoom
		})
		#reactive({
		#	pal <- colorBin(input$Pal, domain = openrice_data$color_type, n=7)
		#})
					
	observe({	
		pal <- if(input$Pal != "Custom") colorFactor(input$Pal, domain = openrice_data$simp_type) else colorFactor(palette = c(brewer.pal(5, 'Blues')[2:4], brewer.pal(5, 'Set2')[c(2,4,5)], 'black'), domain= openrice_data$simp_type)
		#c(brewer.pal(5, 'Blues')[2:4], brewer.pal(5, 'Set2')[c(2,4,5)], 'black')
		proxy <- leafletProxy("map", data=openrice_data)
		proxy %>% clearShapes() %>% addCircles(lng = ~lon, lat = ~lat, radius = ~(3*as.numeric(input$size))^2, color='black', weight=1, fillColor = ~pal(simp_type),  fillOpacity=0.7, popup = ~restaurant_name) 
	})	
	
	observe({
		#pal <- colorFactor(input$Pal, domain = openrice_data$simp_type)
		pal <- if(input$Pal != "Custom") colorFactor(input$Pal, domain = openrice_data$simp_type) else colorFactor(palette = c(brewer.pal(5, 'Blues')[2:4], brewer.pal(5, 'Set2')[c(2,4,5)], 'black'), domain= openrice_data$simp_type)
		proxy <- leafletProxy("map", data= openrice_data)
		#Remove any existing legend
		proxy %>% clearControls() %>% addLegend("topright", pal=pal, values= ~simp_type, title= "Hong Kong Restaurant Types", opacity=1)
	})
}


shinyApp(ui = ui, server = server)
