#### Objective ####

# Find where TextWiller uses its dependencies ("stringr", "twitteR", "RCurl" "SnowballC")
# NOTE: TW = TextWiller

#### Packages ####

library(tidyverse)
library(funchir)
library(packrat)
library(TextWiller)
library(NCmisc)
library(data.table)
library(stringr)
library(kableExtra)

#### wd ####

setwd("./dependencies/data")

#### EXTRACT FUNCTIONS ####

#--- Create vector of TW functions' names

tw_functions <- read.table("filenames.txt")
tw_functions <- tw_functions$V1
tw_functions <- tw_functions[! tw_functions %in% 'filenames.txt']

#--- Check library() or require() calls in each function's script

tw_calls_check <- sapply(tw_functions, stale_package_check)

#--- List all functions used in all TW functions' scripts
tw_funs_check <- sapply(tw_functions, list.functions.in.file)

#### DATA CLEANING ####

#--- Fix hidden functions' names
names(tw_funs_check$classificaUtenti.R)[1] <- ".hidden"
names(tw_funs_check$normalizzaTesti.R)[1] <- ".hidden"
names(tw_funs_check$RTHound.R)[1] <- ".hidden"
names(tw_funs_check$sentiment.R)[1] <- ".hidden"

#--- Fix package names 
names(tw_funs_check$sentiment_utils.R)[1] <- "package:tibble"
names(tw_funs_check$sentiment_utils.R)[2] <- "package:tidytext"

#--- Remove package info file (does not contain functions)
tw_funs_check <- within(tw_funs_check, rm("TextWiller-package.R"))

#--- Extract functions, remove hidden TW functions

deps_funs <- unlist(tw_funs_check, recursive = F)
deps_funs <- within(deps_funs, rm("classificaUtenti.R..hidden"))
deps_funs <- within(deps_funs, rm("normalizzaTesti.R..hidden"))
deps_funs <- within(deps_funs, rm("RTHound.R..hidden"))
deps_funs <- within(deps_funs, rm("sentiment.R..hidden"))

#### RESULTS ####

#--- Extract dependencies' functions, their package, and the TW function they're used for

y <- unlist(deps_funs)
y <- as.data.frame(y)
y$names <- rownames(y)
y$names <- str_split_fixed(y$names, ".R.", 2)
y$names[,2] <-gsub("package:", "", as.character(y$names[,2]))
y$names[,2] <-gsub("[[:digit:]]", "", as.character(y$names[,2]))
rownames(y) <- NULL
y$dep_function <- y$y 
y$tw_function <- y$names[,1]
y$dependency <- y$names[,2]
dependencies <- y[, -(1:2)]
rm(y)
dependencies <- dependencies[, c(2, 3, 1)]

#--- Save results in table

kbl_col_names <- c("TextWiller function", "Dependency", "Dependency function")
kbl(dependencies)
table_1 <- kable_styling(kbl(dependencies, col.names = kbl_col_names),
                         full_width = F,
                         bootstrap_options = c("striped", "hover",
                                               "condensed", "responsive"))
table_1
save_kable(table_1, file = "../results/dependencies.html")

#--- Save results in csv file

write.csv(dependencies, file = "../results/dependencies.csv", row.names = F)
