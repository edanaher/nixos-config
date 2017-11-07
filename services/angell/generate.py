#!/usr/bin/env python

import re
import sys

def extractMatch(match, errString = "ERROR"):
  if match == None:
    return errString
  else:
    return match.group(0)


with open("urls") as f:
  urls = f.read().splitlines()

days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

classes = {}
for u in urls:
  with open(re.sub("/", "_", u)) as f:
    lines = f.read()
  title_line = re.search('product_image.*alt="([^"]*)"', lines)
  if title_line == None:
    continue
  name = title_line.group(1)
  classes[name] = []
  for c in re.finditer('option value=[^>]*>([^<]*)<', lines):
    desc = c.group(1)
    day = extractMatch(re.search("|".join(days), desc))
    dateRegex = "[A-Z][a-z]+\s+[0-9][0-9]?[a-z]*"
    period = extractMatch(re.search(dateRegex + "\s*-\s*" + dateRegex + "|[Nn]ot [Cc]urrently [Aa]vailable|TBD|See you [^)]*|rolling|[Cc]urrently [Uu]navailable", desc))
    timeRegex = "[0-9]+(:[0-9]+)?[\sAPM]*"
    timeString = extractMatch(re.search(timeRegex + "\s*-\s*" + timeRegex, desc), "Unknown")
    endTimeSp = extractMatch(re.search(timeRegex + "$", timeString), "NoEndTime")
    endTime = re.sub("^([0-9]*)([AP]M)", r"\1:00\2", re.sub("\s", "", endTimeSp))
    noClass = extractMatch(re.search("[Nn]o\s*[Cc]lass\s*[^)]*", desc), "")
    remainder = re.split("|".join([day, timeString, period, noClass]), desc)
    prefix = ""
    if len(remainder[0]) > 2:
      prefix = remainder[0]
    remainder = re.sub("|".join([day, timeString, period, prefix, noClass]), "", desc)
    remainders = [r.group(0) for r in re.finditer('\w\w\w[^)]*', remainder)]
    classes[name].append((prefix, day, timeString, period, noClass, endTime, remainders, c.group(1)))

for c in sorted(classes):
  print  c
  for t in sorted(classes[c]):
    print "  ", t
