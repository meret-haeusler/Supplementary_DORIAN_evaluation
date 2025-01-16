#!/bin/bash
# Evaluation of DORIAN tool
# Run correction on simulated reads with specified set of parameters
# Author: Meret Haeusler


# Iterate over each coverage condition
for C in 5 7.5 10
do

    # Iterate over each simulation run
    for R in 1 2 3 4 5
    do

        ### NO CORRECTION ###
        OUT1=./03-DORIAN_evaluation/01-Correction_HQ439467/no_correction
        mkdir -p $OUT1

        java -jar ../DORIAN/out/artifacts/DORIAN_jar/DORIAN.jar \
            -c 3 -m 1 -o $OUT1 -f 0.65 \
            -b ./02-analysis_SimulatedAncientReads_HQ439467/EAGERmapping/ANCIENT.SIM.CONT.COV-${C}.RUN-${R}/9-GATKBasics/ANCIENT.SIM.CONT.COV-${C}.RUN-${R}.truncated.MT_realigned.mappedonly.sorted.qF.sorted.cleaned_rmdup.sorted.real.bam \
            -r ./references/NC_001640_Equus-caballus_mt/NC_001640.1.fna


        
        #### REFERENCE-BASED SILENCING ###
        OUT2=./03-DORIAN_evaluation/01-Correction_HQ439467/ref-based_silencing
        mkdir -p $OUT2

        java -jar ../DORIAN/out/artifacts/DORIAN_jar/DORIAN.jar \
            -c 3 -m 2 -o $OUT2 -f 0.65 \
            -b ./02-analysis_SimulatedAncientReads_HQ439467/EAGERmapping/ANCIENT.SIM.CONT.COV-${C}.RUN-${R}/9-GATKBasics/ANCIENT.SIM.CONT.COV-${C}.RUN-${R}.truncated.MT_realigned.mappedonly.sorted.qF.sorted.cleaned_rmdup.sorted.real.bam \
            -r ./references/NC_001640_Equus-caballus_mt/NC_001640.1.fna
                       


        ### REFERENCE-FREE SILENCING ###
        OUT3=./03-DORIAN_evaluation/01-Correction_HQ439467/ref-free_silencing
        mkdir -p $OUT3

        java -jar ../DORIAN/out/artifacts/DORIAN_jar/DORIAN.jar \
            -c 3 -m 3 -o $OUT3 -f 0.65\
            -b ./02-analysis_SimulatedAncientReads_HQ439467/EAGERmapping/ANCIENT.SIM.CONT.COV-${C}.RUN-${R}/9-GATKBasics/ANCIENT.SIM.CONT.COV-${C}.RUN-${R}.truncated.MT_realigned.mappedonly.sorted.qF.sorted.cleaned_rmdup.sorted.real.bam \
            -r ./references/NC_001640_Equus-caballus_mt/NC_001640.1.fna



        ### RFERENCE-FREE WEIGHTING ###
        OUT4=./03-DORIAN_evaluation/01-Correction_HQ439467/ref-free_weighting
        mkdir -p $OUT4

        java -jar ../DORIAN/out/artifacts/DORIAN_jar/DORIAN.jar \
            -c 3 -m 4 -o $OUT4 -f 0.65 \
            -b ./02-analysis_SimulatedAncientReads_HQ439467/EAGERmapping/ANCIENT.SIM.CONT.COV-${C}.RUN-${R}/9-GATKBasics/ANCIENT.SIM.CONT.COV-${C}.RUN-${R}.truncated.MT_realigned.mappedonly.sorted.qF.sorted.cleaned_rmdup.sorted.real.bam \
            -r ./references/NC_001640_Equus-caballus_mt/NC_001640.1.fna\
            -dp5 ./02-analysis_SimulatedAncientReads_HQ439467/EAGERmapping/ANCIENT.SIM.CONT.COV-${C}.RUN-${R}/7-DnaDamage/ANCIENT.SIM.CONT.COV-${C}.RUN-${R}.truncated.MT_realigned.mappedonly.sorted.qF.sorted.cleaned_rmdup.sorted/5p_freq_misincorporations.txt \
            -dp3 ./02-analysis_SimulatedAncientReads_HQ439467/EAGERmapping/ANCIENT.SIM.CONT.COV-${C}.RUN-${R}/7-DnaDamage/ANCIENT.SIM.CONT.COV-${C}.RUN-${R}.truncated.MT_realigned.mappedonly.sorted.qF.sorted.cleaned_rmdup.sorted/3p_freq_misincorporations.txt 

    done
done