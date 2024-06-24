#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MIN=1
MAX=1000
RANDOM_NUMBER=$((RANDOM % (MAX - MIN + 1) + MIN))
echo $RANDOM_NUMBER

GUESS=0
BEST=0

echo -e "Enter your username:"
read USERNAME

USER_SEARCH=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USERNAME'");

if [[ -z $USER_SEARCH ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_INSERT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, NULL)")
  GAMES_PLAYED=0
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

while [[ $GUESS != $RANDOM_NUMBER ]]
do
  read GUESS
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $RANDOM_NUMBER ]]
  then 
    echo "It's lower than that, guess again: "
  elif [[ $GUESS -lt $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi
  ((BEST++)) 
done

((GAMES_PLAYED++))

# Update best game if the current game is better
if [[ -z $BEST_GAME || $BEST -lt $BEST_GAME ]]
then
  BEST_GAME=$BEST
  BEST_INSERT=$($PSQL "UPDATE users SET best_game=$BEST_GAME WHERE username = '$USERNAME'")
fi

# Update games played count
GAMES_INSERT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username = '$USERNAME'")

echo "You guessed it in $BEST tries. The secret number was $RANDOM_NUMBER. Nice job!"
