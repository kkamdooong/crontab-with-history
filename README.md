# Crontab with History

This script wraps the original crontab.  
It is useful in situations where several people are managing servers.  
  
It writes diff history after editing crontab and prevents removing crontab by mistake.  
It also locks when someone modifies crontab to prevent overwriting problems.


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
