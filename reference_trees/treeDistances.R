#####
# This script aims to output a similarity score between a selected input file
# and the JGI tree (version Jan 2025), as well as the tree from Li et al. 2021,
# following the scoring metric from Nye et al. 2006.
#
# Make sure to place all input files in the same folder as this script, as the
# script will not run without the JGItree.nwk and Lietal_2021.nwk files available
# in this folder.
# 
# Use: Rscript treeDistances.R input output
#      input: tree in Newick file format
#      output: file name you want to output the results to. if the file exists,
#              outputs will be appended. if not, file will be created.
#####

# Command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Wrong number of arguments
if(length(args) < 2){
  print("Please include both input and output file names.")
  stop("Requires command line argument.")
}

fin <- args[1]
fout <- args[2]

# Load all libraries
library(TreeDist)
library(ape)

# Read in reference trees
jgi <- read.tree("JGItree.nwk")
li <- read.tree("Lietal_2021.nwk")

# Read in comparison tree
input_tree <- read.tree(fin)

# Get tip labels for all trees
jgi_labels <- jgi$tip.label
li_labels <- li$tip.label
input_labels <- input_tree$tip.label

# Input + JGI
# Find all tips in common
in_jgi_common <- intersect(jgi_labels, input_labels)
jgi <- keep.tip(jgi, in_jgi_common)
input_jgi <- keep.tip(jgi, in_jgi_common)

# Input + Li
# Find all tips in common
in_li_common <- intersect(li_labels, input_labels)
li <- keep.tip(li, in_li_common)
input_li <- keep.tip(li, in_li_common)

# Compute the Nye similarity scores
nye_jgi <- NyeSimilarity(jgi, input_jgi, normalize = pmax.int)
nye_li <- NyeSimilarity(li, input_li, normalize = pmax.int)

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
jgi_text <- "compared with JGI\t"
li_text <- "compared with Li et al. 2021\t"

if(file.exists(fout)) {
  conx <- file(fout, "a")
  cat(fin, "\t", jgi_text, nye_jgi, "\n", file = conx)
  cat(fin, "\t", li_text, nye_li, "\n", file = conx)
  close(conx)
} else {
  cat(fin, "\t", jgi_text, nye_jgi, "\n", file = fout)
  conx <- file(fout, "a")
  cat(fin, "\t", li_text, nye_li, "\n", file = conx)
  close(conx)
}
