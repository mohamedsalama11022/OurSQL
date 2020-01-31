#!/bin/bash

function createDB {
	echo Enter The DataBase Name:
	read dbName
	if test -z $dbName
		then
			echo "Database name can not be empty"
			createDB
		else
			if test -d ~/oursql/${dbName}
				then
					echo "$dbName already exists"
					createDB
				else
					mkdir -p ~/oursql/${dbName}
					echo "$dbName was created successfuly"
					main
			fi
	fi
}

function dbOperations {

	select tblOperation in ".." "create table" "show tables" "delete table" "insert into table"
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
				"..") showDatabases
				;;
			esac
		done
}

function showDatabases {
	select operation in  ".." `ls ~/oursql`
 		do
		 	if test -z $operation
				then
				echo "Unkonwn database"
				else

					if [ $operation = ".." ]
						then
							main
						else
							echo "The database you select is ${operation}"
							dbOperations
					fi
			fi
		done
}

function createTable {
	echo "Enter The Table Name:"
	read tbName
	if test -z $tbName
		then
			echo "Table name can not be empty"
			createTable
		else
			touch ~/oursql/$operation/$tbName
			touch ~/oursql/$operation/$tbName.meta
			insertTableMeta
	fi
}
function insertTableMeta {
	echo "Select PK column"
	insertNewColumn
}
function insertNewColumn {
	echo "Enter the column name:"
	read colName
	echo $colName
	if test -z $colName
		then
			echo "Column name can not be empty"
			insertNewColumn
		else 
			echo "Enter The Column Data Type:"
			colDataType
	fi
}
function colDataType {
	
	select datatType in "string" "integer" "float"
	do
		if test -z $datatType
			then
				echo "Wrong data type"
				colDataType
			else
				echo "${colName}:${datatType}" >> ~/oursql/$operation/$tbName.meta
				select op in ".." "Insert new Column"
				do
					case $op in
						"..")
							dbOperations
							;;
						"Insert new Column")
							insertNewColumn
							;;
					esac
				done
		fi
	done
}


function showTables { 
	ls ~/oursql/$operation  | grep "$tableName" | grep -v ".meta$"
	dbOperations
}

function removeTable {
	ls ~/oursql/$operation  
	echo "Enter the table name"
	read tableName
	ls ~/oursql/$operation
    rm ~/oursql/$operation/$tableName.*
	rm ~/oursql/$operation/$tableName
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