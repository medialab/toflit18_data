# README.md

*December 9th 2020 version*

Welcome to the data repository of the Toflit18 project!
More details on the project can be found on its research blog: https://toflit18.hypotheses.org/
Details on the funding, partners, contributors, etc. can be found here: http://toflit18.medialab.sciences-po.fr/#/about
The main research tool we provide to researchers is the datascape: http://toflit18.medialab.sciences-po.fr/#/home
There is a companion GitHub repository dealing with the software aspects of the datascape (https://github.com/medialab/toflit18).

All the data are encoded in UTF-8, comma-separated. We recommend working with them using LibreOffice.

The data will be soon released under datapackage format.

The data are released under an ODbl licence : http://opendatacommons.org/licenses/odbl/1.0/

# Sources
The folder "source" includes sources used in the project as csv files. For more details on the different types of sources, see http://toflit18.medialab.sciences-po.fr/#/exploration/sources

# Raw aggregated data
- The folder "base" has all the data, classification and various files. These include:
	- bdd_centrale.csv.zip which is a aggregation of all sources (except the "Out" ones"). This is the go-to file if you want the latest, raw version of the data.
	- documentation about all variables in bdd_centrale.csv is available in the file "Variables explanation.csv"

# Relational database
- We provide you basically with all the necessary files to do a relational database. We work with it ourselves with the scripts included in the folder "scripts". Our workflow creates Stata and Neo4J output.
- documentation about the classifications is available in the file "classifications_index.csv". Do not hesitate to contribute new ones, starting from "marchandises_pour_nouvelle_classification.csv"
- bdd_courante.csv.zip is the "flat file" build around bdd_centrale.csv. This includes all the classifications, some computations for imputed value of flow and value_per_unit, best guess sources etc. This is the go-to file if you want the lastet, cleaned and enriched version of the data

# Contact us
For history related issues, ask Loïc Charles (lcharles02@univ-paris8.fr) or Guillaume Daudin (guillaume.daudin@dauphine.psl.eu)

For basic guidance in using these ressources, ask Guillaume Daudin (guillaume.daudin@dauphine.psl.eu)

For advanced technical issues, ask Paul Girard (paul@ouestware.com)
