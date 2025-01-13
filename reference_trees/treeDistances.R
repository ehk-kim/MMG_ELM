#####
# This script aims to output a similarity score between a selected input file
# and the JGI tree (version Jan 2025), as well as the tree from Li et al. 2021,
# following the scoring metric from Nye et al. 2006.
#
# Make sure to place all input files in the same folder as this script, as the
# script will not run without the JGItree.nwk and Lietal_2021.nwk files available
# in this folder.
# 
# Use: treeDistances.R input output
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

# Load all libraries
library(TreeDist)
library(ape)


jgi <- read.tree("JGItree.nwk")
# li <- read.tree("Lietal_2021.nwk")

input_file <- read.tree()
