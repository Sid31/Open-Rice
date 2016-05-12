options(stringsasfactors=F)
setwd('/Users/christopherlee/Documents/CAL/openrice/')
library('plyr')
library('dplyr')
Sys.setlocale(category = "LC_ALL", locale = "zh_CN.UTF-8")
R<-read.csv('Island_Formatted.csv') #HK Island restaurants database 
R$restaurant_name<-gsub('_{2,}','',R$restaurant_name) #because of encoding errors, spaces and Chinese characters are replaced with _. This line deletes the Chinese character _
R$restaurant_name<-gsub('_',' ', R$restaurant_name) #This line replaces the remaining single '_' with spaces
R<-R[-which(R[,1]=='restaurant name'),] #In the openrice scraper, every new page included a set of headers. This deletes all extraneous headers
#next 3 lines replace the string prices with numerics
prices<-unique(R$price) 
avg_price<-c(75,150, 300, 40, 600, 1200)
R$avg_price<-as.numeric(as.character(mapvalues(R$price,prices,avg_price)))
R$smiles<-as.numeric(as.character(R$smiles))
R$frowns<-as.numeric(as.character(R$frowns))

plot(count(R$type1), las=2, cex=0.1)
names<-count(R$type1)$x
count1<-count(R$type1)$freq
barplot(count1,names.arg=names, cex.names=0.5, las=2)

J<-read.csv('Kowloon_Formatted.csv') #Kowloon restaurant database
J$restaurant_name<-gsub('_{2,}','',J$restaurant_name) #
J$restaurant_name<-gsub('_',' ', J$restaurant_name)
J<-J[-which(J[,1]=='restaurant name'),]
J$avg_price<-as.numeric(as.character(mapvalues(J$price,prices,avg_price)))
J$smiles<-as.numeric(as.character(J$smiles))
J$frowns<-as.numeric(as.character(J$frowns))

NT<-read.csv('NT_Formatted.csv') #New Territories restaurant database
NT$restaurant_name<-gsub('_{2,}','',NT$restaurant_name)
NT$restaurant_name<-gsub('_',' ', NT$restaurant_name)
NT<-NT[-which(NT[,1]=='restaurant name'),]
NT$avg_price<-as.numeric(as.character(mapvalues(NT$price,prices,avg_price)))
NT$smiles<-as.numeric(as.character(NT$smiles))
NT$frowns<-as.numeric(as.character(NT$frowns))
NT<-unique(NT)

OUT<-read.csv('Outlying_Formatted.csv')
OUT$restaurant_name<-gsub('_{2,}','',OUT$restaurant_name)
OUT$restaurant_name<-gsub('_',' ', OUT$restaurant_name)
OUT<-OUT[-which(OUT[,1]=='restaurant name'),]
OUT$avg_price<-as.numeric(as.character(mapvalues(OUT$price,prices,avg_price)))
OUT$smiles<-as.numeric(as.character(OUT$smiles))
OUT$frowns<-as.numeric(as.character(OUT$frowns))
OUT<-unique(OUT)

