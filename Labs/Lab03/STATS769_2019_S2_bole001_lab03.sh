#!/bin/bash
# file: STATS769_2019_S2_bole001_lab03.sh

# Copy all of the .csv files to the local directory
cp /course/Labs/Lab02/*.csv .

# Count the total number of bicycle trips
echo "Total bicycle trips:"
grep "bicycle" trips*.csv | wc -l

# Get the scooter strips for each file and put into another file
for i in trips*.csv
do
    head -1 $i > "scooter-"$i
    grep "scooter" $i >> "scooter-"$i    
    echo "$i created"
done

# Run the R code for the lab
echo "Running RMD script"
Rscript -e 'library("rmarkdown"); render("STATS769_2019_S2_bole001_lab03.Rmd")'

# Exit
echo "Done"