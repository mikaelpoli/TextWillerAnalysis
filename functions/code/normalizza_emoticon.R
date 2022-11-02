normalizza_emoticon <-
  function(testo, perl = TRUE){
    testo <- gsub("([:=8]([- '])?[])Dd>]+)|(\\^[-_o]?\\^)",
                  "emoticon_positiva", 
                  testo, 
                  perl = perl)
    testo <- gsub("([:=]([- '])?[(|/x*[])|([>Xx#][._][>Xx<#])|(\\):)",
                  "emoticon_negativa", 
                  testo, 
                  perl = perl)
    testo <- gsub(";-?[])>Ddo]",
                  "emoticon_ammiccante", 
                  testo)
    testo <- gsub("\\*[-._o]\\*",
                  "emoticon_meravigliata", 
                  testo)
    testo <- gsub("([:=]-?[pP]+)|(\\b[xX][dD]+\\b)|(\\bd:\\b)",
                  "emoticon_scherzosa", 
                  testo, 
                  perl = perl)
    testo <- gsub("[0Oo]+[\\._-]+[0Oo]+",
                  "emoticon_shockata", 
                  testo, 
                  perl = perl)
    testo <- gsub("[[:blank:]]+",
                  " ", 
                  testo, 
                  perl = perl) # substitute multiple blank spaces with a single blank space
    testo
  }

