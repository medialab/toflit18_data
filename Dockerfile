FROM neo4j:3.5.16

RUN rm -fr /data/databases/*

COPY --chown=neo4j:neo4j ./neo4j_database/graph.db /data/databases/graph.db/
