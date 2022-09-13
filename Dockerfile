FROM neo4j:3.5.16

RUN rm -fr /data/databases/*

COPY --chown=neo4j:neo4j ./neo4j_data/databases/graph.db /data/databases/graph.db/
COPY --chown=neo4j:neo4j ./neo4j_plugins/apoc-3.5.0.14-all.jar /plugins/
