#!/bin/bash -l
#$ -P bi720
#$ -N GTR_iqtree
#$ -m ea
#$ -M lukeberg@bu.edu
#$ -j y
#$ -o /projectnb/bi720/MMG/ELM/EPAng/

# Assign positional arguments to variables
inputFasta=$1
outName=$2
outDir=$3

# Create outDir if it doesnt exist
mkdir -p "$outDir"

echo "started"
module purge
module load clustalomega
module load iqtree/2.2.2.6

echo "building msa"
clustalo -i "$inputFasta" -o "${outName}_msa.fasta"

echo "running iqtree"
iqtree2 -s "${outName}_msa.fasta" \
        --prefix "GTR_forced_${outName}" \
        -m GTR

#move all files to outdir
mv "${outName}_msa.fasta" "$outDir"
mv GTR_forced*  "$outDir"

echo "finished"
