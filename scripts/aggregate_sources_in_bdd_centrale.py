import csvkit
import os

output_filename="../base_centrale/bdd_centrale.csv"
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
					sources_aggregation+=list(r)
sources_aggregation = sorted(sources_aggregation, key=lambda e:(e["sourcetype"],e["year"],e["direction"] if "direction" in e else "",e["exportsimports"] if "exportsimports" in e else "",int(e["numrodeligne"])  if ("numrodeligne" in e and e["numrodeligne"]) else "",e["marchandises"],e["pays"] if "pays" in e else ""))
headers=set(headers)
headers=[h for h in  headers if h not in ordered_headers]
headers=ordered_headers+headers
with open(output_filename,"w") as output_file:
	agg_csv=csvkit.DictWriter(output_file,headers)
	agg_csv.writeheader()
	agg_csv.writerows(sources_aggregation)

#csvsort  -c SourceType,year,direction,exportsimports,numrodeligne,marchandises,pays "$f" > last_ordered.csv
			