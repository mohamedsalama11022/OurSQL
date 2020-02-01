#!/bin/bash

function createDB {
	echo -e "Enter The DataBase Name:"
	read dbName
	mkdir -p ~/oursql/${dbName}
	echo -e "$dbName was created successfuly"
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
				"insert into table") validateDBdirectory
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
	ls ~/oursql/$operation  | grep "$tbName" | grep -v ".meta$"
	dbOperations
}

function removeTable {
	ls ~/oursql/$operation  
	echo "Enter the table name"
	read tableName
	if [ $tableName = "." ]
	then
	dbOperations
	else 
	ls ~/oursql/$operation
    rm ~/oursql/$operation/$tableName.meta
	rm ~/oursql/$operation/$tableName
	dbOperations
fi
	

	
}


test -z varName
function validateDBdirectory {
	if [  "$(ls -A ~/oursql/$operation)" ]; then

	ls ~/oursql/$operation  | grep "$tableName" | grep -v ".meta$"
	echo "Enter the table name"

	select tblToInsert in `ls ~/oursql/$operation  | grep "$tableName" | grep -v ".meta$"` 
		do
			echo "The table you select is ${tblToInsert}"
			insertTableData
		done

else
    echo "Sorry, $operation is Empty"
    dbOperations
fi


}

function insertTableData {

	count=$(wc -l < ~/oursql/$operation/$tblToInsert.meta)
	row=""
for ((j=1;j<=$count;j++)){
	echo "Enter $(awk "NR == $j" ~/oursql/$operation/$tblToInsert.meta) Value"	
	dataType=$(awk -v x="$j" -F: 'BEGIN{}{if(NR == x){print $2}} END{}' ~/oursql/$operation/$tblToInsert.meta)
	read tblData

if [[ j -eq 1 ]];
	 then
		validatePriKey $tblData
		while [[ $? -eq 1 ]]; do
			echo "The Value is Duplicated"
			read tblData
			validatePriKey $tblData
		done
	fi

	if [ $dataType == "integer" ] 
	then
	validataInteger $tblData
		while [[ $? -eq 0 ]]; do
			echo "The Value is not integer"
			read tblData
			validataInteger $tblData
		done
		if [[ $j == $count ]]; then
			# echo -n "${tblData}" >> ~/oursql/$operation/$tblToInsert	
			row+="${tblData}"
		else
			# echo -n "${tblData}:" >> ~/oursql/$operation/$tblToInsert	
			row+="${tblData}:"
		fi			
elif [[ $dataType == "Float" ]];
	then
	validateFloat $tblData
	while [[ $? -eq 0 ]]; do
			echo "The Value Is Not Float"
			read tblData
			validateFloat $tblData
		done
		 if [[ $j == $count ]]; then
			# echo -n "${tblData}" >> ~/oursql/$operation/$tblToInsert
			row+="${tblData}"
		else
			# echo -n "${tblData}:" >> ~/oursql/$operation/$tblToInsert
			row+="${tblData}:"
		fi	
else			
	 	if [[ $j == $count ]]; then
			# echo -n "${tblData}" >> ~/oursql/$operation/$tblToInsert
			row+="${tblData}"	
		else
			# echo -n "${tblData}:" >> ~/oursql/$operation/$tblToInsert	
			row+="${tblData}:"
		fi
fi

	}

	echo  $row$'\r' >> ~/oursql/$operation/$tblToInsert	
	echo -e "Data Inserted Successfuly"

}


function validatePriKey {
	priKeyValue=$(awk -v y="$1" -F: 'BEGIN{}{if($1 == y){print $1}} END{}' ~/oursql/$operation/$tblToInsert)


	if  [[ $priKeyValue == $1 ]]; then
	 	
		return 1;
	else
	
		return 0;
	fi
}
	function validataInteger {
		if [[ $1 =~ ^[+-]?[0-9]+$ ]]; 
		then
		return 1
	else
		return 0
		fi
	}
function validateFloat {
	if [[ $1 =~ ^[+-]?[0-9]+\.?[0-9]*$ ]];
	then
	return 1
else
	return 0
	fi
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


