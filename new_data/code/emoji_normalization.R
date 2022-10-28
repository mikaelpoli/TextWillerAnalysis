#### PACKAGES ####

library(tidyverse)
library(data.table)
library(writexl)
library(textclean)
library(sentimentr)
library(TextWiller)

#### wd ####

# setwd("./new_data/code") 

#### DATA ####

# Emoji list with sentiment scores 
load("../results/textwill_emoji_snake.rda")

# Emoji (symbols) list 
load("../results/textwill_emoji_sym.rda")

# Example Twitter data

load("../data/spritz.Rdata")
spritz <- spritz %>%
  pull(text)

#### AIM ####

# The aim of this script is to create a function for normalizing emojis
# by turning them into text in the form "emoji_[CLDR short name]". 

#### UTF-8 to bytes ####

# Check that emoji symbols' encoding is UTF-8
Encoding(emoji_sym)

# Convert to byte
emoji_byte <- iconv(emoji_sym, from = "UTF-8", to = "ASCII", sub = "byte")

# Add new vector to existing dataset

textwiller_emoji <- cbind(textwill_emoji_snake, emoji_byte)

#### CLEAN DATASET ####

# Build full emoji dictionary following lexicon::emojis_sentiment template

textwiller_emojis_sentiment_full <- textwiller_emoji %>%
  select(keyword,
         vader_score,
         lexicon_score,
         avg_score,
         emoji_byte) %>%
  relocate(emoji_byte, .before = keyword) %>%
  relocate(avg_score, .after = keyword) %>%
  rename(byte = emoji_byte,
         name = keyword,
         sentiment = avg_score) %>%
  as.data.table()

# Build short version of textwiller_emojis_sentiment_full for use with
# sentimentr::sentiment

# data.table where x = byte
textwiller_emojis_sentiment <- textwiller_emojis_sentiment_full %>%
  select(byte,
         sentiment) %>%
  rename(x = byte,
         y = sentiment) %>%
  as.data.table()

# data.table where x = emoji symbol
textwiller_emojis_sym_sentiment <- textwiller_emojis_sentiment %>%
  select(y) %>%
  cbind(emoji_sym) %>%
  as.data.table()

# Build emoji to text conversion table to use with textclean::replace_emoji

textwiller_hash_emojis <- textwiller_emojis_sentiment_full %>%
  select(byte,
         name) %>%
  rename(x = byte,
         y = name) %>%
  as.data.table()

# Build emoji sentiment dictionary following textwiller::vocabolarioMattivio's
# template

name <- textwiller_emojis_sentiment_full %>%
  pull(name)
byte <- textwiller_emojis_sentiment_full %>%
  pull(byte)
unicode <- textwiller_emoji %>%
  pull(code)
score <- textwiller_emojis_sentiment_full %>%
  pull(sentiment)

textwiller_style_emojis_sentiment <- data.frame(name,
                                                unicode,
                                                byte,
                                                score) %>%
  as.data.table()

#### TEST textclean::replace_emoji ####

# Test textclean::replace_emoji function with textwiller emoji dataset
# using a character vector of emojis

emoji_conversion_ex_text <- textclean::replace_emoji(emoji_sym, emoji_dt = textwiller_hash_emojis)
emoji_conversion_ex <- data.frame(emoji_sym, emoji_conversion_ex_text) %>%
  rename(emoji = emoji_sym,
         name = emoji_conversion_ex_text)

# SUCCESS

# Test textclean::replace_emoji function with textwiller emoji dataset
# using a character vector of tweets containing emojis

emoji_conversion_ex_spritz_text <- textclean::replace_emoji(spritz, emoji_dt = textwiller_hash_emojis)
emoji_conversion_ex_spritz <- data.frame(spritz, emoji_conversion_ex_spritz_text) %>%
  rename(emoji = spritz,
         name = emoji_conversion_ex_spritz_text)

# SUCCESS, but:
# NOTE: textclean::replace_emoji also turns all special characters (e.g.,
# letters with accents) to their byte representation. MUST FIX FOR ITALIAN.

#### Save

# Textwiller_emojis_sentiment_full: 

# This dictionary contains:
# byte: byte representation of emojis
# name: name of the emoji in the form "emoji_[cldr_short_name]"
# sentiment: sentiment score calculated following Gupta, Singh, and Ranjan's 
# (2021) procedure as illustrated in "Emoji Score and Polarity Evaluation Using
# CLDR Short Name and Expression Sentiment"(doi:10.1007/978-3-030-73689-7)
# vader_score: sentiment score calculated using VADER algorithm
# lexicon_score: sentiment score retrieved from lexicon::emojis_sentiment

save(textwiller_emojis_sentiment_full, file = "../results/textwiller_emojis_sentiment_full.rda")

# dizionario_emoji_id:

# This dictionary contains:
# x = byte representation of emojis
# y = name of the emoji in the form "emoji_[cldr_short_name]"

dizionario_emoji_id <- textwiller_hash_emojis
save(dizionario_emoji_id , file = "../results/dizionario_emoji_id.rda")

# Textwiller_emojis_sentiment:

# This dictionary contains:
# x = byte representation of emojis
# y = sentiment score calculated following Gupta, Singh, and Ranjan's 
# (2021) procedure as illustrated in "Emoji Score and Polarity Evaluation Using
# CLDR Short Name and Expression Sentiment"(doi:10.1007/978-3-030-73689-7)

save(textwiller_emojis_sentiment, file = "../results/textwiller_emojis_sentiment.rda")

# Textwiller_emojis_sym_sentiment:

# This dictionary contains:
# x = emoji symbols
# y = sentiment score calculated following Gupta, Singh, and Ranjan's 
# (2021) procedure as illustrated in "Emoji Score and Polarity Evaluation Using
# CLDR Short Name and Expression Sentiment"(doi:10.1007/978-3-030-73689-7)

save(textwiller_emojis_sym_sentiment, file = "../results/textwiller_emojis_sym_sentiment.rda")

# Textwiller_style_emojis_sentiment:

# This dictionary contains:
# name = name of the emoji in the form "emoji_[cldr_short_name]"
# unicode = unicode representation of emoji
# byte = byte representation of emoji
# sentiment = sentiment score calculated following Gupta, Singh, and Ranjan's 
# (2021) procedure as illustrated in "Emoji Score and Polarity Evaluation Using
# CLDR Short Name and Expression Sentiment"(doi:10.1007/978-3-030-73689-7)

save(textwiller_style_emojis_sentiment, file = "../results/textwiller_style_emojis_sentiment.rda")

#### FUNCTION ####

# Load stopwords list
data("itastopwords")

# Normalize text using TextWiller
s1 <- TextWiller::normalizzaTesti(spritz,
                                  tolower = T,
                                  normalizzahtml = T,
                                  normalizzacaratteri = T,
                                  normalizzaemote = F,
                                  normalizzaEmoticons = F,
                                  normalizzapunteggiatura = T,
                                  normalizzaslang = T,
                                  fixed = T,
                                  perl = F,
                                  encoding = "UTF-8",
                                  remove = itastopwords,
                                  removeUnderscore = F) 

# Normalize emojis in s1 using textclean
s2 <- textclean::replace_emoji(s1, emoji_dt = textwiller_hash_emojis)

# Create dataframe of results
df <- data.frame(spritz, s1, s2)

