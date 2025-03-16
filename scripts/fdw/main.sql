CREATE EXTENSION postgres_fdw;

CREATE SERVER books_1_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'postgresql-b1', port '5432', dbname 'books_db');

CREATE SERVER books_2_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'postgresql-b2', port '5432', dbname 'books_db');

CREATE USER MAPPING FOR postgres
SERVER books_1_server
OPTIONS (user 'postgres', password 'postgres');

CREATE USER MAPPING FOR postgres
SERVER books_2_server
OPTIONS (user 'postgres', password 'postgres');

CREATE FOREIGN TABLE books_1 (
    category_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    year INTEGER CHECK (year > 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
) SERVER books_1_server
OPTIONS (schema_name 'public', table_name 'books');

CREATE FOREIGN TABLE books_2 (
    category_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    year INTEGER CHECK (year > 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
) SERVER books_2_server
OPTIONS (schema_name 'public', table_name 'books');

CREATE VIEW books AS
    SELECT * FROM books_1
    UNION ALL
    SELECT * FROM books_2;

CREATE RULE books_insert_to_1 AS ON INSERT TO books
WHERE (category_id <= 50)
DO INSTEAD INSERT INTO books_1 VALUES (NEW.*);

CREATE RULE books_insert_to_2 AS ON INSERT TO books
WHERE (category_id  > 50)
DO INSTEAD INSERT INTO books_2 VALUES (NEW.*);

CREATE RULE books_insert AS ON INSERT TO books DO INSTEAD NOTHING;
CREATE RULE books_update AS ON UPDATE TO books DO INSTEAD NOTHING;
CREATE RULE books_delete AS ON DELETE TO books DO INSTEAD NOTHING;