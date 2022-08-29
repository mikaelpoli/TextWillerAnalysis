#### Packages ####

library(data.table)
library(sentimentr)

#### wd ####

# setwd("../new_data/code")

#### DATA ####

#--- Vocabolario Madda

load("../data/vocabolariMadda.rda")

#### WEIGHTS ####

# NOTE:
# -1 = negative
# +1 = positive

p_word <- vocabolariMadda$positive
p_weight <- rep(1, length(p_word))
p <- data.frame(p_word, p_weight)
colnames(p) <- c("x", "y")

neg_word <- vocabolariMadda$negative
neg_weight <- rep(-1, length(neg_word))
n <- data.frame(neg_word, neg_weight)
colnames(n) <- c("x", "y")

#--- Merge

madda <- data.frame(rbind(p, n))

#### CLEANING ####

madda$x <- tolower(madda$x)

#--- As data.table for compatibility with sentimentr::sentiment

madda <- setDT(madda)

#--- Remove objects

rm(neg_word, neg_weight, p_word, p_weight, n, p)

#### Save ####

save(madda, file = "../results/madda.rda")

#### sentimentr::sentiment test ####

# Example phrases 

test_madda <- c("ciao bella", "mi piaci", "wow!!","good","casa", "farabutto!","ti odio")

# Create Madda sentimentr::sentiment dictionary

ita_madda <- as_key(madda, 
                 comparison = NULL,
                 sentiment = T)

sentimentr::sentiment(test_madda, polarity_dt = ita_madda)

