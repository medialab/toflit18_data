#!/usr/bin/python3
# -*- coding: utf-8 -*-
import os
import re
from csv import DictReader, DictWriter
import json
from collections import defaultdict

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


AN_REGEX = re.compile(r'An (\d+)', re.IGNORECASE)
YEAR_REGEX = re.compile(r'(\d{4})', re.IGNORECASE)

def normalize_year(year):
    m = AN_REGEX.match(year)

    if not m:
        try:
            return int(year)
        except ValueError:
            return YEAR_REGEX.findall(year)[0]
    else:
        nb = int(m[1])
        if nb < 2 or nb > 14:
            raise Exception('toflit18.republican_calendar.normalizeYear: invalid year %s.'%nb)
        return 1792 + nb



empty_value = lambda v : v=="0" or v=="." or v=="" or v=="?"

def clean_float_string(f):
    f=re.sub(r"[,，、،﹐﹑]",".",f)
    f=re.sub(r"[\s ]","",f)
    return f

def add_calculated_fields_to_line(d):

    d.setdefault("source", "")
    d.setdefault("value", "")
    d.setdefault("value_per_unit", "")
    d.setdefault("quantity", "")

    if (
        (not d["source"]=="") and
        (not(d["value"]=="0" and d["quantity"]=="" and d["value_per_unit"]=="")) and
        (not(empty_value(d["value"]) and empty_value(d["quantity"]) and empty_value(d["value_per_unit"])))
    ):

        d["value_as_reported"] = d["value"]
        # false 0 to null
        if d["value"]=="0" and not empty_value(d["quantity"]):
            # nb_value_set_null+=1
            d["value"]=""

        #À CHANGER : IL FAUT DONNER LA PRIORITÉ AUX VALEURS CALCULÉES % AUX VALEURS
        # Was the d["value"] computed expost based on unit price and quantities ? 0 no 1 yes
        if not empty_value(d["value_per_unit"]) and not empty_value(d["quantity"]):
            d["computed_value"]=1
            q=clean_float_string(d["quantity"])
            pu=clean_float_string(d["value_per_unit"])
            try :
                d["value"] = float(q)*float(pu)
            except :
                print("can't parse to float q: '%s' pu:'%s' "%(q,pu))
                d["value"]=""
            # nb_computed_value+=1
        else :
            d["computed_value"]=0

        # Was the unit price computed expost based on and quantities and value ? 0 no 1 yes
        if empty_value(d["value_per_unit"]) and not empty_value(d["value"]) and not empty_value(d["quantity"]):
            d["replace_computed_up"]=1
            q=clean_float_string(d["quantity"])
            v=clean_float_string(d["value"])
            try:
                d["value_per_unit"] = float(v)/float(q)
            except:
                print("can't parse to float q: '%s' v:'%s' "%(q,v))
                d["value_per_unit"]=""

            # nb_computed_value+=1
        else :
            d["replace_computed_up"]=0

    # transform "." and "?" into ""
    for field in ["value","quantity","value_per_unit"]:
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
        for extra_header in ["value_as_reported", "computed_value", "replace_computed_up", "best_guess_national_prodxpart","best_guess_national_partner", "best_guess_department_prodxpart", "best_guess_national_department" ]:
            if extra_header not in headers:
                headers+=[extra_header]

    # Best guess year index
    # to compute best guess we need to store years when best guess are available to use it to compute secondary definitions
    best_guess_year_index = defaultdict(set)
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

                                    # compute Best guess source type
                                    # best_guess_national_prodxpart
                                    year = normalize_year(line['year']) # republican calendar back to current
                                    if (line['source_type']=="Objet Général" and year<=1786) or line['source_type']=="Résumé" or line['source_type']=="National toutes directions tous partenaires":
                                        line['best_guess_national_prodxpart'] = 1
                                        best_guess_year_index['best_guess_national_prodxpart'].add(year)
                                    # best_guess_national_partner
                                    if line['source_type']=="Tableau Général" or line['source_type']=="Résumé":
                                        line['best_guess_national_partner'] = 1
                                    # best_guess_department_prodxpart
                                    if (line['source_type']=="Local" and year != 1750) or (line['source_type']== "National toutes directions tous partenaires" and year == 1750):
                                        line['best_guess_department_prodxpart'] = 1 
                                    if line['tax_department']=="Rouen" and line['export_import']=="Imports" and (year==1737 or (year>= 1739 & year<=1749) or year==1754 or (year>=1756 & year <=1762)):
                                    	line['best_guess_department_prodxpart'] = 0
                                    # best_guess_national_department
                                    if line['source_type']=="National toutes directions sans produits" or (line['source_type'] == "National toutes directions tous partenaires" and year == 1750):
                                        line['best_guess_national_department'] = 1
                                        best_guess_year_index['best_guess_national_department'].add(year)
                                    if line['source_type'] =="National toutes directions partenaires manquants":
                                    	line['best_guess_national_department'] = 1
                                    	best_guess_year_index['best_guess_national_department'].add(year)
                                writer.writerow(line)
    if with_calculated_values:
        # compute best guess secondary variables
        # create a tmp file to stream directly without loading in memory
        with open(output_filename, "r", encoding="utf-8") as input_file, open('./bdd_centrale_tmp.csv', "w", encoding="utf-8") as output_file:
            reader = DictReader(input_file)
            writer = DictWriter(output_file, reader.fieldnames)
            writer.writeheader()
            for flow in reader:
                year = normalize_year(flow['year'])
                # best_guess_national_prodxpart
                if flow['source_type']=="Compagnie des Indes" and flow['tax_department']=="France par la Compagnie des Indes" and year in best_guess_year_index['best_guess_national_prodxpart'] :
                    flow['best_guess_national_prodxpart'] = 1
                # best_guess_national_department
                if flow['source_type'] == 'local' and year in best_guess_year_index['best_guess_national_department']:
                    flow['best_guess_national_department'] = 1
                writer.writerow(flow)
        # finally replace original file with the tmp one
        os.replace('./bdd_centrale_tmp.csv', output_filename)
if __name__ == "__main__":
    aggregate_sources_in_bdd_centrale(False)