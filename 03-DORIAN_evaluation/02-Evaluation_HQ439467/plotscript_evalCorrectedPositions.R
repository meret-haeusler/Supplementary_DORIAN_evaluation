#!/usr/bin/env Rscript
# Author: Meret Haeusler
# Draw diagrams for simulation analysis for all damage-correction methods

# Set working directory ---------------------------------------------
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# remove variables
rm(list = ls())

# Load required packages
library(dplyr)
library(plyr)
library(tidyverse)
library(stringr)
library(ggplot2)
library(ggbreak)
library(cowplot)
library(ggpubr)
library(patchwork)


# Define script functions -------------------------------------------
## From http://www.sthda.com/english/wiki/ggplot2-error-bars-quick-start-guide-r-software-and-data-visualization
#+++++++++++++++++++++++++
# Function to calculate the mean and the standard deviation
# for each group
#+++++++++++++++++++++++++
# data : a data frame
# varname : the name of a column containing the variable
#to be summariezed
# groupnames : vector of column names to be used as
# grouping variables
data_summary <- function(data, varname, groupnames){
  require(plyr)
  summary_func <- function(x, col){
    c(mean = mean(x[[col]], na.rm=TRUE),
      sd = sd(x[[col]], na.rm=TRUE))
  }
  data_sum<-ddply(data, groupnames, .fun=summary_func,
                  varname)
  data_sum <- rename(data_sum, c("mean" = varname))
  return(data_sum)
}



# Corrected Positions -----------------------------------------------
tab <- read.csv('HQ.sim.cont.reco.eval.cor-pos.cleaned.csv')

tab_impr <- data_summary(tab, varname = "Impr",
                         groupnames = c("COV_COND", "COR_MODE"))
tab_impr <- rename(tab_impr, c("sd" = "Impr_SD"))

tab_simp <- data_summary(tab, varname = "SImpr",
                         groupnames = c("COV_COND", "COR_MODE"))
tab_simp <- rename(tab_simp, c("sd" = "SImpr_SD"))

tab_swor <- data_summary(tab, varname = "SWors",
                         groupnames = c("COV_COND", "COR_MODE"))
tab_swor <- rename(tab_swor, c("sd" = "SWors_SD"))

tab_wors <- data_summary(tab, varname = "Wors",
                         groupnames = c("COV_COND", "COR_MODE"))
tab_wors <- rename(tab_wors, c("sd" = "Wors_SD"))

tab_smry <- merge(tab_impr, tab_simp, by=c("COV_COND", "COR_MODE"))
tab_smry <- merge(tab_smry, tab_swor, by=c("COV_COND", "COR_MODE"))
tab_smry <- merge(tab_smry, tab_wors, by=c("COV_COND", "COR_MODE"))

  
colours <- c("#005493", "#38B4CF", "#CAE8F5")
label_names <- c("Reference-based Silencing", "Reference-free Silencing", "Reference-free Weighting")
positions <- c("COV-10", "COV-7.5", "COV-5")

plot_imp <- ggplot(tab_smry, aes(x=COV_COND, y=Impr, fill = COR_MODE)) +
  geom_col(position = "dodge", width = 0.6, color = "black", size = 0.1) +
  geom_errorbar(aes(ymin = Impr-Impr_SD, ymax = Impr+Impr_SD), 
                position = position_dodge(width = 0.6), width=0.2) +  #Draw error bars
  scale_x_discrete(limits = positions) + #Define Coverage.Condition order
  ylim(0, 125) +
  labs(x="", y="Number base calls") +
  ggtitle(label = "A) Improved base calls", subtitle = "") +
  scale_fill_manual(values=colours, labels = label_names) +
  theme(legend.position = "none", legend.title = element_blank()) +
  theme_bw()


