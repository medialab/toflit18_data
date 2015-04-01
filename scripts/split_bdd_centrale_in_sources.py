#!/usr/bin/python
# -*- coding: utf8 -*-
import csvkit
import itertools
import os 

WRITE=True

with open("../base_centrale/bdd_centrale.csv") as bdd_centrale:
	reader=csvkit.reader(bdd_centrale)
	data=list(reader)
	headers_bdd_centrale=data[0]
	print headers_bdd_centrale
	# sort order
	# SourceType / year / direction / exportsimports / numéro de ligne / marchandises / pays
	multiple_key_sort= lambda k:(k[4],k[5],k[7],k[6],int(k[0]) if len(k[0])>0 else "",k[10],k[11])
	# year / partenaire / exportsimports / numéro de ligne
	multiple_key_sort_nationale_par_direction=lambda k:(k[5],k[11],k[6],int(k[0])  if len(k[0])>0 else "")
	# year / exportsimports / numéro de ligne
	multiple_key_sort_1671=lambda k:(k[5],k[6],int(k[0])  if len(k[0])>0 else "")
	#remove headers
	data=data[1:]
	data = sorted(data, key=lambda e:e[3])
	for k,g in itertools.groupby(data, key=lambda e:e[3]):
		print k.encode("UTF8")
		# let's sort
		source_data=list(g)
		if k=="National par direction/Saint-Brieuc/1750.csv":
			source_data=sorted(source_data,key=multiple_key_sort_nationale_par_direction)
		elif k =="Divers/AN/F_12_1834A/1671.csv":
			source_data=sorted(source_data,key=multiple_key_sort_1671)
		else:
			source_data=sorted(source_data,key=multiple_key_sort)

		## let's remove empty columns
		columns_index_to_remove=[3]
		for i in range(len(source_data[0])):
			if len([_[i] for _ in source_data if _[i]])==0:
				print "column %s empty in %s"%(headers_bdd_centrale[i].encode("UTF8"),k.encode("UTF8"))
				columns_index_to_remove.append(i)
		try :
			with open(os.path.join("..","sources", k),"r") as s:
				print "%s:%s/%s"%(k.encode("UTF8"),len(source_data),len(s.readlines())-1)
		except IOError as e:
			print "%s doesn't exist"%k.encode("UTF8")
			print "%s:%s"%(k.encode("UTF8"),len(source_data))
		if WRITE:
			with open(os.path.join("..","sources", k),"w") as s:
				writer=csvkit.writer(s)
				source_headers=[h for i,h in enumerate(headers_bdd_centrale) if i not in columns_index_to_remove]
				writer.writerow(source_headers)
				for source_data_line in source_data:
					source_data_line=[d for i,d in enumerate(source_data_line) if i not in columns_index_to_remove]
					writer.writerow(source_data_line)

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