#!/bin/bash

function createDB {
	echo Enter The DataBase Name:
	read dbName
	if test -d ~/oursql/${dbName}
		then
			echo "$dbName already exists"
			createDB
		else
			mkdir -p ~/oursql/${dbName}
			echo "$dbName was created successfuly"			
	fi
}

function dbOperations {
	select tblOperation in "create table" "delete table" "insert into table" "back"
		do
			case $tblOperation in 
				"create table") echo "test creating the table"
				;;
				"delete table") echo "test Deleting the table"
				;;
				"insert tnto table") echo "test insering into the table"
				;;
				"back") showDatabases
				;;
			esac
		done
}
function showDatabases {
	select operation in `ls ~/oursql`
		do
			echo "The database you select is ${operation}"
			dbOperations
		done
}


select choice in "create database" "show dataBases"
do
	case $choice in
		"create database")
			createDB
			;;
		"show dataBases")
			showDatabases
		;;
	esac
done
