# Postgres Chinook Sample Image

PostgreSQL docker image that seeds with chinook sample data on first run.
The image is useful for learning Postgres queries and/or unit testing
a Postgres library with known relational data.

The sample databases from ftp.postgresql.org have minimal schemas. Chinook is
more representative of a small e-commerce site.

## Usage

Run the image like the oficial PostgreSQL image

```sh
docker run --rm -e 'POSTGRES_PASSWORD=password' --name chinook-sample ghcr.io/mgutz/chinook:postgres-12
```

Perform a query

```sh
docker exec chinook-sample psql -U postgres -d chinook -c 'select * from album limit 10'
```

Run psql from container

```sh
docker exec -it chinook-sample psql -U postgres -d chinook
```

NOTE: The name of the database is "chinook" NOT the value of $POSTGRES_DB.

## Instructions to Build Image

Seeding chinook data is time consuming. The backup is made by running a seed
image with a persistent moun, then copying the persistent directory
to a final image.

1. Build a seed image that downloads chinook SQL script and adds it
   to the init directory to be run when image is run.
2. Run the seed image to seed the chinook database. The mount dir is `./mntdata`
3. Build final image by copying `./mntdata` to postgres data dir.

Each step corresponds to a `bake` task, namely: `build-seed`, `run-seed`,
and 'build-final'
