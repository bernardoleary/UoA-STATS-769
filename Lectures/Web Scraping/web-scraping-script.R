
## See set of demos in
## https://www.stat.auckland.ac.nz/~paul/stats769/web-scraping/

# Reading files vs web resource
read.csv("example.csv")
read.csv("https://www.stat.auckland.ac.nz/~paul/stats769/web-scraping/example.csv")

# Downloading web resource
download.file("https://www.stat.auckland.ac.nz/~paul/stats769/web-scraping/example.csv", "example-download.csv")

# Reading collection of static web resources
countries <- c("NZ1", "AUS", "US1")
urls <- sprintf("https://www.stat.auckland.ac.nz/~paul/stats769/web-scraping/AC34/20130901103549-NAV-%s.csv", countries)
urls
races <- lapply(urls, read.csv)


# HTTP
library(httr)
# GET a web page
response <- GET("https://www.stat.auckland.ac.nz/~paul/")
headers(response)
headers(response)$`content-type`
content(response)
# GET a CSV file
GET("https://www.stat.auckland.ac.nz/~paul/stats769/web-scraping/example.csv")
# GET a password-protected page
GET("http://httpbin.org/basic-auth/user/passwd")
GET("http://httpbin.org/basic-auth/user/passwd",
    authenticate("user", "passwd"))
# Automatically calls read.csv() on response body
response <- GET("https://www.stat.auckland.ac.nz/~paul/stats769/web-scraping/example.csv")
headers(response)$`content-type`
content(response)
# Leave response body as text 
content(response, as="text")

# GET a form
# Demonstrate interactive use of
# https://www.stat.auckland.ac.nz/~paul/stats769/web-scraping/demo-form-get.html
url <- "https://www.stat.auckland.ac.nz/~paul/stats769/web-scraping/demo-form-get-output.php?count=5"
response <- GET(url)
content(response, as="text")

# POST a form
# Demonstrate interactive use of
# https://www.stat.auckland.ac.nz/~paul/stats769/web-scraping/demo-form-post.html
url <- "https://www.stat.auckland.ac.nz/~paul/stats769/web-scraping/demo-form-post-output.php"
query <- list(count="5")
response <- POST(url, body = query)
content(response, as="text")

# Dynamic Web Pages
# 'rdom' package (REQUIRES phantomjs)
# Web page not only has no <table> elements, but content is dynamically
# generated
# http://www.worldrugby.org/results
library(rdom)
rdom("https://www.stat.auckland.ac.nz/~paul/stats769/web-scraping/demo-javascript.html", css="div#data", all=TRUE)

# Example web API
# GeoNet API
# http://wfs.geonet.org.nz/
read.csv("http://wfs.geonet.org.nz/geonet/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=geonet:quake_search_v1&maxFeatures=50&outputFormat=csv")

# Extract an HTML table from a web page as a data frame
library(rvest)
response <- GET("https://www.stat.auckland.ac.nz/~paul/stats769/web-scraping/demo-html-table.html")
html_table(content(response))

# Extra HTML from NOT a table
library(xml2)
html <- read_html("https://www.stat.auckland.ac.nz/~paul/stats769/web-scraping/demo-html-not-table.html")
extractVar <- function(xpath) {
    span <- xml_find_all(html, xpath)
    text <- xml_text(span)
    gsub("^ +| +$", "", text)
}
names <- extractVar("//div/span[@class = 'car-name']")
cyl <- as.numeric(extractVar("//div/span[@class = 'car-cyl']"))
hp <- as.numeric(extractVar("//div/span[@class = 'car-hp']"))
data.frame(names, cyl, hp)






# Query API with JSON result
# GeoNet API
# http://info.geonet.org.nz/display/appdata/Advanced+Queries
jsonResult <- GET("http://wfs.geonet.org.nz/geonet/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=geonet:quake_search_v1&maxFeatures=10&outputFormat=json")
# Raw JSON
library(jsonlite)
jsonResult
head(content(jsonResult))
content(jsonResult, as="text")
prettify(content(jsonResult, as="text"))
# Messy list of list of lists (automatic "parsed" conversion)
quakesList <- fromJSON(content(jsonResult, as="text"))
str(quakesList)
str(quakesList$features)
str(quakesList$features$properties)

# Query API with XML result
xmlResult <- GET("http://wfs.geonet.org.nz/geonet/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=geonet:quake_search_v1&maxFeatures=50&outputFormat=text/xml;subtype=gml/3.2")
substr(content(xmlResult, as="text"), 1, 300)
cat(substr(content(xmlResult, as="text"), 1, 300))
# Automatically converted to XML document
# Presents some challenges to extract result!
quakesXML <- content(xmlResult)
xml_structure(quakesXML)

