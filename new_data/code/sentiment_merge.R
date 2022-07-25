#### Packages ####

#### wd ####

# # setwd("../new_data/code")

#### DATA #### 

#--- Loughran italian lexicon
load("../results/lexicon_loughran_ita.rda")

#--- TextWiller italian lexicon
load("../data/vocabolariMadda.rda")

#### POSITIVE DICTIONARY ####

#--- Find differences between Loughran and TextWiller dictionaries (positive)
# Extract vectors of positive words

l_positive <- lexicon_loughran_ita[lexicon_loughran_ita$sentiment == "positive",]
l_positive <- l_positive$word

m_positive <- vocabolariMadda$positive

# Find differences

x_positive <- setdiff(l_positive, m_positive)

#### NEGATIVE DICTIONARY #### 

#--- Find differences between Loughran and TextWiller dictionaries (negative)
# Extract vectors of pnegative words

l_negative <- lexicon_loughran_ita[lexicon_loughran_ita$sentiment == "negative",]
l_negative <- l_negative$word

m_negative <- vocabolariMadda$negative

# Find differences

x_negative <- setdiff(l_negative, m_negative)

#### NEUTRAL DICTIONARY ####

l_uncertainty <- lexicon_loughran_ita[lexicon_loughran_ita$sentiment == "uncertainty",]
l_uncertainty <- l_uncertainty$word
x_uncertainty <- l_uncertainty

#### MERGE DICTIONARIES ####

# In order for the dictionary to be compatible with sentimentr::sentiment,
# it must contain words and their weights in two columns x and y. E.g.:

lexicon_example <- head(lexicon::hash_sentiment_jockers)
lexicon_example

# Create dictionary where y is a character vector of polarity

col_names_lexicon_ita <- c("x", "y") 

x_p <- c(m_positive, x_positive)
x_p_w <- rep("postive", length(x_p))
lexicon_ita_p <- data.frame(x_p, x_p_w)
colnames(lexicon_ita_p) <- col_names_lexicon_ita
rm(x_p, x_p_w, x_positive, m_positive, l_positive)

x_n <- c(m_negative, x_negative)
x_n_w <- rep("negative", length(x_n))
lexicon_ita_n <- data.frame(x_n, x_n_w)
colnames(lexicon_ita_n) <- col_names_lexicon_ita
rm(x_n, x_n_w, x_negative, m_negative, l_negative)

x_u <- x_uncertainty
x_u_w <- rep("uncertainty", length(x_u))
lexicon_ita_u <- data.frame(x_u, x_u_w)
colnames(lexicon_ita_u) <- col_names_lexicon_ita
rm(x_u, x_u_w, x_uncertainty, l_uncertainty)

lexicon_ita <- rbind(lexicon_ita_p, lexicon_ita_n, lexicon_ita_u)
rm(lexicon_ita_p, lexicon_ita_n, lexicon_ita_u)

#### Save results ####

save(lexicon_ita, file = "../results/lexicon_madda_loughran_ita.rda")

#### As list ####

#--- Convert to list so it is compatible with TextWiller::sentiment

lexicon_ita_list <- as.list(lexicon_ita)

#### Save resuls ####

save(lexicon_ita_list, file = "../results/lexicon_madda_loughran_ita_list.rda")