Total<-rbind(R,J,NT, OUT)
relocated<-grep('Relocated', Total$restaurant_name, ignore.case=TRUE)
Total<-Total[-relocated,]
Chinese<-c('Sichuan','Hakka','Beijing','Fujian', 'Chiu Chow', 'Shanghainese', 'Taiwan', 'Northeastern', 'Yunnan', 'Jingchuanhu', 'Hunan', 'Hot Pot', 'Shanxi (Shan)', 'Noodles/Rice Noodles', 'Shanghai', 'Shandong', 'Shanxi (Jin)', 'Guangxi', 'Shunde', 'Jiang-Zhe', 'Chinese BBQ', 'Congee', 'Village Food', 'Stir Fry', 'Stir-Fry', 'Taiwanese Drink', 'Guizhou', 'Herbal Cuisine', 'Herbal Tea','Huaiyang')
Western<-c('German', 'Belgian', 'Swiss', 'French', 'Italian', 'Spanish', 'Russian', 'British', 'Australian', 'Mediterranean', 'Dutch', 'Portuguese', 'Western', 'American', 'Western Restaurant', 'Irish', 'Fast Food')
Asian<-c('Korean', 'Japanese', 'Malaysian', 'Vietnamese', 'Thai', 'Singaporean', 'Indonesian', 'Philippines')
Others<-c('Bakery', 'Wine/Cigar', 'Dessert', 'Coffee Shop', 'Snack Shop & Deli', 'Peruvian', 'Takeaway', 'Mexican', 'Chocolate/Candy Shop', 'BBQ Ground', 'Upper-floor Cafe', 'Bar', 'BBQ', 'Karaoke', 'Club House', 'Seafood')
SouthAsian_MiddleEast<-c('Indian', 'Nepalese', 'Middle Eastern', 'Sri Lanka', 'Xinjiang', 'Turkish', 'Egyptian')
HK<-c('Guangdong', 'Hong Kong Style', 'Tea Restaurant', 'Food Stall Noodles', 'Chinese Buns', 'Dim Sum', 'Dim Sum Restaurant')
sub_cat<-rep(0,nrow(Total))
#Since the total OpenRice categories are too extensive to easily visualize, I've manuallly grouped them into fewer categories
#The following for loop iterates through the data and assigns one of 7 categories to the data
for (i in 1:nrow(Total)){
	if (Total$type1[i] %in% Chinese) {
		sub_cat[i]=1
		Total$simp_type[i]='Chinese'
	}		
	else if (Total$type1[i] %in% Western) {
		sub_cat[i]=2
		Total$simp_type[i]='Western'
		}
	else if (Total$type1[i] %in% Asian) {
		sub_cat[i]=3
		Total$simp_type[i]='Asian'
		}
	else if (Total$type1[i] %in% Others) {
		sub_cat[i]=4
		Total$simp_type[i]='Others'
	} 
	else if (Total$type1[i] %in% SouthAsian_MiddleEast){
		sub_cat[i]=5
		Total$simp_type[i]='South Asian'
	}
	else if (Total$type1[i] %in% HK) {
		sub_cat[i]=6
		Total$simp_type[i]='Hong Kong'
	}
	else {
		sub_cat[i]=7
		Total$simp_type[i]="International"
	}
}
Total$simp_type<-as.factor(Total$simp_type)
#levels(Total$simp_type)<-c('Chinese', 'Western', 'Asian', 'Others', 'South Asian', 'Hong Kong', 'International')
Total$type1[which(sub_cat==7)]
library('RColorBrewer')
Acccent<-brewer.pal(7,'Accent') #1. Green. 2. Purple. 3. Orange. 4. Yellow. 5. Blue. 6. Magenta 7. Brown


#Mapping
readRDS('HKG_adm0.rds')->m0
readRDS('HKG_adm1.rds')->m1

RB<-c(brewer.pal(12,'Set3'), brewer.pal(6,'Set2'))
Accent<-c(brewer.pal(7, 'Accent'))
Heat<-heat.colors(18, alpha=0.9)
CM<-cm.colors(18, alpha=0.9)
centroid<-matrix(nrow=18, ncol=2)
for (i in 1:18) {
	centroid[i,]<-apply(m1@polygons[[i]]@Polygons[[1]]@coords,2,mean)
	}
	
plot(m1, col=Heat)
points(centroid, pch=21, bg='black')

#need to map Open Rice regions to the 18 Hong Kong Districts
regions<-m1@data$NAME_1
read.csv('regions.csv')->region_mapping #file contains names of open rice regions
apply(region_mapping,2,as.character)->region_mapping
Districts<-vector(mode='character',length=length(Total$region))
for (i in 1:length(Total$region)){
	Districts[i]<-region_mapping[which(region_mapping[,1]==as.character(Total$region[i])),2]
}
Total$Districts<-Districts
Total$DistrictValue<-rep(0,length(Total$region))
Total$DistrictValue<-match(Total$Districts, regions)
RandomPoints<-matrix(nrow=nrow(Total), ncol=2)

