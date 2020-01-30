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

	select tblOperation in "create table" "show tables" "delete table" "insert into table" "back"
		do
			case $tblOperation in 
				"create table") createTable
				;;
				"show tables") showTables
				;;
				"delete table") removeTable
				;;
				"insert into table") echo "test insering into the table"

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




function createTable {
	echo "Enter The Table Name:"
	read tbName
	if [ $tbName = "." ]
	then 
  	dbOperations
	else
    touch ~/oursql/$operation/$tbName
	touch ~/oursql/$operation/$tbName.meta
	insertTableMeta
	fi
}
function insertTableMeta {
	echo "Enter the column name:"
	read colName
	if [ $colName = "." ]
	then
	dbOperations
	else 
	echo "Enter The Column Data Type:"
	colDataType
fi
}
function colDataType {
	
	select colDatatType in "string" "integer" "float"

	do
		case $colDatatType in 
		"string")
			echo "${colName}:${colDatatType}" >> ~/oursql/$operation/$tbName.meta
			insertTableMeta
		;;
		"integer")
			echo "${colName}:${colDatatType}" >> ~/oursql/$operation/$tbName.meta
			insertTableMeta
		;;
		"float")
			echo "${colName}:${colDatatType}" >> ~/oursql/$operation/$tbName.meta
			insertTableMeta
		
		;;
		esac
	done
}


function showTables { 
	ls ~/oursql/$operation  | grep "$tableName"
	dbOperations
}

function removeTable {
	ls ~/oursql/$operation  
	echo "Enter the table name"
	read tableName
	ls ~/oursql/$operation
    rm ~/oursql/$operation/$tableName.*
	rm ~/oursql/$operation/$tableName

	
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

