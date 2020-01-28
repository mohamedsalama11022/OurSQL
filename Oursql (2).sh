#!/bin/bash
select choice in createDB showDataBases
	do
		case $choice in
			createDB) echo Enter The DataBase Name:
	read dbName
	echo "the dbName is $dbName"
	break
	;;
			showDataBases) select operation in useDataBase
			do
				case $operation in
					useDataBase) echo Enter The DataBase name you want to use
	select tblOperation in createTable DeleteTable InsertIntoTable
					do
						case $tblOperation in 
						createTable) echo "test creating the table"
						;;
						DeleteTable) echo "test Deleting the table"
						;;
						InsertIntoTable) echo "test insering into the table"
						;;
						esac
					done
				esac
			done
		esac
	done