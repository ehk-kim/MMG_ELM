### This is a copy of the code in CCASE_analysis.rmd
### I am crossing it with the data in the 5 blast files
### and slighly modifying it to output tables:
# Sample name | # taxa | predEC | actual EC | pearson

### Condense to the following:
# Sample | pearson | # genomes that made that pearson

# originally written by katie
# edited by luke for blast data
# edited by emily for genus+species and species data

### Set up
setwd("/projectnb/bi720/MMG")

library(tidyverse)
library(vroom)
library(vegan)
library(ggplot2)
library(ecodist)
library(scales)
library(robCompositions)
library(plyr)

### Load data

#metadata
metagenomes_metadata <- read.csv("CCASE_data/ccase_metagenome_metadata.csv")
mycocosm <- read.csv("picrust-for-fungi/data/mycocosm_its_merge.csv")

#metagenomes
metagenomes_fungi <- read.csv("CCASE_data/CCASE_soil_MG_2013_2014_full_annotation_fungi.csv") #contains EC

# metagenomes_fungi$X <- 1 # i guess this is a useless col 

gsp <- read.csv('CCASE_data/ccase_its_w_species.csv')



###Reformat
# split metagenome taxonomy
split_taxa <- stringr::str_split(metagenomes_fungi$phylo, pattern = ";")
domain_names <- c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species")
taxa_names <- lapply(split_taxa, function(x) x[1:length(domain_names)])
tax_table <- taxa_names %>%
  unlist() %>% matrix(ncol = length(domain_names), byrow = TRUE) %>%
  data.frame() %>%
  magrittr::set_colnames(domain_names) %>%
  #tidyr::unite("Species", "Species", "Species2") %>%
  mutate(Genus = replace(Genus, Genus == "Escherichia-Shigella", "Escherichia"))

metagenomes_fungi_tax <- cbind(metagenomes_fungi, tax_table)

# split metagenome gold ids
split_transcript <- stringr::str_split(metagenomes_fungi$transcript, pattern = "_")
transcript_names <- c("Gold_ID")
gold_ids <- unlist(lapply(split_transcript, function(x) x[1:length(transcript_names)]))
metagenomes_fungi_tax$GoldID <- gold_ids

#cleanup
rm(split_taxa, domain_names, taxa_names, tax_table, split_transcript,
   transcript_names, gold_ids)



###single copy genes per fungal genome
sicgs <- unique(metagenomes_fungi$ec[grep("\\bRNA polymerase I\\b", metagenomes_fungi$product_names, ignore.case = T)]) # RNA Polymerase I
sicgs <- c(sicgs, unique(metagenomes_fungi$ec[grep("\\bRNA polymerase II\\b", metagenomes_fungi$product_names, ignore.case = T)])) # RNA Polymerase II
sicgs <- c(sicgs, unique(metagenomes_fungi$ec[grep("Glyceraldehyde 3-phosphate dehydrogenase", metagenomes_fungi$product_names, ignore.case = T)])) # GAPDH
sicgs <- c(sicgs, unique(metagenomes_fungi$ec[grep("ELF1", metagenomes_fungi$product_names, ignore.case = T)])) # ELF1
sicgs <- c(sicgs, unique(metagenomes_fungi$ec[grep("MCM7", metagenomes_fungi$product_names, ignore.case = T)])) # MCM7
sicgs <- c(sicgs, unique(metagenomes_fungi$ec[grep("Glucose-6-phosphate 1-dehydrogenase", metagenomes_fungi$product_names, ignore.case = T)])) # G6PDH
sicgs <- c(sicgs, unique(metagenomes_fungi$ec[grep("Malate Synthase", metagenomes_fungi$product_names, ignore.case = T)])) # MLS
sicgs <- c(sicgs, unique(metagenomes_fungi$ec[grep("alpha-aminoadipate reductase", metagenomes_fungi$product_names, ignore.case = T)])) # LYS2
sicgs <- c(sicgs, unique(metagenomes_fungi$ec[grep("DNA topoisomerase II", metagenomes_fungi$product_names, ignore.case = T)])) # TOP2