order<-rep(0,18)
for(i in 1:18){
	order[i]<-attributes(m1@polygons[[i]])@plotOrder[1] 
	#because the shapefile for Hong Kong includes many distinct polygons
	#representing islands and whatnot separated by district, the biggest polygon for each district as defined by plotOrder is chosen
}
for(i in 1:nrow(Total)){
	RandomPoints[i,]<-spsample(m1@polygons[[Total$DistrictValue[i]]]@Polygons[[order[Total$DistrictValue[i]]]], 1, 'random')@coords[1,]
}
#spsample randomly picks a point from within the bounded box. The shapefile for Hong Kong includes many
#The graphing
leg.txt<-c('Chinese','Western','Asian','Others', 'South Asian/Middle Eastern', 'Hong Kong', 'International')
plot(m1, main='Types of Restaurants in Hong Kong')
points(RandomPoints, cex=0.03, pch=23, col=Accent[sub_cat], bg=Accent[sub_cat], alpha=0.9)
legend('topleft',leg.txt,fill=Accent, cex=0.7)

#Multiple hists
par(mfrow=c(3,6))
par(mar=c(2.5,1,2.5,1))
for (i in 1:18) {
	hist(Total$avg_price[which(Total$DistrictValue==i)], main=paste('Restaurant Prices in',regions[i], sep='\n'), xlab='Prices', col=Accent, 25, cex.main=0.8, cex.lab=0.4, cex.axis=0.3)
}
for (i in 1:18) {
	plot(density(Total$avg_price[which(Total$DistrictValue==i)], bw=100), main=paste('Restaurant Prices in',regions[i], sep='\n'), xlab='Prices', xlim=c(0, 1500), ylim=c(0, 0.0035), col='green', 25, cex.main=0.8, cex.lab=0.4, cex.axis=0.3)
}
par(mfrow=c(3,6))
par(mar=c(2.5,1,2,1))
for (i in 1:18) {
	barplot(table(Total$simp_type[which(Total$DistrictValue==i)])/length(which(Total$DistrictValue==i)), main=paste('Restaurant types in', regions[i], sep='\n'), xlab='Restaurant Types', cex.names=.4, las=3.5, col=Accent, ylim=c(0,.7), cex.main=0.6)
}



rated<-which(Total$smiles>0)
ddply(Total, .(avg_price), summarize, mean=round(mean(smiles),2), sd=round(sd(smiles),2))
ddply(Total, .(avg_price), summarize, mean=mean(frowns))
ddply(Total, .(Districts, simp_type), nrow)->Breakdown
ddply(Breakdown, .(Districts, simp_type), mutate, V2=V1/sum(Breakdown$V1[which(Breakdown[,1]==Districts)])) #HOLY SHIT THIS WORKS
ddply(Breakdown, .(simp_type), summarize, sum(V1))->Restaurant_Types
colnames(Restaurant_Types)[2]<-'Number'
Restaurant_Types$Ratio<-Restaurant_Types$Number/sum(Restaurant_Types$Number)
priceFrame<-ddply(Total, .(Districts), summarize, mean=mean(avg_price))
priceFrame<-cbind(priceFrame, 1:18)
colnames(priceFrame)[3]<-'id'
library('ggmap')
library('rgeos')

Total$address<-as.character(Total$address) #call Google api and translate addresses to coordinates
	
ggm1<-fortify(m1)
HK1<-qmap(location=c(114.11, 22.22, 114.233, 22.335), maptype= 'satellite', zoom=12)

ggm1$id<-as.numeric(ggm1$id)
ggm3<-left_join(ggm1, priceFrame)
p<-ggplot() +geom_polygon(data=ggm3, aes(x=long, y=lat, group=group, fill=mean), color='grey', lwd=0.1) + scale_fill_continuous(low= '#FFFF99', high = '#BF5B17', name='Price $') + ggtitle('Hong Kong Restaurants') + labs(x='', y='')

