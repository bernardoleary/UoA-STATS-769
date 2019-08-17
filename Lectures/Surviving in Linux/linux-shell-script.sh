
## Getting into Linux
# Boot a lab machine into Linux 
# ... OR ...
# Putty/ssh into Linux

# VM
ssh pmur002@sc-cer00014-04.its.auckland.ac.nz

### Basic file system operations
# Where are we ?
pwd
# Make a directory (folder) for my project
mkdir Flights
# List current files and directories
ls
# List parent directories
ls ..
ls ../..
# List absolute paths
ls /
ls /tmp
# There are places we cannot go!
ls /root
# Change to new directory
cd Flights
# Where are we ?
pwd
# Copy a file into this directory
cp /scratch/ASADataExpo2009/Data/airports.csv .
# Notice that overwriting happens without warning
cp /scratch/ASADataExpo2009/Data/airports.csv .
# Remove a file (then copy it again)
rm airports.csv 
ls
cp /scratch/ASADataExpo2009/Data/airports.csv .
# List more about current files
ls -lh
# What else can 'ls' do ?
man ls
# View the contents of a file
cat airports.csv
# View just the first few lines
head airports.csv
# View the last few lines
tail airports.csv
# View the file one "page" at a time
# (space bar for next page, 'q' to quit)
more airports.csv
# (space bar for next page, 'b' for previous page, 'q' to quit,
#  '/pattern' to search, 'n' for next match, 'N' for previous match)
less airports.csv

### Multi-user, shared-resource environment
who
top
df -h

### Running R
R
# The working directory is the directory we started in

# getwd()
# airports <- read.csv("airports.csv")
# head(airports)
# unique(airports$country)
# table(airports$country)
# airportsUS <- airports[airports$country == "USA",]
# table(airportsUS$state)
# sort(table(airportsUS$state))
# pdf("airport-count.pdf")
# barplot(table(sort(airportsUS$state)))
# dev.off()
# write.csv(airportsUS, "airportsUS.csv")
# q()

# If you have logged into a Linux machine this may work.
# If you have ssh'ed into a Linux machine, work in a directory that
# is also available on the machine that you are logged into, then
# you can use PDF viewer on your local machine
evince airport-count.pdf

### Editing files by hand
# If you have logged into a Linux machine there are GUI editors.
# If you have ssh'ed into a Linux machine ...
# (i) work in a directory that is also available on the machine 
# that you are logged into, then you can use editors on your local machine.
# (ii) use a terminal-based editor like nano or vi
cp ../airports.R .
vi airports.R
# Batch run an R file
Rscript airports.R
# List files in reverse chronological order (most recent last)
ls -ltr

### Processing R Markdown
cp ../airports.Rmd .
cat airports.Rmd
# Generate HTML
Rscript -e 'library(rmarkdown); render("airports.Rmd")'
# Generate PDF
Rscript -e 'library(rmarkdown); render("airports.Rmd", "pdf_document")'
# If you want more control over your final result
cp ../airports.Rhtml .
cat airports.Rhtml
Rscript -e 'library(knitr); knit("airports.Rhtml")'
# Clean up (explained next week)
rm $(ls airports.* | grep -v .csv)
cp ../airports.Rnw .
cat airports.Rnw
R CMD Sweave airports.Rnw
pdflatex airports.tex
