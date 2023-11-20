#!/bin/sh

# help_text displays the purpose of each command-line option.
help_text() {
    echo "
    --human name to supply username.
    --keep file to save intermediate states of game.
    --human-symbol letter to choose the letter to be used by the human player. Default is o.
    --computer-symbol letter to choose the letter to be used by the computer. Default is x."
    exit 0
}

# ai function computes the computers move
ai(){
    # randomly compute the computer move by using the least 
    # significant digit from the current seconds
    pos=`date +%S | sed -e 's/^[0-9]//'`
    pos=`expr $pos / 1`
    while [ $turn = 'true' ]; do 
        if [ $pos = 0 ] 
            then comp_row=1 comp_col=1
        elif [ $pos = 1 ]
            then comp_row=1 comp_col=3
        elif [ $pos = 2 ]
            then comp_row=3 comp_col=1
        elif [ $pos = 3 ]
            then comp_row=3 comp_col=3
        elif [ $pos = 4 ]
            then comp_row=2 comp_col=2
        elif [ $pos = 5 ]
            then comp_row=1 comp_col=2
        elif [ $pos = 6 ]
            then comp_row=2 comp_col=1
        elif [ $pos = 7 ]
            then comp_row=2 comp_col=3
        elif [ $pos = 8 -o $pos = 9 ]
            then comp_row=3 comp_col=2
        fi
    turn='false'
    done
    # temp variable checks what is in the chosen space in the board    
    temp=`echo $board | head -n $comp_row | tail -n +$comp_row | \
    cut -c $comp_col | sed -e 's/\n//g'`
    # if temp is equal to the computer symbol or the human symbol, the space has already
    # been occupied by the player or the computer
    if [ $temp = $player1 ]
        then 
            # It remains the computers turn until an unoccupied space is chosen 
            turn='true'
    elif [ $temp = $human ]
        then 
            # It remains the computers turn until an unoccupied space is chosen 
            turn='true'
    else 
        echo "Computer's turn"
        # if space is unoccupied, place the computer symbol in that position
        board=`echo "$board" | sed -e ''$comp_row's/./'$player1'/'$comp_col''`
        echo "Current state of game:"
        echo $board
        # save game state to file
        echo $board > $filename
        # Computers turn has been completed 
        player1=$human
        moves=`expr $moves + 1`
    fi 

    # call functions to check for winner
    CHECK_HORIZONTAL_WINNER;
    CHECK_VERTICAL_WINNER;
    CHECK_LEFT_DIAGONAL;
    CHECK_RIGHT_DIAGONAL;

    # check for draw
    CHECK_DRAW;
}

# checks if no winner has been determined
CHECK_DRAW(){
    if [ $winner = "false" -a $moves -eq 9 ]
        then 
            echo "Both players draw!"
            exit 0
    fi 
}

# checks whether checkmate has occured on the horizontal axis 
CHECK_HORIZONTAL_WINNER(){
    index=1
    # while loop to iterate through the 3 rows
    while [ $index -le 3 ]
    do 
    # check_row isolates each row 
    check_row=`echo $board | head -n $index | tail -n +$index`
        # if the row has three occurences of the computer symbol 
        # machine has won
        if [ $check_row = ''$computer''$computer''$computer'' ]
            then
                winner="true"
                echo "And the winner is... computer!"
                # game has completed, terminate the script
                exit 0
        # if row has three occurrences of the human symbol 
        # human has won
        elif [ $check_row = ''$human''$human''$human'' ]
            then
                winner="true"
                echo "And the winner is... $name!"
                # game has been completed, terminate the script
                exit 0
        else
            winner="false"
        fi
        # increment the index, index resets to 1 once value 3 has been reached 
        index=`expr $index + 1`
    done
}

