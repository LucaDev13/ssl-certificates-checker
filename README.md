This script allows to check certificates validity and expiry at the desired interval. 

It calculates how many days are left before the expiry of the certificates in question. 

Based on how many days are left before the expiry, messages are sent to the specified slack webhook url.

Endpoints to be checked and slack webhook url are to be configured in the config.rb file.


***Steps to install and start the process on EC2:***

    * install rvm and ruby on instance
    * install rubygems
    * gem install sslcheck
    * gem install rufus-scheduler
    * gem install slack-notifier
    * amend settings as needed for scheduler in certcheck.rb script. See various options on https://github.com/jmettraux/rufus-scheduler#rufus-scheduler
    * amend the config.rb file with the desired endpoint list and the desired slack webhook
    * sudo touch certcheck.rb && sudo touch config.rb
    * sudo nano certcheck.rb > paste script and save
    * sudo nano config.rb and paste script and save
    * nohup ruby certcheck.rb &
    * logout from ssh instance

***Steps to find and terminate the process*** 

1. ps -ef | grep certcheck.rb
2. restart the instance or kill PID
