#!/bin/bash

cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/ | parallel -j10 -k -L1
echo '### Test bug #34241: --pipe should not spawn unneeded processes'
  seq 5 | ssh csh@lo parallel -k --block 5 --pipe -j10 cat\\\;echo Block_end

echo '### --env _'
  fUbAr="OK FUBAR" parallel -S csh@lo --env _ echo '$fUbAr $DISPLAY' ::: test
echo '### --env _ with explicit mentioning of normally ignored var $DISPLAY'
  fUbAr="OK FUBAR" parallel -S csh@lo --env DISPLAY,_ echo '$fUbAr $DISPLAY' ::: test

echo '### --filter-hosts --slf <()'
  parallel --nonall --filter-hosts --slf <(echo localhost) echo OK

EOF
