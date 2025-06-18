# Neo4j 

Graph Databae 

```bash

  docker run -d \
  --name neo4j \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/password \
  neo4j:latest
```

**Connect Url** bolt://localhost:7687
**Web UI** http://localhost:7474



```
    CREATE (p:PERSON {name: "Alice", age: 1});
CREATE (p:PERSON {name: "SWAN", age: 22}),
       (p:PERSON {name: "HTET", age: 22}),
       (c:Company {name: 'TechCrop'});
MATCH (a:PERSON {name: 'SWAN'}), (c:Company {name: 'TechCrop'})
CREATE (a)-[:WORK_FOR {since: 2025}]->(c);
```