#!/bin/bash
# file: STATS769_2019_S2_bole001_lab04.sh

# Run the R code for the lab
echo "Running RMD script"
Rscript -e 'library("rmarkdown"); render("STATS769_2019_S2_bole001_lab04.Rmd")'

# Exit
echo "Done"