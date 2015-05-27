
# requirements

To execute those scripts you'll need python 2.7 and [csvkit](https://csvkit.readthedocs.org/en/0.9.1/).
To install csvkit :

```bash
pip install csvkit
```

You might want to use virtualenv to install csvkit.

# aggregate sources into bdd_centrale.csv

## check sources headers

```bash
bash scripts/print_source_headers.sh > sources_headers.csv
```

Open the sources_headers.csv into a spreadsheet software (LibreOffice recommanded) and check of the mandatory headers are in the sources and labled correctly.

## aggregation script

```bash
cd scripts
python aggregate_sources_in_bdd_centrale.py
```

Currently the mandatory headers are : "sourcetype","year","marchandises".
The known columns are : "numrodeligne","dataentryby","source","sourcepath","sourcetype","year","exportsimports","direction","bureaux","sheet","marchandises","pays","value","quantit","origine","total","quantity_unit","leurvaleursubtotal_1","leurvaleursubtotal_2","leurvaleursubtotal_3","prix_unitaire","probleme","remarks".

Note that this script currently blacklist the sources beginning with "Divers/AN/F_12_1835".


## check and commit bdd_centrale.csv

```bash
git add base_centrale/bdd_centrale.csv
git commit -m "new aggregation"
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




