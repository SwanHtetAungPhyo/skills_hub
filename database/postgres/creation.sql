 --- SCHEMA CREATION
CREATE SCHEMA SchemaOne;

-- By Default, public schema is set to the default schema
-- To perform the required task on the destination schema
SET search_path to SchemaOne;


--- Table Creation
--- single table creation
CREATE table  Users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_name varchar(150) not null ,
    email varchar(150) not null unique ,
    password varchar(200) not null
);

-- Index creation
-- By Default, postgres use the B tree index
CREATE INDEX  email_index ON Users (email);

---Hash Index creation
--  Optimized for equality comparisons only
-- Cannot be used for range queries or sorting
CREATE  INDEX  user_name_index  ON Users USING HASH (user_name);

--- GIST INDEX creation
--  Supports geometric data types, full-text search
-- Used for complex data types and custom operators
CREATE  INDEX  gigs_index on Users USING GIS (column_name);

-- Composite Index
 CREATE INDEX idx_username_email_status ON Users (user_name, email);