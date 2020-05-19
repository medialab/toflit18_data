#!/usr/bin/python3
# -*- coding: utf8 -*-
import itertools
import os
from csv import DictReader, writer, DictWriter
import re
import json
from unidecode import unidecode
import collections

class PackageTranslator:
    DATA_DIR = 'sources'
    variables_translations_to_datapackage = {
        "numrodeligne": "line_number",
        "dataentryby": "data_collector",
        "source": "source",
        "sourcepath": "filepath",
        "sourcetype": "source_type",
        "year": "year",
        "exportsimports": "export_import",
        "direction": "tax_department",
        "bureaux": "tax_office",
        "sheet": "sheet",
        "marchandises": "product",
        "pays": "partner",
        "value": "value",
        "quantit": "quantity",
        "origine": "origin",
        "total": "value_total",
        "quantity_unit": "quantity_unit",
        "leurvaleursubtotal_1": "value_sub_total_1",
        "leurvaleursubtotal_2": "value_sub_total_2",
        "leurvaleursubtotal_3": "value_sub_total_3",
        "prix_unitaire": "value_unit",
        "probleme": "difference_value_unit_price",
        "remarks": "remarks",
        "unverified": "unverified",
        "doubleaccounts_droitsdedouane": "duty_part_of_bundle",
        "quantité pour les droits": "duty_quantity",
        "doubleaccounts": "value_part_of_bundle",
        "doubleaccount": "value_part_of_bundle",
        "remarks pour les droits": "duty_remarks",
        "Droits unitaires": "duty_by_unit",
        "Largeur en lignes (pour tissu)": "width_in_line",
        "quantity": "quantity",
        "unité pour les droits": "duty_quantity_unit",
        "Remarques": "remarks",
        "numerodeligne": "line_number",
        "Droits totaux indiqués": "duty_total"
    }
    # Balance en argent au désavantage de la France   trade_deficit
    # Balances en argent en faveur de la France     trade_surplus

    def __init__(self):
        with open('../csv_sources_schema.json', 'r', encoding='UTF8') as schema_f:
            self.schema = json.load(schema_f)
            self.fieldnames = [f['name'] for f in self.schema["fields"]]


    def _format_for_datapackage(self, rows, filepath):
        extra_fields = set()
        for row in rows:
            formated_row = {}
            for field, value in row.items():
                if field == '':
                    print(field, value)
                    print(row)
                if field in self.variables_translations_to_datapackage:
                    formated_row[self.variables_translations_to_datapackage[field]] = value
                elif field not in ['value_as_reported', 'replace_computed_up', 'computed_value']:
                    # computed fields are not reported as extra fields.
                    extra_fields.add(field)
                formated_row['filepath'] = filepath
            yield formated_row
        if len(extra_fields) > 0:
            print("extra fields %s in %s"%(extra_fields,filepath))
    
    def write_flows_in_new_format(self, flows, source_type, name):
        path = os.path.join(self.DATA_DIR, source_type)
        if not os.path.exists(path):
            os.makedirs(path)
        path = os.path.join(path, "%s.csv" % name)
        with open(path, 'w', encoding='utf8') as output:
            writer = DictWriter(output, fieldnames=self.fieldnames)
            writer.writeheader()
            writer.writerows(self._format_for_datapackage(flows, path))

            # path to be added in the datapackage resource
            return path

WRITE=True
VERBOSE=True
REMOVE_COLUMN=False

def cast_numrodeligne(value):
    if not len(value):
        return 0

    try:
        return int(value)
    except:
        return 0#value

year_re = re.compile('.*?(\d{4}).*')
special_chars = re.compile('[^-A-z0-9\._/]')
def slugify (s):
    s = unidecode(s.strip(' ').replace(' ', '_').replace('/', '_').replace('+', '_').replace("'", "_"))
    return special_chars.sub('', s)

### virer des noms des pays accent et apostrophe
### virer les virgules et accents des noms de sources
### réécriture : numéro de lignes
### 

# load country classification made for generate source name
COUNTRIES_CLASSIF = {}

sourceclassif = {}
with open('../base/classification_partner_sourcename.csv', 'r', encoding='utf8') as f:
    ccs = DictReader(f)
    for l in ccs :
        sourceclassif[l['simplification']]= l['sourcename']
simpl = {}
with open('../base/classification_partner_simplification.csv', 'r', encoding='utf8') as f:
    ccs = DictReader(f)
    for l in ccs :
        simpl[l['orthographic']] = sourceclassif[l['simplification']]

with open('../base/classification_partner_orthographic.csv', 'r', encoding='utf8') as orthof:
    orthoc = DictReader(orthof)
    for ortho in orthoc:
        COUNTRIES_CLASSIF[ortho['source']]=simpl[ortho['orthographic']] 


