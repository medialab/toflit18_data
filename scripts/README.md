This readme explains how to aggregate the individual csv sources into bdd_centrale.csv and vice-versa.


# requirements

To execute those scripts you'll need [python 3](https://www.python.org/download/releases/3/).

# aggregate sources into bdd_centrale.csv

The sources are split into as many CSV files as archive volumes following the transcription process.
To group all the source data in one single CSV file, use the aggregation script as follow :

```bash
cd scripts
python aggregate_sources_in_bdd_centrale.py
```

This script groups the sources in one single CSV file **./base/bdd_centrale.csv**

```bash
/toflit18_data$ xsv headers base/bdd_centrale.csv
1   line_number
2   source_type
3   year
4   tax_department
5   tax_office
6   partner
7   export_import
8   product
9   origin
10  width_in_line
11  value
12  value_part_of_bundle
13  quantity
14  quantity_unit
15  value_per_unit
16  filepath
17  source
18  sheet
19  value_total
20  value_sub_total_1
21  value_sub_total_2
22  value_sub_total_3
23  data_collector
24  unverified
25  remarks
26  value_minus_unit_val_x_qty
27  trade_deficit
28  trade_surplus
29  duty_quantity
30  duty_quantity_unit
31  duty_by_unit
32  duty_total
33  duty_part_of_bundle
34  duty_remarks
```

A variant of this script add custom variables when aggregating: **value imputations** from unit price and volume and the **best guess sourcetypes**.

```bash
cd scripts
python aggregate_sources_in_bdd_centrale_with_calculations.py
```
This scripts adds eight variables to bdd_centrale.csv :
```bash 
35  value_as_reported
36  computed_value
37  computed_up
38  computed_quantity
39  best_guess_national_prodxpart
40  best_guess_national_partner
41  best_guess_department_prodxpart
42  best_guess_national_department
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




