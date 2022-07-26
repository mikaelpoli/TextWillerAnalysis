Scripts in */code* rely on objects created through other scripts. To avoid errors, run the scripts in the following order:

 1. *loughran_ita.R*: produces the full Loughran-McDonald lexicon for financial documents in Italian (with positive - negative - uncertainty - strong modal - weak modal levels for the "sentiment" variable of the dictionary). Also produces separate dictionaries (a positive-negative and an uncertainty dictionary) for the Loughran-McDonald Italian dictionary. All can be found in the */results* directory.  
     -  NOTE: Contains a test of both Loughran Italian dictionaries using the `sentimentr::sentiment` function  
 3. *stopwords_ar.R*: produces the character vector for a new list of Italian stopwords
 4. *stopwords_merge.R*: merges the TextWiller "itastopwords" stopwords list with the new one
 5. *sentiment_merge.R*: merges the TextWiller "vocabolariMadda" dictionary with the full Italian Loughran-McDonald one for sentiment analysis.
 6. *madda_weights.R*: produces a version TextWiller "vocabolariMadda" dictionary with numeric weights
     -  NOTE: Contains a test of the dictionary using the `sentimentr::sentiment` function