TotAll<-read.csv('TotAll.csv')
pal<-c(brewer.pal(5, 'Blues')[2:4], brewer.pal(5, 'Set2')[c(2,4,5)], 'black')
p1<-ggplot() + geom_polygon(data=ggm3,  aes(x=long, y=lat)) + geom_point(aes(x=lon, y=lat, colour=simp_type), size=0.02, data=TotAll) + coord_cartesian(xlim=c(114.02, 114.31), ylim=  c(22.19, 22.4))
p1<-ggplot() + geom_polygon(data=ggm3, aes(x=long, y=lat, group=id), colour='white', fill=NA) + geom_point(aes(x=lon, y=lat, colour=simp_type), size=0.01, data=TotAll) + coord_cartesian(xlim=c(114.12, 114.28), ylim=  c(22.19, 22.4))
p+ geom_point(aes(x=lon, y=lat, colour=simp_type), size=0.01, data=TotAll) + coord_cartesian(xlim=c(114.07, 114.28), ylim=  c(22.19, 22.4)) + scale_colour_manual(values=pal)
p+ geom_point(aes(x=jitter(lon,1/13), y=jitter(lat, 1/13), colour=simp_type, size = smiles), alpha=0.8, data=TotAll) + coord_map(xlim=c(113.84, 114.35), ylim=  c(22.18, 22.56)) + scale_colour_manual(values=pal, name='Cuisine Type') + scale_size_continuous(range=c(0,0.15), guide=FALSE)
#HK1 + geom_polygon(aes(x=long, y=lat, group=id), data=ggm3, colour = NA, fill=NA, alpha=0.4) + geom_point(aes(x=lon, y=lat, colour=simp_type), size=0.002, data=TotAll) + ggtitle('Hong Kong Restaurants\n香港餐廳') + scale_colour_discrete(name='Cuisine Type') + theme(text=element_text(size=16, family="PMingLiU"))
HK1 + geom_polygon(aes(x=long, y=lat, group=id), data=ggm3, colour = NA, fill=NA, alpha=0.4) + geom_point(aes(x=lon, y=lat, colour=simp_type, size=smiles), alpha=0.7, data=TotAll) + ggtitle('Hong Kong Restaurants\n香港餐廳') + scale_colour_manual(values=pal, name='Cuisine Type') + scale_size_continuous(range=c(0,0.2), guide=FALSE) +  theme(plot.title=element_text(size=16, family="PMingLiU"), legend.key = element_rect(fill = "white"), panel.border = element_rect(fill = NA, colour = "orange", size = 2))

glookup<- function(names, total, startat=1) {
	loc3=data.frame(lon=numeric(total), lat=numeric(total))	
	for (i in startat:(startat+total)) {
		k<-geocode(paste(names[i], 'Hong Kong', sep= ', '))
		loc3$lon[i-startat]<-k$lon
		loc3$lat[i-startat]<-k$lat
		}
	return(loc3)
}
fix<-numeric()

for(i in 1:nrow(TotAll)){
	if(is.na(TotAll$lon[i]) | TotAll$lon[i]<114){
		fix=append(fix,i)
		#TotAll[i,c(16,17)]
	}
}
start<-Sys.time()
for(i in 1:length(fix)){
	k<-geocode(paste(Total$address[fix[i]], 'Hong Kong', sep=', '))
	TotAll[fix[i],c(16,17)]<-c(k$lon, k$lat)
}
end<-Sys.time()

which(TotAll$lon<114.1096 & TotAll$lon>114.1094)->Dupes
start<-Sys.time()
for(i in 1:length(Dupes)){
	k<-geocode(paste(Total$address[Dupes[i]], 'Hong Kong', sep=', '))
	TotAll[Dupes[i],c(16,17)]<-c(k$lon, k$lat)
}
end<-Sys.time()
coords2200<-glookup(Total$address, 2000, startat=6500)