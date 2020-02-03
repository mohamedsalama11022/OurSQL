#!/bin/bash

function createDB {
	echo Enter The DataBase Name:
	while  true ; do
		read dbName
		echo $dbName
			if test -z "$dbName"
			then
				echo "Database name can not be empty"
				continue
		fi
		if [[ ! $dbName  =~ ^[a-zA-Z_]+[a-zA-Z]+[0-9a-zA-Z_]*$ ]]; then
				echo "Sorry, INvalid Format"
				continue
		fi

		validateDBExist  ~/oursql/$dbName
		if [[  $? -eq 1  ]]; then
				echo "Sorry, The Database Exists"
				continue
		fi
	
		break
	done
	mkdir -p ~/oursql/${dbName}
	echo "$dbName was created successfuly"
	main
}
function validateDBExist {
	echo $1
	if  test -d $1 ; then
		return 1 #exists
	else 
	return 0 #not
	fi
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

function dbOperations {

	select tblOperation in ".." "create table" "show tables" "delete table" "insert into table" "select by PK" "select All" "delete by PK" "update record"
		do
			case $tblOperation in 
				"create table") createTable
				;;
				"show tables") showTables
				;;
				"delete table") removeTable
				;;
				"insert into table") validateDBdirectory

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
				"update record") validateDBdirectory
				;;
			esac
		done
}