sicgs <- unique(sicgs)
sicgs <- sicgs[!is.na(sicgs)]


###load ITS data metagenome only its
# load ITS files
its_metadata <- read.csv("CCASE_data/ccase_its_metadata.csv")
its_metadata_gold <- its_metadata[,c(6,7)]

# load predicted metagenome files
mmg_pred <- read.csv("CCASE_data/gene_count_per_sample.csv", row.names = 1)
mmg_pred_t <- as.data.frame(t(mmg_pred))

mmg_pred_t$JGI.ID <- rownames(mmg_pred_t)
mmg_pred_t_gold <- merge(mmg_pred_t, its_metadata_gold, by = "JGI.ID")
mmg_pred_t_gold <- mmg_pred_t_gold[,-1]

mmg_pred_t_gold[,1:(ncol(mmg_pred_t_gold)-1)] <- mmg_pred_t_gold[,1:(ncol(mmg_pred_t_gold)-1)] %>% mutate_if(is.character, as.numeric)

# Average predicted metagenomes within a sample
mmg_pred_wide <- aggregate(mmg_pred_t_gold, .~GOLD.ID, FUN="mean")

# Adjust column names to match real data column names
colnames(mmg_pred_wide) <- gsub("X", "EC:", colnames(mmg_pred_wide))
colnames(mmg_pred_wide) <- gsub("\\.\\.\\.\\.\\.\\.", ".-", colnames(mmg_pred_wide))
colnames(mmg_pred_wide) <- gsub("\\.\\.\\.\\.\\.", ".-", colnames(mmg_pred_wide))
colnames(mmg_pred_wide) <- gsub("\\.\\.\\.\\.", ".-", colnames(mmg_pred_wide))
colnames(mmg_pred_wide) <- gsub("\\.\\.\\.", ".-", colnames(mmg_pred_wide))
colnames(mmg_pred_wide) <- gsub("\\.\\.", ".-", colnames(mmg_pred_wide))

for(i in 1:nrow(mmg_pred_wide)){
  sample <- mmg_pred_wide[i,2:ncol(mmg_pred_wide)]
  sicg_counts <- sample[,colnames(sample) %in% sicgs]
  median_sicg <- apply(sicg_counts, 1, median, na.rm=T)
  mmg_pred_wide[i,2:ncol(mmg_pred_wide)] <- mmg_pred_wide[i,2:ncol(mmg_pred_wide)]/median_sicg
}

# Make a long version for plotting real vs. predicted
mmg_pred_long <- mmg_pred_wide %>% pivot_longer(!GOLD.ID, names_to = "ec", values_to = "ITS_pred_count")
colnames(mmg_pred_long)[1] <- "GoldID"

#clean
rm(its_metadata_gold, mmg_pred_t, mmg_pred_t_gold, mmg_pred_wide, sample, sicg_counts, median_sicg)


###aggregate mycocosm
# add transcripts within a sample, summing across taxa
if(USE_BLAST){
  mycocosm_blast <- mycocosm[which(mycocosm$portal %in% blast$portal_id),] #cut down only meta genomes in this blast 
  metagenomes_fungi_mycocosm <- metagenomes_fungi_tax[which(metagenomes_fungi_tax$Genus %in% mycocosm_blast$genus),] #cut down to only metagenomes in mycocosm_blast
  metagenomes_fungi_all <- aggregate(X ~ ec + GoldID, metagenomes_fungi_mycocosm, FUN ="sum") #edit 
  
  #subset metagenomes_metadata
  metagenomes_metadata <- metagenomes_metadata[which(metagenomes_metadata$GOLD.ID %in% metagenomes_fungi_mycocosm$GoldID),]
  #this gets modified but then never used?
  
  #subset mmg_pred
  mmg_pred_long <- mmg_pred_long[mmg_pred_long$GoldID %in% metagenomes_fungi_all$GoldID,]
  
  rm(mycocosm_blast, metagenomes_fungi_mycocosm)
}else{
  metagenomes_fungi_all <- aggregate(X ~ ec + GoldID, metagenomes_fungi_tax, FUN ="sum")
  metagenomes_metadata <- metagenomes_metadata[which(metagenomes_metadata$GOLD.ID %in% metagenomes_fungi_tax$GoldID),]
}




