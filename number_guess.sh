#!/bin/bash

PSQL="psql -U freecodecamp -d number_guess -t --no-align -c"

PRINT () {
  if [[ $2 == 'success' ]]; then
    echo -e "\033[32m$1\033[0m"
    elif [[ $2 == 'warning' ]]; then
    echo -e "\033[33m$1\033[0m"
    elif [[ $2 == 'error' ]]; then
    echo -e "\033[31m$1\033[0m"
    else
    echo -e "$1"
  fi
}


GUESS_SECRET_NUMBER () {
  echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~\n~ Number guessing game ~\n~~~~~~~~~~~~~~~~~~~~~~~~\n"
  echo "Enter your username:"
  read NAME
  USER_INFO="$($PSQL "SELECT * FROM users FULL JOIN games USING(user_id) WHERE name = '$NAME'")"

  if [[ -z $USER_INFO ]]; then
    echo -e "\nWelcome, \033[32m$NAME\033[0m! It looks like this is your first time here."
    echo "$($PSQL "INSERT INTO users(name) VALUES('$NAME')" > /dev/null)"

    USER_ID="$($PSQL "SELECT user_id FROM users WHERE name = '$NAME'")"
    echo -n "$($PSQL "INSERT INTO games(user_id) VALUES($USER_ID)" > /dev/null)"

    else
      echo $USER_INFO | while IFS='|' read USER_ID  NAME  GAMES_PLAYED  BEST_GAME; do
        echo -e "\nWelcome back, \033[32m$NAME\033[0m! You have played \033[32m$GAMES_PLAYED\033[0m games, and your best game took \033[32m$(($BEST_GAME + 0))\033[0m guesses."
      done
  fi

  SECRET_NUMBER=$(($RANDOM%1000 + 1))   
  echo -e "\n\n----------------------------------------------\n- Guess the secret number between 1 and 1000 -\n----------------------------------------------\n"

  while true; do
    read USER_INTENT

    if [[ ! $USER_INTENT =~ ^[0-9]+$ ]]; then
      PRINT "That is not an integer, guess again:" "error"
      continue
    fi
    
    ((NUMBER_GUESSES++))
    if [[ $USER_INTENT -eq $SECRET_NUMBER ]]; then
      echo -e "You guessed it in $NUMBER_GUESSES tries. The secret number was \033[32m$SECRET_NUMBER\033[0m. Nice job!"
      
      if [[ $USER_INFO ]]; then
        echo $USER_INFO | while IFS='|' read USER_ID  _  GAMES_PLAYED  BEST_GAME; do

          ((GAMES_PLAYED++))

          if [[ -z $BEST_GAME || $NUMBER_GUESSES -le $BEST_GAME ]]; then
            echo "$($PSQL "UPDATE games SET best_game = $NUMBER_GUESSES, games_played = $GAMES_PLAYED WHERE user_id = $USER_ID" > /dev/null)"
            break
          fi

          echo "$($PSQL "UPDATE games SET games_played = $GAMES_PLAYED WHERE user_id = $USER_ID" > /dev/null)"
        done
        break
      fi

      ((GAMES_PLAYED++))
      USER_ID="$($PSQL "SELECT user_id FROM users WHERE name = '$NAME'")"
      echo "$($PSQL "UPDATE games SET best_game = $NUMBER_GUESSES, games_played = $GAMES_PLAYED WHERE user_id = $USER_ID" > /dev/null)"
      break
      
      elif [[ $USER_INTENT -lt $SECRET_NUMBER ]]; then
        echo "It's higher than that, guess again:"

      else 
        echo "It's lower than that, guess again:"
    fi
  done

}

GUESS_SECRET_NUMBER
