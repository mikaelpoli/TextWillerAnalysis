#### Packages ####

#### wd ####

# setwd("../new_data/code")

#### DATA ####

stopwords_ar <- read.csv("../data/stopwords_ar.txt", sep = "")

#--- Cleaning

stopwords_ar <- as.character(stopwords_ar[,1])

#### SAVE RESULTS ####

save(stopwords_ar, file = "../results/stopwords_ar.rda")
