
### Set up
rm -r Flights
mkdir Flights
cd Flights
cp /course/ASADataExpo2009/Data/airports.csv .
cp /course/ASADataExpo2009/Data/carriers.csv .
cp ../airports.Rmd .
cp ../carriers.Rmd .
cat airports.Rmd
cat carriers.Rmd
cp ../airports.R .
cat airports.R
Rscript airports.R

### Globs
# list all files
ls
# list only CSV files
ls *.csv
# list all airports files
ls airports.*
# remove all .Rmd files 
rm *.Rmd
# (then put them back)
cp ../airports.Rmd .
cp ../carriers.Rmd .

### Command subsitution
## Just to show the idea
wc $(ls)
## What I would normally do in that case
wc *

## Escape sequences
## Spaces are important - do NOT put spaces in file names
cp ../linux-prosper-script.sh "linux prosper script.sh"
ls linux prosper script.sh
ls linux\ prosper\ script.sh
ls "linux prosper script.sh"
ls linux*
ls "linux*"

### Shell redirection
# Redirect command output to a file
ls > listing.txt
more listing.txt 
# Pipe command output to another command
ls | wc

### Loops
# call wc on all CSV files
## Just to show the idea
for i in *.csv
do
    wc $i
done
## What I would normally do in that case
wc *.csv
# call wc on all CSV files that have a corresponding Rmd file
for i in *.Rmd
do
    filename=$(basename --suffix=.Rmd $i)
    wc $filename.csv
done

### GNU tools
# How many lines (and words and characters) in a file
wc airports.csv
# Searching for text patterns within files
head airportsUS.csv
# Find lines with Springfield
grep Springfield airportsUS.csv
grep "Springfield" airportsUS.csv
# Find lines with Los Angeles
grep "Los Angeles" airportsUS.csv
# Find lines with "Springfield"
grep '"Springfield"' airportsUS.csv
# find all CSV files within a directory, recursively
# (the quotes are necessary so that *.csv is not expanded by the shell)
find /course/ASADataExpo2009/ -name "*.csv"
# find all CSV files within a directory that are larger than 1GB
find /course/ASADataExpo2009/ -name "*.csv" -size +1G
# tar
tar cvfz ../flights.tar.gz .
du -sh .
ls -lh ../flights.tar.gz
mkdir Temp
cd Temp
tar ztvf ../../flights.tar.gz
tar zxvf ../../flights.tar.gz
ls
ls ..
ls > /tmp/ls1.txt && ls .. > /tmp/ls2.txt && diff /tmp/ls1.txt /tmp/ls2.txt
cd ..
rm -r Temp

### Shell one-liners
# how big are the non-year CSV files ?
ls -lh $(find /course/ASADataExpo2009/ -name "*.csv" | grep -v [0-9].csv)
# remove all airports files, EXCEPT the CSV files
rm $(ls airports* | grep -v .csv)
ls
# Extract just "Springfield" airports
grep '"Springfield"' airportsUS.csv > springfield-airports.csv
# How many airports in "Springfield"
grep '"Springfield"' airportsUS.csv | wc -l
# Extract column headers and "Springfield" airports
head -1 airportsUS.csv > springfield-airports.csv
grep '"Springfield"' airportsUS.csv >> springfield-airports.csv
more springfield-airports.csv
# Examples from first week
ls -lh /course/ASADataExpo2009/Data/*.csv
head -1 /course/ASADataExpo2009/Data/1988.csv | tee 1988.csv > 1989.csv
shuf -n10000 /course/ASADataExpo2009/Data/1988.csv >> 1988.csv
shuf -n10000 /course/ASADataExpo2009/Data/1989.csv >> 1989.csv
wc -l *.csv
# Extract small random subset from all 21st century yearly CSV files
for i in /course/ASADataExpo2009/Data/2*.csv
do
    echo $i
    # Note the definition of new variable
    # Note the lack of space around '='
    filename=$(basename $i)
    shuf -n100 $i > $filename
done
ls -lh

### Awk
cat springfield-airports.csv
awk -e '{ print }' springfield-airports.csv
awk -e '{ if (NR == 1) print(NF) }' springfield-airports.csv
awk -F, -e '{ if (NR == 1) print(NF) }' springfield-airports.csv
awk -F, -e '{ print($1) }' springfield-airports.csv
awk -e '/"M."/ { print }' springfield-airports.csv
awk -F, -e '/"M."/ { print($1) }' springfield-airports.csv
head 1988.csv
grep ",SGF," 1988.csv | head
grep ",SGF," 1988.csv | wc
awk -F, -e '{ if ($17 == "SGF") print }' 1988.csv
awk -F, -e '{ if ($17 == "SGF") print }' 1988.csv > 1988-from-springfield.csv
cat 1988-from-springfield.csv
wc 1988-from-springfield.csv

### Shell scripts
cp ../airports.Rmd .
cp ../carriers.Rmd .
# Building R markdown files
Rscript -e 'library("rmarkdown"); render("airports.Rmd")'
# Escape double quotes rather than surround with single quotes
Rscript -e "library(\"rmarkdown\"); render(\"airports.Rmd\")"
# Shell script
cp ../rendermd.sh .
cat rendermd.sh
bash rendermd.sh
# Multiple commands
cp ../rendermd-multiple.sh rendermd.sh
cat rendermd.sh
bash rendermd.sh
# Shell script variable
cp ../rendermd-var.sh rendermd.sh
cat rendermd.sh
bash rendermd.sh airports.Rmd
bash rendermd.sh carriers.Rmd
# My R+ script
cp ../R+ .
cat R+
# Make script executable
chmod u+x rendermd.sh
./rendermd.sh airports.Rmd

### Make
cp ../Makefile .
cat Makefile
make 
# Make multiple commands
cp ../Makefile-multiple Makefile
cat Makefile
make
# Make target and dependencies
cp ../Makefile-dependency Makefile
cat Makefile
make airports.html
touch airports.Rmd
make airports.html
# Make patterns
cp ../Makefile-pattern Makefile
cat Makefile
make airports.html
touch airports.Rmd
make airports.html
touch carriers.Rmd
make carriers.html
# More Make patterns
cp ../Makefile-pattern-2 Makefile
cat Makefile
touch carriers.Rmd
make carriers.html
diff carriers-built.html carriers.html 

