
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

