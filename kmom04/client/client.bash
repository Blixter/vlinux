#!/usr/bin/env bash
#
# A Command script for learning to create my own bash-scripts.
#
# Exit values:
#  0 on success
#  1 on failure
#



# Name of the script
SCRIPT=$( basename "$0" )

# Current version
VERSION="1.0.0"

# Server to access
SERVER="localhost"

# Port on server
PORT="5000"



#
# Message to display for usage and help.
#
function usage
{
    local txt=(
"Utility $SCRIPT for doing stuff."
"Usage: $SCRIPT [options] <command> [arguments]"
""
"Command:"
"  all             Outputs the content from the route /all"
"  names           Outputs the content from the route /names"
"  color <color>   Outputs the content from the route /color using given parameter."
"  test <url>      Check if the webserver is online or not, can be used with a parameter."
""
"Options:"
"  --help, -h      Print help."
"  --version, -h   Print version."
"  --save, -s      Save the returned data to local file 'saved.data'"
    )

    printf "%s\n" "${txt[@]}"
}



#
# Message to display when bad usage.
#
function badUsage
{
    local message="$1"
    local txt=(
"For an overview of the command, execute:"
"$SCRIPT --help"
    )

    [[ -n $message ]] && printf "%s\n" "$message"

    printf "%s\n" "${txt[@]}"
}



#
# Message to display for version.
#
function version
{
    local txt=(
"$SCRIPT version $VERSION"
    )

    printf "%s\n" "${txt[@]}"
}



#
# Function for taking care of specific command. 
# Outputs the route /all
#
function app-all
{
    # Store arguments in an array
    argArray=("$@")

    # Check if -s or --save is among the arguments.
    if [[ "${argArray[*]}" =~ "-s" || "${argArray[*]}" =~ "--save" ]]
    then 
        curl -o saved.data $SERVER:$PORT/all
    else
        curl $SERVER:$PORT/all
    fi
}

#
# Function for taking care of specific command.
# Outputs the route /names
#
function app-names
{
    # Store arguments in an array
    argArray=("$@")

    # Check if -s or --save is among the arguments.
    if [[ "${argArray[*]}" =~ "-s" || "${argArray[*]}" =~ "--save" ]]
    then 
        curl -o saved.data $SERVER:$PORT/names
    else 
        curl $SERVER:$PORT/names
    fi
}

#
# Function for taking care of specific command.
# Outputs the route /color
#
function app-color
{
    # Store arguments in an array
    argArray=("$@")

    color=$1

    # Check if -s or --save is among the arguments.
    if [[ "${argArray[*]}" =~ "-s" || "${argArray[*]}" =~ "--save" ]]
    then
        curl -o saved.data $SERVER:$PORT/color/"$color"
    else
        curl $SERVER:$PORT/color/"$color"
    fi
}

function app-test
{
    webserver=$SERVER:$PORT
    
    # Check for incoming argument
    if [[ -n $1 ]]
    then
        # First check if the argument is -s or --save
        if [[ $1 == "-s" || $1 == "--save" ]]
        then
        # continue if so
            webserver=$SERVER:$PORT
        else
        # if not change the webserver to the incoming argument
            webserver=$1
        fi
    fi

    # Store arguments in an array
    argArray=("$@")

    # Check if -s or --save is among the arguments.
    if [[ "${argArray[*]}" =~ "-s" || "${argArray[*]}" =~ "--save" ]]
    then 
        if [[ $(curl -sL -w "%{http_code}\\n" "$webserver" -o /dev/null) == "200" ]]
        then
            echo "Server is online" > saved.data
        else
            echo "Server is offline" > saved.data
        fi
    else
        if [[ $(curl -sL -w "%{http_code}\\n" "$webserver" -o /dev/null) == "200" ]]
        then
            echo "Server is online"
        else
            echo "Server is offline"
        fi
    fi
}


#
# Process options
# Main function
#
function main
{
    while (( $# ))
    do
        case "$1" in

            --help | -h)
                usage
                exit 0
            ;;

            --version | -v)
                version
                exit 0
            ;;

            all            \
            | names        \
            | color        \
            | test)
                command=$1
                shift
                app-"$command" "$@"
                exit 0
            ;;

            *)
                badUsage "Option/command not recognized."
                exit 1
            ;;

        esac
    done
}

main "$@"

badUsage
exit 1
