CREATE (p:PERSON {name: "Alice", age: 1});
CREATE (p:PERSON {name: "SWAN", age: 22}),
       (p:PERSON {name: "HTET", age: 22}),
       (c:Company {name: 'TechCrop'});

MATCH (a:PERSON {name: 'SWAN'}), (c:Company {name: 'TechCrop'})
CREATE (a)-[:WORK_FOR {since: 2025}]->(c);