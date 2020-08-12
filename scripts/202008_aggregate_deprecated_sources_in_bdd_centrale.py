#!/usr/bin/python3
# -*- coding: utf-8 -*-
import os
import re
from csv import DictReader, DictWriter
import datapackage

DOUBLE_QUOTES = r'[«»„‟“”"]'
SIMPLE_QUOTES = r"[’‘`‛']"
SPACES_COMPACTING = r'\s+'
ELLIPSIS = r'…'
HYPHEN = r'–'

#IL FAUDRAIT RAJOUTER ICI LE Œ FAUTIF, MAIS JE NE SAIS PAS COMMENT FAIRE
OEWRONG=r'u'

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
    #s = re.sub(OEWRONG, u"œ", s)
    return s

empty_value = lambda v : v=="0" or v=="." or v=="" or v=="?"

def clean_float_string(f):
    f=re.sub(r"[,，、،﹐﹑]",".",f)
    f=re.sub(r"[\s ]","",f)
    return f

def add_calculated_fields_to_line(d):

    d.setdefault("source", "")
    d.setdefault("value", "")
    d.setdefault("prix_unitaire", "")
    d.setdefault("quantit", "")

    if (
        (not d["source"]=="") and
        (not(d["value"]=="0" and d["quantit"]=="" and d["prix_unitaire"]=="")) and
        (not(empty_value(d["value"]) and empty_value(d["quantit"]) and empty_value(d["prix_unitaire"])))
    ):

        d["value_as_reported"] = d["value"]
        # false 0 to null
        if d["value"]=="0" and not empty_value(d["quantit"]):
            # nb_value_set_null+=1
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
                print("can't parse to float q: '%s' pu:'%s' "%(q,pu))
                d["value"]=""
            # nb_computed_value+=1
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
                print("can't parse to float q: '%s' v:'%s' "%(q,v))
                d["prix_unitaire"]=""

            # nb_computed_value+=1
        else :
            d["replace_computed_up"]=0

    # transform "." and "?" into ""
    for field in ["value","quantit","prix_unitaire"]:
        if d[field] in [".","?"]:
            d[field]=""

def aggregate_sources_in_bdd_centrale(with_calculated_values = False):
    output_filename="./deprecated_bdd_centrale.csv"
    directory="../sources_deprecated_202008"
    black_list=[]#["Divers/AN/F_12_1835", "Out"]

    sources_aggregation=[]
    ordered_headers=["numrodeligne","dataentryby","source","sourcepath","sourcetype","year","exportsimports","direction","bureaux","sheet","marchandises","pays","value","quantit","origine","total","quantity_unit","leurvaleursubtotal_1","leurvaleursubtotal_2","leurvaleursubtotal_3","prix_unitaire","probleme","remarks","unverified"]
    headers=[]

    # First we need to read the headers
    for (dirpath,dirnames,filenames) in os.walk(directory):
        if not sum(dirpath == os.path.join(directory,b) for b in black_list) :
            for csv_file_name in filenames :
                ext = csv_file_name.split(".")[-1] if "." in csv_file_name else None
                if ext == "csv":
                    # print "%s in %s"%(csv_file_name,dirpath)
                    with open(os.path.join(dirpath,csv_file_name),"r",  encoding="utf-8") as source_file:
                        r=DictReader(source_file)
                        headers+=r.fieldnames

    headers=set(headers)
    headers=[h for h in  headers if h not in ordered_headers]
    headers=ordered_headers+headers

    if with_calculated_values:
        for extra_header in ["value_as_reported","computed_value","replace_computed_up"]:
            if extra_header not in headers:
                headers+=[extra_header]

    # Then we actually read and write the lines
    with open(output_filename,"w", encoding="utf-8") as output_file:
        writer = DictWriter(output_file, headers)
        writer.writeheader()

        for (dirpath,dirnames,filenames) in os.walk(directory):
            if not sum(dirpath == os.path.join(directory,b) for b in black_list) :
                for csv_file_name in filenames :
                    ext = csv_file_name.split(".")[-1] if "." in csv_file_name else None
                    if ext == "csv":
                        print("%s in %s"%(csv_file_name,dirpath))

                        filepath = os.path.join(dirpath, csv_file_name)

                        with open(filepath,"r", encoding="utf-8") as source_file:
                            r=DictReader(source_file)

                            for line in r:
                                for k in line:
                                    line[k] = clean(line[k])

                                # if not filepath.decode('utf-8').endswith(line['sourcepath']):
                                #     print 'WARNING: incorrect sourcepath!'
                                #     raise Exception('incorrect sourcepath')
                                if (line['sourcetype'] != "" or line['sourcepath'] != "")  : # and line['sourcetype'] !="Out"
                                    if with_calculated_values:
                                        add_calculated_fields_to_line(line)
                                    writer.writerow(line)

if __name__ == "__main__":
    aggregate_sources_in_bdd_centrale(False)