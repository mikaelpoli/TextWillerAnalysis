#### Packages ####

#### wd ####

# setwd("../new_data/code")

#### DATA #### 

#--- Arjuna stopwords
load("../results/stopwords_ar.rda")

#--- TextWiller stopwords
load("../data/itastopwords.rda")

#### CREATE NEW DICTIONARY ####

#--- Find differences between Arjuna and TextWiller dictionaries
x <- setdiff(stopwords_ar, itastopwords)

#--- Merge new stopwords with TextWiller dictionary
y <- c(itastopwords, x)

#--- Sort alphabetically and rename
stopwords_ita <- sort(y)

#### Save results ####
save(stopwords_ita, file = "../results/stopwords_ita.rda")
