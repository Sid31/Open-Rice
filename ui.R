library(shiny)
ui <- fluidPage(
	titlePanel("OpenRice Interactive Map"),
	sliderInput(inputId = "size", label = "Choose a size", value = 2, min = 1, max = 6, width='300px'),
	radioButtons(inputId = "Pal", label = "Choose a Palette", c('Set1' = 'Set1', 'Set2' = 'Set2', 'Set3'= "Set3", 'Blues' = 'Blues', 'Reds' = 'Reds', 'Custom' = 'Custom'), inline=T),
	p(),
	#radioButtons(inputId = "Pal", label = "Choose a color", c('Turquoise' = palette[1], 'Orange' = palette[2], 'Bluish'=palette[3], 'Pink'=palette[4], 'Lime Green' = palette[5])),
	
	leafletOutput("map", width = "80%", height = "500px"),
	p(),
	p()
)