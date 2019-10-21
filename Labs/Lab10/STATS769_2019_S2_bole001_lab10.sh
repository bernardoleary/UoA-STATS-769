#!/bin/bash
# file: STATS769_2019_S2_bole001_lab10.sh

# Run the R code for the lab
echo "Running RMD script"
/usr/bin/time -f "%e" Rscript -e 'library("rmarkdown"); render("STATS769_2019_S2_bole001_lab10.Rmd")'

# Exit
echo "Done"