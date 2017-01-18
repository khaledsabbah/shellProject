export LC_COLLATE=C

checkString(){

	if test -n $1 > 0
	then
		if [[ "$1" =~ ^[A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]+)*$  ]]
                then
                   	echo 'good name;';
			return 1;
		else
			echo "Note , the value shouldn not start with number";
			return 0;
            	fi
	else
		echo "Please Enter Value do not leave it empty"
		return 0;
	fi;

}

checkInt(){
	if test -n $1 >0
	then
		if ! [[ "$scale" =~ ^[0-9]+$ ]]
		then
			echo "Integers only allowed !!";
			return 0;
		else
			echo "right Number entered ";
			return 1;
		fi
	else
		echo "please Enter value do not leave it empty";
		return 0;
	fi;
}

 createPrimary() {
         # $1 -> DB name $2->table name
 
         if test -f ~/shell/$1/${2}.primary
         then    
                 echo "primary key already Existed";	
		return 0;
         else     
                  while true
                  do     
                         echo "Enter the column you want as Primary key";
                          read primary;
                          checkString $primary ;
                          if test $? -eq 0
                          then    
                                  echo wrong primary key name Entered ;
                                 continue;
                          else
                           
   				found=`awk -v pr=$primary -F: '{if(pr==$1) print pr}' ~/shell/$1/${2}.table`;
				echo $found;
				if [ !  $found == $primary ]
				then
					echo "primary key not existed";
					continue;
				else
                                  touch ~/shell/$1/${2}.primary ;
                                  echo $primary >> ~/shell/$1/${2}.primary ;
				  echo "Your primary key created successfully";
				  return 1;
                                  break;
                          fi;
			fi;
                  done;
         fi;
 
 }


changePrimary() {

	 # $1 -> DB name $2->table name $3 ->new primary name column
          if test -f ~/shell/$1/${2}.primary
          then   
                   while true
                   do   
                        echo "Enter the column you want as a new Primary key";
                        read primary;
                        checkString $primary ;
                        if test $? -eq 0
			then    
                                   echo wrong primary key name Entered ;
                                   continue;
                        else   
                                   echo $primary > ~/shell/$1/${2}.primary ;
                                   break;
				   return 1;
                        fi;
                   done;
 	else   
                   echo "SomeThing Goes wrong and the primary key file is not existed any more";
		   return 0;
          fi;

	

}

createDatabase(){
if  cd ~/shell
then
	if test -d  ~/shell/$1
	then
		echo 'Database already Exist , please Enter another name ';
		return 0;
	else
		mkdir $1;
		return 1;
	fi;
else
	echo 'folder found';
	mkdir ~/shell;
	mkdir $1;
	return 1;
fi;
}


selectDatabase(){
if test -d ~/shell/$1
then
	while true
	do
        	echo 'Do you want to add new tables or to select ?';
		echo "'y' for Yes and 'n' for No";
		read answer;
		if test $answer="y" 
		then
			echo 'Your Database has been selected';
			return 1;
			break;
		elif test $answer="n"
		then
			return 0;
			break ;
		else
			echo "please Enter right answer ";
		fi;
	done;
else

       echo 'Please Enter Right Database Name';	
	return 0;
fi;
}

createTable(){
echo 'Enter the table name';
read name;

if test -f ~/shell/$1/${name}.table
then
	echo 'Table already Existed !!';
	return 0;
else
	touch ~/shell/$1/${name}.table
	echo 'please Enter number of columns';
	read num;
	typeset -i  counter=0;
	
	while test $counter -lt $num
	do
	echo "please Enter the $counter column name:";
	read colname;
	checkString $colname;
	#echo $? ;
	if [ $? -eq 0 ]
	then
	#	echo 'equal to zoro'
		continue ;
	fi;
	select type in "int" "string"
	do
	case $REPLY in 
	1)
		echo "$colname : INT">> ~/shell/$1/${name}.table;
		counter=`expr $counter + 1` ;
		continue 2;
	;;
	2)
		echo "$colname : String">> ~/shell/$1/${name}.table;
		checkInt $colname;
		counter=`expr $counter + 1` ;
		continue 2;
	;;
	esac;
	done;
	done;
		createPrimary $1 $name ;	
		echo "Your Table has been Created Succesccfully";	
	return 1;