def new_source_name(flow):
    new_name = []
    source = correct_source(flow)
    new_name.append(slugify(source))
    
    #"AD76 7F97 - via Dardel" => pas d'année, pas de direction, pas de pays mais export/imports

    if 'Colonies' not in source:
        if ('AN F12 1835' in flow['source'] and flow['year'] == '1788' and 'direction' in flow and flow['direction'].strip() != ''):
            new_name.append('Colonies') 
        elif ("partenaires manquants" in flow['sourcetype'] and \
                flow['source'] != 'AN F12 1666' and \
                flow['source'] != 'AN F12 250' and \
                'AN F12 1667' not in flow['source']) or \
                'Fonds Gournay' in flow['source']:
            new_name.append(slugify(COUNTRIES_CLASSIF[flow['pays']]))
        elif flow['source'] != "AD76 7F97 - via Dardel" and 'direction' in flow and flow['direction'].strip() != '' and flow['sourcetype'] != 'National toutes directions sans produits':
            new_name.append(slugify(flow['direction']))
    
    new_name.append(flow['exportsimports'])
    if flow['source'] not in ["WEBER Commerce de la compagnie des Indes 1904", "BNF_MF_6431", "Romano1957+Velde+IIHS-128", "AD76 7F97 - via Dardel"]:
        try:
            # todo calendrier républicain
            new_name.append(year_re.match(flow['year']).group(1))
        except : 
            new_name.append(slugify(flow['year']))

    return slugify('_'.join(new_name))

ANOM_source = re.compile(r'.*ANOM[ _]Col[ _]F[ _]2B[ _]1[34]')
AD17_missing = re.compile(r'^41 ETP 270/(\d{4})')


def correct_source(flow):
    new_source = flow['source']
    # correct mistakes in source value
    new_source = new_source.replace(' - ', ' ')
    new_source = new_source.replace('AD 44', 'AD44')
    new_source = new_source.replace('NEHA', 'IIHS')
    new_source = new_source.replace('Montbret', 'BMRouen Montbret')
    new_source = new_source.replace('Fond Montyon', 'APHP Fond Montyon')
    # removing (Tableau ...) from ANOM source names
    m = ANOM_source.match(new_source)
    if m:
        new_source = m.group()+" Colonies"
    new_source = new_source.replace('AD44 C716 n°30', 'AD44 C716-30')
    new_source = new_source.replace('AD44 C716 n°34', 'AD44 C716-34')
    new_source = new_source.replace('AD44 C717_14', 'AD44 C717-14')
    new_source = new_source.replace('AD44C717', 'AD44 C717')
    new_source = new_source.replace('AD44 C 717', 'AD44 C717')
    new_source = new_source.replace('AD44 C707', 'AD44 C706')
    new_source = new_source.replace('AD C706', 'AD44 C706')
    m = AD17_missing.match(new_source)
    if m:
        subid = m.group(1)
        if flow['year'] == '1726':
            subid = 9393
        if flow['year'] == '1757':
            subid = 9421
        if flow['year'] == '1760':
            subid = 9424
        new_source = "AD17 41 ETP 270 %s" % subid
    return new_source


with open("../base/bdd_centrale.csv", encoding='utf-8') as bdd_centrale:

    reader = DictReader(bdd_centrale)
    translator = PackageTranslator()
    data = list(reader)

    # line sort order
    # SourceType / year / direction / exportsimports / numéro de ligne / marchandises / pays
    lines_key_sort = lambda k:(k.get('sourcetype',''), k.get('year',''), k.get('direction',''), k.get('exportsimports',''), cast_numrodeligne(k.get('numrodeligne',0)), k.get('marchandises',''), k.get('pays',''))

    data = sorted(data, key=lambda r : (r['sourcetype'], new_source_name(r)) )
    csvreport=[["new sourcepath","nb line bdd_centrale","old source.s","source type.s", "nb old sourcepath.s","old sourcepath.s","columns removed"]]
    datapackage_resource_path = []
    for (source_type, filename),data in itertools.groupby(data, key=lambda r : (r['sourcetype'], new_source_name(r))):
        if filename=="":
            print("sourcefilename IS empty ARRRG")
            for l in g:
                print(l)
        # print("source filename: %s"%(k))
        empty_columns=[]
        nb_lines_source=None
        nb_lines_bdd_centrale=None

        # if VERBOSE:
        # 	print(k.encode("UTF8"))
        # let's sort
        source_data=list(data)

        nb_lines_bdd_centrale=len(source_data)
        source_data=sorted(source_data, key=lines_key_sort)

        print("%s:%s"%(filename,len(source_data)))

        if WRITE:
            path = translator.write_flows_in_new_format(source_data, source_type, filename)
            datapackage_resource_path.append(path)

        csvreport.append([filename,nb_lines_bdd_centrale,
            ";".join(set(d['source'] for d in source_data)),
            ";".join(set(d['sourcetype'] for d in source_data)),
            len(set(d['sourcepath'] for d in source_data)),";".join(set(d['sourcepath'] for d in source_data)),";".join(empty_columns)])
    datapackage_resource = collections.OrderedDict([     
        ("name", "flows"),
        ("mediatype","text/csv"),
        ("format","csv"),
        ("encoding","UTF8"),
        ("profile","tabular-data-resource"), 
        ("schema","csv_sources_schema.json"),
        ("sources",[{"title":"French Bureau de la balance du commerce statistics see http://toflit18.medialab.sciences-po.fr/#/exploration/sources for more details"}]),
        ("path",datapackage_resource_path),
    ])


with open("desagregate_bdd_centrale.csv","w", encoding='utf-8') as csvreport_f:
    csvreport_writer=writer(csvreport_f)
    for l in csvreport:
        csvreport_writer.writerow(l)
# update datapackage
with open("../datapackage.json", "r", encoding="utf8") as datapackage_file, open("datapackage.json", "w", encoding='utf8') as new_datapackage_file:
    datapackage = json.load(datapackage_file, object_pairs_hook=collections.OrderedDict)
    datapackage['resources'].append(datapackage_resource)
    json.dump(datapackage, new_datapackage_file, indent=2, ensure_ascii=False)


