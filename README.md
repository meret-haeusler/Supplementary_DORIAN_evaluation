# DORIAN evaluation
This repository contains the scripts and data to evaluate DORIAN, a tool for damage-aware genome reconstruction of ancient data.

### Structure of Directory
```
|
|- 01-simulation_AncientReads_HQ439467:         Scripts and data created in the simulation run
|– 02-analysis_SimulatedAncientReads_HQ439467:  Results of EAGER analysis of simulated data needed for downstream analysis
|– 03-DORIAN_evaluation:    Scripts and data created for correction and evaluation
|– data:                    Horse template genome for simulation
|– references:              NCBI reference genomes used for evaluation
```

## Simulation of Ancient Reads
Simulation of ancient datasets using the mitochondiral horse genome (NC_001640) as template genome and the mitochondiral human genome (NC_012920) for contamination. Simulate three different coverage levels (5X, 7.5X, 10X) each with 5 replication runs. 

### Structure of Subdirectory
```
|
|- 01-gargammel:    Data created in the simulation run
|– 02-EAGERmapping: Results of initial EAGER mapping of simulated data
|– 03-Downsampling: Final datasets with set coverage levels used for downstream analyses
|– src:             Scripts and auxiliary files for data simulation
```

### Requirements
**Ancient Read Simulation**:  
* Active gargammel conda environment (script: `src/gargammel_script.sh`)

**Downsampling**: 
* EAGER: Command line version (v1.92.37) 
* Active seqtk conda environment (script: `src/downsampling_script.sh`)
* samtools 1.13 (or upper)



## Analysis of Simulated Ancient Reads
The simulated ancient reads were processed and analysed using the EAGER pipeline (v1.92.37) following a typical ancient data analysis.\
This directory contains the mapping and damage estimation files per simulation run and coverage that will be used for the DORIAN evaluation.


### Structure of subdirectory
```
|
|- EAGERmapping: Damage profile and mapping files of EAGER analysis of simulated data
```

### Requirements
**EAGER**:  
* Command line version of EAGER v.1.92.37



## DORIAN_evaluation
Two evaluation metrics were used; first, the positions that were considered for correction and their final base calls were evaluated across all correction methods. Second, the difference in the number of non-informative (**N**) calls was considered. Details on both analyses below.

### Structure of Subdirectory
```
|
|- 01-Correction_HQ439467: Result files of damage correction
|– 02-Evaluation_HQ439467: Result files and plot script of evaluation of damage correction 
|– src:     Scripts to perform correction automatically and evaluation script
```

### Requirements
**DORIAN**:  
* https://github.com/meret-haeusler/DORIAN
* Clone ```DORIAN``` repository to same directory as this one

### Evaluation Outline
#### Corrected positions
> Idea: Compare all corrected posiitions and their final call across all correction methods

1) Collect for each sample the positions that were considered for correction across all correction methods, as well as the respective ground truth base and the uncorrected call from the log files

    Example:
    
| POS 	| GT 	| UNCOR 	| – 	| RBS 	| RFS 	| RFW 	|
|-----	|----	|-------	|---	|-----	|-----	|-----	|
| 1   	|  G 	|   A   	| – 	|  N  	|  N  	|  G  	|
| 7   	|  T 	|   T   	| – 	|  T  	|  T  	|  T  	|
| 11  	|  C 	|   T   	| – 	|     	|  T  	|  T  	|
| 17  	|  G 	|   A   	| – 	|     	|  C  	|  C  	|


2) Compare each correction set (RBS, RFS, RFW) to the ground truth and uncorrected call based on the reference position. Cound the following scenarios:
    ````
    a) Call == GT  & UN != GT –> Improved call
    b) Call == 'N' & UN != GT –> Semi-conservative call (better 'N' than incorrect)
    c) Call == 'N' & UN == GT –> Too conservative call
    d) Call != GT  & UN != GT & Call != 'N' & UN != 'N' –> Incorrect call
    ````
3) Note that if there is no entry for a position in the RBS, then the base call is the same as the uncorrected call.

#### Number of non-informative calls
> Idea: Compare how the correction changes the number of N calls compared to the uncorrected reconstruction

1) Count the number of Ns per condition and correction mode and average the number per condition and correction mode.

2) Compare counts of each correction mode to the uncorrected reconstruction and compute the percentage on how the counts differ
    - Uncorrected count ≜ 100%
    - Negative percentage means reduction in number of Ns; positive percentage means increase in number of Ns

## Contact
> Author: Meret Häusler \
> Contact: ```meret.haeusler@uni-tuebingen.de```