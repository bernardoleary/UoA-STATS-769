#!/bin/bash
# file: STATS769_2019_S2_bole001_lab09.sh

# Split the files
split -l 653246 /course/data.austintexas.gov/distance-duration.csv

# Run the R code for the lab
echo "Running RMD script"
/usr/bin/time -f "%e" Rscript -e 'library("rmarkdown"); render("STATS769_2019_S2_bole001_lab09.Rmd")'

# Exit
echo "Done"