# -*- coding: utf-8 -*-
import csvkit
import os
import re

DOUBLE_QUOTES = ur'[«»„‟“”"]'
SIMPLE_QUOTES = ur"[’‘`‛']"
SPACES_COMPACTING = ur'\s+'
ELLIPSIS = ur'…'
HYPHEN = ur'–'
OEWRONG=ur'u'

# Daudin's cleaning process
def clean(s):
	if not s:
		s = u""

	s = s.strip()
	s = re.sub(ELLIPSIS, "...", s)
	s = re.sub(HYPHEN, "-", s)
	s = re.sub(DOUBLE_QUOTES, '"', s)
	s = re.sub(SIMPLE_QUOTES, "'", s)
	s = re.sub(SPACES_COMPACTING, " ", s)
	s = re.sub(OEWRONG, "œ", s)
	
	#IL FAUDRAIT RAJOUTER ICI LE Œ FAUTIF, MAIS JE NE SAIS PAS COMMENT FAIRE

	return s

output_filename="../base/bdd_centrale.csv"
directory="../sources"
black_list=["Divers/AN/F_12_1835"]

sources_aggregation=[]
ordered_headers=["numrodeligne","dataentryby","source","sourcepath","sourcetype","year","exportsimports","direction","bureaux","sheet","marchandises","pays","value","quantit","origine","total","quantity_unit","leurvaleursubtotal_1","leurvaleursubtotal_2","leurvaleursubtotal_3","prix_unitaire","probleme","remarks"]
headers=[]

for (dirpath,dirnames,filenames) in os.walk(directory):
	if not sum(dirpath == os.path.join(directory,b) for b in black_list) :
		for csv_file_name in filenames :
			ext = csv_file_name.split(".")[-1] if "." in csv_file_name else None
			if ext == "csv":
				print "%s in %s"%(csv_file_name,dirpath)
				with open(os.path.join(dirpath,csv_file_name),"r") as source_file:
					r=csvkit.DictReader(source_file)
					headers+=r.fieldnames
					lines = list(r)
					sources_aggregation+=lines
sources_aggregation = sorted(sources_aggregation, key=lambda e:(e["sourcetype"],e["year"],e["direction"] if "direction" in e else "",e["exportsimports"] if "exportsimports" in e else "",int(e["numrodeligne"])  if ("numrodeligne" in e and e["numrodeligne"]) else "",e["marchandises"],e["pays"] if "pays" in e else ""))

# Cleaning sources
for row in sources_aggregation:
	for k in row:
		row[k] = clean(row[k])

headers=set(headers)
headers=[h for h in  headers if h not in ordered_headers]
headers=ordered_headers+headers+["computed_value","computed_up"]
with open(output_filename,"w") as output_file:
	agg_csv=csvkit.DictWriter(output_file,headers, encoding="utf-8")
	agg_csv.writeheader()
	agg_csv.writerows(sources_aggregation)

#csvsort  -c SourceType,year,direction,exportsimports,numrodeligne,marchandises,pays "$f" > last_ordered.csv

#taking care of 0/missing in "values" and in "prix_unitaire"

def clean_float_string(f):
	f=re.sub(r"[,，、،﹐﹑]",".",f)
	f=re.sub(r"[\s ]","",f)
	return f

with open(output_filename,"r") as output_file:
	lines = csvkit.DictReader(output_file)
	lines.next()
	headers=lines.fieldnames
	lines=list(lines)

nb_lines_before = len(lines)

empty_value = lambda v : v=="0" or v=="." or v=="" or v=="?"

lines = [d for d in lines if not d["source"]=="" ]
lines = [d for d in lines if not(d["value"]=="0" and d["quantit"]=="" and d["prix_unitaire"]=="")] #Dans tous les cas regardés le 31 mai 2016, ce sont des "vrais" 0
lines = [d for d in lines if not(empty_value(d["value"]) and empty_value(d["quantit"]) and empty_value(d["prix_unitaire"]))]
print "removed %s empty or missing value lines"%(nb_lines_before - len(lines))

nb_value_set_null=0
nb_computed_value=0
nb_computed_value=0
for d in lines :
	# false 0 to null
	if d["value"]=="0" and not empty_value(d["quantit"]):
		nb_value_set_null+=1
		d["value"]="" 


	#À CHANGER : IL FAUT DONNER LA PRIORITÉ AUX VALEURS CALCULÉES % AUX VALEURS 
	# Was the d["value"] computed expost based on unit price and quantities ? 0 no 1 yes
	if not empty_value(d["prix_unitaire"]) and not empty_value(d["quantit"]):
		d["computed_value"]=1
		q=clean_float_string(d["quantit"])
		pu=clean_float_string(d["prix_unitaire"])
		try :
			d["value"] = float(q)*float(pu)
		except :
			print "can't parse to float q: '%s' pu:'%s' "%(q,pu)
			d["value"]=""
		nb_computed_value+=1
	else :
		d["computed_value"]=0

	# Was the unit price computed expost based on and quantities and value ? 0 no 1 yes
	if empty_value(d["prix_unitaire"]) and not empty_value(d["value"]) and not empty_value(d["quantit"]):
		d["replace_computed_up"]=1
		q=clean_float_string(d["quantit"])
		v=clean_float_string(d["value"])
		try:
			d["prix_unitaire"] = float(v)/float(q)
		except:
			print "can't parse to float q: '%s' v:'%s' "%(q,v)
			d["prix_unitaire"]=""

		nb_computed_value+=1
	else :
		d["replace_computed_up"]=0

	# transform "." and "?" into ""
	for field in ["value","quantit","prix_unitaire"]:
		if d[field] in [".","?"]:
			d[field]=""

#18000
print "removed %s false 0 values"%nb_value_set_null 
#10000
print "computed %s values from quantit*prix_unitaire "%nb_computed_value
#82000
print "computed %s prix_unitaire from value/quantit"%nb_computed_value
#83000 // 200

with open(output_filename,"w") as output_file:
	writefile=csvkit.DictWriter(output_file,fieldnames=headers+["computed_value","replace_computed_up"])
	writefile.writeheader()
	writefile.writerows(lines)
