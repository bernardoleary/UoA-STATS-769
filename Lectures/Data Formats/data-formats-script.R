
## JSON & dot.notation
## Example JSON file (from the Star Wars API)
cat(readLines("luke.json"), sep="\n")

# JSON <-> R conversions
library(jsonlite)
demoJSON <- function(x) {
    cat("\nOriginal R:\n")
    cat("-----------\n")
    print(x)
    cat("\nR to JSON:\n")
    cat("----------\n")
    xjson <- toJSON(x)
    print(xjson)
    cat("\nR to JSON (pretty):\n")
    cat("-------------------\n")
    print(prettify(xjson))
    cat("\nR from JSON:\n")
    cat("------------\n")
    print(fromJSON(xjson))
    invisible()
}
demoJSON(1:5)
demoJSON(month.name)
x <- 1:12
names(x) <- month.name
demoJSON(x)
demoJSON(matrix(1:6, nrow=2))
demoJSON(mtcars[1:4, 1:3])
demoJSON(list(a=month.name, b=1:12))
nested <- fromJSON('[ { "x": 1, 
                        "y": { "a": 1, "b": "A" } }, 
                      { "x": 2, 
                        "y": { "a": 2, "b": "B" } } ]')
nested
dim(nested)
flatten(nested)
dim(flatten(nested))

## A *list*
cat(readLines("luke.json"), sep="\n")
luke <- fromJSON(readLines("../../Lectures/data-formats/luke.json"))
str(luke)

## A data frame of *lists*
## (because the "films" column [at least] is array of values ?)
people <- fromJSON(readLines("sw-people.json"))
dim(people)
sapply(people, class)
head(people$name)
head(people$films)
names <- unlist(people$name)
films <- sapply(people$films, length)
## Characters who appeared in the most films
o <- order(films, decreasing=TRUE)[1:20]
cbind(names[o], films[o])

## MongoDB (JSON-like)
## Also see ./data-formats-script.sh if 'mongolite' does not work
system("mongo --eval 'db.zips.find().limit(3).forEach(printjson)' test")
## NOTE that the MongoDB server does not require authorisation
## (like a more serious server would) so please limit yourself
## to *querying* the server.
library(mongolite)
m <- mongo("zips")
m$find(limit=3)
m$find(query='{"city": "NEW YORK"}')
result <- m$find(query='{"city": "NEW YORK"}')
dim(result)
result$loc
## Zip codes in New York, showing just the zip codes
m$find(query='{"city": "NEW YORK"}', fields='{"_id": 1}')
## Zip codes in New York, ordered by population
m$find(query='{"city": "NEW YORK"}', sort='{"pop": 1}')
## Zip codes in New York, top ten ordered by population
m$find(query='{"city": "NEW YORK"}', sort='{"pop": -1}', limit=10)
## Zip codes with population > 100,000
m$find('{"pop": {"$gt": 100000}}')
## compound query
m$find(query='{"city": "NEW YORK", "pop": {"$gt": 100000}}')

## How many zip codes
m$count()

## Total population for New York
m$aggregate('[{"$match": {"city": "NEW YORK"}}, {"$group": {"_id": "$city", "total": {"$sum": "$pop"}}}]')
## Total population per city
m$aggregate('[{"$group": {"_id": "$city", "total": {"$sum": "$pop"}}}]')
## Total population per city (first 10 cities)
m$aggregate('[{"$group": {"_id": "$city", "total": {"$sum": "$pop"}}}, {"$sort": {"total": -1}}, {"$limit": 10}]')
## Total population per city (first 10 cities in New York State)
## (New York city is broken into boroughs and even smaller neighbourhoods)
m$aggregate('[{"$match": {"state": "NY"}}, {"$group": {"_id": "$city", "total": {"$sum": "$pop"}}}, {"$sort": {"total": -1}}, {"$limit": 10}]')


## XML & XPath
## Example XML file
cat(readLines("pets.xml", n=20), sep="\n")

library(xml2)
petsXML <- read_xml("pets.xml")
petsXML
class(petsXML)
rows <- xml_find_all(petsXML, "row/row")
rows
library(selectr)
xml_find_all(petsXML, css_to_xpath("row row"))
months <- xml_text(xml_find_all(rows, "month"))
counts <- xml_text(xml_find_all(rows, "pets_adopted"))
# Turning an XML document into a data frame
pets <-
    data.frame(month=as.Date(paste0("2016-", months, "-01"), format="%Y-%b-%d"),
               count=as.numeric(counts))
o <- order(pets$month)
plot(pets$month[o], pets$count[o], type="l")

## More complex XML (HTML)
## http://jmatchparser.sourceforge.net/factbook/
cat(readLines("factbook.xml", n=50), sep="\n")
factbook <- read_xml("factbook.xml")
cities <- xml_find_all(factbook, "//country/city")
countryNames <- sapply(cities,
                       function(c) {
                           country <- xml_find_first(c, "ancestor::country")
                           xml_attr(country, "name")
                       })
populations <- as.numeric(xml_text(xml_find_first(cities, "population")))
cityNames <- xml_text(xml_find_first(cities, "name"))
o <- order(populations, decreasing=TRUE)[1:10]
cbind(cityNames[o], countryNames[o], populations[o])
## Check year of data
popYears <- xml_attr(xml_find_first(cities, "population"), "year")
table(popYears)
cbind(cityNames[o], countryNames[o], populations[o], popYears[o])
## XPath with predicate
xml_find_all(factbook, "//country/city[population > 3000000]/name")

## XBase (XML) & XQuery
## See ./data-formats-script.sh



