DROP TABLE IF EXISTS books;

SELECT citus_remove_node('postgresql-b3', 5432);
SELECT citus_remove_node('postgresql-b2', 5432);

SELECT citus_set_coordinator_host('postgresql-b', 5432);
SELECT citus_add_node('postgresql-b2', 5432);
SELECT citus_add_node('postgresql-b3', 5432);

SELECT * FROM citus_check_cluster_node_health();
SELECT * FROM citus_get_active_worker_nodes();

CREATE TABLE books (
    id SERIAL,
    category_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    year INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (category_id, id)
);

CREATE INDEX idx_books_category_id ON books(category_id);

SELECT create_distributed_table('books', 'category_id', shard_count => 2);

SELECT rebalance_table_shards();

SELECT shardid, nodename, nodeport
FROM pg_dist_shard
JOIN pg_dist_placement USING (shardid)
JOIN pg_dist_node ON (pg_dist_node.nodeid = pg_dist_placement.groupid)
WHERE logicalrelid = 'books'::regclass;

EXPLAIN ANALYZE SELECT * FROM books;