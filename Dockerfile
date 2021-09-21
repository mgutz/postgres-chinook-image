FROM postgres:12-alpine

# Don't override this value. Do not use this value for `POSTGRES_USER`. We're making this change to
# to make sure the default database created by the `postgres` base image does not interfere with
# our database creation while populating data.
ENV POSTGRES_DB donotuse
COPY ./mntdata /var/lib/postgresql/data

