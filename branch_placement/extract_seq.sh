#!/bin/bash -l
#$ -P bi720
#$ -N extract_seq
#$ -m ea
#$ -M lukeberg@bu.edu
#$ -j y
#$ -o /projectnb/bi720/MMG/ELM/EPAng/

# Input arguments
inputFasta=$1
seqNumber=$2  # 1-based index of the sequence to extract/remove
outputDir=$3

# Load seqkit module
module load seqkit

# Create output directory if it doesn't exist
mkdir -p "$outputDir"

# Get total number of sequences
totalSeqs=$(seqkit stats "$inputFasta" | awk 'NR==2 {print $4}')

# Extract the Nth sequence to a separate file
seqkit range -r "$seqNumber:$seqNumber" "$inputFasta" -o "$outputDir/${JOB_ID}_seq${seqNumber}.fasta"

# Prepare temporary files for the split parts
firstPart="$outputDir/.${JOB_ID}_tmp_part1.fasta"
secondPart="$outputDir/.${JOB_ID}_tmp_part2.fasta"

# Extract 1 to N-1 if applicable
if [ "$seqNumber" -gt 1 ]; then
    seqkit range -r "1:$(($seqNumber - 1))" "$inputFasta" -o "$firstPart"
fi

# Extract N+1 to total if applicable
if [ "$seqNumber" -lt "$totalSeqs" ]; then
    seqkit range -r "$(($(($seqNumber + 1)) )):$totalSeqs" "$inputFasta" -o "$secondPart"
fi

# Concatenate the valid parts into final output
cat "$firstPart" "$secondPart" > "$outputDir/${JOB_ID}_without_seq${seqNumber}.fasta"

# Clean up temporary files
rm -f "$firstPart" "$secondPart"
