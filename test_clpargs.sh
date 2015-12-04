#!/usr/bin/env bash

#test_clpargs - Testing clpargs
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

source clpargs.bash

ARG3_DEFAULT_VALUE=defvalue3

clpargs_program_description "Testing clpargs."

clpargs_define ARG1 "NAME1" "ARG1 is mandatory" true
clpargs_define ARG2 "NAME2" "ARG2 is not mandatory" false
clpargs_define ARG3 "NAME3" "ARG3 is not mandatory and has default value" false "$ARG3_DEFAULT_VALUE" 


clpargs_parse "$@"

function argdef
{
	echo $1 Definition:
	clpargs_arg_definition $1 DESC
	echo "  " $1 description  : $RETURN_VALUE
	clpargs_arg_definition $1 VALUE_NAME
	echo "  " $1 value name   : $RETURN_VALUE
	clpargs_arg_definition $1 MANDATORY
	echo "  " $1 mandatory    : $RETURN_VALUE
	clpargs_arg_definition $1 DEFAULT_VALUE
	echo "  " $1 default value: $RETURN_VALUE

}

argdef ARG1
argdef ARG2
argdef ARG3

echo ARG1 value: $ARG1

if [[ "$ARG2" == "" ]] ; then
	echo ARG2 is empty
else
	echo ARG2 is not empty: $ARG2
fi 

echo "ARG3 value: $ARG3 (should be: $ARG3_DEFAULT_VALUE)"

