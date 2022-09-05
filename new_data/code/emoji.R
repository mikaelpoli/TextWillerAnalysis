#### PACKAGES ####

library(tidyverse)
library(rvest)
library(XML)
library(snakecase)

#### wd ####

# setwd("./new_data/code") 

#### DATA ####

### TextWiller's mattivio2 dictionary

load("../results/mattivio.rda")

### Fetch emoji list

# Start by reading a HTML page with library(XML):

url <- "http://www.unicode.org/emoji/charts/full-emoji-list.html"
emoji <-readHTMLTable(url)

emoji <- emoji$'NULL'

#### CLEANING ####

# Remove header 

emoji <- emoji[-1, ]

# Extract only keyword and code

e1 <- emoji %>% 
  select(V2, V15) %>%
  relocate(V15, .before = V2) %>%
  rename(keyword = V15, code = V2)

# Remove all rows containing headers

e2 <- e1[(!e1$code == "Code") & (!e1$keyword == "CLDR Short Name"), ]

# Remove NAs

e2 <- na.omit(e2)

# Split cells where "code" contains more than one element into separate columns
# and only keep the first code string

e2[c('code1', 'code2')] <- str_split_fixed(e2$code, ' ', 2)

e2 <- e2 %>% 
  select(keyword, code1) %>%
  rename(code = code1)

# Remove punctuation in "keyword" elements

e2$keyword1 <- gsub(":", "", e2$keyword)
e2$keyword1 <- tolower(e2$keyword1)
e2$keyword1 <- to_snake_case(e2$keyword1)

e2 <- e2 %>%
  select(keyword1, code) %>%
  rename(keyword = keyword1)

e2$keyword <- paste0("emote_", e2$keyword)
  





