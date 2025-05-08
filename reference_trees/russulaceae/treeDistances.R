#####
# This script aims to output a similarity score between a selected input file
# and the russ tree (version Jan 2025), as well as the tree from Li et al. 2021,
# following the scoring metric from Nye et al. 2006.
#
# Make sure to place all input files in the same folder as this script, as the
# script will not run without the russtree.nwk and Lietal_2021.nwk files available
# in this folder.
# 
# Use: Rscript treeDistances.R referenceTree inputTree outputFile
#      input: tree in Newick file format
#      output: file name you want to output the results to. if the file exists,
#              outputs will be appended. if not, file will be created. output is
#              a csv.
#####

# Command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Wrong number of arguments
if(length(args) < 3){
  print("Please include a reference tree, an input tree, and an output file name.")
  stop("Requires command line argument.")
}

refFile <- args[1]
fin <- args[2]
fout <- args[3]

# Load all libraries
if (!require(TreeDist)) {
  print("Installing required package TreeDist")
  install.packages(TreeDist)
}

if (!require(ape)) {
  print("Installing required package ape")
  install.packages(ape)
}

library(TreeDist)
library(ape)

# Read in reference tree
ref_tree <- read.tree(refFile)

# Read in comparison tree
input_tree <- read.tree(fin)

# Get tip labels for all trees
ref_labels <- ref_tree$tip.label
input_labels <- input_tree$tip.label

# Input + reference tree
# Find all tips in common
in_ref_common <- intersect(ref_labels, input_labels)
ref_tree <- keep.tip(ref_tree, in_ref_common)
input_ref <- keep.tip(input_tree, in_ref_common)
ref_tips_kept <- length(input_ref$tip.label)

# Compute the Nye similarity scores
nye_score <- NyeSimilarity(ref_tree, input_ref, normalize = pmax.int)

#####
# normalize = pmax.int normalizes against the number of splits in the most
# resolved tree; in this case, the references
#
# Nye similarity is a generalized Robinson-Foulds metric. It finds the optimal
# matching that pairs each branch from one tree with a branch in the second and
# scores matches according to the size of the largest split that is
# consistent with both of them. It is then normalized against the Jaccard index.
#
# Since the resulting scores are similarity scores, they range from 0-1 with 1
# being a perfect match.
#####

# Output the results to a file
headers <- "reference,input,Nye score,tips kept"

if(file.exists(fout)) {
  conx <- file(fout, "a")
  cat(refFile, ",", fin, ",", nye_score, ",", ref_tips_kept, "\n", file = conx)
  close(conx)
} else {
  cat(headers, "\n", refFile, ",", fin, ",", nye_score, ",", ref_tips_kept, "\n", file = fout)
  conx <- file(fout, "a")
  close(conx)
}
