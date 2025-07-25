# Web Scraping the data of North Carolina Senators

# Web Scraping and Analysis of Scrap Data
# The code runs very slow so, run them in batches i.e batches 1-4

# BATCH 1
library(tidyverse)
library(rvest)
library(purrr)
library(polite)
library(data.table)
library(sf)
library(ggplot2)
library(rgdal)

# First, create a session object using bow(). You can put a host and path in the bow()
# function, not just the host
session = bow("https://www.ncleg.gov/Members/MemberList/S")

# now, let's retrieve the first page of results
res = scrape(session)

#BATCH 2
# next, looking at the Chrome inspector, let's find the table element that
# contains the list of senators.
senator_grid_names = html_elements(res, "div.col-4.col-md-5.pr-0.text-right")
senator_grid_names

# Get all the senator links from the grid
links = html_elements(senator_grid_names, "a") %>% html_attr("href")
links

# BATCH 3
senator_info = list()
i = 1

#Loop through all the senator links
for (link in links) {
  print(paste("https://www.ncleg.gov", link, sep=""))
  
  # Go to senator link
  senator_session = bow(paste("https://www.ncleg.gov", link, sep=""))
  senator_res = scrape(senator_session)
  title = html_element(senator_res, ".section-title") %>% html_text2() %>% strsplit(split = "Senator ")
  party_district = html_element(senator_res, "h6.text-nowrap") %>% html_text2() %>% strsplit(split = " - ")
  term = html_element(senator_res, "div.col-12.col-md-7.col-lg-9.col-xl-6 p") %>% html_text2()
  
  name = title[[1]][2] %>% strsplit(split = " \\(")  %>% `[[`(c(1,1))
  party = party_district[[1]][1]
  district = party_district[[1]][2] %>% strsplit(split = "District ")  %>% `[[`(c(1,2))
  
  data = list("Senator"=name, "Party"=party, "District"=district, "Terms"=term)
  # senator_info <- append(senator_info, data)
  senator_info[[i]] <- data
  i <- i + 1
}

# BATCH 4
senators <- bind_rows(senator_info)
senators

#shp_file <- st_read("SL 2022-2.shp")
shp_file <- read_sf("SL 2022-2.shp")

shp_file
summary(shp_file)

write_csv(senators, "senators.csv")

# merge on common variable, here called 'District'
joined_files <- merge(senators, shp_file, by.x='District', by.y ='DISTRICT')
joined_files$Terms_int <- joined_files$Terms %>% strsplit(split = " \\(") %>% lapply(`[`, 1) %>% as.character %>%
  strsplit(split = "\\+") %>% lapply(`[`, 1) %>% as.numeric
joined_files

total_party_terms <- aggregate(list("Total Terms" = joined_files$Terms_int), by=list(Party=joined_files$Party), FUN="sum", na.rm=TRUE, na.action=NULL)
avg_party_terms <- aggregate(list("Average Terms" = joined_files$Terms_int), by=list(Party=joined_files$Party), FUN="mean", na.rm=TRUE, na.action=NULL)
total_party_terms
avg_party_terms

# Selects only Republicans
plot_data = as.data.table(joined_files)
republicans_nc = filter(plot_data, Party == "Republican") 

#Plot 1: shows the entire North Carolina
ggplot() +
  geom_sf(data=shp_file)

#Plot 2: shows the Republican Senators in North Carolina and their terms
ggplot() +
  geom_sf(data=republicans_nc, aes(geometry = geometry, fill=Terms_int), lwd=0) +
  scale_fill_fermenter(palette="Greens")+
  ggtitle("Republican Senators in NC and Their Terms")

#Plot 3: shows all the Senators in North Carolina and their terms
ggplot() +
  geom_sf(data=plot_data, aes(geometry = geometry, fill=Terms_int), lwd=0) +
  scale_fill_fermenter(palette="Reds")+
  ggtitle("Senators in NC and Their Terms")
