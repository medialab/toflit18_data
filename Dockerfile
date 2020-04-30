FROM neo4j:3.5.16

RUN rm -fr /data/databases/* \
    && mkdir -p /data/databases/graph.db/

ADD ./neo4j_database/graph.db /data/databases/graph.db/