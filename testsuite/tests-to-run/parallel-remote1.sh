#!/bin/bash

SERVER1=parallel-server3
SERVER2=lo
SSHLOGIN1=parallel@parallel-server3
SSHLOGIN2=parallel@lo

echo '### Test use special ssh with > 9 simultaneous'
echo 'ssh "$@"; echo "$@" >>/tmp/myssh1-run' >/tmp/myssh1
echo 'ssh "$@"; echo "$@" >>/tmp/myssh2-run' >/tmp/myssh2
chmod 755 /tmp/myssh1 /tmp/myssh2
seq 1 100 | parallel --sshlogin "/tmp/myssh1 $SSHLOGIN1, /tmp/myssh2 $SSHLOGIN2" \
  -j10000% -k echo

cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/\;s/\$SSHLOGIN1/$SSHLOGIN1/ | parallel -j2 -k -L1
echo '### --filter-hosts - OK, non-such-user, connection refused, wrong host'
  parallel --nonall --filter-hosts -S localhost,NoUser@localhost,154.54.72.206,"ssh 5.5.5.5" hostname

echo '### test --workdir . in $HOME'
  cd && mkdir -p parallel-test && cd parallel-test && 
    echo OK > testfile && parallel --workdir . --transfer -S $SSHLOGIN1 cat {} ::: testfile
EOF
