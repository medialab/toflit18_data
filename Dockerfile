FROM neo4j:3.1.4

RUN rm -fr /data/databases/* \
    && mkdir -p /data/databases/graph.db/

ADD ./neo4j_database/graph.db /data/databases/graph.db/