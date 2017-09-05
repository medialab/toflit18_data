import pandas as pd

df = pd.read_csv('../traitements_marchandises/01RepertoireMarchandises.csv')
df = df[df['Inconnu'] != 1]
df = df.rename(columns={'marchandises': 'name'})
df = df.filter(items=['name', 'definition'])
df = df.drop_duplicates(subset='name')

json = df.to_json(orient='records')

print json
