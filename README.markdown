
<img src="http://cloud.github.com/downloads/jamesu/rucksack/rckguy-lsm.png" alt="Rucksack"/>

## What is it?

Simply put, this is an collaborative organization tool, 
inspired by a certain other collaborative organization tool. 

The key feature is that you have "Pages" which can contain 
any of the following content (or "widgets"):

* Notes
* Lists
* Separators (or you can call them headings)
* Files

These pages can be edited by yourself and any other 
user you choose to share it to. 
You can also re-order and move content between pages. 

In addition there are a few complimentary features, namely:

* Reminders
* Journals & Status (think Twitter)

## Sounds great, how do i install it?

Firstly, make a "config/database.yml" file based off of 
"config/database.example.yml". If you want a quick start, 
you can use the file as-is since it is already set up to 
use a local SQLite database.

Next, you'll want to actually install the initial content. 
You can do this by typing in the following command: 

    script/setup

Next, run it either by pointing Phusion Passenger to the 
public folder, or run the local server, e.g.:

    script/server

Finally, login. The default credentials are:

    Username: admin
    Password: password

## I just upgraded and now it doesn't work!

The most likely explanation is that the database schema has been updated. You'll need to type in the following command to resolve this:

    rake db:migrate

## A word of warning

If you are planning on deploying RuckSack in a production environment, *make sure you change the secret session key*. Otherwise unauthorized users will be able to make a fake session (e.g. logged in as the administrator) and compromise your installation.

The relevant line is located in "config/app_config.yml":

    session: "_rucksack_session"
    secret: "CHANGE THIS TO SOMETHING LONG AND RANDOM"

Have fun!
