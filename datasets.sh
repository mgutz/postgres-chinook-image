#!/usr/bin/env bash

# Data Sources.
# PG Foundry: http://pgfoundry.org/frs/?group_id=1000150
# SportsDB:   http://www.sportsdb.org/sd/samples

declare -A SQL=(
	[chinook]="(chinook.sql)"
	#[dellstore]="(dellstore2-normal-1.0/dellstore2-normal-1.0.sql)"
	#[iso3166]="(iso-3166/iso-3166.sql)"
	#[sportsdb]="(sportsdb_sample_postgresql_20080304.sql)"
	#[usda]="(usda-r18-1.0/usda.sql)"
	#[world]="(dbsamples-0.1/world/world.sql)"
)

declare -A URL=(
	[chinook]=https://github.com/kohanyirobert/chinook-database/raw/master/ChinookDatabase/DataSources/Chinook_PostgreSql_SerialPKs_CaseInsensitive.sql
	#[dellstore]=https://ftp.postgresql.org/pub/projects/pgFoundry/dbsamples/dellstore2/dellstore2-normal-1.0/dellstore2-normal-1.0.tar.gz
	#[iso3166]=https://ftp.postgresql.org/pub/projects/pgFoundry/dbsamples/iso-3166/iso-3166-1.0/iso-3166-1.0.tar.gz
	#[sportsdb]=http://www.sportsdb.org/modules/sd/assets/downloads/sportsdb_sample_postgresql.zip
	#[usda]=https://ftp.postgresql.org/pub/projects/pgFoundry/dbsamples/usda/usda-r18-1.0/usda-r18-1.0.tar.gz
	#[world]=https://ftp.postgresql.org/pub/projects/pgFoundry/dbsamples/world/world-1.0/world-1.0.tar.gz
)

for DATASET in "${!SQL[@]}"; do
	export DATASET_URL="${URL[$DATASET]}"
	declare -a DATASET_SQL="${SQL[$DATASET]}"
	if [[ $DATASETS == *"$DATASET"* ]]; then
		echo "Populating dataset: ${DATASET}"
		if [[ $DATASET_URL == *.tar.gz ]]; then
			wget -qO- $DATASET_URL | tar -C . -xzf -
		elif [[ $DATASET_URL == *.sql ]]; then
			wget -qO ${DATASET}.sql $DATASET_URL
		elif [[ $DATASET_URL == *.zip ]]; then
			wget $DATASET_URL -O tmp.zip &&
				unzip -d . tmp.zip
			rm tmp.zip
		elif [[ $DATASET_URL == *.git ]]; then
			git clone $DATASET_URL
		fi
		echo "CREATE DATABASE $DATASET;" >>"/docker-entrypoint-initdb.d/${DATASET}.sql"
		echo "\c $DATASET;" >>"/docker-entrypoint-initdb.d/${DATASET}.sql"
		for i in "${!DATASET_SQL[@]}"; do
			cat "${DATASET_SQL[i]}" >>"/docker-entrypoint-initdb.d/${DATASET}.sql"
		done

        # backup_script="/docker-entrypoint-initdb.d/ZZ-${DATASET}.sh"
        # echo "#!/bin/sh" > "$backup_script"
        # echo "mkdir -p /backups" >> "$backup_script"
        # echo "pg_dump -U postgres --format custom '$DATASET' > '/backups/$DATASET.pgdata'" >> "$backup_script"
        # chmod a+x "$backup_script"

		#rm -rf *
	fi
done
