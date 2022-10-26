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

# TextWiller mattivio dictionary (duplicates already removed)
load("../results/textwill.rda")

# Emoji (symbols) list 
load("../results/textwill_emoji_sym.rda")

# Emoji (byte) sentiment df 
load("../results/textwiller_emojis_sentiment_full.rda")

# Example Twitter data
load("../data/spritz.Rdata")
spritz <- spritz %>%
  pull(text)

#### AIM ####

# Create single TextWiller dictionary containing emojis, words,
# and their sentiment score

#### CLEAN ####

# Remove old emoji list from textwill

textwiller_dictionary <- textwill[!grepl("emote_", textwill$keyword),]

# Prepare new emoji list

textwiller_emojis <- textwiller_emojis_sentiment_full %>%
  select(name,
         byte,
         sentiment) %>%
  rename(keyword = name,
         code = byte,
         score = sentiment)

ngram <- rep(NA, nrow(textwiller_emojis))

textwiller_emojis <- cbind(textwiller_emojis, ngram)

# Add new emoji list

textwiller_dictionary <- rbind(textwiller_emojis, textwiller_dictionary)

#### Save ####

# New TextWiller dictionary

save(textwiller_dictionary, file = "../results/textwiller_dictionary.rda")
