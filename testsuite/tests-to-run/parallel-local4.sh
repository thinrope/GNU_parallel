#!/bin/bash

cat <<'EOF' | parallel -j0 -vk
echo '### bug #36595: silent loss of input with --pipe and --sshlogin'
  seq 10000 | xargs | parallel --pipe -S 10/localhost cat | wc

echo 'bug #36707: --controlmaster eats jobs'
  seq 2 | parallel -k --controlmaster --sshlogin localhost echo OK{}

echo '### -L -n with pipe'
  seq 14 | parallel --pipe -k -L 3 -n 2 'cat;echo 6 Ln line record'

echo '### -L -N with pipe'
  seq 14 | parallel --pipe -k -L 3 -N 2 'cat;echo 6 LN line record'

echo '### -l -N with pipe'
  seq 14 | parallel --pipe -k -l 3 -N 2 'cat;echo 6 lN line record'

echo '### -l -n with pipe'
  seq 14 | parallel --pipe -k -l 3 -n 2 'cat;echo 6 ln line record'

echo '### bug #39360: --joblog does not work with --pipe'
  seq 100 | parallel --joblog - --pipe wc | tr '0-9' 'X'

echo '### bug #39572: --tty and --joblog do not work'
  seq 1 | parallel --joblog - -u true | tr '0-9' 'X'

echo '### How do we deal with missing $HOME'
   unset HOME; stdout perl -w $(which parallel) echo ::: 1 2 3

echo '### How do we deal with missing $SHELL'
   unset SHELL; stdout perl -w $(which parallel) echo ::: 1 2 3
EOF
