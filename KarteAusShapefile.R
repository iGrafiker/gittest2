library(sp)
library(RColorBrewer)
library(maptools)

setwd("/Users/Holger/Google Drive/RDaten/")

# get spatial data for Germany on county level
#con <- url("http://www.igrafik.de/rdaten/DEU_adm3.RData")
#print(load(con))
#close(con)

# from your data file working directory 
load ("Karten/DEU_adm3.RData")

### DATA PREP ###
# loading the unemployment data
unempl <- read.delim2(file="arbeitslosigkeit.txt", header = TRUE, sep = "\t",
                      dec=",", stringsAsFactors=F)
# due to Mac OS encoding, otherwise not needed
gadm_names <- iconv(gadm$NAME_3, "ISO_8859-2", "UTF-8")   

# fuzzy matching of data: quick & dirty
# caution: this step takes some time ~ 2 min.

# parsing out "Städte"
gadm_names_n <- gsub("Städte", "", gadm_names) 

total <- length(gadm_names)
# create progress bar
pb <- txtProgressBar(min = 0, max = total, style = 3) 
order <- vector()
for (i in 1:total){  
  order[i] <- agrep(gadm_names_n[i], unempl$Landkreis, 
                    max.distance = 0.2)[1]
  setTxtProgressBar(pb, i)               # update progress bar
}

# choose color by unemployment rate
col_no <- as.factor(as.numeric(cut(unempl$Wert[order],
                                   c(0,2.5,5,7.5,10,15,100))))
levels(col_no) <- c(">2,5%", "2,5-5%", "5-7,5%",
                    "7,5-10%", "10-15%", ">15%")
gadm$col_no <- col_no
myPalette<-brewer.pal(6,"Purples")

nc1 <- readShapePoly("Karten/DEU_adm/DEU_adm1.shp", proj4string=CRS("+proj=longlat +datum=NAD27"))
nc3 <- readShapePoly("Karten/DEU_adm/DEU_adm3.shp", proj4string=CRS("+proj=longlat +datum=NAD27"))
par(mar=c(0,0,0,0))
plot(nc3, col=myPalette[col_no], border=grey(.9), lwd=.5)
plot(nc1, col=NA, border=grey(.5), lwd=1, add=TRUE)

