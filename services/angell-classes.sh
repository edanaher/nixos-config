#!/bin/sh

urls=$(curl -s https://www.mspca.org/animal_care/boston-dog-training/ | grep 'See Dates' | grep -o 'https://secure2.convio.net[^"]*' | sort | uniq)
TMPFILE=/tmp/mspca_dates-$$

cat <<EOF
<html>
  <head>
    <title>Unofficial list of MPSCA Angell Training Classes</title>
    <style type="text/css">
      table {
        border-spacing: 0px 2px;
        border: 1px solid #DDDDDD;
      }
      td {
        padding-right: 1em;
        margin-bottom: 2px;
      }
      tr:nth-child(even) {
        background: #EEEEEE;
      }
      p {
        margin-bottom: 0px;
        margin-top: 4px;
      }
    </style>
  </head>
  <body>
    <p>This list is unofficial and automatically generated, and as such may be incorrect or out of date.  Links should take you to registration, but check everything before signing up.  No warranty, use at your own risk, <a href="http://catb.org/jargon/html/N/nasal-demons.html">nasal demons</a>, etc.</p>
    <p>Class listings taken from the MSPCA Angell's <a href="https://www.mspca.org/animal_care/boston-dog-training/">Boston Dog and Cat Training Page</a>, schedules taken from individual class pages linked.</p>
    <p>Send comments or complaints to <a href="mailto:mspca-classes@kdf.sh">mspca-classes@kdf.sh</a></p>
    <p>Last updated `TZ=America/New_York date`</p>
EOF

for u in $urls; do
  curl -s $u > $TMPFILE
  name=$(cat $TMPFILE | grep 'product_image' | grep -o 'alt="[^"]*"' | cut -d\" -f 2)
  if [ -n "$name" ]; then
    echo "<h2><a href=\"$u\">$name</a></h2>"
    echo "<table>"
    cat $TMPFILE | grep 'option value=' | sed 's|.*>\([^<]*\)<.*|\1|; t l; :l; s|^\([^:]*\): *\([a-zA-Z]*\)\?:\?\([^(]*\)\(([^)]*)\?\)\(.*\)$|<tr><td>\1</td><td>\2</td><td>\3</td><td>\4</td><td>\5</td></tr>|; t; s/^/<tr><td>/; s|$|</td></tr>|' | sort 
    echo "</table>"
    rm $TMPFILE
  fi
  echo -e '\000'
done | sort -z -t\> -k3 | sed 's/\x00//'

echo <<EOF
  </body>
</html>
EOF
