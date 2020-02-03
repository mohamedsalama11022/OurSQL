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
					if test -z "$rowVal"
						then
							echo "there is no matching record"
						else
							colNames=`awk -F: '{print $1}' ~/oursql/$operation/$tbName.meta`
							echo "$rowVal"
							echo $colNames$'\n\n'$rowVal | column -t -s " :" 
					fi
				else
					echo "Invalid selection"
			fi
			dbOperations
		done
}
function deleteByPK {
	echo "enter the table name to delete from"
	select tbName in ".." `ls ~/oursql/$operation | grep -v ".meta$"`
		do
			if test ! -z $tbName && [ $tbName = ".." ]
				then
					dbOperations
			fi
			colName=`awk -F: '{if(NR==1){print $1}}' ~/oursql/$operation/$tbName.meta 2> /dev/null`
			if test ! -z $colName
				then
					tableData
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
					echo "Invalid selection"
			fi
			dbOperations
		done
}

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

function  tableData {
	colNames=`awk -F: 'BEGIN{ORS=""}{if(NR>1){print ":|:"$1}else{print "|:"$1}}END{print ":|"}' ~/oursql/$operation/$tbName.meta`
	rows=`awk -F: 'BEGIN{ORS=""}{for(i = 1; i <= NF; i++){if(i==NF){print "|:"$i":|\n"}else{print "|:"$i":" }}}' ~/oursql/$operation/$tbName`
	echo $colNames$'\n\n'"$rows" | column -t -s ":" 
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
	while  true ; do
		read tbName
			if test -z "$tbName"
			then
				echo "Table name can not be empty"
				continue
		fi
		if [[ ! $tbName  =~ ^[a-zA-Z_]+[a-zA-Z]+[0-9a-zA-Z_]*$ ]]; then
				echo "Sorry, Invalid Format"
				continue
		fi

		validateTableExist  ~/oursql/$operation/$tbName
		if [[  $? -eq 1  ]]; then
				echo "Sorry, The Table Is Exists"
				continue
		fi
	
		break
	done
		
		rm ~/oursql/$operation/.temp
		touch ~/oursql/$operation/.temp
		insertTableMeta	
}
function validateTableExist {
	if  test -f $1 ; then
		return 1 #exists
	else 
	return 0 #not
	fi
}

function insertTableMeta {
	echo "Enter PK column"
	insertNewColumn	
}

function insertNewColumn {
	echo "Enter the column name:"
	validateColName $colName
		while  true ; do
		read colName
		echo $colName
			if test -z "$colName"
			then
				echo "Column name can not be empty"
				continue
		fi
		if [[ ! $colName  =~ ^[a-zA-Z_]+[a-zA-Z]+[0-9a-zA-Z_]*$ ]]; then
				echo "Sorry, INvalid Format"
				continue
		fi

		validateColName $colName
		if [[  $? -eq 1  ]]; then
				echo "Sorry, Column Name Can't Be Duplicayed"
				continue
		fi
	
		break
	done
	echo "Enter The Column Data Type:"
	colDataType

}
function colDataType {
	select datatType in "string" "integer" "float"
	do
		if test -z $datatType
			then
				echo "Wrong data type"
				colDataType
			else
				echo "${colName}:${datatType}" >> ~/oursql/$operation/.temp
				select op in ".." "Insert new Column" "Save"
				do
					case $op in
						"..")
							dbOperations
							;;
						"Insert new Column")
							insertNewColumn
							;;
						"Save")
							touch ~/oursql/$operation/$tbName
							mv ~/oursql/$operation/.temp ~/oursql/$operation/$tbName.meta
							echo "Table was created successfuly"
							dbOperations
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
	echo "Enter the table name"
	select tableName in ".." `ls ~/oursql/$operation | grep -v ".meta$"`
		do
			if test ! -z $tableName && [ $tableName = ".." ]
				then
					dbOperations
			fi
			if test ! -f ~/oursql/$operation/$tableName
			then
				echo "Invalid selection"
				dbOperations
			fi
 		    rm ~/oursql/$operation/$tableName.*
			rm ~/oursql/$operation/$tableName
			echo "Table has been deleted successfuly"
			dbOperations
		done
}

function validateDBdirectory {
	#if [  "$(ls -A ~/oursql/$operation)" ]; then

	#ls ~/oursql/$operation  | grep "$tableName" | grep -v ".meta$"
	echo "Enter the table name"

		select tblToInsert in ".." `ls ~/oursql/$operation | grep -v ".meta$"`
		do
			if test ! -z $tblToInsert && [ $tblToInsert = ".." ]
				then
					dbOperations
			fi
			if test ! -f ~/oursql/$operation/$tblToInsert
			then
				echo "Invalid selection"
				dbOperations
			fi
			echo "The table you select is ${tblToInsert}"
			if [[ $tblOperation == "insert into table" ]]; then
				insertTableData
			else
				updateRecored
			fi
		done

	# select tblToInsert in `ls ~/oursql/$operation  | grep "$tableName" | grep -v ".meta$"` 
	# 	do
	# 		echo "The table you select is ${tblToInsert}"
	# 		if [[ $tblOperation == "insert into table" ]]; then
	# 			insertTableData
	# 		else
	# 			updateRecored
	# 		fi
	# 	done

	# else
	# 	echo "Sorry, $operation is Empty"
	# 	dbOperations
	# fi
}

