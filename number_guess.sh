#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

ASK_NAME(){
  if [[ -z $1 ]]
  then
    echo -e "Enter your username:"
  else
    echo -e "$1"
  fi

  read NAME

  if [[ -z $NAME ]]
  then
    ASK_NAME "Plase provide a name:"
  fi

  QUERY_USER=$($PSQL "SELECT string_agg(id || ' | ' || games_played || ' | ' || best_game, ',') FROM users WHERE username='$NAME'")
  read ID BAR GAMES BAR BEST <<< $QUERY_USER

  if [[ -z $ID ]]
  then
    echo -e "Welcome, $NAME! It looks like this is your first time here."
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users (username, games_played) VALUES ('$NAME', 1)")
    ID=$($PSQL "SELECT id FROM users WHERE username='$NAME'")
  else
    echo -e "Welcome back, $NAME! You have played $GAMES games, and your best game took $BEST guesses."
    INCREMENT_GAMES_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE id = $ID")
  fi
}
ASK_NAME

TARGET=$(( ( RANDOM % 999 ) + 1 ))
echo "$TARGET"
COUNT=0

ASK_GUESS(){
  if [[ -z $1 ]]
  then
    echo -e "Guess the secret number between 1 and 1000:"
  else
    echo -e "$1"
  fi

  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
     ASK_GUESS "That is not an integer, guess again:"
  fi
}
ASK_GUESS


COMPARE(){
  ((COUNT+=1))
  if [[ $GUESS -gt $TARGET ]]
  then
    ASK_GUESS "It's lower than that, guess again:"
    COMPARE
  elif [[ $GUESS -lt $TARGET ]]
  then
    ASK_GUESS "It's higher than that, guess again:"
    COMPARE
  else
    echo -e "You guessed it in $COUNT tries. The secret number was $TARGET. Nice job!"

    if [[ $COUNT -lt $BEST || $BEST -eq 0 ]]
    then
      UPDATE_BEST_RESULT=$($PSQL "UPDATE users SET best_game = $COUNT WHERE id = $ID")
    fi
    
  fi
}
COMPARE