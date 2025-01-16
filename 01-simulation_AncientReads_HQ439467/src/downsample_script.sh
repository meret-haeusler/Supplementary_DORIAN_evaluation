#!/bin/bash

# Create tmp directory for auxiliary files
mkdir -p ./01-simulation_AncientReads_HQ439467/03-Downsampling/tmp

# Convert bam files of mapping reads to fastq
for ITER in 1 2 3 4 5
do 
    samtools bam2fq ./01-simulation_AncientReads_HQ439467/02-EAGERmapping/ANCIENT.SIM.CONT.RUN-${ITER}/9-GATKBasics/ANCIENT.SIM.CONT.RUN-${ITER}_s.fq.truncated.MT_realigned.mappedonly.sorted.qF.sorted.cleaned_rmdup.sorted.real.bam \
        > ./01-simulation_AncientReads_HQ439467/03-Downsampling/tmp/ANCIENT.SIM.CONT.RUN-${ITER}.fq
done


# Downsample 10X coverage sample
for ITER in 1 2 3 4 5
do
    # Sub-sample fastq file
    seqtk sample -s100 ./01-simulation_AncientReads_HQ439467/03-Downsampling/tmp/ANCIENT.SIM.CONT.RUN-${ITER}.fq 5150 \
        > ./01-simulation_AncientReads_HQ439467/03-Downsampling/ANCIENT.SIM.CONT.COV-10.RUN-${ITER}.fq
done


## Downsample 7.5X coverage sample
for ITER in 1 2 3 4 5
do
    # Sub-sample fastq file
    seqtk sample -s100 ./01-simulation_AncientReads_HQ439467/03-Downsampling/tmp/ANCIENT.SIM.CONT.RUN-${ITER}.fq 3890 \
        > ./01-simulation_AncientReads_HQ439467/03-Downsampling/ANCIENT.SIM.CONT.COV-7.5.RUN-${ITER}.fq
done


## Downsample 5X coverage sample
for ITER in 1 2 3 4 5
do
    # Sub-sample fastq file
    seqtk sample -s100 ./01-simulation_AncientReads_HQ439467/03-Downsampling/tmp/ANCIENT.SIM.CONT.RUN-${ITER}.fq 2600 \
        > ./01-simulation_AncientReads_HQ439467/03-Downsampling/ANCIENT.SIM.CONT.COV-5.RUN-${ITER}.fq
done