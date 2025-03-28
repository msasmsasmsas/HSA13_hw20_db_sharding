
docker network prune -f
docker compose down
docker-compose up -d


git clone -b main https://github.com/msasmsasmsas/HSA13_hw20_db_sharding .


git init
git remote add origin https://github.com/msasmsasmsas/HSA13_hw20_db_sharding
git config --global --add safe.directory E:/HSA13/HSA13_hw20_db_sharding
git remote add origin https://github.com/msasmsasmsas/HSA13_hw20_db_sharding

git fetch origin
git checkout main
git merge origin/main



docker compose -f docker-compose.noshards.yml up -d
#win
Get-Content scripts/noshards/init.sql | docker exec -i  postgresql-b psql -U postgres -d books_db
#nix
PGPASSWORD=postgres docker exec -i postgresql-b psql -U postgres -d books_db < scripts/noshards/init.sql
docker exec -it app python insert_db.py 100000 --batch-size 10000

docker compose -f docker-compose.noshards.yml down


docker compose -f docker-compose.fdw.yml up -d
#win
Get-Content scripts/fdw/shard-1.sql | docker exec -i  postgresql-b1 psql -U postgres -d books_db
Get-Content scripts/fdw/shard-1.sql | docker exec -i  postgresql-b2 psql -U postgres -d books_db
Get-Content scripts/fdw/main.sql | docker exec -i  postgresql-b psql -U postgres -d books_db
#nix
PGPASSWORD=postgres docker exec -i postgresql-b1 psql -U postgres -d books_db < scripts/fdw/shard-1.sql
PGPASSWORD=postgres docker exec -i postgresql-b2 psql -U postgres -d books_db < scripts/fdw/shard-2.sql
PGPASSWORD=postgres docker exec -i postgresql-b psql -U postgres -d books_db < scripts/fdw/main.sql
docker exec -it app python insert_db.py 100000 --batch-size 10000

docker compose -f docker-compose.fdw.yml down


docker compose -f docker-compose.citus.yml up -d
#win
Get-Content scripts/citus/main.sql| docker exec -i  postgresql-b psql -U postgres -d books_db
#nix
PGPASSWORD=postgres docker exec -i postgresql-b psql -U postgres -d books_db < scripts/citus/main.sql
docker exec -it app python insert_db.py 100000 --batch-size 10000

docker compose -f docker-compose.citus.yml down