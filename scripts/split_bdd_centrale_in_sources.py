#!/usr/bin/python3
# -*- coding: utf8 -*-
import itertools
import os
from csv import DictReader, writer, DictWriter
import re
import json
import collections
import shutil
import csv
import unidecode

WRITE = True
VERBOSE = True
REMOVE_COLUMN = False
SOURCES_ROOT_DIR = '..'


def cast_line_number(value):
    if not len(value):
        return 0
    try:
        return float(value.replace(',', '.'))
    except:
        raise Exception("line_number is not a float %s" % value)


with open("../base/bdd_centrale.csv", encoding='utf-8') as bdd_centrale:

    reader = DictReader(bdd_centrale)

    # check bdd_centrale format
    with open('../csv_sources_schema.json', 'r', encoding='utf8') as f:
        toflit18_flow_schema = json.load(f)
        flows_headers = [f['name'] for f in toflit18_flow_schema['fields']]
        flows_fields = set(flows_headers)
        bdd_fields = set(reader.fieldnames)
        if bdd_fields != flows_fields:
            missing_fields = flows_fields - bdd_fields
            extra_fields = bdd_fields - flows_fields
            if len(missing_fields) > 0:
                print("columns are missing in bdd_centrale.csv: %s" %
                      missing_fields)
            if len(extra_fields) > 0:
                print("Unexpected columns in bdd_centrale.csv: %s" %
                      extra_fields)
            raise Exception('bdd_centrale.csv does not respect flows format')

    data = list(reader)

    # line sort order
    # source_type / year / customs_region / export_import / numéro de ligne / product / partner
    def lines_key_sort(k): return cast_line_number(k.get('line_number', 0))

    def sort_bdd_centrale(r): return (r['source_type'], r['filepath'])
    data = sorted(data, key=sort_bdd_centrale)
    # list existing files and count lines
    existing_files = {}
    for (dirpath, dirnames, filenames) in os.walk(os.path.join(SOURCES_ROOT_DIR, 'sources')):
        for csv_file_name in filenames:
            filepath = os.path.join(dirpath, csv_file_name)
            with open(filepath, 'r', encoding='utf8') as f:
                blouf = csv.DictReader(f)
                existing_files[filepath] = sum((1 for _ in blouf))
    if WRITE:
        shutil.rmtree(os.path.join(SOURCES_ROOT_DIR, 'sources'))
    datapackage_resource_path = []
    with open('desagregate_bdd_centrale_in_sources.csv', 'w', encoding='utf8') as report_f:
        report = csv.DictWriter(report_f, fieldnames=[
                                "filepath", "nb_line", "diff_nb_line", "sources", "source_types"])
        report.writeheader()
        for (source_type, currentFilePath), data in itertools.groupby(data, key=sort_bdd_centrale):
            filename = os.path.basename(currentFilePath)

            if currentFilePath == "":
                print("sourcefilename IS empty ARRRG")
                for l in g:
                    print(l)
            # let's sort
            source_data = list(data)
            real_path = os.path.join(SOURCES_ROOT_DIR, currentFilePath)
            newFilePath = os.path.join(
                SOURCES_ROOT_DIR, 'sources', source_type, filename)

            nb_lines_bdd_centrale = len(source_data)
            nb_lines_existing_file = existing_files[real_path] if real_path in existing_files else 0
#           nb_lines_existing_file=0
            source_data = sorted(source_data, key=lines_key_sort)
            if real_path == newFilePath:
                if nb_lines_existing_file != nb_lines_bdd_centrale:
                    print("%s:%s>%s" %
                          (real_path, nb_lines_existing_file, nb_lines_bdd_centrale))
            else:
                # a change in source type implies a change in filepath
                for line in source_data:
                    # TODO: in case of change in data, the filename might need to be updated too
                    line["filepath"] = os.path.join(
                        "sources", source_type, filename)
                print("%s:%s>%s:%s" %
                      (real_path, nb_lines_existing_file, newFilePath, nb_lines_bdd_centrale))

            if WRITE:
                # make sure directory exist
                path = os.path.dirname(newFilePath)
                if not os.path.exists(path):
                    os.makedirs(path)

                with open(newFilePath, 'w', encoding='utf8') as output:
                    writer = DictWriter(output, fieldnames=flows_headers)
                    writer.writeheader()
                    writer.writerows(source_data)
                datapackage_resource_path.append(
                    os.path.join('sources', source_type, filename))

            report.writerow({
                'filepath': newFilePath,
                'nb_line': nb_lines_bdd_centrale,
                'diff_nb_line': nb_lines_bdd_centrale - nb_lines_existing_file,
                'sources': ";".join(sorted(set(d['source'] for d in source_data))),
                'source_types': ";".join(sorted(set(d['source_type'] for d in source_data)))
            })

    datapackage_resource = collections.OrderedDict([
        ("name", "flows"),
        ("mediatype", "text/csv"),
        ("format", "csv"),
        ("encoding", "UTF8"),
        ("profile", "tabular-data-resource"),
        ("schema", "csv_sources_schema.json"),
        ("sources", [{"title": "French Bureau de la balance du commerce statistics see http://toflit18.medialab.sciences-po.fr/#/exploration/sources for more details"}]),
        ("path", datapackage_resource_path),
    ])


# update datapackage
datapackage = {}
with open("../datapackage.json", "r", encoding="utf8") as datapackage_file:
    datapackage = json.load(
        datapackage_file, object_pairs_hook=collections.OrderedDict)
    # replace flow resource
    datapackage['resources'][-1] = datapackage_resource
with open("../datapackage.json", "w", encoding='utf8') as new_datapackage_file:
    json.dump(datapackage, new_datapackage_file, indent=2, ensure_ascii=False)
