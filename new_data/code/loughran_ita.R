#### Packages ####

library(tidyverse)
library(data.table)
library(sentimentr)
library(TextWiller)

#### wd ####

# setwd("../new_data/code")

#### DATA ####

#--- Negative words

lm_negative <- read.csv("../data/lm_negative.csv", header = F)

#--- Positive words

lm_positive <- read.csv("../data/lm_positive.csv", header = F)

#--- Uncertain words

lm_uncertainty <- read.csv("../data/lm_uncertainty.csv", header = F)

#--- Strong modal words

lm_strong <- read.csv("../data/lm_strong_modal.csv", header = F)

#--- Weak modal words

lm_weak <- read.csv("../data/lm_weak_modal.csv", header = F)

#### BUILD FULL DICTIONARY ####

#--- Negative words and sentiment

lm_ita_negative <- rep("negative", nrow(lm_negative))
lm_ita <- data.frame(lm_negative)
lm_ita$word <- lm_ita$V1
lm_ita$sentiment <- lm_ita_negative

#--- Positive words and sentiment

lm_ita_positive <- rep("positive", nrow(lm_positive))
positive <- data.frame(lm_positive)
positive$word <- positive$V1
positive$sentiment <- lm_ita_positive
lm_ita <- rbind(lm_ita, positive)

#--- Uncertain words and sentiment

lm_ita_uncertainty <- rep("uncertainty", nrow(lm_uncertainty))
uncertainty <- data.frame(lm_uncertainty)
uncertainty$word <- uncertainty$V1
uncertainty$sentiment <- lm_ita_uncertainty
lm_ita <- rbind(lm_ita, uncertainty)

#--- Strong modal words and sentiment

lm_ita_strong <- rep("strong", nrow(lm_strong))
strong <- data.frame(lm_strong)
strong$word <- strong$V1
strong$sentiment <- lm_ita_strong
lm_ita <- rbind(lm_ita, strong)

#--- Weak modal words and sentiment

lm_ita_weak <- rep("weak", nrow(lm_weak))
weak <- data.frame(lm_weak)
weak$word <- weak$V1
weak$sentiment <- lm_ita_weak
lm_ita <- rbind(lm_ita, weak)

#--- Clean dataframe

lm_ita <- lm_ita[,-1]
lm_ita$word <- tolower(lm_ita$word)
lexicon_loughran_ita <- lm_ita

#--- Remove old objects

rm(lm_ita,
   lm_negative,
   lm_positive,
   lm_uncertainty,
   lm_strong,
   lm_weak,
   lm_ita_negative,
   lm_ita_positive,
   lm_ita_uncertainty,
   lm_ita_strong,
   lm_ita_weak,
   positive,
   uncertainty,
   strong,
   weak)

#--- Change column names to be compatible with sentimentr::sentiment 

colnames(lexicon_loughran_ita) <- c("x", "y")

#### Save ####

dizionario_loughran_ita_full <- lexicon_loughran_ita
save(dizionario_loughran_ita_full, file = "../results/dizionario_loughran_ita_full.rda")

#### BUILD POSITIVE-NEGATIVE-UNCERTAIN DICTIONARY ####

dizionario_loughran_ita <- dizionario_loughran_ita_full[dizionario_loughran_ita_full$y %in% c("positive", "negative", "uncertainty"), ]

#--- Assign weights to sentiment
# NOTE: 
# -1 = negative
# 0 = uncertain
# +1 = positive

dizionario_loughran_ita$y <- gsub("positive", "1", dizionario_loughran_ita$y)
dizionario_loughran_ita$y <- gsub("negative", "-1", dizionario_loughran_ita$y)
dizionario_loughran_ita$y <- gsub("uncertainty", "0", dizionario_loughran_ita$y)
dizionario_loughran_ita$y <- as.numeric(dizionario_loughran_ita$y)

#### Save ####

save(dizionario_loughran_ita, file = "../results/dizionario_loughran_ita.rda")

