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
		counter=`expr $counter + 1` ;
		continue 2;
	;;
	esac;
	
	done;
	done;
	return 1;
fi;

}

insert() {
awk '{for(i=0;i<NR;i++) print "please Enter the data for $fi"
	read data; echo }'

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
		echo "Your Table has been Created Succesccfully";	
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
