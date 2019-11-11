library(readxl)
library(ggplot2)
library(psych)
library(tidyr)
library(ggplot2)
library(treemapify)
library(dplyr)
library(colorspace)  # install via: install.packages("colorspace", repos = "http://R-Forge.R-project.org")
library(RColorBrewer)
library(reshape2)
library(tidyverse)
library(e1071) 
library(wesanderson)
library(Metrics)
library(countrycode)
library(scales)
library(ggthemes)
library(maps)
library(evaluate)
library(sf)
library(GGally)

#Importing Data
HBRData <- read_excel("C:/Users/carlj/OneDrive/Documents/School-MSBA/Classes/Fall/Data Visualization/Homework1/HBR-CEO-data.xlsx",   col_types = c("numeric", "text", "text", "text", "text", "numeric", "text",  "numeric", "text", "text", "text",       "numeric", "numeric", "numeric",  "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"))
HBRData <- HBRData[1:100,]

#There are two NA cases in Engineering Degree Variable, and both upon research are false
HBRData[is.na(HBRData)] <- 0
HBRData$`ENGINEERING DEGREE` <- gsub("No", "NO", HBRData$`ENGINEERING DEGREE`)

#Creating an averaged Sustainability Rank similar to the given Financial Rank
HBRData$`SUSTAINABILITY RANK` <- rowMeans(HBRData[,19:20])

#Standardizing all CEO names
HBRData$`CEO NAME` <- gsub("[*]","",HBRData$`CEO NAME`)
HBRData$`CEO NAME` <- gsub("-","",HBRData$`CEO NAME`)
HBRData$`CEO NAME` <- gsub( " \"terry\"", "", HBRData$`CEO NAME`)
HBRData$`CEO NAME` <- gsub( " \"pony\"", "", HBRData$`CEO NAME`)
HBRData$`CEO NAME` <- gsub( " \"alfred\"", "", HBRData$`CEO NAME`)
HBRData$`CEO NAME` <- gsub( " \"george\"", "", HBRData$`CEO NAME`)

#Fixing casing issues with CEO Names and Industry
HBRData$`CEO NAME` <- tolower(HBRData$`CEO NAME`)
HBRData$INDUSTRY <- tolower(HBRData$INDUSTRY)
HBRData$COUNTRY <- tolower(HBRData$COUNTRY)
HBRData$MBA <- tolower(HBRData$MBA)
CapStr <- function(y) {
  c <- strsplit(y, " ")[[1]]
  paste(toupper(substring(c, 1,1)), substring(c, 2),
        sep="", collapse=" ")
}
HBRData$`CEO NAME` <- sapply(HBRData$`CEO NAME`, CapStr)
HBRData$INDUSTRY<- sapply(HBRData$INDUSTRY, CapStr)
HBRData$COUNTRY<- sapply(HBRData$COUNTRY, CapStr)
HBRData$MBA<- sapply(HBRData$MBA, CapStr)

#Utilizing a unique color scheme
colourCount = length(unique(HBRData$INDUSTRY))
getPalette = colorRampPalette(brewer.pal(6, "Set1")) #bias=1

