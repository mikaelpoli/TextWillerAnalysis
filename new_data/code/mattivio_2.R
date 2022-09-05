#### PACKAGES ####

library(TextWiller)
library(janitor)
library(sentimentr)
library(tidyverse)
library(data.table)

#### wd ####

# setwd("../new_data/code") 

#### DATA ####

#--- Vocabolario Mattivio

data("vocabolarioMattivio")

save(vocabolarioMattivio, file = "../data/vocabolarioMattivio.rda")

load("../data/vocabolarioMattivio.rda")

mattivio <- vocabolarioMattivio 
rm(vocabolarioMattivio)
  
#### FIND DUPLICATES ####

# Identify duplicated keywords 

dupes <- subset(mattivio[(duplicated(mattivio$keyword) | 
             duplicated(mattivio$keyword, fromLast = TRUE)), ])

dupes <- dupes[order(dupes$keyword),]
dupes

#### FIX DUPLICATES #### 

# Disambiguate where the meaning is more clearly either positive or negative

# Positive words 

mattivio <- mattivio[!(mattivio$keyword == "brav" & mattivio$score == "-1"),]
mattivio <- mattivio[!(mattivio$keyword == "divertent" & mattivio$score == "-1"),]
mattivio <- mattivio[!(mattivio$keyword == "fort" & mattivio$score == "-1"),]
mattivio <- mattivio[!(mattivio$keyword == "grazios" & mattivio$score == "-1"),]
mattivio <- mattivio[!(mattivio$keyword == "intatt" & mattivio$score == "-1"),]
mattivio <- mattivio[!(mattivio$keyword == "super" & mattivio$score == "-1"),]
mattivio <- mattivio[!(mattivio$keyword == "tenac" & mattivio$score == "-1"),]
mattivio <- mattivio[!(mattivio$keyword == "umil" & mattivio$score == "-1"),]
mattivio <- mattivio[!(mattivio$keyword == "zel" & mattivio$score == "-1"),]

# Negative words

mattivio <- mattivio[!(mattivio$keyword == "stord" & mattivio$score == "1"),]

#--- Remove remaining duplicates 

# Identify remaning duplicates 

dupes_2 <- subset(mattivio[(duplicated(mattivio$keyword) | 
                            duplicated(mattivio$keyword, fromLast = TRUE)), ])

dupes_2 <- dupes_2[order(dupes_2$keyword),]
dupes_2

# Remove 

mattivio <- mattivio[!(duplicated(mattivio$keyword) | 
                         duplicated(mattivio$keyword, fromLast = TRUE)), ]

#### Save ####

save(mattivio, file = "../results/mattivio.rda")

#### Sentimentr test ####

## STILL NOT WORKING

# Create dictionary 

dic <- mattivio %>%
  select(keyword, score) %>%
  rename(x = keyword, y = score) %>%
  as.data.table()

dic$x <- tolower(dic$x)

dic <- as_key(dic)

# Create text vector

text <- c("ciao bella", "mi piaci", "wow!!","good","casa", "farabutto!","ti odio")

# Analyze 

sentimentr::sentiment(text, polarity_dt = dic)