function insertTableData {
	count=$(wc -l < ~/oursql/$operation/$tblToInsert.meta)
	row=""
	for ((j=1;j<=$count;j++)){
		echo "Enter $(awk "NR == $j" ~/oursql/$operation/$tblToInsert.meta) Value"	
		dataType=$(awk -v x="$j" -F: 'BEGIN{}{if(NR == x){print $2}} END{}' ~/oursql/$operation/$tblToInsert.meta)
		while true
			do
				read tblData
				if [[ $j -eq 1 ]]; then
					if test -z $tblData
					then
						echo "PK can not be empty"
						continue		
					fi
					validatePriKey $tblData
					if [[ $? -eq 1 ]]; then
							echo "PK is duplicated"
							continue
					fi
				fi
			
				if [[ $dataType == "integer" ]]; then
					validataInteger $tblData
					if [[ $? -eq 0 ]]; then
						echo "the value is not integer"
						continue
					fi
				elif [[ $dataType == "float" ]]; then
						validateFloat $tblData	
						if [[ $? -eq 0 ]]; then
						echo "the value is not float"
						continue
						fi
				elif [[ $dataType == "string" ]]; then
					if [[ ! $tblData  =~ ^[a-zA-Z_]+[[:space:]0-9a-zA-Z_]*$ ]]; then
						echo "Sorry, INvalid Format"
						continue
					fi
				fi
				break
			done
			if [[ $j == $count ]]; then
					row+="${tblData}"
				else
					row+="${tblData}:"
			fi		
		}

		echo  $row$'\r' >> ~/oursql/$operation/$tblToInsert	
		echo -e "Data Inserted Successfuly"
		dbOperations
}
function updateRecored {
	metaRows=$(awk '{print}' ~/oursql/$operation/$tblToInsert.meta)
	echo "Enter The Primary Key of The Row"
	read updatePriKey
	validatePriKey $updatePriKey
	while [[ $? -eq 0 ]]; do
			echo "Sorry, THe Primary Key Does Not Exist"
			read updatePriKey
			validatePriKey $updatePriKey
		done	
	 PS1="Enter The Field You Want To Update It's Value: "
	select metaValues in $metaRows
	do
		updateDataType=$(awk -v x="$REPLY" -F: 'BEGIN{}{if(NR == x){print $2}} END{}' ~/oursql/$operation/$tblToInsert.meta)
		echo "Enter The Value You Want To Update: "
		
		while true
		do
			read valToUpdate
			if [[ $REPLY -eq 1 ]]; then
				if test -z $valToUpdate
				then
					echo "PK can not be empty"
					continue		
				fi
				validatePriKey $valToUpdate
				if [[ $? -eq 1 ]]; then
						echo "PK is duplicated"
						continue
				fi
			fi
		
			if [[ $updateDataType == "integer" ]]; then
				validataInteger $valToUpdate
				if [[ $? -eq 0 ]]; then
					echo "the value is not integer"
					continue
				fi
			elif [[ $updateDataType == "float"  ]]; then
					validateFloat $valToUpdate	
					if [[ $? -eq 0 ]]; then
					continue
					echo "the value is not float"
					fi
			elif [[ $updateDataType == "string" ]]; then
					if [[ ! $valToUpdate  =~ ^[a-zA-Z_]+[[:space:]0-9a-zA-Z_]*$ ]]; then
						echo "Sorry, INvalid Format"
						continue
					fi
				
			fi
			break
		done
		 theOldValue=$(awk -F: -v x=$REPLY 'BEGIN{}{if(NR == x){print $2}} END{}' ~/oursql/$operation/$tblToInsert)
		# echo $REPLY
		id="$updatePriKey"
		 theField="$REPLY"
		 content=$(awk -F: -v x="$id" -v y="$theField" -v val="$valToUpdate" 'BEGIN{OFS=":";ORS=""} {if($1==x){for(i=1;i<=NF;i++){if(i==y){print val}else{print $i};if(NF!=i){print ":"}};print "\n"}else{print $0"\n"}}' ~/oursql/$operation/$tblToInsert)
		 url=~/oursql/$operation/$tblToInsert
		 echo "$content" > "$url"
		 echo "Data Updated Successfuly!"
		 dbOperations
	done
	
}
function validatePriKey {
	priKeyValue=$(awk -v y="$1" -F: 'BEGIN{}{if($1 == y){print $1}} END{}' ~/oursql/$operation/$tblToInsert)
	if  [[ $priKeyValue == $1 ]]; then
	 	
		return 1; #exists
	else
	
		return 0; #notExists
	fi
}
function validateColName {
    validation=$(awk -v y="$1" -F: 'BEGIN{}{if($1 == y){print $1}} END{}' ~/oursql/$operation/.temp)
    	if  [[ $validation == $1 ]]; then
			return 1; #exists
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