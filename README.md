# Postgres Chinook Sample Image

PostgreSQL docker image that seeds with chinook sample data on first run.
The image is useful for learning Postgres queries and/or unit testing
a Postgres library with known relational data.

## Usage

Run the image like the oficial PostgreSQL image

```sh
docker run --rm -e 'POSTGRES_PASSWORD=password' --name chinook-sample ghcr.io/mgutz/chinook:postgres-12
```

Perform a query

```
docker exec chinook-sample psql -U postgres -d chinook -c 'select * from album limit 10'
```

NOTE: The name of the database is "chinook" NOT the value of $POSTGRES_DB.

## Instructions to Regenerate Backup

The file `chinook.pgdata` is a backup of a preseeded chinook database.
Seeding chinook data is time consuming. The backup is made by running a seed
image and requires manual steps:

1. Build a seed image that downloads chinook SQL script and adds it
   to the init directory to be run when image is run.
2. Run the seed image to seed the chinook databae.
3. Make a backup of the running seeded chinook databaes using `pg_dump`
4. Build final image.

Each step corresponds to a `bake` task, namely: `build-seed`, `run-seed`,
`backup-seed` and 'build-final'

Restoring the backup is MUCH faster than running the chinook SQL scripts.
