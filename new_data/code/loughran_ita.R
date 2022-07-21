#### Packages ####

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

#### BUILD DICTIONARY ####

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

#### SAVE RESULTS ####

save(lexicon_loughran_ita, file = "../results/lexicon_loughran_ita.rda")

