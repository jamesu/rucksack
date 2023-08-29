# Rucksack

## What is it?

Simply put, this is an collaborative organization tool, 
inspired by a certain other collaborative organization tool. 

The key feature is that you have "Pages" which can contain 
any of the following content (or "widgets"):

* Notes
* Lists
* Separators (or you can call them headings)
* Files
* Images

These pages can be edited by yourself and any other 
user you choose to share it to. 
You can also re-order and move content between pages. 

In addition there are a few complimentary features, namely:

* Reminders
* Journals & Status (think Twitter)

## What does it look like?

Currently there are no included screenshots... but if you have an imagination, you can imagine it as a web app with tabs, with the main interactive element being a page you can insert content into.

## What about a demo?

Currently there is no demo available. However since rucksack takes mere minutes to install, who needs a demo? :)

## Sounds great, how do i install it?

Firstly, make a "config/database.yml" file based off of 
"config/database.example.yml". If you want a quick start, 
you can use the file as-is since it is already set up to 
use a local SQLite database.

Next, you'll want to actually install the initial content. 
You can do this by typing in the following command: 

    script/setup

To run it, refer to your favorite rails setup guide. If you need a simple development instance, executing the following should work:

    script/rails server -p <port>

Finally, login. The default credentials are:

    Username: admin
    Password: password

## I just upgraded and now it doesn't work!

The most likely explanation is that the database schema has been updated. You'll need to type in the following command to resolve this:

    rake db:migrate

Also note that if you are migrating from the rails 4 version of rucksack, there is currently no migration for file data as it has been refactored to use ActiveStorage.


Have fun!
