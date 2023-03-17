#!/bin/bash

PSQL="psql -U freecodecamp -d number_guess -t --no-align -c"

GUESS_SECRET_NUMBER () {
  echo "Enter your username:"
  read NAME
  USER_INFO="$($PSQL "SELECT * FROM users FULL JOIN games USING(user_id) WHERE name = '$NAME'")"

  if [[ -z $USER_INFO ]]; then
    echo -n "Welcome, $NAME! It looks like this is your first time here."
    echo "$($PSQL "INSERT INTO users(name) VALUES('$NAME')" > /dev/null)"

    USER_ID="$($PSQL "SELECT user_id FROM users WHERE name = '$NAME'")"
    echo -n "$($PSQL "INSERT INTO games(user_id) VALUES($USER_ID)" > /dev/null)"

    else
      echo $USER_INFO | while IFS='|' read USER_ID  NAME  GAMES_PLAYED  BEST_GAME; do
        echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $(($BEST_GAME + 0)) guesses."
      done
  fi

  SECRET_NUMBER=$(($RANDOM%1000 + 1))
  echo "Guess the secret number between 1 and 1000:"

  while true; do
    read USER_INTENT

    if [[ ! $USER_INTENT =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
      continue
    fi
    
    ((NUMBER_GUESSES++))
    if [[ $USER_INTENT -eq $SECRET_NUMBER ]]; then
      echo "You guessed it in $NUMBER_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      
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
