# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

export NLS_LANG=AMERICAN_KOREA.AL32UTF8
export JAVA_HOME=/usr/java/jdk1.8.0_211-amd64
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$JAVA_HOME/jre/lib/amd64/server:$/lib:/usr/lib:$LD_LIBRARY_PATH
export SPARK_HOME=/home/oracle/spark
export OSA_HOME=/home/oracle/osa

PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH
set -o vi
alias ll='ls -ltr'
