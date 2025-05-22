#!/bin/bash -l

#$ -P bi720
#$ -N run_epa
#$ -m ea
#$ -M lukeberg@bu.edu
#$ -j y
#$ -o /projectnb/bi720/MMG/ELM/EPAng/

# Assign positional arguments to variables
missingSeqFasta=$1
inputQuery=$2
missingSeqTree=$3
missingSeqModel=$4
outputDir=$5
outNwk=$6


echo "loading modules"
module load miniconda
module load hmmer
module load pplacer
mamba activate epa_test #requires you to have installed epang to a conda enviorment

# Create outDir if it doesnt exist
mkdir -p "$outputDir"

echo "building hmmer profile"
hmmbuild --dna missing_seq_profile.hmmfile "$missingSeqFasta"

echo "align query to profile"
hmmalign --dna -o hmmer_align_query_and_MSA.afa --outformat afa \
        --mapali "$missingSeqFasta" missing_seq_profile.hmmfile "$inputQuery"

echo "split query and reference"
epa-ng --split "$missingSeqFasta" hmmer_align_query_and_MSA.afa

echo "perform placements"
epa-ng --tree "$missingSeqTree" --ref-msa reference.fasta --query query.fasta \
        --out-dir "$outputDir" --model "$missingSeqModel"

echo "convert jplace to newick"
guppy tog -o "$outputDir/$outNwk" "$outputDir"/epa_result.jplace

# Move intermediate files to outDIR
mv missing_seq_profile.hmmfile "$outputDir/${JOB_ID}_missing_seq_profile.hmmfile"
mv hmmer_align_query_and_MSA.afa "$outputDir/${JOB_ID}_hmmer_align_query_and_MSA.afa"
mv reference.fasta "$outputDir/${JOB_ID}_reference.fasta"
mv query.fasta "$outputDir/${JOB_ID}_query.fasta"

# Rename epa outfiles with job id
mv "$outputDir"/epa_result.jplace "$outputDir/${JOB_ID}_epa_result.jplace"
mv "$outputDir"/epa_info.log "$outputDir/${JOB_ID}_epa_info.log"

echo "finished"
