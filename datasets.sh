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

seed_file_sh="/docker-entrypoint-initdb.d/seed.sh"
cat <<EOF >"$seed_file_sh"
#!/bin/bash
EOF
chmod a+x "$seed_file_sh"

mkdir /etc/seed.d
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

        seed_file_sql="/etc/seed.d/${DATASET}"
        cat <<EOF >"$seed_file_sql"
CREATE DATABASE $DATASET;
\\c $DATASET;
EOF
		for i in "${!DATASET_SQL[@]}"; do
			cat "${DATASET_SQL[i]}" >>"$seed_file_sql"
		done

        cat <<EOF >>"$seed_file_sh"
echo -n Seeding $DATASET \(be patient\)...
psql --echo-errors --quiet -f "$seed_file_sql"
echo OK
EOF
		#rm -rf *
	fi
done

cat <<EOF >>"$seed_file_sh"
    echo "Stopping postgres ..."
    pg_ctl -m smart stop
    echo OK
    exit
EOF

