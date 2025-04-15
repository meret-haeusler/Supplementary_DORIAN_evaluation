#!/usr/bin/env Rscript
# Author: Meret Haeusler
# Draw diagrams for simulation analysis for all damage-correction methods
# Used this as tutorial:
#https://www.datanovia.com/en/blog/how-to-add-p-values-onto-a-grouped-ggplot-using-the-ggpubr-r-package/

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
library(rstatix)
library(ggsignif)


# PREPROCESS DATA ---------------------------------------------------
# Read in data
tab <- read.csv('HQ.recon.compareDamagedPositions.SimulatedPositions.csv')

# Split condition column into coverage and run
tab <- separate(tab, COV_COND, into = c("COV", "RUN"), sep = "(?<=X).")

# Factorise Coverage and Correction mode variables
tab[["COV"]] = factor(tab[["COV"]], levels = c("10X", "7.5X", "5X"))
tab[["COR_MODE"]] = factor(tab[["COR_MODE"]], levels = c("RGS", "RFS", "RFW"), labels = c("PBDS", "PFDS", "PFDW"))

# Drop columns not used in analysis
tab <- subset(tab, select = -c(RUN, X.DAMPOS_UNION, X.DAMPOS_SPEC, X.POS_COR_CHANGED))

# Normalise data and remove column not needed for downstream analysis
tab_norm <- tab %>% mutate(across(c(3:6), .fns = ~./X.POS_SIM_DAM))
tab_norm <- subset(tab_norm, select = -c(X.POS_SIM_DAM))



# STATISTICAL TESTING -----------------------------------------------
# Perform Kruskal-Wallis test to test for differences in #BaseCalls per evaluation metric
# If KW test is significant (p<.05), perform Dunn test

# Improved
tab_norm %>% group_by(COV) %>% kruskal_test(Impr ~ COR_MODE) %>% adjust_pvalue(method = "BH") %>% add_significance("p.adj")

#Semi-conservative
tab_norm %>% group_by(COV) %>% kruskal_test(SImpr ~ COR_MODE) %>% adjust_pvalue(method = "BH") %>% add_significance("p.adj")
test.simpr <- tab_norm %>% group_by(COV) %>% dunn_test(SImpr ~ COR_MODE) %>% adjust_pvalue(method = "BH") %>% add_significance("p.adj")

# Too conservative
tab_norm %>% group_by(COV) %>% kruskal_test(SWors ~ COR_MODE) %>% adjust_pvalue(method = "BH") %>% add_significance("p.adj")
test.swors <- tab_norm %>% group_by(COV) %>% dunn_test(SWors ~ COR_MODE) %>% adjust_pvalue(method = "BH") %>% add_significance("p.adj")

# Incorrect
tab_norm %>% group_by(COV) %>% kruskal_test(Wors ~ COR_MODE) %>% adjust_pvalue(method = "BH") %>% add_significance("p.adj")
test.wors <- tab_norm %>% group_by(COV) %>% dunn_test(Wors ~ COR_MODE) %>% adjust_pvalue(method = "BH") %>% add_significance("p.adj")


# PLOT --------------------------------------------------------------
colours <- c("#005493", "#38B4CF", "#CAE8F5")


# Improved
plot_imp <-
ggbarplot(tab_norm, x = "COV", y = "Impr",                            #Add data
          add = "mean_sd",                                            #Calculate average and draw SD error bars
          fill = "COR_MODE", palette = colours,                       #Fill bar by correction mode
          position = position_dodge(0.8)) +                           #Define distance between bars
  labs(x="", y="Base Calls [in %]") +                                 #Define y-axis title
  ggtitle(label = "A) Improved base calls", subtitle = "") +          #Define plot title and subtitle
  theme_bw() +
  theme(legend.position = "none", legend.title = element_blank()) +   #Remove legend from plot
  scale_y_continuous(expand = expansion(mult = c(0.01, 0.1)))         #Adjust y-axis: bottom 1% spacing, top 10% spacing

  
# Semi-conservative
test.simpr <- test.simpr %>% add_xy_position(x = "COV", fun = "mean_sd", dodge = 0.8)

plot_simp <-
ggbarplot(tab_norm, x = "COV", y = "SImpr",                           #Add data
          add = "mean_sd",                                            #Calculate average and draw SD error bars
          fill = "COR_MODE", palette = colours,                       #Fill bar by correction mode
          position = position_dodge(0.8)) +                           #Define distance between bars
  labs(x="", y="Base Calls [in %]") +                                 #Define y-axis title
  ggtitle(label = "B) Semi-conservative base calls",                  #Define plot title
          subtitle = "N-calls vs. incorrect") +                       #Define plot subtitle
  theme_bw() +
  theme(legend.position = "none", legend.title = element_blank(),     #Remove legend from plot
        plot.subtitle = element_text(hjust = 0.1)) +                  #Adjust subtitle font size
  stat_pvalue_manual(test.simpr, label = "p.adj.signif",              #Add p-value bars
                     hide.ns = T) +                                   #Hide non-significant p-values
  scale_y_continuous(expand = expansion(mult = c(0.01, 0.1)))         #Adjust y-axis: bottom 1% spacing, top 10% spacing



  
# Too conservative
test.swors <- test.swors %>% add_xy_position(x = "COV", fun = "mean_sd", dodge = 0.8)

