#### PACKAGES ####

library(tidyverse)
library(data.table)
library(rvest)
library(XML)
library(snakecase)
library(writexl)
library(vader)

#### wd ####

# setwd("./new_data/code") 

#### DATA ####

### TextWiller's mattivio2 dictionary

load("../results/textwill.rda")

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

e2$keyword <- paste0("emoji_", e2$keyword)

#---

#### Extract emoji, keyword and code ####

e1 <- emoji %>% 
  select(V2, V3, V15) %>%
  relocate(V15, .before = V2) %>%
  rename(keyword = V15, code = V2, emoji = V3)

# Remove all rows containing headers

e2 <- e1[(!e1$code == "Code") & (!e1$keyword == "CLDR Short Name"), ]

# Remove NAs

e2 <- na.omit(e2)

# Split cells where "code" contains more than one element into separate columns
# and only keep the first code string

e2[c('code1', 'code2')] <- str_split_fixed(e2$code, ' ', 2)

e2 <- e2 %>% 
  select(keyword, code1, emoji) %>%
  rename(code = code1)

# Remove punctuation in "keyword" elements

e2$keyword1 <- gsub(":", "", e2$keyword)
e2$keyword1 <- tolower(e2$keyword1)
e2$keyword1 <- to_snake_case(e2$keyword1)

e2 <- e2 %>%
  select(keyword1, code, emoji) %>%
  rename(keyword = keyword1)

e2$keyword <- paste0("emoji_", e2$keyword)
e2 <- e2[order(e2$keyword), ]

# Pull emoji list

emoji_sym <- e2 %>%
  pull(emoji)

save(emoji_sym, file = "../results/textwill_emoji_sym.rda")

#---

# Convert to data table 

e2 <- e2 %>%
  as.data.table()

#### Save ####

 # save(e2, file = "../results/textwill_emoji.rda")

#### POLARITY SCORE ####

#--- Calculate polarity score for emojis.

# Use Gupta, Singh, and Ranjan's (2021) procedure
# as illustrated in "Emoji Score and Polarity Evaluation Using
# CLDR Short Name and Expression Sentiment"
# (doi:10.1007/978-3-030-73689-7)

# Get cldr short names as vector 

cldr_short_name <- e1_2 %>%
  pull(keyword)

# Pass vector through vader

textwill_emoji_vader <- vader_df(cldr_short_name, 
                                 incl_nt = F,
                                 neu_set = T, 
                                 rm_qm = T)

  # Extract "code" and put it back in back in dataframe

  code <- e1_2 %>%
    pull(code)
  
  textwill_emoji_vader$code <- code

# Get sentiment emoji ranking list (Novak, Smailovic, Sluban, & Mozetic's (2015))

lexicon_emoji_ranking <- lexicon::emojis_sentiment

# For emojis appearing both in textwill and in lexicon,
# calculate compound score as the mean of the "compound" and "sentiment"
# scores respectively

  # Get df of emojis contained in both dataframes

  x <- lexicon_emoji_ranking[lexicon_emoji_ranking$name %in% 
                               textwill_emoji_vader$text, ]
  y <- textwill_emoji_vader[textwill_emoji_vader$text %in% 
                              lexicon_emoji_ranking$name, ]

  # Sort both alphabetically so the values match

  x <- x[order(x$name), ]
  y <- y[order(y$text), ]
  
  # Add x$sentiment to y
  
  x_sentiment <- x %>%
    pull(sentiment)
  
  y <- cbind(y, x_sentiment)
  
  # Average them and create "score" column in y with reults
  
  y$score <- rowMeans(subset(y, select = c(compound, x_sentiment)), na.rm = F)
  
  # Create dictionary with emojis not present in y
  
  df <- textwill_emoji_vader[!textwill_emoji_vader$text %in% y$text, ]
  
  df <- df %>%
    select(text,
           compound,
           code)
  
  df_lexicon <- y %>%
    select(text,
           code,
           compound,
           x_sentiment,
           score)
  
  df$score <- rep(NA, nrow(df)) %>%
    as.numeric()
  
  df$x_sentiment <- rep(NA, nrow(df)) %>%
    as.numeric()
  
  # Create final alphabetically ordered emoji dictionary
  
  textwill_emoji <- rbind(df, df_lexicon)
  
  textwill_emoji <- textwill_emoji[order(textwill_emoji$text), ]

  # When "score" is NA, fill cell with "compound" value
  
  textwill_emoji$score[is.na(textwill_emoji$score)] <- 
    textwill_emoji$compound[is.na(textwill_emoji$score)]
  
  # Rename and rearrange columns for clarity
  
  textwill_emoji <- textwill_emoji %>%
    rename(keyword = text,
           vader_score = compound,
           lexicon_score = x_sentiment,
           avg_score = score) %>%
    relocate(code, .before = vader_score) %>%
    relocate(lexicon_score, .before = avg_score)
  
  # Round scores to two decimal palces
  
  textwill_emoji$vader_score <- round(textwill_emoji$vader_score, 2)
  textwill_emoji$lexicon_score <- round(textwill_emoji$lexicon_score, 2)
  textwill_emoji$avg_score <- round(textwill_emoji$avg_score, 2)
  
  # Create df with snake case keyword
  
  textwill_emoji_snake <- textwill_emoji

  textwill_emoji_snake$keyword <- tolower(textwill_emoji_snake$keyword)
  textwill_emoji_snake$keyword <- to_snake_case(textwill_emoji_snake$keyword)
  
  textwill_emoji_snake$keyword <- paste0("emoji_", textwill_emoji_snake$keyword)
    
#### Save ####

# rda
  
save(textwill_emoji, file = "../results/textwill_emoji_scores.rda")
save(textwill_emoji_snake, file = "../results/textwill_emoji_snake.rda")
  
# xlsx

write_xlsx(textwill_emoji, path = "../results/textwill_emoji_scores.xlsx")
write_xlsx(textwill_emoji_snake, path = "../results/textwill_emoji_snake.xlsx")
  
  