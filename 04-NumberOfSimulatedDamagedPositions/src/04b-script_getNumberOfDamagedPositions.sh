#!/bin/bash

for C in 5 7.5 10
do
    for R in 1 2 3 4 5
    do

        java -jar /Users/meret/Projects/gargammel_extractDamagedPositions/out/artifacts/gargammel_extractDamagedPositions_jar/gargammel_extractDamagedPositions.jar \
            ../../data/HQ439467_1.fasta \
            ../ANCIENT.SIM.COV-${C}.RUN-${R}.adapters.fq \
            0.33

    done
done