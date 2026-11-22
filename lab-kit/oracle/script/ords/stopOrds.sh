#!/bin/bash
#. /home/oracle/scripts/setEnv.sh
ps -ef | grep java | grep "/home/oracle/ords/config" | awk '{print $2}' | xargs kill -9
