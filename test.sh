#!/bin/sh

ANT_PATH=/Users/jmgerona/Documents/apache-ant-1.9.6/bin
TOOL_PATH=/Users/jmgerona/Library/Android/sdk/tools
PTOOL_PATH=/Users/jmgerona/Library/Android/sdk/platform-tools

JAVA_FILE=$1
APPS=$2
NAME=`echo $1 | cut -d '.' -f 1`
EXT=`echo $1 | cut -d '.' -f 2`
DATE=`date +%Y%m%d_%H%M%S`
TEMP=t.temp
REPORT="testing_"$NAME"_$DATE.html"

function printUsage {
	echo 
	echo This script automates the building of test projects
	echo Correct usage is:
	echo './test.sh <Java File> "<App1> <App2> <App3>..."'
	echo Sample:
	echo '[1] ./test.sh MyTestCase.java Contacts,Music,Camera'
	echo '[2] ./test.sh MyTestCase.java Facebook'
	echo 
}

function buildAndExecuteTest {
	echo Making directory...
	mkdir $NAME;
	echo Creating project...
	$TOOL_PATH/android create uitest-project -t android-22 -p $NAME
	echo Copying java file...
	cp $JAVA_FILE $NAME/src
	echo Building project...
	$ANT_PATH/ant build -f $NAME/build.xml
	echo Deploying project to device...
	$PTOOL_PATH/adb push $NAME/bin/$NAME.jar /data/local/tmp
	echo Running test...
	$PTOOL_PATH/adb shell uiautomator runtest $NAME.jar -c $NAME | grep FOUND >> $TEMP

	echo Deleting test directory...
	rm -rf $NAME

	echo Deleting test JAR file and resources...
	$PTOOL_PATH/adb shell rm -f /data/local/tmp/$NAME.jar
	$PTOOL_PATH/adb shell rm -f /data/local/tmp/$NAME.txt
	rm -f $NAME.txt
}

function buildHTML {
	echo "<html><head><title>Testing report for " $NAME "</title><body><h2 style='align:center'>Testing report for " $NAME >> $REPORT 
	echo "<h4>As of " $DATE "</h4><hr/>" >> $REPORT

	cat $TEMP | while read line; do
		id=`echo $line | cut -d ':' -f 1`
		result=`echo $line | cut -d ':' -f 2`
		if [ "$id" = "FOUND" ]; then
			echo "<span style='color:green'>"$result" found!</span><br/>" >> $REPORT
		elif [ "$id" = "NOT_FOUND" ]; then
			echo "<span style='color:red'>"$result " not found!</span><br/>" >> $REPORT
		fi
	done
	echo "</body></html>" >> $REPORT
	rm -f $TEMP
}

function makeFileResource {
	AP=($APPS)
	for a in ${AP[@]}; do
		printf $a'\n' >> $NAME.txt
	done
	$PTOOL_PATH/adb push $NAME.txt /data/local/tmp
}

if [ $# -lt 2  ]; then printUsage; exit 0; fi
if [ ! -f $1 ]; then printUsage; exit 0; fi
if [ $EXT != "java" ]; then printUsage; exit 0; fi

makeFileResource
buildAndExecuteTest
buildHTML
echo Done!

