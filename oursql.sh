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

function selectByPK {
	select tbName in ".." `ls ~/oursql/$operation | grep -v ".meta$"`
		do
			if test ! -z $tbName && [ $tbName = ".." ]
				then
					echo back
					dbOperations
			fi
			colName=`awk -F: '{if(NR==1){print $1}}' ~/oursql/$operation/$tbName.meta 2> /dev/null`
			if test ! -z $colName
				then
					echo Enter $colName
					
					read val
					while test -z $val
						do
							echo "value can not be empty"
							echo Enter $colName again
							read val
					done
					rowVal=`awk -F: -v val="$val" '{if(val==$1){print $0}}' ~/oursql/$operation/$tbName`
					if test -z $rowVal
						then
							echo "there is no matching record"
						else
							colNames=`awk -F: '{print $1}' ~/oursql/$operation/$tbName.meta`
							echo $colNames$'\n\n'$rowVal | column -t -s " :" 
					fi
				else
					echo "Something went wrong"
			fi
			dbOperations
		done
}
function deleteByPK {
	select tbName in ".." `ls ~/oursql/$operation | grep -v ".meta$"`
		do
			if test ! -z $tbName && [ $tbName = ".." ]
				then
					echo back
					dbOperations
			fi
			colName=`awk -F: '{if(NR==1){print $1}}' ~/oursql/$operation/$tbName.meta 2> /dev/null`
			if test ! -z $colName
				then
					echo Enter $colName
					
					read val
					while test -z $val
						do
							echo "value can not be empty"
							echo Enter $colName again
							read val
					done
					typeset -i num=0;
					rowNum=`awk -F: -v val="$val" '{if(val==$1){print NR}}' ~/oursql/$operation/$tbName`
					if test ! -z $rowNum
						then
							`sed -i "$rowNum d" ~/oursql/$operation/$tbName`
							echo "Record with $colName = $val has been deleted"
						else
							echo "Nothing changed"
						fi
				else
					echo "Something went wrong"
			fi
			dbOperations
		done
}

function selectAll {
	select tbName in ".." `ls ~/oursql/$operation | grep -v ".meta$"`
		do
			if test ! -z $tbName && [ $tbName = ".." ]
				then
					echo back
					dbOperations
			fi
			colNames=`awk -F: '{print $1}' ~/oursql/$operation/$tbName.meta`
			rows=`cat ~/oursql/$operation/$tbName`
			echo $rows
			echo $colNames$'\n\n'"$rows" | column -t -s " :" 
			dbOperations
		done
}
function dbOperations {

	select tblOperation in ".." "create table" "show tables" "delete table" "insert into table" "select by PK" "select All" "delete by PK"
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
				"select by PK")
					selectByPK
				;;
				"select All")
					selectAll
				;;
				"delete by PK")
					deleteByPK
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