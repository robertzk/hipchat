Hipchat R integration [![Build Status](https://travis-ci.org/robertzk/hipchat.svg?branch=master)](https://travis-ci.org/robertzk/hipchat)
=======

Features
--------

* Send messages to rooms or private users
* Set a room's topic
* Create and delete rooms
* Fetch chat history for a room
* List rooms for a given group
* Create, update and delete (and undelete) a Hipchat user
* Show user details
* List all users in a group

Installation
-----------

This package is not yet available from CRAN (as of Oct 10, 2014).
To install the latest development builds directly from GitHub, run this instead:

```R
if (!require("devtools")) install.packages("devtools")
devtools::install_github("robertzk", "hipchat")
```

You will need to have a `HIPCHAT_API_TOKEN` in your environment variables,
or set a `options(hipchat.api_token = 'your_api_token')` in your `~/.Rprofile`.

To get started with the Hipchat API and set up a token, see their [getting started guide](https://www.hipchat.com/docs/apiv2).


Getting started
----------------

To test that the package is set up correctly, try messaging yourself:

```R
hipchat_message('your_email@organization.com', 'This package is awesome')
```

Here is a semi-exhaustive list of examples of other features:

```R
hipchat_message('Room name or email', "I'm in a hipchat!")
hipchat_topic('Room name', "This is the new topic")
hipchat_create_room('Room name')
hipchat_delete_room('Room name') # Will prompt a confirmation
hipchat_history('Room name')
hipchat_list_rooms('Group name')
hichat_create_user(...)
hipchat_update_user(...)
hipchat_delete_user('terrible@employee.com')
hipchat_list_users()
```

If you find any bugs or would like more features, feel free to [create an issue](https://github.com/robertzk/hipchat/issues/new).
