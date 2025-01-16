#!/bin/bash

# Create auxiliary gargammel directory containing template genomes
mkdir -p ./01-simulation_AncientReads_HQ439467/01-gargammel/tmp/bact ./01-simulation_AncientReads_HQ439467/01-gargammel/tmp/cont ./01-simulation_AncientReads_HQ439467/01-gargammel/tmp/endo
scp ./data/HQ439467_1.fasta ./01-simulation_AncientReads_HQ439467/01-gargammel/tmp/endo
scp ./references/NC_012920_Homo-sapiens_mt/NC_012920_1.fasta ./01-simulation_AncientReads_HQ439467/01-gargammel/tmp/cont

for ITER in 1 2 3 4 5
do
    # Run Read Simulation
    gargammel --comp 0,0.4,0.6 \
        -o ./01-simulation_AncientReads_HQ439467/01-gargammel/ANCIENT.SIM.CONT.RUN-${ITER} \
        -c 50 \
        -f ./01-simulation_AncientReads_HQ439467/src/fragment-size_distribution.txt \
        -mapdamage ./01-simulation_AncientReads_HQ439467/src/misincorporation_60.txt single \
        -fa AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC\
        -sa AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTA\
        -se \
        ./01-simulation_AncientReads_HQ439467/01-gargammel/tmp

    # Remove gargammel auxiliary files
    rm ./01-simulation_AncientReads_HQ439467/01-gargammel/ANCIENT.SIM.CONT.RUN-${ITER}_a.fa.gz
    rm ./01-simulation_AncientReads_HQ439467/01-gargammel/ANCIENT.SIM.CONT.RUN-${ITER}.b.fa.gz
    rm ./01-simulation_AncientReads_HQ439467/01-gargammel/ANCIENT.SIM.CONT.RUN-${ITER}.c.fa.gz
    rm ./01-simulation_AncientReads_HQ439467/01-gargammel/ANCIENT.SIM.CONT.RUN-${ITER}_d.fa.gz
    rm ./01-simulation_AncientReads_HQ439467/01-gargammel/ANCIENT.SIM.CONT.RUN-${ITER}.e.fa.gz
    
done

# Delete auxiliary gargammel directory
rm -r ./01-simulation_AncientReads_HQ439467/01-gargammel/tmp