fi;

}

selectFromTable() {
	# $1-> DB name; $2->table name; 
select option in "do you want to choose specific col?" "Just select * the table"
do
	case $REPLY in 
	1) 
		echo "please enter your column name";
		read colName;
		checkString $colName;
		if test $? -eq 1 
		then
			awk -v name=$colName  -F: '{if (name==$1) print"res:1:NR" }' ~/shell/$1/${2}.table  > coltest.txt;
			awk -F: '{ if($2==1) print ${NR}   }' coltest.txt;
			return 1;
			continue 2;
		else
			continue 2;
		fi;
				
	;;	

	2)
		if test -f ~/shell/$1/${2}.data
		then
		awk '{print $0}' ~/shell/$1/${2}.data;
		echo '-------------------------------------------------------';
		return 1;
		else
			echo "Empty Table ";
			return 1;
		fi;
	;;
	esac;
done

}

	
insert() {
	# $1-> DB name; $2->table name; 
lin='';

if [ ! -f ~/shell/$1/${2}.data ]
then
	touch ~/shell/$1/${2}.data;
fi;
colNum=`awk 'END{ print NR;  } ' ~/shell/$1/${2}.table`;  #max fields number for this table
primary=`cat ~/shell/$1/${2}.primary`;			 # primary field name
primaryNR=`awk -v pr=$primary -F: '{if(pr==$1) print NR; print pr}' ~/shell/$1/${2}.table`   #primary field number
echo $primary;
echo "****** $primaryNR  *****";
counter=0;
flag=1;
echo "$colNum *****"
while test $counter -lt $colNum
do

	echo "please Enter the value of  ";
	awk -v i=$counter -F: '{ if(i==NR)  print $1,$2  }' ~/shell/$1/${2}.table;
	read data;
	var= ` awk -v i="$data" -F: '{ if(i==NR)  print $1 }' ~/shell/$1/${2}.data `;
	echo "$var IS the var";
	echo "$data is found";
	if test -n $var
	then
		echo "repeated Primary key";
		flag=0;
		return 0;
	fi
	lin=${line}:$data;
counter= `expr $counter+1`;
echo $counter;
done;
if test $flag -eq 1
then
	echo $lin >> ~/shell/$1/${2}.data;
fi;
}


delete(){

awk -v  '   '  ~/shell/$1/${2}.data;

}


desc_Table(){

while true
do
	select choice in "Select" "Update" "Insert" "Delete"
	do
		case $REPLY in 	
		1 ) 	
			echo "Select From Table";
			selectFromTable $1 $2;
			break;
		;;
		2 )
			echo "Update Table";
			update $1 $2 ;
			break;
		;;
		3 )
			echo "Insert Into Table";
			insert  $1 $2 ;
			break;
		;;
		* )
			echo "Delete From Table";
			delete $1 $2 ;
			break;
		;;
		esac;
	done


done

}



selectTable(){

	echo "Please Enter Table name : ";
	read name;
	if test -f ~/shell/$1/${name}.table
	then
		desc_Table $1 $name;
	fi 
}


checkDatabase (){

select option in "Create Table" "Select Table" "Back"
do
case $REPLY in

1)
	 createTable $1;
	if test $? -eq 1
	then	
		return 1;
	fi;
;;	

2)
	selectTable $1;
;;

3)
	return 1 ;
;;
esac;


done;


}



while true 
do

select option in "create New Database"  "Select Database" "Exit"
do
	case $REPLY  in
1 )
	echo "Please Enter Your Database Name and press Enter";
	read name;
	echo "------------------------------------------------";
	createDatabase $name;
	if test $? -eq 0
	then
		echo 'res equal 0';
		break 1; 
	else
		checkDatabase $name;		
	fi
	;;
2 )
	echo 'Please Enter Your database Name and press Enter : ';
	read name;
	selectDatabase $name;
	if test $? -eq 1
	then 
		checkDatabase $name;
	fi;
	
	
;;

3)
	break 3;
	esac;
done;

done;

echo "thank You for Using Our product !";
sleep 2;
exit;
