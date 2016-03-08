options(stringsasfactors=F)
setwd('/Users/christopherlee/Documents/CAL/openrice/')
library('plyr')
R<-read.csv('Island_restaurants3b.csv')
R$restaurant_name<-gsub('_{2,}','',R$restaurant_name)
R$restaurant_name<-gsub('_',' ', R$restaurant_name)
R<-R[-which(R[,1]=='restaurant name'),]
prices<-unique(R$price)
avg_price<-c(75,150, 300, 40, 600, 1200)
R$avg_price<-as.numeric(as.character(mapvalues(R$price,prices,avg_price)))
R$smiles<-as.numeric(as.character(R$smiles))
R$frowns<-as.numeric(as.character(R$frowns))

plot(count(R$type1), las=2, cex=0.1)
names<-count(R$type1)$x
count1<-count(R$type1)$freq
barplot(count1,names.arg=names, cex.names=0.5, las=2)

J<-read.csv('Kowloon_Formatted.csv')
J$restaurant_name<-gsub('_{2,}','',J$restaurant_name)
J$restaurant_name<-gsub('_',' ', J$restaurant_name)
J<-J[-which(J[,1]=='restaurant name'),]
J$avg_price<-as.numeric(as.character(mapvalues(J$price,prices,avg_price)))
J$smiles<-as.numeric(as.character(J$smiles))
J$frowns<-as.numeric(as.character(J$frowns))

NT<-read.csv('NT_Formatted.csv')
NT$restaurant_name<-gsub('_{2,}','',NT$restaurant_name)
NT$restaurant_name<-gsub('_',' ', NT$restaurant_name)
NT<-NT[-which(NT[,1]=='restaurant name'),]
NT$avg_price<-as.numeric(as.character(mapvalues(NT$price,prices,avg_price)))
NT$smiles<-as.numeric(as.character(NT$smiles))
NT$frowns<-as.numeric(as.character(NT$frowns))
NT<-unique(NT)

Total<-rbind(R,J,NT)
Chinese<-c('Sichuan','Hakka','Beijing','Fujian', 'Chiu Chow', 'Shanghainese', 'Taiwan', 'Northeastern', 'Yunnan', 'Jingchuanhu', 'Hunan', 'Hot Pot', 'Shanxi (Shan)', 'Noodles/Rice Noodles', 'Shanghai', 'Shandong')
Western<-c('German', 'Belgian', 'Swiss', 'French', 'Italian', 'Spanish', 'Russian', 'British', 'Australian', 'Mediterranean', 'Dutch', 'Portuguese', 'Western', 'American', 'Western Restaurant')
Asian<-c('Korean', 'Japanese', 'Malaysian', 'Vietnamese', 'Thai', 'Singaporean', 'Indonesian', 'Xinjiang')
Others<-c('Bakery', 'Wine/Cigar', 'Dessert', 'Coffee Shop', 'Snack Shop & Deli', 'Peruvian', 'Takeaway', 'Mexican', 'Chocolate/Candy Shop')
SouthAsian<-c('Indian', 'Nepalese', 'Middle Eastern')
HK<-c('Guangdong', 'Hong Kong Style')
sub_cat<-rep(0,nrow(Total))
for (i in 1:nrow(Total)){
	if (R$type1[i] %in% Chinese) {
		sub_cat[i]=1
	}		
	else if (R$type1[i] %in% Western) {
		sub_cat[i]=2
		}
	else if (R$type1[i] %in% Asian) {
		sub_cat[i]=3
		}
	else if (R$type1[i] %in% Others) {
		sub_cat[i]=4
	} 
	else if (R$type1[i] %in% SouthAsian){
		sub_cat[i]=5
	}
	else if (R$type1[i] %in% HK) {
		sub_cat[i]=6
	}
	else {
		sub_cat[i]=7
	}
}

new_cats<-c(rep('Chinese', length(Chinese)), rep('Western', length(Western)), rep('Asian', length(Asian)), rep('Others',length(Others)), rep('SouthAsian', length(SouthAsian)), rep('Hong Kong', length(HK)), rep('International', length(unique(Total$type1[which(sub_cat==7)]))))

#Mapping
readRDS('HKG_adm0.rds')->m0
readRDS('HKG_adm1.rds')->m1
library('RColorBrewer')
RB<-c(brewer.pal(12,'Set3'), brewer.pal(6,'Set2'))
centroid<-matrix(nrow=18, ncol=2)
for (i in 1:18) {
	centroid[i,]<-apply(m1@polygons[[i]]@Polygons[[1]]@coords,2,mean)
	}
	
plot(m1, col=RB)
points(centroid, pch=21, bg='black')

regions<-m1@data$NAME_1
new_regions<-vector(mode='character',length=length(Total$region))
for (i in 1:length(new_regions)){
	if (Total$region[i] %in% c('Central', 'Sheung Wan', 'Western District', 'Admiralty', 'Mid-Levels')) {
		new_regions[i]='Central and Western'
	}
	else if (Total$region[i] %in% c('Aberdeen', 'Stanley', 'Shek O')) {
		new_regions[i]='Southern'
	}
}

spsample(m1@polygons[[1]]@Polygons[[1]], 10, 'random')