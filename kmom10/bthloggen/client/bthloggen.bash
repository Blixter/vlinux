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


# Server to access, reads from file 'server.data', DEFAULT is localhost
SERVER=$(cat 'server.data')

# Port on server
PORT="1337"


#
# Message to display for usage and help.
#
function usage
{
    local txt=(
"Utility $SCRIPT for testing a server."
"Usage: $SCRIPT [options] <command> [arguments]"
"The view commands can be combined, eg: view url <url> ip <ip> month <month>"
""
"Command:"
"  url                  Get url to view the server in browser."
"  view                 List all entries."
"  view url <url>       View all entries containing <url>."
"  view ip <ip>         View all entries containing <ip>."
"  view month <month>   View all entries containing <month>."
"  view day <day>       View all entries containing <day>."
"  view time <time>     View all entries containing <time>."
"  use <server>         Set the servername (localhost or service name)."
""
"Options:"
"  --help, -h       Display the menu"
"  --version, -h    Display the current version"
"  --count, -c      Display the number of rows returned"
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
# Outputs the url for the server
#
function app-url
{
    echo "Open the server in your browser: http://localhost:$PORT"
}

# 
# Outputs the route /data
#
function app-view
{
    # Store args in array
    args=("$@")

    len=${#args[@]}

    query=""

    for (( i=0; i<len-1; i++ ))
    do
        query+="${args[i]}=${args[i+1]}&"
    done

    curl "$SERVER":"$PORT"/data?"$query"
}

# 
# Counts the returned elements of the route /data
#
function app-view-count
{
    # Store args in array
    args=("$@")

    len=${#args[@]}

    query=""

    for (( i=0; i<len-1; i++ ))
    do
        query+="${args[i]}=${args[i+1]}&"
    done

    curl -s "$SERVER":"$PORT"/data?"$query" | jq '. | length'
}

#
# Set the server
#
function app-use
{
    echo "$1" > 'server.data'
    echo "Server is now: $1"
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

            --count | -c)
                app-"$2"-count "$@"
                exit 0
            ;;

            view        \
            | use       \
            | url)
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
