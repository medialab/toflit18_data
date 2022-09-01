# NEO4J scripts for TOFLIT18

## requirements

This is a node module. You need node to execute the scripts and to install deps:

```
npm i
```

## Create Neo4J data

First transform Toflit18 CSVs into Neo4j compliant nodes.csv and edges.csv.

```
$npm run import -- -- --path ../../
...
$ ls -la .output/
total 168088
drwxrwxr-x 2 paul paul     4096 sept.  1 16:15 .
drwxrwxr-x 7 paul paul     4096 sept.  1 16:17 ..
-rw-rw-r-- 1 paul paul 73371117 sept.  1 16:17 edges.csv
-rw-rw-r-- 1 paul paul 98716197 sept.  1 16:17 nodes.csv
```

## Import data into Neo4J

Use a Neo4J 3.5.16 database to import data

```
bash ./neo4j_3.5.16/bin/neo4j stop &&
echo 'neo4j stopped'
# Erasing the current database
rm -rf ./neo4j_3.5.16/data/databases/graph.db &&

# Creating the new database
rm -rf graph.db &&
bash ./neo4j_3.5.16/bin/neo4j-import --into graph.db --nodes ./.output/nodes.csv --relationships ./.output/edges.csv &&

# Replacing the database
mv graph.db ./neo4j_3.5.16/data/databases/ &&
#sudo chown -R neo4j:neo4j ./neo4j_3.5.16/data/databases/graph.db &&

# Restarting the databse
bash ./neo4j_3.5.16/bin/neo4j start &&
```

## Execute Quantities script

```
npm run quantities -- -- --path ../../
```

## Execute Indices script

```
npm run indices
```
