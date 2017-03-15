Recogmaster
=============

## Running server
+ Create hostname to l.recognizeapp.com
+ Run server on port 8000
    
    ````
    bin/rails s -p8000
    
## Running tests

    RAILS_ENV=test bin/rake recognize:init # first time only
    bin/rspec spec

##Dependencies
+ Qt(for capybara-webkit)
+ libv8
+ Mysql(v5.6.x)

## Mailcatcher(for local mail delivery)

    gem install mailcatcher
