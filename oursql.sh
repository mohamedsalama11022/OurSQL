#!/bin/bash
source ./database_operations.sh
source ./table_creation.sh
source ./table_manipulations.sh

function selectAll {
	select tbName in ".." `ls ~/oursql/$operation | grep -v ".meta$"`
		do
			if test ! -z $tbName && [ $tbName = ".." ]
				then
					dbOperations
			fi

			tableData
			dbOperations
		done
}

function tableData {
	colNames=`awk -F: 'BEGIN{ORS=""}{if(NR>1){print ":|:"$1}else{print "|:"$1}}END{print ":|"}' ~/oursql/$operation/$tbName.meta`
	rows=`awk -F: 'BEGIN{ORS=""}{for(i = 1; i <= NF; i++){if(i==NF){print "|:"$i":|\n"}else{print "|:"$i":" }}}' ~/oursql/$operation/$tbName`
	echo $colNames$'\n\n'"$rows" | column -t -s ":" 
}

function showTables { 
	ls ~/oursql/$operation  | grep "$tableName" | grep -v ".meta$"
	dbOperations
}

function main {
	select choice in "create database" "show dataBases" "exit"
	do
		case $choice in
			"create database")
				createDB
				;;
			"show dataBases")
				showDatabases
			;;
			"exit")
				exit
			;;
		esac
	done
}

main