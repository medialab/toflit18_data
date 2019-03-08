#!/usr/bin/python3
# -*- coding: utf8 -*-
import itertools
import os
from csv import DictReader, writer
import re

WRITE=False
VERBOSE=True
REMOVE_COLUMN=False

def cast_numrodeligne(value):
    if not len(value):
        return ''

    try:
        return int(value)
    except:
        return value

year_re = re.compile('.*?(\d{4}).*')

slugify = lambda s : s.strip().replace(' ','_').replace('/','_').replace('+','_')

def new_source_name(flow):
    new_name = []
    source = correct_source(flow)
    new_name.append(slugify(source))
    
    if 'Colonies' not in source:
        if ('AN F12 1835' in flow['source'] and flow['year'] == '1788' and 'direction' in flow and flow['direction'].strip() != ''):
            new_name.append('Colonies') 
        elif ("partenaires manquants" in flow['sourcetype'] and \
                flow['source'] != 'AN F12 1666' and \
                flow['source'] != 'AN F12 250' and \
                'AN F12 1667' not in flow['source']) or \
                'Fonds Gournay' in flow['source']:
            new_name.append(slugify(flow['pays']))
        elif 'direction' in flow and flow['direction'].strip() != '':
            new_name.append(slugify(flow['direction']))
    
    new_name.append(flow['exportsimports'])
    if flow['sourcetype'] != "Résumé Général" and flow['source'] != "WEBER Commerce de la compagnie des Indes 1904" :
        try:
            # todo calendrier républicain
            new_name.append(year_re.match(flow['year']).group(1))
        except : 
            new_name.append(slugify(flow['year']))

    return '_'.join(new_name)

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
        new_source = "AD17 41 ETP 270 %s"%subid
    return new_source


with open("../base/bdd_centrale.csv", encoding='utf-8') as bdd_centrale:
    reader = DictReader(bdd_centrale)
    data = list(reader)
    headers_bdd_centrale=data[0]
    if VERBOSE:
        print(headers_bdd_centrale)
    # sort order
    # SourceType / year / direction / exportsimports / numéro de ligne / marchandises / pays
    multiple_key_sort = lambda k:(k['sourcetype'],k['year'],k['direction'],k['exportsimports'],cast_numrodeligne(k['numrodeligne']),k['marchandises'],k['pays'])
    # year / partenaire / exportsimports / numéro de ligne
    multiple_key_sort_nationale_par_direction = lambda k:(k['year'],k['pays'],k['exportsimports'],cast_numrodeligne(k['numrodeligne']))
    # year / exportsimports / numéro de ligne
    multiple_key_sort_1671 = lambda k:(k['year'],k['exportsimports'],cast_numrodeligne(k['numrodeligne']))
    #remove headers
    data=data[1:]
    

    data = sorted(data, key=new_source_name )
    csvreport=[["new sourcepath","nb line bdd_centrale","old source.s","source type.s", "nb old sourcepath.s","old sourcepath.s","columns removed"]]
    for filename,data in itertools.groupby(data, key=new_source_name):
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
        # if k=="National par direction/Saint-Brieuc/1750.csv":
        # 	source_data=sorted(source_data,key=multiple_key_sort_nationale_par_direction)
        # elif k =="Divers/AN/F_12_1834A/1671.csv":
        # 	source_data=sorted(source_data,key=multiple_key_sort_1671)
        # else:
        # 	source_data=sorted(source_data,key=multiple_key_sort)

# 		## let's remove empty columns			
# 		columns_index_to_remove= [headers_bdd_centrale.index(h) for h in []]
        empty_columns = []
        for k in source_data[0].keys():
            if len([d[k] for d in source_data if d[k] and d[k].strip() !=''])==0:
                empty_columns.append(k)
# 		for i in columns_index_to_remove:
# 			empty_columns.append(headers_bdd_centrale[i])
# 			if VERBOSE:
# 				print("column %s empty in %s"%(headers_bdd_centrale[i].encode("UTF8"),k.encode("UTF8")))
# #Pour garder toutes les colonnes ?
# 		columns_index_to_remove= []


        # try :
        # 	with open(os.path.join("..","sources", k),"r", encoding='utf-8') as s:
        # 		nb_lines_source=len(s.readlines())-1
        # 		if VERBOSE:
        # 			print("%s: source/bdd_centrale %s/%s"%(k.encode("UTF8"),nb_lines_source,nb_lines_bdd_centrale))
        # except IOError as e:
        # 	nb_lines_source=0
        # 	print("%s doesn't exist"%k.encode("UTF8"))
        print("%s:%s"%(filename,len(source_data)))

        if WRITE:
            # todo
            print('writing sources part has to be rewrite')
            # with open(os.path.join("..","sources", k),"w", encoding='utf-8') as s:
            # 	writer= DictWriter(s)
            # 	source_headers=[h for i,h in enumerate(headers_bdd_centrale) if i not in columns_index_to_remove]
            # 	writer.writerow(source_headers)
            # 	for source_data_line in source_data:
            # 		source_data_line=[d for i,d in enumerate(source_data_line) if i not in columns_index_to_remove]
            # 		writer.writerow(source_data_line)
        # ["sourcepath","nb line bdd_centrale","nb line source","columns removed"]
        csvreport.append([filename,nb_lines_bdd_centrale,
            ";".join(set(d['source'] for d in source_data)),
            ";".join(set(d['sourcetype'] for d in source_data)),
            len(set(d['sourcepath'] for d in source_data)),";".join(set(d['sourcepath'] for d in source_data)),";".join(empty_columns)])

with open("desagregate_bdd_centrale.csv","w", encoding='utf-8') as csvreport_f:
    csvreport_writer=writer(csvreport_f)
    for l in csvreport:
        csvreport_writer.writerow(l)
# L’ordre de tri actuel (see commit 389c8fa) de la base de donnée centrale en croissant:
# SourceType / year / direction / exportsimports / numéro de ligne / marchandises / pays

# Pour les source on les trie de la même manière.
# Sauf pour National / Par direction/ 1749-50-51
# year / partenaire / exportsimports / numéro de ligne

# Et divers 1671 : year / exportsimports / numéro de ligne

# Il faut enlever les colonnes qui sont vides pour une source donnée. Ces colonnes vides sont des colonnes qui n'existent que dans d'autres sources.

# Passage de base centrale à Sources :
# Grouper les lignes par source
# pour chaque groupe de ligne par sourcePath
# on trie suivant la règle établie ci-dessus
# on enlève les colonnes vides dans ce groupe
# on écrit le groupe dans un fichier source qui remplace la version actuelle (en versionnant)

# Il faut pouvoir repérer les fichiers sources qui n'ont pas été modifié par cette mise à jour.
