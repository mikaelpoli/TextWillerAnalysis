#### PACKAGES ####

library(TextWiller)
library(janitor)
library(sentimentr)
library(tidyverse)
library(data.table)
library(textclean)

#### wd ####

# setwd("../new_data/code") 

#### DATA ####

#--- Vocabolario Mattivio

# data("vocabolarioMattivio")

# save(vocabolarioMattivio, file = "../data/vocabolarioMattivio.rda")

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

# NOTE: removing now one remaining duplicated word (according to sentimentr::sentiment)

mattivio <- mattivio[!(mattivio$keyword == "trucc"),]

# NOTE: removing one dubious word ("not") (according to sentimentr::sentiment)

mattivio <- mattivio[!(mattivio$keyword == "not"),]

# Rename and coerce to data table

textwill <- mattivio %>%
  as.data.table()

#### Save ####

save(textwill, file = "../results/textwill.rda")

#### Sentimentr test ####

# Create dictionary 

textwill <- textwill %>%
  select(keyword, score) %>%
  rename(x = keyword, y = score)

textwill$x <- tolower(textwill$x)

textwill <- as_key(textwill,
              comparison = NULL)

# Create text vector (not stemmed, manually stemmed, stemmed with SnowballC)

text <- c("ciao bella", "mi piaci", "wow!!", "good", "casa", "farabutto!", "ti odio")
text_stem <- c("ciao bell", "mi piac", "wow!!", "good", "casa", "farabutto!","ti odi")
text_stem1 <- SnowballC::wordStem(text, language = "italian")

# Analyze 

sentimentr::sentiment(text, polarity_dt = textwill)

# NOT WORKING: function seems to look for exact matches
# Trying with stemmed words

sentimentr::sentiment(text_stem, polarity_dt = textwill)
sentimentr::sentiment(text_stem1, polarity_dt = textwill)

# It works.

#### textwiller::sentiment test ####

TextWiller::sentiment(text = text, algorithm = "Mattivio", vocabularies = vocabolarioMattivio)

# It works and is more accurate than sentimentr::sentiment (both 
# with unstemmed text and with text stemmed with SnowballC) in
# assigning a polarity score to the last sentence ("ti odio")