plot_swors <-
ggbarplot(tab_norm, x = "COV", y = "SWors",                           #Add data
          add = "mean_sd",                                            #Calculate average and draw SD error bars
          fill = "COR_MODE", palette = colours,                       #Fill bar by correction mode
          position = position_dodge(0.8)) +                           #Define distance between bars
  labs(x="", y="Base Calls [in %]") +                                 #Define y-axis title
  ggtitle(label = "C) Too conservative base calls",                   # Define plot title
          subtitle = "N-calls vs. correct") +                         #Define plot subtitle
  theme_bw() +
  theme(legend.position = "none", legend.title = element_blank(),     #Remove legend from plot
        plot.subtitle = element_text(hjust = 0.1)) +                  #Adjust subtitle font size
  stat_pvalue_manual(test.swors, label = "p.adj.signif",              #Add p-value bars
                     hide.ns = T) +                                   #Hide non-significant p-values
  scale_y_continuous(expand = expansion(mult = c(0.01, 0.1)))         #Adjust y-axis: bottom 1% spacing, top 10% spacing


# Incorrect
test.wors <- test.wors %>% add_xy_position(x = "COV", fun = "mean_sd", dodge = 0.8)

plot_wors <-
ggbarplot(tab_norm, x = "COV", y = "Wors",                            #Add data
          add = "mean_sd",                                            #Calculate average and draw SD error bars
          fill = "COR_MODE", palette = colours,                       #Fill bar by correction mode
          position = position_dodge(0.8)) +                           #Define distance between bars
  labs(x="", y="Base Calls [in %]") +                                 #Define y-axis title
  ggtitle(label = "D) Incorrect base calls", subtitle = "") +         #Define plot title and subtitle
  theme_bw() +
  theme(legend.position = "none", legend.title = element_blank(),     #Remove legend from plot
        plot.subtitle = element_text(hjust = 0.1)) +                  #Adjust subtitle font size
  stat_pvalue_manual(test.wors, label = "p.adj.signif",               #Add p-value bars
                     hide.ns = T) +                                   #Hide non-significant p-values
  scale_y_continuous(expand = expansion(mult = c(0.01, 0.1)))         #Adjust y-axis: bottom 1% spacing, top 10% spacing



###############################################################################
# NUMBER OF N's -----------------------------------------------------
# Read data ---------------------------------------------------------
dat_Ns <- read.csv("HQ.sim.cont.reco.genome.stats.csv", header = TRUE)

# Split coverage column into coverage and run
dat_Ns <- separate(dat_Ns, COV_COND, into = c("COV", "RUN"), sep = "(?<=[0-9]).RUN-")

# Factorise data
dat_Ns[["COR_MODE"]] <- factor(dat_Ns[["COR_MODE"]], 
                               levels = c("no_correction", "ref-based_silencing", "ref-free_silencing", "ref-free_weighting"),
                               labels = c("no_correction", "Polarization-based Damage Silencing", 
                                          "Polarization-free Damage Silencing", "Polarization-free Damage Weighting"))
dat_Ns[["COV"]] <- factor(dat_Ns[["COV"]], levels = c("COV-10", "COV-7.5", "COV-5"), labels = c("10X", "7.5X", "5X"))
dat_Ns[["RUN"]] <- factor(dat_Ns[["RUN"]], levels = c(1,2,3,4,5))


# Calculate relative difference--------------------------------------
dat_rel_diff <- dat_Ns %>%
  group_by(COV, RUN) %>%
  mutate(
    CNT_N_no_correction = CNT_N[COR_MODE == "no_correction"],
    diff = (CNT_N - CNT_N_no_correction) / CNT_N_no_correction * 100
  ) %>%
  ungroup() %>%
  filter(COR_MODE != "no_correction")


# Compute kruskal wallis test ---------------------------------------
dat_rel_diff %>% group_by(COV) %>% kruskal_test(diff ~ COR_MODE) %>% adjust_pvalue(method = "BH") %>% add_significance("p.adj")
test.rel_diff <- dat_rel_diff %>% group_by(COV) %>% dunn_test(diff ~ COR_MODE) %>% adjust_pvalue(method = "BH") %>% add_significance("p.adj")


# Plot Relative Difference -------------------------------------------
test.rel_diff <- test.rel_diff %>% add_xy_position(x = "COV", fun = "mean_sd", dodge = 0.8)

plot_N <-
  ggbarplot(dat_rel_diff, x = "COV", y = "diff",                        #Add data
            add = "mean_sd",                                            #Calculate average and draw SD error bars
            fill = "COR_MODE", palette = colours,                       #Fill bar by correction mode
            position = position_dodge(0.8)) +                           #Define distance between bars
  labs(x="", y="Difference [in %]") +                                   #Define y-axis title
  ggtitle(label = "E) Relative Difference",                             #Define plot title
          subtitle = "Non-informative Base Calls") +                    #Define plot subtitle
  theme_bw() +
  theme(legend.text = element_text(size=13),
        legend.position = "right", 
        legend.title = element_blank(),                      
        plot.subtitle = element_text(hjust = 0.1)) +                    #Adjust subtitle font size
  stat_pvalue_manual(test.rel_diff, label = "p.adj.signif",             #Add p-value bars
                     hide.ns = T) +                                     #Hide non-significant p-values
  scale_y_continuous(expand = expansion(mult = c(0.1, 0.1)))            #Adjust y-axis: bottom 10% spacing, top 10% spacing


###############################################################################
# Plot all plots
plot_grid <-
plot_imp + plot_simp + guide_area() + plot_swors + plot_wors + plot_N + 
  plot_layout(ncol = 3, guides = "collect") &
  theme(legend.title = element_blank())


ggsave("plot_SupplementsComparison.png", plot_grid,
       width = 37.3, height = 18.6, units = "cm")
