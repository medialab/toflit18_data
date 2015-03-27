#!/usr/bin/python
# -*- coding: utf8 -*-
import csvkit
import itertools
import os 

with open("../base_centrale/bdd_centrale.csv") as bdd_centrale:
	reader=csvkit.reader(bdd_centrale)
	data=list(reader)[1:]
	print data[0]
	data = sorted(data, key=lambda e:e[3])
	for k,g in itertools.groupby(data, key=lambda e:e[3]):
		print k.encode("UTF8")
		try :
			with open(os.path.join("..","sources", k),"r") as s:
				print "%s:%s/%s"%(k.encode("UTF8"),len(list(g)),len(s.readlines())-1)
		except IOError as e:
			print "%s doesn't exist"%k.encode("UTF8")
			print "%s:%s"%(k.encode("UTF8"),len(list(g)))

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