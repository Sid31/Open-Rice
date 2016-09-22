library(shiny)
library(ggplot2)
library(leaflet)
library(RColorBrewer)

openrice_data<-read.csv("~/Documents/CAL/openrice/TotAll.csv", stringsAsFactors=F)
openrice_data<-subset(openrice_data, !is.na(lon)) #need to get rid of missing data, Shiny has issues otherwise
openrice_data$color_type <- as.numeric(as.factor(openrice_data$simp_type))

server <- function(input, output, session) {
	output$map <- renderLeaflet( {
		leaflet(openrice_data) %>% addProviderTiles("CartoDB.Positron") %>%
		setView(114.1, 22.3, zoom = 11) #start off centered in HK with a far off zoom
		})
		#reactive({
		#	pal <- colorBin(input$Pal, domain = openrice_data$color_type, n=7)
		#})
					
	observe({	
		#Create palette based on radioButtons input. The buttons all correspond to already defined palette functions, except for Custom, which has its own special construction
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
