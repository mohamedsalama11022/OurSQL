#!/bin/bash
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
