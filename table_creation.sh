#!/bin/bash
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
				echo "Sorry, The Table Exists"
				continue
		fi
	
		break
	done
		
		rm ~/oursql/$operation/.temp 2> /dev/null
		touch ~/oursql/$operation/.temp
		insertTableMeta	
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
	select datatType in "string" "integer" "float" "date"
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
function validateColName {
    validation=$(awk -v y="$1" -F: 'BEGIN{}{if($1 == y){print $1}} END{}' ~/oursql/$operation/.temp)
    	if  [[ $validation == $1 ]]; then
			return 1; #exists
		else
			
			return 0;
		
	fi
}
function validateTableExist {
	if  test -f $1 ; then
		return 1 #exists
	else 
	return 0 #not
	fi
}