This readme explains how to aggregate the individual csv sources into bdd_centrale.csv and vice-versa.


# requirements

To execute those scripts you'll need [python 2.7](https://www.python.org/download/releases/2.7/) and [csvkit](https://csvkit.readthedocs.org/en/0.9.1/).
To install csvkit (after having installed python 2.7):

```bash
pip install csvkit
```

You might want to use [virtualenv](https://virtualenv.pypa.io/en/stable/) to install csvkit.
If you don'y know what virtualenv you can skip it.

# aggregate sources into bdd_centrale.csv

## check sources headers

```bash
bash scripts/print_source_headers.sh > sources_headers.csv
```

Open the sources_headers.csv into a spreadsheet software (LibreOffice recommanded) and check of the mandatory headers (see next paragraph) are in the sources and labled correctly.


## aggregation script

```bash
cd scripts
python aggregate_sources_in_bdd_centrale.py
```

Currently the mandatory headers are : "sourcetype","year","marchandises".
The known columns are : "numrodeligne","dataentryby","source","sourcepath","sourcetype","year","exportsimports","direction","bureaux","sheet","marchandises","pays","value","quantit","origine","total","quantity_unit","leurvaleursubtotal_1","leurvaleursubtotal_2","leurvaleursubtotal_3","prix_unitaire","probleme","remarks".

Note that this script currently blacklist the sources beginning with "Divers/AN/F_12_1835".

The compilation of the sources in one single file is available in 

```bash
$ head base/bdd_centrale.csv
numrodeligne,dataentryby,source,sourcepath,sourcetype,year,exportsimports,direction,bureaux,sheet,marchandises,pays,value,quantit,origine,total,quantity_unit,leurvaleursubtotal_1,leurvaleursubtotal_2,leurvaleursubtotal_3,prix_unitaire,probleme,remarks,Largeur en lignes (pour tissu),Droits totaux indiqués,doubleaccounts_droitsdedouane,doubleaccount,Droits unitaires,unité pour les droits,doubleaccounts,quantité pour les droits,remarks pour les droits,value_as_reported,computed_value,replace_computed_up
1,Demba,AN F12 1835,National partenaires manquants/Angleterre 1784.csv,National partenaires manquants,1784,Imports,,,4,Bois d'Inde de Campeche,Angleterre,62300,454000,,,livres,,,,0.137224669604,,,,,,,,,,,,62300,0,1
2,Demba,AN F12 1835,National partenaires manquants/Angleterre 1784.csv,National partenaires manquants,1784,Imports,,,4,Bois de Sainte Marthe,Angleterre,49100,98300,,,livres,,,,0.499491353001,,,,,,,,,,,,49100,0,1
3,Demba,AN F12 1835,National partenaires manquants/Angleterre 1784.csv,National partenaires manquants,1784,Imports,,,4,Bois de Sandal,Angleterre,20000,100000,,,livres,,,,0.2,,,,,,,,,,,,20000,0,1
4,Demba,AN F12 1835,National partenaires manquants/Angleterre 1784.csv,National partenaires manquants,1784,Imports,,,4,Cendre dite soude,Angleterre,33000,367200,,,livres,,,,0.0898692810458,,,,,,,,,,,,33000,0,1
5,Demba,AN F12 1835,National partenaires manquants/Angleterre 1784.csv,National partenaires manquants,1784,Imports,,,4,Charbon de terre,Angleterre,3781800,90600,,,muids,,,,41.7417218543,,,,,,,,,,,,3781800,0,1
6,Demba,AN F12 1835,National partenaires manquants/Angleterre 1784.csv,National partenaires manquants,1784,Imports,,,4,Cuivre,Angleterre,35700,27100,,,livres,,,,1.31734317343,,,,,,,,,,,,35700,0,1
7,Demba,AN F12 1835,National partenaires manquants/Angleterre 1784.csv,National partenaires manquants,1784,Imports,,,4,Etain,Angleterre,701400,694500,,,livres,,,,1.00993520518,,,,,,,,,,,,701400,0,1
8,Demba,AN F12 1835,National partenaires manquants/Angleterre 1784.csv,National partenaires manquants,1784,Imports,,,4,fer divers,Angleterre,84500,982200,,,livres,,,,0.0860313581755,,,,,,,,,,,,84500,0,1
9,Demba,AN F12 1835,National partenaires manquants/Angleterre 1784.csv,National partenaires manquants,1784,Imports,,,4,Graines diverses,Angleterre,9300,16200,,,livres,,,,0.574074074074,,,,,,,,,,,,9300,0,1
```

# split bdd_centrale.csv into sources

## split script

```bash
cd scripts
python split_bdd_centrale_in_sources.py
```
## check and rename report 

```bash
mv desagregate_bdd_centrale.csv desagregate_bdd_centrale_20150527.csv
```

## commit 

....