#### BUILD POSITIVE-NEGATIVE DICTIONARY ####

lexicon_loughran_ita_pn <- lexicon_loughran_ita[c(lexicon_loughran_ita$y == "positive" |
                                                    lexicon_loughran_ita$y == "negative"),]

#--- Assign weights to sentiment
# NOTE: 
# -1 = negative
# +1 = positive

lexicon_loughran_ita_pn$y <- gsub("positive", "1", lexicon_loughran_ita_pn$y)
lexicon_loughran_ita_pn$y <- gsub("negative", "-1", lexicon_loughran_ita_pn$y)
lexicon_loughran_ita_pn$y <- as.numeric(lexicon_loughran_ita_pn$y)

#--- Turn into data.table

lexicon_loughran_ita_pn <- setDT(lexicon_loughran_ita_pn)

#### Save ####

dizionario_loughran_ita_pn <- lexicon_loughran_ita_pn
save(dizionario_loughran_ita_pn, file = "../results/dizionario_loughran_ita_pn.rda")

#### BUILD UNCERTAINTY DICTIONARY ####

u <- lexicon_loughran_ita[lexicon_loughran_ita$y == "uncertainty",]
u <- as.character(u$x)
w <- lexicon_loughran_ita[lexicon_loughran_ita$y == "weak",]
w <- as.character(w$x)
s <- lexicon_loughran_ita[lexicon_loughran_ita$y == "strong",]
s <- as.character(s$x)

#--- Check differences between vectors 

u_w <- setdiff(w, u)

# all words in w are already contained in u

# Create "u" vector without "w" words

w_u <- setdiff(u, w) 

# ---

u_s <- setdiff(s, u)

# all words in s are novel compared to u

#--- Assign weights

# NOTE: weights are based on "strength of centrainty", where:
# -1 = weak modal
# 0 = uncertainty
# +1 = strong modal

w_weight <- rep(-1, length(w))
u_weight <- rep(0, length(w_u))
s_weight <- rep(1, length(s))

#--- Combine weights with character vectors

w <- data.frame(w, w_weight)
colnames(w) <- c("word", "sentiment")

u <- data.frame(w_u, u_weight)
colnames(u) <- c("word", "sentiment")

s <- data.frame(s, s_weight)
colnames(s) <- c("word", "sentiment")

#--- Merge dataframes

lexicon_loughran_ita_u <- data.frame(rbind(w, u, s))

#--- Change column names to be compatible with sentimentr::sentiment 

colnames(lexicon_loughran_ita_u) <- c("x", "y")

#--- Turn into data.table

lexicon_loughran_ita_u <- setDT(lexicon_loughran_ita_u)

# Remove objects 

rm(s, u, w, s_weight, u_weight, w_weight, u_s, u_w, w_u)

#### Save #### 

dizionario_loughran_ita_u <- lexicon_loughran_ita_u
save(dizionario_loughran_ita_u, file = "../results/dizionario_loughran_ita_u.rda")

#### sentimentr::sentiment test ####

# Example phrases 

test_loughran <- c("ha rinunciato all'offerta", "mi sembra vada bene", "si può certamente fare",
                   "di sicuro non funziona")

# Create Loughran (positive-negative) italian dictionary and run test 

ita_pn <- as_key(lexicon_loughran_ita_pn, 
       comparison = NULL,
       sentiment = T)

sentimentr::sentiment(test_loughran, polarity_dt = ita_pn)

# Create Loughran uncertainty italian dictionary 

ita_u <- as_key(lexicon_loughran_ita_u, 
                 comparison = NULL,
                 sentiment = T)

sentimentr::sentiment(test_loughran, polarity_dt = ita_u) # NOT WORKING?

# Try with example tweet dataset

load("../data/spritz.rdata")

test_tweet <- spritz$text
test_tweet <- normalizzaTesti(test_tweet)

sentimentr::sentiment(test_tweet, polarity_dt = ita_pn)
sentimentr::sentiment(test_tweet, polarity_dt = ita_u)