plot_simp <- ggplot(tab_smry, aes(x=COV_COND, y=SImpr, fill = COR_MODE)) +
  geom_col(position = "dodge", width = 0.6, color = "black", size = 0.1) +
  geom_errorbar(aes(ymin = SImpr-SImpr_SD, ymax = SImpr+SImpr_SD), 
                position = position_dodge(width = 0.6), width=0.2) +  #Draw error bars
  scale_x_discrete(limits = positions) + #Define Coverage.Condition order
  ylim(0, 50) +
  labs(x="", y="Number base calls") +
  ggtitle(label = "B) Semi-conservative:", subtitle= "N-calls vs. incorrect") +
  scale_fill_manual(values=colours, labels = label_names) +
  theme(legend.position = "none", legend.title = element_blank(), plot.subtitle = element_text(hjust = 0.1)) +
  theme_bw()


plot_swors <- ggplot(tab_smry, aes(x=COV_COND, y=SWors, fill = COR_MODE)) +
  geom_col(position = "dodge", width = 0.6, color = "black", size = 0.1) +
  geom_errorbar(aes(ymin = SWors-SWors_SD, ymax = SWors+SWors_SD), 
                position = position_dodge(width = 0.6), width=0.2) +  #Draw error bars
  scale_x_discrete(limits = positions) + #Define Coverage.Condition order
  ylim(0, 200) +
  labs(x="", y="Number base calls") +
  ggtitle(label = "C) Too conservative:", subtitle = "N-calls vs. correct") +
  scale_fill_manual(values=colours, labels = label_names) +
  theme(legend.position = "none", legend.title = element_blank(), plot.subtitle = element_text(hjust = 0.1)) +
  theme_bw()


plot_wors <- ggplot(tab_smry, aes(x=COV_COND, y=Wors, fill = COR_MODE)) +
  geom_col(position = "dodge", width = 0.6, color = "black", size = 0.1) +
  geom_errorbar(aes(ymin = Wors-Wors_SD, ymax = Wors+Wors_SD), 
                position = position_dodge(width = 0.6), width=0.2) +  #Draw error bars
  scale_x_discrete(limits = positions) + #Define Coverage.Condition order
  ylim(0, 10.5) +
  labs(x="", y="Number base calls") +
  ggtitle(label = "D) Incorrect base calls", subtitle = "") +
  scale_fill_manual(values=colours, labels = label_names) +
  theme(legend.position = "none", legend.title = element_blank()) +
  theme_bw()


ggarrange(plot_imp, plot_simp, plot_swors, plot_wors, ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom") 





# Draw diagrams for simulation analysis for N counts ################
# Read data ---------------------------------------------------------
dat_Ns <- read.csv("HQ.sim.cont.reco.genome.stats.cleaned.csv", header = TRUE)


## Compute Standard Derivation for error bars
dat_smry <- data_summary(dat_Ns, varname = "CNT_N",
                         groupnames = c("COV_COND", "COR_MODE"))


# Calculate reduced percentage --------------------------------------
# with respect to first value in da_smry (should be "no correction")
red_perc <- subset(dat_smry, select = -c(sd)) %>%
  group_by(COV_COND) %>%
  mutate(pct_change = (CNT_N - first(CNT_N)) / first(CNT_N) * 100)

# Drop rows for "no correction"
dat_reduced_perc <- red_perc[-(which(red_perc$COR_MODE %in% "no_correction")),]


# Plot reduced percentage -------------------------------------------
plot_Ns <- ggplot(dat_reduced_perc, aes(x=COV_COND, y=pct_change, fill = COR_MODE)) +
  geom_col(position = "dodge", width = 0.6, color = "black", size = 0.1) +
  scale_x_discrete(limits = positions) + #Define Coverage.Condition order
  ylim(-15, 15) +
  labs(x="", y="Difference [in %]") +
  ggtitle(label = "E) Relative Difference", subtitle = "Non-informative Base Calls") +
  scale_fill_manual(values=colours, labels = label_names) +
  theme(legend.text = element_text(size=13),
        legend.position = "right", 
        legend.title = element_blank(), 
        plot.subtitle = element_text(hjust = 0.4)) +
  theme_bw()



###############################################################################
# Plot all plots
plot_imp + plot_swors + plot_Ns + plot_simp + plot_wors + guide_area() + 
  plot_layout(ncol = 3, guides = "collect") &
  theme(legend.title = element_blank())
