#!/bin/bash

# Activate entrez conda environment
eval "$(conda shell.bash hook)"
conda activate seqkit


for C in 5 7.5 10
do
    for R in 1 2 3 4 5
    do

        # Get reads that map to the reference including the adapters
        seqkit grep -f <(seqkit seq -n -i ../01-simulation_AncientReads_HQ439467/03-Downsampling/ANCIENT.SIM.CONT.COV-${C}.RUN-${R}.fq) \
            ../01-simulation_AncientReads_HQ439467/01-gargammel/ANCIENT.SIM.CONT.RUN-${R}_s.fq.gz \
            > ../../tmp/ANCIENT.SIM.CONT.COV-${C}.RUN-${R}.adapters.fq

        # Remove contaminating reads (i.e. reads that are not from HQ439467)
        sh ~/Tools/bbmap/filterbyname.sh \
            in=../tmp/ANCIENT.SIM.CONT.COV-${C}.RUN-${R}.adapters.fq \
            out=../ANCIENT.SIM.COV-${C}.RUN-${R}.adapters.fq \
            names=HQ439467.1 \
            substring=t \
            include=t

    done
done