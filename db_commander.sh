#!/bin/sh

PG_USER="postgres"
DB_NAME="zetteldatabase"

STATEMENTS="psql connectionstring: "

generate_sql() {
	read -p "Script Name: " f_name
	echo "generating sql script..."

	IFS='|'
	for line in $STATEMENTS; do
		echo $line
	done >> "$f_name.sql"
}

create_table() {
	echo "Create table $2 in $1"
	read -p "Fields(seperate by comma): " fields 

	STATEMENTS="$STATEMENTS|CREATE TABLE $2 ($fields);"
}

create_db() {
	read -p "New database name: " name
	read -p "Tables(seperate by space): " tables

	STATEMENTS="$STATEMENTS|CREATE DATABASE $name;"
	STATEMENTS="$STATEMENTS|\\c $name"

	IFS=' '
	for table in $tables; do create_table $name $table; done

	generate_sql	
}

select() {
	echo 'select'
	case $# in
		1) echo "1, $1";;
		2)
			echo "[ psql -U $PG_USER -d $DB_NAME -c 'SELECT $1 FROM $2';; ]"
			read -p "execute command?" answer
			if [ $answer = "yes" ]; then
				psql -U $PG_USER -d $DB_NAME -c "SELECT $1 FROM $2"
			fi
			;;
		*) echo "else";;
	esac

	echo $1 $2
}

commander() {
	case $# in
		0) printf "init\ncreate\ntest\nschema\ndd\tdelete data\nddb\tdelete database\n\nselect TABLE/COLUMN\n";;
		1 | 2 | 3) case $1 in
							'init') psql -U $PG_USER -f sql_scripts/init_db.sql;;
							'create') create_db;; 
							'test') psql -U $PG_USER -d $DB_NAME -f sql_scripts/test_db.sql;;
							'schema') psql -U $PG_USER -c "\dn";;

							'select'*) select $2 $3;;

							'dd') psql -U $PG_USER -d $DB_NAME -f sql_scripts/delete_data.sql;;
							'ddb') psql -U $PG_USER -f sql_scripts/delete_db.sql;;
							*) echo "1|2 else";;
						esac
						;;
		*) echo "4 or more args";;
	esac
}

commander $*
