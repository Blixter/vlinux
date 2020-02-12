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
SERVER=server

# Port on server
PORT="1337"

# Convert to csv
CSV="?type=csv"

# Current game ID
GAMEID=$(cat gameid.data | cut -d"," -f2 | tail -n1)

# Current room ID
ROOMID=$(cat room.data | cut -d"," -f1 | tail -n1)

# Map choosed
CHOSEDMAP=false

# Game has been started
STARTED=false

# User has entered the maze
ENTERED=false

# User won the game
WON=false




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
"  init             Initialize and the starts the game"
"  maps             Outputs the maps available"
"  select <#>       Select map by number"
"  enter            Enter the first room in the maze"
"  info             Outputs information about the room"
"  go <direction>   Go to a new room in the given direction"
""
"Options:"
"  --help, -h      Print help."
"  --version, -h   Print version."
    )

    printf "%s\n" "${txt[@]}"
}

#
# Message to display for usage and help.
#
function loop-usage
{
    local txt=(
""
"Command:"
"  east             Go to the east (if available)"
"  south            Go to the south (if available)"
"  west             Go to the west (if available)"
"  north            Go to the north (if available)"
"  info             Information about the current room"
"  help             Show this help window"
"  quit             Exit the game"
""
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
# Help function to check if the direction requested is valid.
#
function check-direction
{
    testdirection=$1

    if [[ $testdirection == "west" ]] \
    || [[ $testdirection == "east" ]] \
    || [[ $testdirection == "north" ]] \
    || [[ $testdirection == "south" ]]
    then
        declare -A directions

        curl -s $SERVER:$PORT/"$GAMEID"/maze/"$ROOMID""$CSV" > return.data

        west=$(cat return.data | cut -d"," -f3 | tail -n1)
        east=$(cat return.data | cut -d"," -f4 | tail -n1)
        south=$(cat return.data | cut -d"," -f5 | tail -n1)
        north=$(cat return.data | cut -d"," -f6 | tail -n1)
        
        directions["west"]="$west"
        directions["east"]="$east"
        directions["south"]="$south"
        directions["north"]="$north"

        if [[ ${directions["$testdirection"]} == "-" ]]
        then
            echo "false" > result.data
        else
            echo "true" > result.data
        fi
    else
        echo "false" > result.data
    fi
}


# 
# Loop the game
#
function app-loop
{
    while [[ $WON == false ]]
    do
        if [[ $STARTED == false ]]
        then
            app-init
        fi

        if [[ $CHOSEDMAP == false ]]
        then
            app-maps
            echo ""
            read -p 'Select map: ' -r SELECT
            if [[ -n "$SELECT" ]]
            then
                if [[ "$SELECT" == "quit" ]]
                then
                    break
                elif [[ "$SELECT" == "help" ]]
                then 
                    loop-usage
                else
                    app-select "$SELECT"
                    app-enter
                fi
            fi
        fi

        if [[ -n "$ENTERED" ]]
        then
            echo ""
            read -p "Choose a direction: " -r CHOICE
            if [[ -n "$CHOICE" ]]
            then
                if [[ "$CHOICE" == "quit" ]]
                then
                    break
                elif [[ "$CHOICE" == "help" ]]
                then 
                    loop-usage
                elif [[ "$CHOICE" == "info" ]]
                then 
                    app-info
                else
                    app-go "$CHOICE"
                fi
            fi
        fi
    done
}

#
# Starts the game.
# ROUTE /
#
function app-init
{
    curl -s $SERVER:$PORT"$CSV" > gameid.data 
    GAMEID=$(cat gameid.data | cut -d"," -f2 | tail -n1)
    cat gameid.data | cut -d"," -f1 | tail -n1
    STARTED=true
    echo "With game id: $GAMEID."
    echo ""
    echo "First you need to choose a map."
}


#
# Return a list of all available maps. 
# ROUTE /map
#
function app-maps
{
    curl -s $SERVER:$PORT/map"$CSV" > maps.data
    map1=$(cat maps.data | cut -d"," -f1 | tail -n1)
    map2=$(cat maps.data | cut -d"," -f2 | tail -n1)
    echo "Maps to choose from:"
    echo "1." "$map1"
    echo "2." "$map2"
}

#
# Loads the current map. 
# ROUTE /:gameid/map/:map
#
function app-select
{
    mapnumber=$1
    map=$(cat maps.data | cut -d"," -f"$mapnumber" | tail -n1)
    curl -s $SERVER:$PORT/"$GAMEID"/map/"$map""$CSV" > return.data
    cat return.data | cut -d"," -f1 | tail -n1
    CHOSEDMAP=true
}

#
# Enters the first room. 
# ROUTE /:gameid/maze
#
function app-enter
{
    declare -A directions

    ENTERED=true

    curl -s $SERVER:$PORT/"$GAMEID"/maze"$CSV" > room.data
    ROOMID=$(cat room.data | cut -d"," -f1 | tail -n1)
    description=$(cat room.data | cut -d"," -f2 | tail -n1)
    west=$(cat room.data | cut -d"," -f3 | tail -n1)
    east=$(cat room.data | cut -d"," -f4 | tail -n1)
    south=$(cat room.data | cut -d"," -f5 | tail -n1)
    north=$(cat room.data | cut -d"," -f6 | tail -n1)
    
    directions["West"]="$west"
    directions["East"]="$east"
    directions["South"]="$south"
    directions["North"]="$north"
    
    echo "Current room: $description."
    echo ""
    echo "You can go: "
    
    for direction in "${!directions[@]}"
    do
        if [[ ${directions["$direction"]} != "-" ]]
        then
            echo "$direction": "${directions["$direction"]}""."
        fi
    done
}

#
# Info about the room. 
# ROUTE /:gameid/maze/:roomId
#
function app-info
{
    declare -A directions

    curl -s $SERVER:$PORT/"$GAMEID"/maze/"$ROOMID""$CSV"> return.data
    
    description=$(cat return.data | cut -d"," -f2 | tail -n1)
    west=$(cat return.data | cut -d"," -f3 | tail -n1)
    east=$(cat return.data | cut -d"," -f4 | tail -n1)
    south=$(cat return.data | cut -d"," -f5 | tail -n1)
    north=$(cat return.data | cut -d"," -f6 | tail -n1)

    if [[ $description == "You found the exit" ]]
        then
            echo "Good job! You found the exit."
        else

    
            directions["West"]="$west"
            directions["East"]="$east"
            directions["South"]="$south"
            directions["North"]="$north"
            
            echo ""
            echo "Current room: $description."
            echo ""
            echo "You can go: "
            
            for direction in "${!directions[@]}"
            do
                if [[ ${directions["$direction"]} != "-" ]]
                then
                    echo "$direction": "${directions["$direction"]}""."
                fi
            done
        fi
}

#
# Walks away from the current room in selected direction.
# ROUTE /:gameid/maze/:roomId/:direction
#
function app-go
{
    direction=$1
    
    check-direction "$1"

    result=$(cat result.data)

    if [[ $result == "true" ]]
    then
        declare -A directions

        curl -s $SERVER:$PORT/"$GAMEID"/maze/"$ROOMID"/"$direction""$CSV" > room.data
        ROOMID=$(cat room.data | cut -d"," -f1 | tail -n1)
        description="$(cat room.data | cut -d"," -f2 | tail -n1)"
        west=$(cat room.data | cut -d"," -f3 | tail -n1)
        east=$(cat room.data | cut -d"," -f4 | tail -n1)
        south=$(cat room.data | cut -d"," -f5 | tail -n1)
        north=$(cat room.data | cut -d"," -f6 | tail -n1)
        
        directions["West"]="$west"
        directions["East"]="$east"
        directions["South"]="$south"
        directions["North"]="$north"

        if [[ $description == "You found the exit" ]]
        then
            echo ""
            echo "Good job! You found the exit."
            WON=true
        else      
            echo "Current room: $description."
            echo ""
            echo "You can go: "
            
            for direction in "${!directions[@]}"
            do
                if [[ ${directions["$direction"]} != "-" ]]
                then
                    echo "$direction": "${directions["$direction"]}""."
                fi
            done
        fi
    else
        echo ""
        echo "You can't go that direction"
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

            init          \
            | maps        \
            | select      \
            | enter       \
            | info        \
            | go          \
            | loop )
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
