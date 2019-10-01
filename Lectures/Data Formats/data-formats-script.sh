
## MongoDB example
mongo
mongo --eval 'db.zips.find().limit(3).forEach(printjson)' test  
## Zip codes in New York
mongo --eval 'db.zips.find({"city": "NEW YORK"}).forEach(printjson)' test  
## Zip codes in New York, showing just the zip codes
mongo --eval 'db.zips.find({"city": "NEW YORK"}, {"_id": 1}).forEach(printjson)' test  
## Zip codes in New York, ordered by population
mongo --eval 'db.zips.find({"city": "NEW YORK"}).sort({"pop": 1}).forEach(printjson)' test  
## Zip codes in New York, top ten ordered by population
mongo --eval 'db.zips.find({"city": "NEW YORK"}).sort({"pop": -1}).limit(10).forEach(printjson)' test  
## Zip codes with population > 10,000
mongo --eval 'db.zips.find({"pop": {$gt: 10000}}).forEach(printjson)' test  
## How many zip codes
mongo --eval 'db.zips.find({}).count()' test  
## Total population for New York
mongo --eval 'db.zips.aggregate([{$match: {"city": "NEW YORK"}}, {$group: {_id: "$city", total: {$sum: "$pop"}}}]).forEach(printjson)' test
## Total population per city 
mongo --eval 'db.zips.aggregate([{$group: {_id: "$city", total: {$sum: "$pop"}}}]).forEach(printjson)' test
## Total population per city (first 10 cities)
mongo --eval 'db.zips.aggregate([{$group: {_id: "$city", total: {$sum: "$pop"}}}, {$limit: 10}]).forEach(printjson)' test


# XML Database examples
# Constant expression
basex '<hello>World</hello>'
# Pure XPath 
basex 'doc("factbook.xml")//continent'
# Order result
echo '
for $i in doc("factbook.xml")//continent
order by $i/@name
return $i
' > query.xq
basex query.xq
# Generate wrapper around output (enclosed FLWOR)
echo '
<world>
{
  for $i in doc("factbook.xml")//continent
  order by $i/@name
  return $i
}
</world>
' > query.xq
basex query.xq > result.xml
more result.xml
# Where clause
echo '
for $i in doc("factbook.xml")//country/city
  let $pop := number($i/population/text())
  where $pop > 3000000
  order by $pop descending
  return string-join(($i/name[1]/text(), string($pop)), ", ")
' > query.xq
basex query.xq > result.xml
more result.xml

# Join
echo '
<countries>
{
  for $i in doc("factbook.xml")//continent
  for $j in doc("factbook.xml")//country
  let $country := $j/@name
  let $continent := $i/@name
  where $i/@id = $j/encompassed/@continent
  order by $country
  return <country name="{$country}" continent="{$continent}"/>
}
</countries>
' > query.xq
basex query.xq > result.xml
more result.xml



