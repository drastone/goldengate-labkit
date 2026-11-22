#!/bin/bash
##
## Calls 'print-trail.sh' to dump a trail to stdout via logdump,
## but filters the output further to just print operation type,
## tx-indicator, seqno/rba, etc., all on  a single (grep-able) line.
##

usage() {
  cat <<EOF

  Usage: $0 [ -c | -h | -n ] [ -p {pattern} ] {trail}

  Run a trail through logdump, grepping and reformatting
  so that the inserts/updates/deletes (and RestartAbend)
  can been seen.

  Arguments:
    {trail...}  - path to a trail, trails or two char trail prefix,
                e.g., a single trail (file): dirdat/xx000023
                or, all trails in a series:   dirdat/xx
  Options:
      -c      - colorize output on a "RestartAbend"
      -p {pattern}  - colorize output on a given pattern
      -n      - print line numbers
      -h      - usage message and exit
      -t      - print trail path/name at beginning of output
      -T      - don't print trail path/name at beginning of output

  Caveats: assumes (for the most part) that "logdump"
    is found in the current directory. Sometimes it may work
    to invoke the script from "dirdat", or by
    setting LOGDUMP=path/to/logdump

EOF
  return 0
}

usage_exit() {
  usage
  exit $1
}

type gawk > /dev/null 2>&1 && AWK=gawk || AWK=awk
progdir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

pattern="^."
is_format=
filter=
indent=false
grep_opts=
display_trail=true
is_binary_input=true

while getopts cAhinp:tT opt; do
  case "$opt" in
    A) is_binary_input=false
       ;;
    c) is_format=true
       grep_opts="$grep_opts --color=always"
       pattern="^.|^.*Restart.*"
       ;;
    n) is_format=true
       grep_opts="$grep_opts -n"
       ;;
    h) usage_exit 2
       ;;
    i) indent=true
       ;;
    p) is_format=true
       grep_opts="$grep_opts --color=always"
       pattern="^.|${OPTARG}"
      ;;
    t) display_trail=true
      ;;
    T) display_trail=false
      ;;
    *) usage_exit 2
      ;;
  esac
done; shift $((OPTIND-1)); OPTIND=1

[ $# -eq 0 ] && usage_exit 2

do_summary1() {
 #/usr/bin/time -a -f "%E, %U" -o /tmp/time.awk1.txt \
  $AWK '/^Trans|^Undo|^20..\/|^Name:|^__/ { print $0 }'
  return 0
}

do_strip2() {
 #/usr/bin/time -a -f "%E, %U" -o /tmp/time.sed2.txt \
  sed 's/^Undo.*After: */=/; s/^\(TransInd.*\) \((x[0-9]*)\) *FormatType.*/=\2/; s/^Name: /=/; s/^20..\//=&/'
  return 0
}

do_paste3() {
 #/usr/bin/time -a -f "%E, %U" -o /tmp/time.sed3.txt \
  sed -e ':a' -e '$!N;s/\n=/ \* /;ta' -e 'P;D'
  return 0
}

do_reorder4() {
 #/usr/bin/time -a -f "%E, %U" -o /tmp/time.awk4.txt \
  $AWK -F\* '{ print $3 "\t" $2 "\t" $4 "\t" $5 }'
  return 0
}

do_filter5() {
 #/usr/bin/time -a -f "%E, %U" -o /tmp/time.grep4.txt \
  egrep -v "$filter"
  return 0
}

do_indent() {
  $indent && sed 's/.x0[012]./  &/; s/.x01./  &/' || cat
  return 0
}

do_post_process() {
 #/usr/bin/time -a -f "%E, %U" -o /tmp/time.egrepN.txt \
  [ $is_format ] && do_indent | egrep $grep_opts "$pattern" || do_indent
  return 0
}

process_gg_trails() {
  for trail
  do
    fname=${trail##*/}  # basename
    # check for two-character trail name
    [ ! -e "$trail" ] && [ ${#fname} -eq 2 ] && trail=${trail}??????

    for t in $trail
    do
      [ ! -f "$t" ] && echo "** error: file not found: $t" 1>&2

      #/usr/bin/time -a -f "%E, %U" -o /tmp/time.print_trail.txt \
      [ "$display_trail" = "true" ] && printf "$t\n"
      echo 't->'$t >> /home/oracle/oggmsa/ogg213/bin/c.txt
      $progdir/print-trail-info.sh $t \
          | do_summary1 \
          | do_strip2 \
          | do_paste3 \
          | do_reorder4 \
          | do_post_process
    done
  done
}


process_ascii_dump() {
  for txt_file
  do
      [ ! -f "$txt_file" ] && echo "** error: file not found: $txt_file" 1>&2
      cat $txt_file \
          | do_summary1 \
          | do_strip2 \
          | do_paste3 \
          | do_reorder4 \
          | do_post_process
  done
}

if $is_binary_input ; then
  process_gg_trails "$@"
else
  process_ascii_dump "$@"
fi



