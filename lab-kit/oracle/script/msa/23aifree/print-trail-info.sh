#!/bin/bash
##
## Dump a trail to stdout via logdump.
##

usage() {
  cat <<EOF

  Usage: $0 [-n {num}] ["logdump option_1" "logdump option_2" ...] trail_1 [trail_2 ...]

  Run logdump with the given trail(s), dumping the contents to the stdout.
  Logdump options can be given (using quotes), e.g.: "ghdr on" "usertoken detail" etc.
  Default is "ghdr on" and "usertoken detail".

  Options:
      -n {num}  - limit records printed to {num} per trail
      -v        - print lots of data (verbose)
      -h        - print usage message
      -D        - just dump logdump commands (not trail) to stdout.

  The logdump options be overridden using command line options like "usertoken off".

  Output from "-D" can in turn be used as input to logdump; still runs
  logdump to get record count, unless given "-n".

  Assumes (for the most part) that "logdump" is found in the current
  directory. Sometimes it may work to invoke the script from "dirdat", or by
  setting LOGDUMP=path/to/logdump

EOF
}

#  Notes:
#  The shortest way (linux) to print {num} records:
#    $ num=100
#    $ yes next | head -${num} | ./logdump open trail
#
#  To set logdump options:
#    $ ( printf "ggstoken detail\n"; yes next | head -${num} ) | ./logdump open dirdat/tc000000
#    $ ( printf "ggstoken detail\n usertoken detail\n"; ... etc...
#
#  To process multiple trails:
#  $ for t in dirdat/aa*
#    do
#      ( printf "ggstoken detail\n usertoken detail\n detail data\n"; yes next | head -100 ) | ./logdump open $t
#   done | egrep "some pattern"
#
#  If not linux, "yes" may not exist (it repeatedly prints the given string).
#  Logdump prints its prompt unnecessarily when reading via stdin; an upper bound
#  is therefore required on 'yes' via 'head'. This script uses logdump to calculate
#  the exact record count if no limit is given; also all the extra "logdump" prompts
#  are cleaned up as well.

progdir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
# run logdump from pwd, but allow from dirdat (even if it's a symlink)
#LOGDUMP=${LOGDUMP:-"./logdump"}
LOGDUMP=$progdir/logdump
[ ! -f "$LOGDUMP" ] && [ -f $(dirname $PWD)/logdump ] && LOGDUMP=$(dirname $PWD)/logdump

#LOGDUMP=/home/oracle/oggmsa/ogg213/bin/logdump
#LOGDUMP=$progdir/logdump

declare -a trails opts
max_num=""

# default options
opts=(
  "ghdr on"
  "usertoken detail"
  "ggstoken detail"
  "headertoken detail"
  "detail data"
  "detail on"
  "sfh"
  "fileheader detail"
)

echo 'commands_only => '$command_only >>  /home/oracle/oggmsa/ogg213/bin/e.txt
echo 'first args => '$1 >>  /home/oracle/oggmsa/ogg213/bin/e.txt
#echo 'print  => '{ printf "OPEN $1\n"; cat; } >>  /home/oracle/oggmsa/ogg213/bin/e.txt
## dump trail to stdout, also clean up extra 'Lodgump>' prompts, fix newlines
dump_trail () {
  [ "$commands_only" = "" ] \
    && $LOGDUMP OPEN $1 | sed 's/^Logdump.*Logdump.*Logdump.*> *//; s/Logdump .*>/&\n/' \
    ||  { printf "OPEN $1\n"; cat; }
}


rm  -rf /home/oracle/oggmsa/ogg213/bin/d.txt
while getopts hn:tvD opt ; do
  case "$opt" in
    h) usage; exit 0 ;;
    n) max_num=${OPTARG} ;;
###    t) opts=( "ghdr on" "usertoken detail" "ggstoken detail" "headertoken detail" ) ;;
    v) opts=( "ghdr on" "usertoken detail" "ggstoken detail" "headertoken detail" "detail data" "detail on" "sfh" "fileheader detail" ) ;;
    D) commands_only=true ;;
    *) usage;  exit 2 ;;
  esac
done; shift $((OPTIND-1)); OPTIND=1

[ $# -eq 0 ] && usage && exit 2

echo '.........................0-0-0-0-0'"${trails[@]}" >> /home/oracle/oggmsa/ogg213/bin/d.txt
echo '.........................0-0-0-0-1'"$arg" >> /home/oracle/oggmsa/ogg213/bin/d.txt
# if not a file, assume it's an option
for arg ; do
  [ -f "$arg" ] && trails=( "${trails[@]}" "$arg" ) || opts=( "${opts[@]}" "${arg}" )
done

rm -rf /home/oracle/oggmsa/ogg213/bin/f.txt

echo '.........................0-0-0' >> /home/oracle/oggmsa/ogg213/bin/d.txt
for trail in "${trails[@]}" ; do
  [ ! -f "$trail" ] && echo "** warning: file not found: $trail" 1>&2 && continue

  echo '.........................0-0-0-0 num : '$num >> /home/oracle/oggmsa/ogg213/bin/d.txt
  echo '.........................0-0-0-1 max_num : '$max_num >> /home/oracle/oggmsa/ogg213/bin/d.txt
  #echo '.........................0-0-0-2 NF : '$(NF-1) >> /home/oracle/oggmsa/ogg213/bin/d.txt
  # optionally limit num recs printed to "max_num"; by default print all in trail
  [ "$max_num" != "" ] \
      && num=$max_num \
      || num=$(echo 'count' | $LOGDUMP OPEN $trail | awk '/has.*records/ { print $(NF-1) }')

  # just print the logdump commands to stdout
  [ "$commands_only" = "" ] && printf "trail $trail => print $num records\n"

# 20250114 by cys
num=`echo $num | sed 's/,//';`

echo "num2---->"$num2 >> /home/oracle/oggmsa/ogg213/bin/f.txt
echo "num---->"$num >> /home/oracle/oggmsa/ogg213/bin/f.txt


  echo '.........................0-0-1 num : '$num >> /home/oracle/oggmsa/ogg213/bin/d.txt
  echo '.........................0-0-1-1 num : '"$(printf "%s" "${opts[@]/%/\n}")" >> /home/oracle/oggmsa/ogg213/bin/d.txt
  ( x=1
    printf "$(printf "%s" "${opts[@]/%/\n}")"
    while (( x++ <= num ))
    do
      echo "next\n" >> /home/oracle/oggmsa/ogg213/bin/e.txt
      echo "x->"$x >> /home/oracle/oggmsa/ogg213/bin/e.txt
      printf "next\n"
    done ) | dump_trail $trail

done



