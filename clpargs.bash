#clpargs - Command line arguments for bash scripts (without getopts)
#
#The MIT License (MIT)
#
#Copyright (c) 2015 Sami Salkosuo
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE. 
#
#
#To use in your scripts:
#
#Source this file to your own script.
#source clpargs.bash
#
#Optionally include description of your script.
#clpargs_program_description "My awesome script."
#
#Define one or more arguments
#There can be required argumens
#clpargs_define ARG1 "NAME1" "Description of required arg" true
#
#And arguments that are not required.
#clpargs_define ARG2 "NAME2" "Another desc" false
#
#Default value can be also defined. Typicall for non-required arguments.
#clpargs_define ARG3 "NAME3" "ARG3 is not mandatory and has default value" false "$ARG3_DEFAULT_VALUE" 
#
#Parse all command line arguments.
#clpargs_parse "$@"
#



#print error and exit
function clpargs_error {
        echo "[ERROR] CLPARGS: $1"
        exit 1
}

#program description is optional
function clpargs_program_description
{
	if [ $# -lt 1 ]; then
        clpargs_error "clpargs_program_description <PROGRAM DESCRIPTION>"
    fi

    CLPARGS_PROGRAM_DESCRIPTION=$1
}

#define arguments
function clpargs_define
{
	if [ $# -lt 4 ]; then
        clpargs_error "clpargs_define <NAME> <VALUE_NAME> <DESCRIPTION> <REQUIRED: true | false> [<DEFAULT_VALUE>]"
    fi

    export "CLPARGS_DEFINED_ARG_$1=$3"
    export "CLPARGS_DEFINED_ARG_$1_VALUE_NAME=$2"
    export "CLPARGS_DEFINED_ARG_$1_REQUIRED=$4"
    export "CLPARGS_DEFINED_ARG_$1_DEFAULT_VALUE=$5"
    #add all arg names 
    if [[ "$CLPARGS" == "" ]] ; then
		export CLPARGS=$1
	else
		export CLPARGS=$CLPARGS:$1
	fi		

	#if REQUIRED, add to array to be used when parsing
	if [[ "$4" == "true" ]] ; then
		if [[ "$CLPARGS_REQUIRED_ARGS" == "" ]] ; then
			export CLPARGS_REQUIRED_ARGS=$1
		else
			export CLPARGS_REQUIRED_ARGS=$CLPARGS_REQUIRED_ARGS:$1
		fi		
	fi

}

#retrieve definition (value nae, description, required, default value) for given argument 
function clpargs_arg_definition
{
	if [ $# -lt 2 ]; then
        clpargs_error "clpargs_arg_definition <NAME> <PARAMNAME one of: VALUE_NAME | DESC | REQUIRED | DEFAULT_VALUE>"
    fi

	tmpvar=CLPARGS_NOT_DEFINED_$1
	if [[ "$2" == "DESC" ]] ; then
		tmpvar=CLPARGS_DEFINED_ARG_$1
	fi

	if [[ "$2" == "VALUE_NAME" ]] ; then
		tmpvar=CLPARGS_DEFINED_ARG_$1_VALUE_NAME
	fi

	if [[ "$2" == "REQUIRED" ]] ; then
		tmpvar=CLPARGS_DEFINED_ARG_$1_REQUIRED

	fi

	if [[ "$2" == "DEFAULT_VALUE" ]] ; then
		tmpvar=CLPARGS_DEFINED_ARG_$1_DEFAULT_VALUE

	fi

	export RETURN_VALUE=${!tmpvar}


}

#prints usage
function clpargs_usage
{
	if [[ "$CLPARGS_PROGRAM_DESCRIPTION" != "" ]] ; then
		echo $CLPARGS_PROGRAM_DESCRIPTION
	fi
	local usageString="Usage: $0 "

	CLPARGS2=$CLPARGS_REQUIRED_ARGS
	while IFS=':' read -ra CLPARGS2; do
   		for arg in "${CLPARGS2[@]}"; do
        	var="CLPARGS_DEFINED_ARG_"$arg"_VALUE_NAME"
			usageString=$usageString" "$arg"="${!var}

       	done
 	done <<< "$CLPARGS2"
	echo $usageString

	echo "Arguments:"
	( IFS=:
  		for arg in $CLPARGS; do
  			desc=""
  			valueName=""
  			REQUIRED=""
  			defaultValue=""

			clpargs_arg_definition $arg DESC
			desc=$RETURN_VALUE
			clpargs_arg_definition $arg VALUE_NAME
			valueName="$RETURN_VALUE"
			clpargs_arg_definition $arg REQUIRED
			REQUIRED="$RETURN_VALUE"
			clpargs_arg_definition $arg DEFAULT_VALUE
			defaultValue=$RETURN_VALUE

			if [[ "$defaultValue" != "" ]] ; then
				defaultValue="default value: $defaultValue"
			else
				defaultValue="default value: none"
			fi		

      		echo "  $arg"="<"$valueName">" - $desc "(REQUIRED: ""$REQUIRED"", ""$defaultValue"")"
  		done
	)

}

#helper function to export variable
function clpargs_export_var
{
	local var=$*

	var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
	var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters

	export "$var"
}

#parse command line arguments
function clpargs_parse
{

	#Check all variables and if defined var has default value
	#then set default value
	CLPARGS2=$CLPARGS
	while IFS=':' read -ra CLPARGS2; do
   		for arg in "${CLPARGS2[@]}"; do
			#check if variable is available in environment
			#if it is, then it is used like any other env variable
			env | grep ^$arg= > /dev/null
			if [[  $? != 0 ]]; then
				#not set in env
				#set default value
	        	var="CLPARGS_DEFINED_ARG_"$arg"_DEFAULT_VALUE"
 				if [[ ${!var} != "" ]]; then
 					var2="$(echo $arg=${!var})"
 					clpargs_export_var $var2
 				fi
			fi

       	done
 	done <<< "$CLPARGS2"

	for var in "$@"; do
		#if any help string present, show help and exit
		if [[ $var == "help"  ||  $var == "--help" ||  $var == "-h" ||  $var == "-help" ]]
		then	
  			clpargs_usage
  			exit 1
		fi

		if [[ $var != *"="* ]]
		then	
  			#if var does not contain '=' don't process it
  			continue
		fi
		clpargs_export_var $var
	done

	#check if there are REQUIRED args that are missing
	( IFS=:
  		for REQUIREDArg in $CLPARGS_REQUIRED_ARGS; do
      		isIncluded=1
      		for varName in "${variableNames[@]}"; do
				if [[ $varName == "$REQUIREDArg" ]];then
					isIncluded=0
				fi
			done

			#check if variable is available in environment
			#if it is, then it is used like any other env variable
			env | grep ^$REQUIREDArg= > /dev/null
			if [[  $? == 0 ]]; then
				isIncluded=0
			fi
			#if isIncluded is still 1 then argument is not available
			if [[ $isIncluded == 1 ]]; then
				clpargs_error "REQUIRED argument $REQUIREDArg missing."
			fi

  		done
	) 
	if (($? == 1)); then    
    	exit 1
	fi
}
