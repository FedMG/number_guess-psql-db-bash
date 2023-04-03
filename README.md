# Number Guess Database & Bash Script Project

This project is a database for a number guess game using PostgreSQL that tracks user data, its games played and the best score. Additionally, a Bash script has been created to interact with the game and play it.


## Database Tables

<img src="/public/number-guess-db.webp" alt="Details of the number guess database" width="330" height="150"/>


### Games Table

![Alt text](/public/games-table.webp)


### Users Table

![Alt text](/public/users-table.webp)


## Bash Script

The Bash script interacts with the number guess database and performs various tasks such as query user data to verify whether the user exists or not. Also, insert data for a new user, and updating the score and games played by the user. Here is the command and its output:<br>

- Enter `./number-guess.sh` command in the bash terminal to run the script and interacts with the number_guess database.

![Alt text](/public/result.webp)

There are more features beyond the scope of this readme.

## Conclusion

This number guess database project demonstrates the use of PostgreSQL for storing and managing user data. Also, the hability to relate the tables according to the primary and foreign key. The Bash script provides a convenient way to interact with the database when the user plays the game and perform various tasks.
