#Setting the working directory for the analysis
setwd('~/Desktop/PhD/Internship/DatSemShift')
getwd()

#Reading the data
data <- read.csv('Annotations/FinalData.csv')

#Selecting the columns that are relevant for the analysis
data <- data[c('ID', 'PoS_1', 'PoS_2', 'Confidence', 'Extension', 'Connotation', 'Emotive.Value', 'Frame')]
head(data,10)

###Frequency of Categories of Change###

#Calculating the frequency of each category of change
category <- c(
  rep("Frame", sum(data$Frame != "")),
  rep("Extension", sum(data$Extension != "")),
  rep("Emotive.Value", sum(data$Emotive.Value != ""))
)

frequency_test <- chisq.test(table(category))
frequency_test

###Frequency of Metonymy in PoS change and no change conditions###

#Selecting the cases in which PoS changed
data$pos_changed <- ifelse(data$PoS_1 != data$PoS_2, "changed", "same")

#Obtaining a separate row for each possible annotation
annotations_df <- data.frame(
  ID = rep(data$ID, times = 3),
  pos_changed = rep(data$pos_changed, times = 3),
  annotation = c(data$Frame, data$Extension, data$Emotive.Value),
  stringsAsFactors = FALSE
)

#Removing the empty rows
annotations_df <- annotations_df[annotations_df$annotation != "", ]

#For the cases where there is the annotation of metonymy give '1' and the rest '0'
annotations_df$metonymy <- ifelse(annotations_df$annotation == "Metonymy", 1, 0)

#Contingency table for metonymy and the cases in which PoS changed
table_metonymy_pos <- table(annotations_df$metonymy, annotations_df$pos_changed)
table_metonymy_pos

fisher_result_metonymy <- fisher.test(table_metonymy_pos, alternative = "greater")
fisher_result_metonymy

###Frequenct of Metaphor in PoS change and no change conditions###

#The same analysis as the one above but for metaphor instead of metonymy

annotations_df$metaphor <- ifelse(annotations_df$annotation == "Metaphor", 1, 0)

table_metaphor_pos <- table(annotations_df$metaphor, annotations_df$pos_changed)
table_metaphor_pos

fisher_result_metaphor <- fisher.test(table_metaphor_pos, alternative = "greater")
fisher_result_metaphor

###Prevalence of PoS types in different change types###

#Obtaining a row for every possible annotation and with PoS info
annotations_df <- data.frame(
  ID = rep(data$ID, times = 3), 
  PoS_1 = rep(data$PoS_1, times = 3),
  PoS_2 = rep(data$PoS_2, times = 3),
  annotation = c(data$Frame, data$Extension, data$Emotive.Value),
  stringsAsFactors = FALSE
)

#Removing the empty rows
annotations_df <- annotations_df[annotations_df$annotation != "", ]

#Creating the contingency table for PoS 1
table_pos1_type <- table(annotations_df$PoS_1, annotations_df$annotation)
table_pos1_type

#Creating the contingency table for PoS 2
table_pos2_type <- table(annotations_df$PoS_2, annotations_df$annotation)
table_pos2_type

chisq.test(table_pos1_type, simulate.p.value = TRUE, B = 10000)
chisq.test(table_pos2_type, simulate.p.value = TRUE, B = 10000)

###Prevalence of PoS types in different change categories###

#Obtaining a row for every possible annotation and with PoS info
annotations_df <- data.frame(
  ID = c(data$ID, data$ID, data$ID),
  PoS_1 = c(data$PoS_1, data$PoS_1, data$PoS_1),
  PoS_2 = c(data$PoS_2, data$PoS_2, data$PoS_2),
  category = c(
    rep("Frame", nrow(data)),
    rep("Extension", nrow(data)),
    rep("Emotive.Value", nrow(data))
  ),
  value = c(data$Frame, data$Extension, data$Emotive.Value),
  stringsAsFactors = FALSE
)

#Removing the empty rows
annotations_df <- annotations_df[annotations_df$value != "", ]

#Creating the contingency table for PoS 1
table_pos1_category <- table(annotations_df$PoS_1, annotations_df$category)
table_pos1_category

#Creating the contingency table for PoS 2
table_pos2_category <- table(annotations_df$PoS_2, annotations_df$category)
table_pos2_category


chisq.test(table_pos1_category, simulate.p.value = TRUE, B = 10000)
chisq.test(table_pos2_category, simulate.p.value = TRUE, B = 10000)

test1_plain <- chisq.test(table_pos2_category)
test1_plain$stdres

