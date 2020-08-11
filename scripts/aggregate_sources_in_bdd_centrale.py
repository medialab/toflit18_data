#!/usr/bin/python3
# -*- coding: utf-8 -*-
import os
import re
from csv import DictReader, DictWriter
import json

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
    d.setdefault("value_unit", "")
    d.setdefault("quantity", "")

    if (
        (not d["source"]=="") and
        (not(d["value"]=="0" and d["quantity"]=="" and d["value_unit"]=="")) and
        (not(empty_value(d["value"]) and empty_value(d["quantity"]) and empty_value(d["value_unit"])))
    ):

        d["value_as_reported"] = d["value"]
        # false 0 to null
        if d["value"]=="0" and not empty_value(d["quantity"]):
            # nb_value_set_null+=1
            d["value"]=""

        #À CHANGER : IL FAUT DONNER LA PRIORITÉ AUX VALEURS CALCULÉES % AUX VALEURS
        # Was the d["value"] computed expost based on unit price and quantities ? 0 no 1 yes
        if not empty_value(d["value_unit"]) and not empty_value(d["quantity"]):
            d["computed_value"]=1
            q=clean_float_string(d["quantity"])
            pu=clean_float_string(d["value_unit"])
            try :
                d["value"] = float(q)*float(pu)
            except :
                print("can't parse to float q: '%s' pu:'%s' "%(q,pu))
                d["value"]=""
            # nb_computed_value+=1
        else :
            d["computed_value"]=0

        # Was the unit price computed expost based on and quantities and value ? 0 no 1 yes
        if empty_value(d["value_unit"]) and not empty_value(d["value"]) and not empty_value(d["quantity"]):
            d["replace_computed_up"]=1
            q=clean_float_string(d["quantity"])
            v=clean_float_string(d["value"])
            try:
                d["value_unit"] = float(v)/float(q)
            except:
                print("can't parse to float q: '%s' v:'%s' "%(q,v))
                d["value_unit"]=""

            # nb_computed_value+=1
        else :
            d["replace_computed_up"]=0

    # transform "." and "?" into ""
    for field in ["value","quantity","value_unit"]:
        if d[field] in [".","?"]:
            d[field]=""

def aggregate_sources_in_bdd_centrale(with_calculated_values = False):
    output_filename = "../base/bdd_centrale.csv"
    directory = "../sources"
    black_list = []

    sources_aggregation = []
    with open('../csv_sources_schema.json', 'r', encoding='utf8') as f:
        toflit18_flow_schema = json.load(f)
        ordered_headers = [f['name'] for f in toflit18_flow_schema['fields']]
    # headers = []

    # # First we need to read the headers
    # for (dirpath, dirnames, filenames) in os.walk(directory):
    #     if not sum(dirpath == os.path.join(directory, b) for b in black_list):
    #         for csv_file_name in filenames:
    #             ext = csv_file_name.split(".")[-1] if "." in csv_file_name else None
    #             if ext == "csv":
    #                 # print "%s in %s"%(csv_file_name,dirpath)
    #                 with open(os.path.join(dirpath,csv_file_name), "r", encoding="utf-8") as source_file:
    #                     r = DictReader(source_file)
    #                     headers += r.fieldnames

    # headers = set(headers)
    # headers = [h for h in  headers if h not in ordered_headers]
    headers = [h for h in ordered_headers] #+headers
    if with_calculated_values:
        for extra_header in ["value_as_reported", "computed_value", "replace_computed_up"]:
            if extra_header not in headers:
                headers+=[extra_header]

    # Then we actually read and write the lines
    with open(output_filename, "w", encoding="utf-8") as output_file:
        writer = DictWriter(output_file, headers)
        writer.writeheader()

        for (dirpath, dirnames, filenames) in os.walk(directory):
            if not sum(dirpath == os.path.join(directory, b) for b in black_list):
                for csv_file_name in filenames:
                    ext = csv_file_name.split(".")[-1] if "." in csv_file_name else None
                    if ext == "csv":
                        print("%s in %s"%(csv_file_name, dirpath))

                        filepath = os.path.join(dirpath, csv_file_name)

                        with open(filepath, "r", encoding="utf-8") as source_file:
                            r = DictReader(source_file)
                            if r.fieldnames != ordered_headers:
                                print("%s file does not respect the format"%filepath)
                                print(r.fieldnames)
                                exit(1)
                            for line in r:
                                for k in line:
                                    line[k] = clean(line[k])

                                if filepath.replace('../','') != line['filepath']:
                                    print('ERROR: incorrect filepath does not match\n%s\n%s'%(filepath,line['filepath']))
                                    raise Exception('incorrect filepath for line \n%s'%line)
                                if with_calculated_values:
                                    add_calculated_fields_to_line(line)
                                writer.writerow(line)

if __name__ == "__main__":
    aggregate_sources_in_bdd_centrale(False)