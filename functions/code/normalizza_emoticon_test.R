#### PACKAGES ####

#### wd ####

# WD must be TextWillerAnalysis/functions/code
# setwd("./functions/code")

#### FUNCTION ####

source(file = "./normalizza_emoticon.R")

#### DATA ####

test_emoticon <- c(":)", ":(", ";)", "*_*", ":P", "O_o", "a   b")

#### TEST ####

output <- normalizza_emoticon(test_emoticon, perl = T)

# Save results in data.frame

test_emoticon_output <- data.frame(emoticon = test_emoticon,
                                   output) %>%
  print()