#Treeplot. YOU MUST MAKE THE OUTPUT WINDOW (Bottom Right) BIGGER OR ELSE YOU WILL RUN INTO AN ERROR
plot <- ggplot(HBRData, 
               aes(area = `MARKET CAP CHANGE\r\n($BN)`, fill=INDUSTRY, 
                   label = paste(paste(`CEO NAME`, COMPANY, sep = "\n"), 
                                 paste(paste("$", formatC(round(`MARKET CAP CHANGE\r\n($BN)`, 2), format="d", big.mark=","), sep=""), " Bn.", sep=""), sep = "\n"), subgroup=INDUSTRY))+ 
  geom_treemap()+ geom_treemap_subgroup_border(color = "#d4dddd", size = 10)+ 
  geom_treemap_text(place = "topleft", alpha=1.0, colour = "black", 
                    fontface = "plain",size=30, min.size = 0, reflow = F, grow=F, 
                    padding.x = grid::unit(2,"mm"), padding.y = grid::unit(2, "mm"))+ 
  theme(legend.position="bottom") +guides(fill=guide_legend(nrow=2))+ 
  scale_fill_manual(values = getPalette(colourCount))+ 
  theme(plot.background = element_rect(fill = "#acc8d4"))+
  theme(legend.background = element_rect(fill="#d4dddd",size=0.5, 
                                         linetype="solid", colour ="#d4dddd"), 
        legend.title=element_text(size=30), legend.text=element_text(size=20))+
  labs(x="*Chart depicts net growth to each company's market capitalization since the listed CEO assumed office (in billions USD, adjusted for dividends, share issues, and share repurchases).", 
       title = "Looming Giants", subtitle = "Even under the leadership of an excellent CEO, smaller companies still struggle to catch up to industry incumbents.",
       caption = "Source: \"The Best-Performing CEOs in the World 2018\", by HBR Staff, Harvard Business Review, 2018")+
  theme(plot.title = element_text(color="Black", size = 55, face = "bold"),
        axis.title.x= element_text(hjust=0, size = 15, face = "italic"),
        plot.subtitle = element_text(size = 25),
        plot.caption = element_text(size = 15,face="italic")) 

#Output
plot
#Make sure to save this image with the resolution of 2560x1440 when exporting

#-------------Graph 2--------------------------------
#Preparing the data for the second Chart
SelectHBR <- HBRData[,c(2,7,10,11,18,21,1)]

#Setting Names for columns
names(SelectHBR)[7] <- "Final Ranking***"
names(SelectHBR)[5] <- "Financial Ranking*"
names(SelectHBR)[6] <- "Sustainability Ranking**"

#Replacing Yes and No with the proper text
SelectHBR$MBA <- gsub("No","CEOs Without an MBA Degree",SelectHBR$MBA)
SelectHBR$MBA <- gsub("Yes","CEOs With an MBA Degree",SelectHBR$MBA)

#Creating a long Dataframe
HBR_long <- melt(SelectHBR, id.vars=c("CEO NAME","MBA","INSIDER/\r\nOUTSIDER","ENGINEERING DEGREE"))

#BoxPlot
plot2 <- ggplot(HBR_long, aes(x=factor(MBA),y=value,fill=factor(MBA)))+ theme_bw()+
  geom_boxplot() + labs(title="CMP") +facet_wrap(~variable, scales="free")+
  theme(plot.background = element_rect(fill = "#acc8d4"))+
  theme(legend.background = element_rect(fill="#d4dddd",size=0.5, 
                                         linetype="solid", colour ="#d4dddd"), 
        legend.text=element_text(size=10), legend.title = element_blank())+
  scale_fill_manual(values = c("#efe8d1", "#91b8bd"))+
  labs(y="Ranking",
       x="   *Financial Ranking is calculated by taking the average of each CEO's Country-Adjusted Total Shareholder Return ranking, Industry-Adjusted Total Shareholder Return ranking, and change in Market Capitalization ranking.\n **Sustainability Ranking is calculated by taking the average of each CEO's Environmental, Social and Governance (ESG) ranking, and Sustainability and Corporate Social Responsiblity (CSRHub) ranking.\n***Final Ranking is calculated by combining the Financial ranking (weighted at 80%) and the Sustainability ranking (weighted at 20%), omitting CEOs who left office before June 30, 2018.",
       title = "Socially Responsible Education", 
       subtitle = "On average, CEOs with MBA degrees rank higher on sustainability metrics and lower on financial metrics.\nMore MBA programs are developing business leaders who value business ethics over profitability.",
       caption = "Source: \"The Best-Performing CEOs in the World 2018\", by HBR Staff, Harvard Business Review, 2018")+
  theme(plot.title = element_text(color="Black", size = 20, face = "bold"),
        plot.subtitle = element_text(size = 13),
        plot.caption = element_text(size = 8, face="italic"),
        axis.title.x= element_text(hjust=0, size = 8, face = "italic"),
        legend.position="bottom", 
        axis.text.x = element_blank(), 
        axis.ticks.x = element_blank(), 
        axis.text.y=element_text(color="black"), 
        panel.grid.major.x = element_blank())+ 
  expand_limits(y=1)+ scale_y_reverse()

plot2
#Save at 1280x720 resolution