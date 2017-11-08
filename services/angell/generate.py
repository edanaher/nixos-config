#!/usr/bin/env python

import datetime
import os
import re
import sys
from string import Template
import urllib
import urllib.request

DEBUG=False

def fetch(url):
  req = urllib.request.Request(url=url, headers = { "User-Agent": "script for angell.kdf.sh" })
  with urllib.request.urlopen(req) as resp:
    return resp.read()


def extractMatch(match, errString = "ERROR"):
  if match == None:
    return errString
  else:
    return match.group(0)


if DEBUG:
  with open("urls") as f:
    urls = f.read().splitlines()
else:
  page = fetch('https://www.mspca.org/animal_care/boston-dog-training/')
  all_urls = { re.search('https://secure2.convio.net[^"]*', str(l)).group(0) for l in page.splitlines() if(b"See Dates" in l) }
  urls = sorted(all_urls)

days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
months = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ]

def prefixIndex(needle, haystack):
  for i in range(0, len(haystack)):
    if haystack[i].startswith(needle):
      return i
  return -1

def checkDate(strDate):
  r = re.match("([A-Z][a-z]+)\s*([0-9]+)", strDate)
  if r == None:
    return None
  month = 1 + prefixIndex(r.group(1), months)
  if month == 0:
    return 99
  day = int(r.group(2))
  now = datetime.date.today()
  date = datetime.date(now.year, month, day)
  delta = date - now
  if delta < datetime.timedelta(-6*30):
    date = datetime.date(now.year + 1, month, day)
    delta = date - now

  if delta < datetime.timedelta(-7):
    return -2
  if delta < datetime.timedelta(0):
    return -1
  if delta == datetime.timedelta(0):
    return 0
  if delta > datetime.timedelta(7):
    return 2
  if delta > datetime.timedelta(0):
    return 1

def classify(session):
  startDiff = checkDate(session[6])
  endDiff = checkDate(session[7])
  if startDiff == None or endDiff == None:
    return 'class="unscheduled"'
  if startDiff == None and endDiff == None:
    return 'class="error"'
  if startDiff > 0:
    return 'class="future"'
  if startDiff == -1:
    return 'class="recent"'
  if endDiff < 0:
    return 'class="past"'
  if endDiff == 1:
    return 'class="almost-done"'
  return ''


classes = {}
for u in urls:
  if DEBUG:
    with open(re.sub("/", "_", u)) as f:
      lines = f.read()
  else:
    lines = str(fetch(u))
  title_line = re.search('product_image.*alt="([^"]*)"', lines)
  if title_line == None:
    continue
  name = title_line.group(1)
  classes[name] = (u, [])
  for c in re.finditer('option value=[^>]*>([^<]*)<', lines):
    desc = c.group(1)
    day = extractMatch(re.search("|".join(days), desc))
    dateRegex = "[A-Z][a-z]+\s+[0-9][0-9]?[a-z]*"
    period = extractMatch(re.search(dateRegex + "\s*-\s*" + dateRegex + "|[Nn]ot [Cc]urrently [Aa]vailable|TBD|See you [^)]*|rolling|[Cc]urrently [Uu]navailable", desc))
    startDay = extractMatch(re.search("^" + dateRegex, period))
    endDay = extractMatch(re.search(dateRegex + "$", period))
    timeRegex = "[0-9]+(:[0-9]+)?[\sAPM]*"
    timeString = extractMatch(re.search(timeRegex + "\s*-\s*" + timeRegex, desc), "Unknown")
    endTimeSp = extractMatch(re.search(timeRegex + "$", timeString), "NoEndTime")
    endTime = re.sub("^([0-9]*)([AP]M)", r"\1:00\2", re.sub("\s", "", endTimeSp))
    noClass = extractMatch(re.search("[Nn]o\s*[Cc]lass\s*[^)]*", desc), "")
    remainder = re.split("|".join([day, timeString, period, noClass]), desc)
    prefix = ""
    if len(remainder[0]) > 2:
      prefix = re.sub(":$", "", remainder[0].rstrip())
    remainder = re.sub("|".join([day, timeString, period, prefix, noClass]), "", desc)
    remainders = [r.group(0) for r in re.finditer('\w\w\w[^)]*', remainder)]
    classes[name][1].append((prefix, day, timeString, period, noClass, endTime, startDay, endDay, remainders, c.group(1)))

classData = []
for c in sorted(classes):
  sys.stderr.write(c + "\n")
  classData.append('<h2><a href="' + classes[c][0] + '">' + c + '</a></h2>')
  sessions = sorted(classes[c][1])
  if len(sessions) == 0:
    continue
  classData.append('<table>')
  columnAppears = {}
  for s in sessions:
    for i in range(0,5):
      if s[i]:
        columnAppears[i] = True
  for s in sorted(sessions, key = lambda c: (c[0], days.index(c[1]), c[2])):
    columns = [s[i] for i in range(0,5) if i in columnAppears]
    classed = classify(s)
    if s[3] == 'rolling':
      classed = ''
    classData.append('<tr ' + classed + '>' + "\n".join([ '<td>' + c + '</td>' for c in columns ]) + '</tr>')
  classData.append('</table>')

with open("template.html") as f:
  templateContents = f.read()
template = Template(templateContents)
now = list(os.popen('TZ=America/New_York date'))[0].rstrip()
print(template.substitute(now=now, classes = "\n".join(classData)))