###normalize data
#NAs get added in this section after blast edit
# subset long form to make wide form dataframe
metagenomes_fungi_wide_all <- pivot_wider(metagenomes_fungi_all, 
                                          names_from = ec, values_from = X)
metagenomes_fungi_wide_all[is.na(metagenomes_fungi_wide_all)] <- 0

#normalize the reads per median single copy gene count
metagenomes_fungi_wide_all <- as.data.frame(metagenomes_fungi_wide_all)
rownames(metagenomes_fungi_wide_all) <- metagenomes_fungi_wide_all$GoldID
metagenomes_fungi_wide_all <- metagenomes_fungi_wide_all[,-1]

for(i in 1:nrow(metagenomes_fungi_wide_all)){
  sample <- metagenomes_fungi_wide_all[i,]
  sicg_counts <- sample[,colnames(sample) %in% sicgs]
  median_sicg <- apply(sicg_counts, 1, median, na.rm=T)
  metagenomes_fungi_wide_all[i,] <- metagenomes_fungi_wide_all[i,]/median_sicg
}

metagenomes_fungi_wide_make_longer <- metagenomes_fungi_wide_all
metagenomes_fungi_wide_make_longer$GoldID <- rownames(metagenomes_fungi_wide_make_longer)
metagenomes_fungi_long_all <- metagenomes_fungi_wide_make_longer %>% pivot_longer(!GoldID, names_to = "ec", values_to = "Real_Count") 


#clean up
rm(metagenomes_fungi_wide_all, metagenomes_fungi_wide_make_longer, metagenomes_fungi_all, sample, sicg_counts, median_sicg )


###Linear models
pred_vs_real_metagenomes <- merge(metagenomes_fungi_long_all, mmg_pred_long, by = c("ec", "GoldID"))

pred_vs_real_metagenomes_all <- pred_vs_real_metagenomes[complete.cases(pred_vs_real_metagenomes),]
goldids <- unique(pred_vs_real_metagenomes_all$GoldID)
# 
# for(i in 1:length(unique(goldids))){
#   id <- goldids[i]
#   df <- pred_vs_real_metagenomes_all[which(pred_vs_real_metagenomes_all$GoldID == id),]
#   
#   plot <- ggplot(df, aes(x = Real_Count, y = ITS_pred_count)) + geom_point() + geom_smooth(method = "lm") + ggtitle(id) + geom_abline(slope=1, intercept=0, col = "red")
#   print(plot)
# }
#   

rm(pred_vs_real_metagenomes)

###Pearson
pearson_df <- as.data.frame(matrix(data = NA, nrow = length(goldids), ncol = 4))
colnames(pearson_df) <- c("sample_id", "pearson_corr", "n_taxa_w_genome", "prediction_method")
pearson_df$sample_id <- goldids

for(i in 1:nrow(pearson_df)){
  id <- pearson_df$sample_id[i]
  df <- pred_vs_real_metagenomes_all[which(pred_vs_real_metagenomes_all$GoldID == id),]
  pearson_df$pearson_corr[i] <- cor(df$ITS_pred_count, df$Real_Count, method = "pearson")
  pearson_df$n_taxa_w_genome #need to fill this
}
rm(id, df, i)

# pearson_df <- pearson_df[!is.na(pearson_df$pearson_corr),]
# pearson_df$sample_id

pearson_df <- pearson_df[order(pearson_df$sample_id),]
# write.csv(pearson_df, 'ELM/pearson_df_90.csv')
