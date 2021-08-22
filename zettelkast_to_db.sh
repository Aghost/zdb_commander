#!/bin/sh

Z_DIR="0_ZETTELKAST/"
PG_USER='postgres'
DB_NAME='zetteldatabase'
TABLE='zettels(fullpath, data)'

LOGGER="$DB_NAME Migration `date`\n"

add_data_query() {
	psql -U $PG_USER -d $DB_NAME -c "INSERT INTO $TABLE VALUES ('$1', '$2')"
}

for filename in `find $Z_DIR -type f`; do
	if [[ ${filename##*.} == "md" ]]; then
		LOGGER="$LOGGER-Adding $filename\n"
		add_data_query $filename "`cat $filename`"
	fi
done 

echo "$LOGGER" #> todb_logfile
