# -*- coding: utf-8 -*-
import itertools
import csvkit
import os

# Constants
TARGET='../Fichiers de la base avant Neo4J/base_centrale/bdd_centrale.csv'
DUMMY='./test.csv'
DIRECTIONS='../Fichiers de la base avant Neo4J/bdd_directions.csv'

# Helpers
def fix_source_type(sourcetype):
  if sourcetype == u'Tableau Général 1839' or sourcetype == u'Tableau décennal':
    return 'Divers'
  return sourcetype

def fix_direction(i, direction):
  return i.get(direction, direction)

# Reading the directions
with open(DIRECTIONS, 'r') as df:
  directions_rows = list(csvkit.DictReader(df, encoding='utf-8'))
  directions_index = {}
  for row in directions_rows:
    directions_index[row['original']] = row['fixed']

# Reading the flows
with open(TARGET, 'r') as tf:
  flows = list(itertools.islice(csvkit.CSVKitReader(tf, encoding='utf-8'), 50))
  headers = flows[0]

# Fixing the flows
with open(DUMMY, 'w') as of:
  writer = csvkit.CSVKitWriter(of, encoding='utf-8')
  writer.writerow(headers)

  si = headers.index('sourcetype')
  di = headers.index('direction')

  for row in flows[1:]:
    row[si] = fix_source_type(row[si])
    row[di] = fix_direction(directions_index, row[di])

    writer.writerow(row)