# checks whether checkmate has occurred on the vertical axis
CHECK_VERTICAL_WINNER(){
    index=1
    # while loop to iterate threw each column
    while [ $index -le 3 ]
    do 
    # check_col isolates each row and removes any newline characters
    check_col=`echo $board | cut -c $index | sed -e 's/\n//'`
    # check_human displays a winning scenario for the human where the human
    # character is displayed in each column. Sed removes any newline characters
    check_human=`echo ''$human'\n'$human'\n'$human'' | sed -e 's/\n//'`
    # check_comp displays a winning scenario for the computer where the computer
    # character is displayed in each column. Sed removes any trailing characters
    check_comp=`echo ''$computer'\n'$computer'\n'$computer'' | sed -e 's/\n//'`
    # if the column matches the winning human scenario
    if [ $check_col = $check_human ]
        then 
            winner="true"
            # human has won
            echo "And the winner is... $name!"
            # game has been completed, terminate the script
            exit 0
    # if the column matches the winning computer scenario
    elif [ $check_col = $check_comp ]
        then
            winner="true"
            # computer has won
            echo "And the winner is... computer!"
            # game has been completed, terminate the script 
            exit 0
    else
        winner="false"
    fi 
        index=`expr $index + 1`
    done 
}

# checks whether checkmate occurs on the diagonal axis (starting from the top 
# left square)
CHECK_LEFT_DIAGONAL(){
    index=1
    # set diagonal variable to add each occuring character on the diagonal 
    left_diagonal=
    while [ $index -le 3 ]
    do
    # check_left_diagonal accesses each row and uses cut to isolaate the relevant 
    # character on each row. Use sed to remove any newline characters
    check_left_diagonal=`echo $board | head -n $index | tail -n +$index | \
    cut -c $index | sed -e 's/\n//g'`
    # left_diagonal combines each character on the diagonal into one variable
    left_diagonal=`echo ''$left_diagonal' '$check_left_diagonal'' | sed -e 's/ //g'`
    # if all the characters on the diagonal = three occurrances of the human character
    # human has won
    if [ $left_diagonal = ''$human''$human''$human'' ]
        then
            winner="true"
            echo "And the winner is... $name!"
            # game has been completed, terminate the script
            exit 0
    # if all the characters on the diagonal = three occurrances of the computer character
    # computer has won
    elif [ $left_diagonal = ''$computer''$computer''$computer'' ] 
        then
            winner="true"
            echo "And the winner is... computer!"
            # game has been completed, terminate the script 
            exit 0
    else
        winner="false"
    fi 
    # increment index value
    index=`expr $index + 1`   
    done  
}

# checks whether checkmate occurs on the diagonal (from top right corner to bottom
# left corner)
CHECK_RIGHT_DIAGONAL(){
    index=1
    # j is another index value
    j=3
    # set diagonal variable to add each occuring character on the diagonal to 
    right_diagonal=
    # need j as inverted axis to access this diagonal 
    while [ $index -le 3 -a $j -ge 1 ]
    do
    # check_right_diagonal accesses each row and uses cut to isolaate the relevant 
    # character on each row. Use sed to remove any newline characters
    check_right_diagonal=`echo $board | head -n $index | tail -n +$index | \
    cut -c $j | sed -e 's/\n//g'`
    # right_diagonal variable to display all occurring characters on the diagonal
    right_diagonal=`echo ''$right_diagonal' '$check_right_diagonal'' | sed -e 's/ //g'`   
    # if the characters on the diagonal match 3 occurrances of the human character
    # human has won
    if [ $right_diagonal = ''$human''$human''$human'' ]
        then
            winner="true"
            echo "And the winner is... $name!"
            # game is complete, terminate script
            exit 0
    # if the characters on the diagonal match 3 occurrances of the computer character
    # computer has won 
    elif [ $right_diagonal = ''$computer''$computer''$computer'' ] 
        then 
            winner="true"
            echo "And the winner is... computer!"  
            #game is complete, terminate script
            exit 0
    else
        winner="false"
    fi
        #incerement index
        index=`expr $index + 1`
        # decrement j
        j=`expr $j - 1`
    done
}

# OPTIONS displays command line options using case statement 
OPTIONS=
while [ ${#} -ne 0 ]; do
    case ${1} in
        # --help calls help text function to give user more information on 
        # the command line options
        --help) help_text;;
        # reads user input and uses that value for the human name
        --human) NAME="${OPTIONS}${2}";;
        # keep file if filename is specified
        --keep) FILE="${OPTIONS}$2" ;;
        # reads user input uses the input as the human character
        --human-symbol) HUMAN="${OPTIONS}${2}";;
        # reads user input, uses the input as the computer characterS
        --computer-symbol) COMPUTER="${OPTIONS}${2}";;
    esac
    shift 2
done

