# clpargs
Command line arguments for bash scripts (without getopts). 

##Reasoning
Whenever I write shell scripts, I usually need some arguments for it and hardcoding them 
in the script may not be a good idea. I could just use $1, $2 and so on in the scripts but then I'd have to remember what they are. I'm not in the business of remembering that kind of stuff, So there's a definite need for argument parsing.

I came across bash wrapper for getopts (optparse, https://github.com/nk412/optparse) and I was inspired enough to make my own arg parser.

##Using clpargs
The approach of clpargs is slightly different than using traditional command line options since I use args like: *name=value name2="value two"*.

Executing scripts is like: `script.sh name=value name2=value`. To get help, '-h', '--help', '-help' and 'help' options are recognized and if any of them is present then usage and help is displayed (this requires that description and arguments haven been defined as in example below).

A side effect of using clpargs.bash is that you can define your arguments as environment variables. So if you have argument in environment and you don't specify it in command line, then that environment variable is used. If argument is found from environment and you specify it in command line, command line takes precedence.

Here is example how to use clpargs in the script code:
```
#source clpargs.bash functions
source clpargs.bash

#add description for your program (optional)
clpargs_program_description "Do something with strings."

#define arguments to use (optional)
#syntax: clpargs_define <NAME> <VALUE_NAME> <DESCRIPTION> <REQUIRED: true | false> [<DEFAULT_VALUE>]
clpargs_define LINE1 "str" "String 1" true
clpargs_define LINE2 "str" "String 2" false
clpargs_define LINE3 "str" "String 3" false "This is line three"

#call this script like: script.sh LINE1=valueofline1 LINE2="this is line two"
#parse arguments
clpargs_parse "$@"
#note: since one of the defined arguments is mandatory, parse fails if any mandatory argument is missing

#use your arguments like normal environment variables
echo $LINE1
if [[ "$LINE2" != "" ]] ; then
	echo $LINE2
fi
echo $LINE3
```


