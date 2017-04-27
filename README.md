# Crontab with History

This script code is based on using Crontab commands.  
It would be useful if you have many users sharing one ID in a server and they use Crontab.  

## Features
- It writes a history log whenever a user edits Crontab through this.
- It prevents concurrent editing by creating a lock file.
- It prevents users from removing Crontab configs by mistake.


## Usage
```
$ ./crontab-with-history.sh
Usage: ./crontab_with_history.sh { -e | -l | -h | -C }
This script prevents remove crontab and write history.

  -e     Edit crontab and then write history
  -l     Display the current crontab on standard output
  -h     Display history
  -C     Force clean lock and temp files
```
