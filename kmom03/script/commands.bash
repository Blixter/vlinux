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
"  cal                         Print out current calendar"
"  greet                       Personal greeting to the user"
"  loop <min> <max>            Print out current calendar with(out) events."
"  lower <n n n...>            Print out all numbers that are less than 42."
"  reverse <random sentence>   Reverses the given string."
"  starwars                    Get your popcorn and watch a movie."
"  all                         Run all the commands."
""
"Options:"
"  --help, -h                  Print help."
"  --version, -h               Print version."
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
# Outputs a current calendar
#
function app-cal
{
    cal -3
}

#
# Function for taking care of specific command.
# Outputs a welcome-message to the current logged in user
#
function app-greet
{
    echo "Welcome $USER"
}

#
# Function for taking care of specific command.
# Outputs the numbers from <min> to <max>
#
function app-loop
{
    min=$1
    max=$2

    # If no arguments were given give min and max a default value
    if [[ -z $1 ]] || [[ -z $2 ]]
    then 
        min=1
        max=5
    fi

    for (( val="$min"; val<="$max"; val++ ))
    do
        echo "$val"
    done
}

#
# Function for taking care of specific command.
# If arguments is lower than 42 - echo them.
#
function app-lower
{
    # Store arguments in an array
    argArray=("$@")

    # If no arguments were given, give default values to the array
    if [[ -z "${argArray[*]}" ]]
    then 
        argArray=(9 25 123 42 1 21)
    fi

    # Loop through all values in the array and echo if the value is less than 42
    for value in "${argArray[@]}"
    do
        if [[ $value -lt 42 ]]
        then 
            echo "$value"
        fi
    done
}

#
# Function for taking care of specific command.
# Return the argument given in reversed order.
#
function app-reverse
{
    str="$1"

    # If no arguments were given, use a default sentence.
    if [[ -z $1 ]]
    then
        str="randomsentence"
    fi

    reverse=""
    
    length=${#str}

    for (( i=length-1; i >= 0; i-- ))
    do 
        reverse="$reverse${str:$i:1}"
    done 
    
    echo "$reverse"
}

#
# Function for taking care of specific command.
# Starts a Star Wars movie.
#
function app-starwars
{
    telnet towel.blinkenlights.nl
}

#
# Function for taking care of specific command.
# Run all commands (except starwars).
#
function app-all
{
    echo "Loading command 'greet'....."
    echo ""
    (sleep 1; echo "-------------------------------------------------------------------"
    echo ""
    app-greet
    echo ""
    echo "-------------------------------------------------------------------")

    (sleep 2;
    echo ""
    echo "Loading command 'cal'....."
    echo "")
    (sleep 1; 
    echo "-------------------------------------------------------------------"
    echo ""
    app-cal
    echo ""
    echo "-------------------------------------------------------------------")

    (sleep 2;
    echo ""
    echo "Loading command 'reverse'....."
    echo "")
    (sleep 1; echo "-------------------------------------------------------------------"
    echo ""
    app-reverse "$@"
    echo ""
    echo "-------------------------------------------------------------------")

    (sleep 2;
    echo ""
    echo "Loading command 'lower'....."
    echo "")
    (sleep 1; 
    echo "-------------------------------------------------------------------"
    echo ""
    app-lower "$@"
    echo ""
    echo "-------------------------------------------------------------------")

    (sleep 2;
    echo ""
    echo "Loading command 'loop'....."
    echo "")
    (sleep 1; 
    echo "-------------------------------------------------------------------"
    echo ""
    app-loop "$@"
    echo ""
    echo "-------------------------------------------------------------------")
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

            greet          \
            | reverse        \
            | all            \
            | starwars       \
            | cal)
                command=$1
                shift
                app-"$command" "$*"
                exit 0
            ;;
            loop            \
            | lower)
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
