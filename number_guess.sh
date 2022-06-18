#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


echo "Enter your username:"
read USER_NAME
# look for user in database
USER_DATA=$($PSQL "SELECT name, games_played, best_game FROM users WHERE name='$USER_NAME'")
# if not found add user to database 
if [[ -z $USER_DATA ]]
then
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
  USER_IN=$($PSQL "INSERT INTO users(name) VALUES ('$USER_NAME')")
# if user found in database
else
  echo $USER_DATA | while IFS="|" read NAME GAMES SCORE
  do
    echo "Welcome back, $NAME! You have played $GAMES games, and your best game took $SCORE guesses."
  done
fi

# Generate random number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS=0
ATTEMPTS=0

echo "Guess the secret number between 1 and 1000:"
while [[ $SECRET_NUMBER != $GUESS ]]
do
  read GUESS
  if [[ $GUESS =~ [^0-9]+ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS > $SECRET_NUMBER ]]
    then
      (( ATTEMPTS++ ))  
      echo "It's lower than that, guess again:"
    elif [[ $GUESS < $SECRET_NUMBER ]]
    then
      (( ATTEMPTS++ )) 
      echo "It's higher than that, guess again:"
    elif [[ $GUESS == $SECRET_NUMBER ]]
    then
      (( ATTEMPTS++ ))
    fi
  fi
done

echo "You guessed it in $ATTEMPTS tries. The secret number was $SECRET_NUMBER. Nice job!"

# store data in database
GAMES_NO=$($PSQL "SELECT games_played FROM users WHERE name='$USER_NAME';")
(( GAMES_NO++ ))
USER_UPDATE=$($PSQL "UPDATE users SET games_played=$GAMES_NO WHERE name='$USER_NAME';")

BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name='$USER_NAME';")
if [[ $ATTEMPTS < $BEST_GAME || $BEST_GAME == 0 ]]
then
  USER_UPDATE=$($PSQL "UPDATE users SET best_game=$ATTEMPTS WHERE name='$USER_NAME';")
fi

