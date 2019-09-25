for $i in collection("file:///course/Labs/Lab04/XML")//row
    where $i/vehicle_type[text() = 'scooter'] and 
          $i/year[text() = '2018']
    return string-join(($i/trip_duration/text(), $i/trip_distance/text()), ',')