# Get current seconds of date, pipe to sed to access least significant digit
today=`date +%S | sed -e 's/^[0-9]//'`
# default computer character
computer='x'
# default human character
human='o'
# default human name
name='human' 
# Set IFS to empty to preserve newline characters
IFS=
# default value for filename is random value
filename=`mktemp -t $pwd/`

# if human name is specified, switch to that name rather than the default 'human'.
if [ -n "$NAME" ]
    then 
        name=$NAME
fi

# If human-symbol is specified, switch to that letter instead of default.
if [ -n "$HUMAN" ] 
   then 
        human=$HUMAN
        # human_char_len checks the length of the input for the human symbol
        huamn_char_len=`echo $human | wc -c`
        # if longer than one character, do not accept input. Abort script
        if [ $human_char_len -gt 2 ]
            then
                echo "The human symbol may only be one character in length. \
Please try again"
                exit 1
        fi
fi

# If computer-symbol is specified, switch to that letter instead of default.
if [ -n "$COMPUTER" ]
    then 
        computer=$COMPUTER 
        # character_length checks the length of the input for the computer symbol
        comp_char_len=`echo $computer | wc -c`
        # if longer than one character, do not accept input. Abort script
        if [ $comp_char_len -gt 2 ]
            then
                echo "The computer symbol may only be one character in length. \
Please try again"
                exit 1
        fi
fi

# If file name is specified, switch to that filename instead of the defaullt random.
if [ -n "$FILE" ]
    then
        filename=$FILE
else
    # if filename isnt specified, remove file
    rm $filename
fi 

#if least signig=ficant digit is <= 4, computer starts. Otherwise, human starts
if [ $today -le 4 ] 
    then  
        player1=$computer
    else
        player1=$human
fi

# tic tac toe board
board="---\n---\n---"
winner="false"
counter=1
moves=0
# create file to save game state to
while [ $winner = 'false' ]; do 
    if [ $player1 = $human ];
        then 
            echo "Please enter value of row (0..2): "
            read human_row
            # row success indicates in value entered by human has been accepted
            row_success="false"
    
        while [ $row_success = "false" ]; do 
            # If value is in the range 0-2, input is accepted
            if [ $human_row = 0 -o $human_row = 1 -o $human_row = 2 ] 
                then 
                    # increment human_row by 1, as values on board start at 1 instead of 0
                    human_row=`expr $human_row + $counter`
                    # indicates successful input
                    row_success="true"
            else 
                # input has not been accepted, must reinput until value is in correct range
                echo "Please input an integer value in the specified range (0..2): " 
                read human_row  
            fi
        done
    
        echo "Please enter value of column (0..2): "
        read human_col
        # incicates if value entered has been accepted
        col_success="false"
        
        while [ $col_success = "false" ]; do
            # check if input is in the corrent range (0-2)
            if [ $human_col = 0 -o $human_col = 1 -o $human_col = 2 ]
                then
                    # increment value by 1, as values on the board begin at one
                    human_col=`expr $human_col + $counter`
                    # indicates successful input
                    col_success="true"
            else
                # input has not been accepted, must reinput until value is in correct range
                echo " Please input an integer value in the specified range (0..2): "
                read human_col 
            fi 
        done
        # temp variable checks what is in the chosen space in the board  
        temp=`echo $board | head -n $human_row | tail -n +$human_row | \
        cut -c $human_col | sed -e 's/\n//g'`
        # if temp is equal to the computer symbol or the human symbol, the space has already
        # been occupied by the player or the computer
        if [ $temp = $player1 ]
            then 
                echo "That position on the board has already been filled"
        elif [ $temp = $computer ]
            then 
                echo "That position on the board has already been filled"
        else 
            # place the human symbol at the specified index
            board=`echo "$board" | sed -e ''$human_row's/./'$player1'/'$human_col''`
            echo "Current state of game:"
            echo $board
            # save game state to file
            echo $board > $filename
            # humans turn is over
            player1=$computer
            moves=`expr $moves + 1`
        fi

        # checks whether checkmate has occurred
        CHECK_HORIZONTAL_WINNER;
        CHECK_VERTICAL_WINNER;
        CHECK_LEFT_DIAGONAL;
        CHECK_RIGHT_DIAGONAL;

        # check for draw
        CHECK_DRAW;

    # current player is computer
    elif [ $player1 = $computer ];
        then 
            turn='true'
            # execute computers turn
            ai;
    fi
done
 