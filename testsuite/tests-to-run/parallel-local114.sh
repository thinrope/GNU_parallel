#!/bin/bash

cat <<'EOF' | sed -e 's/;$/; /;s/$SERVER1/'$SERVER1'/;s/$SERVER2/'$SERVER2'/' | stdout parallel -j0 -k -L1
echo "### Test -I"; 
  seq 1 10 | parallel -k 'seq 1 {} | parallel -k -I :: echo {} ::'

echo "### Test -X -I"; 
  seq 1 10 | parallel -k 'seq 1 {} | parallel -j1 -X -k -I :: echo a{} b::'

echo "### Test -m -I"; 
  seq 1 10 | parallel -k 'seq 1 {} | parallel -j1 -m -k -I :: echo a{} b::'

echo "### Test max line length -m -I";
  seq 1 60000 | parallel -I :: -m -j1 echo a::b::c | 
  tee >(sort |md5sum) >/tmp/114-a$$;
  export CHAR=$(cat /tmp/114-a$$ | wc -c); 
  export LINES=$(cat /tmp/114-a$$ | wc -l); 
  echo "Chars per line ($CHAR/$LINES): "$(echo "$CHAR/$LINES" | bc); 
  rm /tmp/114-a$$

echo "### Test max line length -X -I"; 
  seq 1 60000 | parallel -I :: -X -j1 echo a::b::c | 
  tee >(sort |md5sum) >/tmp/114-b$$;
  export CHAR=$(cat /tmp/114-b$$ | wc -c); 
  export LINES=$(cat /tmp/114-b$$ | wc -l); 
  echo "Chars per line ($CHAR/$LINES): "$(echo "$CHAR/$LINES" | bc); 
  rm /tmp/114-b$$

echo "### bug #36659: --sshlogin strips leading slash from ssh command"; 
  parallel --sshlogin '/usr/bin/ssh localhost' echo ::: OK

echo "### bug #36660: --workdir mkdir does not use --sshlogin custom ssh"; 
  cd /tmp; echo OK > parallel_test.txt; 
  ssh () { echo Failed; }; 
  export -f ssh; 
  parallel --workdir /tmp/foo/bar --transfer --sshlogin '/usr/bin/ssh localhost' cat ::: parallel_test.txt; 

echo "bug #36657: --load does not work with custom ssh"; 
  cd /tmp; echo OK > parallel_test.txt; 
  ssh () { echo Failed; }; 
  export -f ssh; 
  parallel --load=1000% -S "/usr/bin/ssh localhost" echo ::: OK

echo "bug #34958: --pipe with record size measured in lines"; 
  seq 10 | parallel -k --pipe -L 4 cat\;echo bug 34958-1

echo "bug #37325: Inefficiency of --pipe -L"; 
  seq 2000 | parallel -k --pipe --block 1k -L 4 wc\;echo FOO | uniq

echo "bug #34958: --pipe with record size measured in lines"; 
  seq 10 | parallel -k --pipe -l 4 cat\;echo bug 34958-2

echo "### Test --results"; 
  mkdir -p /tmp/parallel_results_test; 
  parallel -k --results /tmp/parallel_results_test/testA echo {1} {2} ::: I II ::: III IIII; 
  ls /tmp/parallel_results_test/testA/*/*/*/*/*; rm -rf /tmp/parallel_results_test/testA*

echo "### Test --res"; 
  mkdir -p /tmp/parallel_results_test; 
  parallel -k --res /tmp/parallel_results_test/testD echo {1} {2} ::: I II ::: III IIII; 
  ls /tmp/parallel_results_test/testD/*/*/*/*/*; rm -rf /tmp/parallel_results_test/testD*

echo "### Test --result"; 
  mkdir -p /tmp/parallel_results_test; 
  parallel -k --result /tmp/parallel_results_test/testE echo {1} {2} ::: I II ::: III IIII; 
  ls /tmp/parallel_results_test/testE/*/*/*/*/*; rm -rf /tmp/parallel_results_test/testE*

echo "### Test --results --header :"; 
  mkdir -p /tmp/parallel_results_test; 
  parallel -k --header : --results /tmp/parallel_results_test/testB echo {1} {2} ::: a I II ::: b III IIII; 
  ls /tmp/parallel_results_test/testB/*/*/*/*/*; rm -rf /tmp/parallel_results_test/testB*

echo "### Test --results --header : named - a/b swapped"; 
  mkdir -p /tmp/parallel_results_test; 
  parallel -k --header : --results /tmp/parallel_results_test/testC echo {a} {b} ::: b III IIII ::: a I II;
  ls /tmp/parallel_results_test/testC/*/*/*/*/*; rm -rf /tmp/parallel_results_test/testC*

echo "### Test --results --header : piped"; 
  mkdir -p /tmp/parallel_results_test; 
  (echo Col; perl -e 'print "backslash\\tab\tslash/null\0eof\n"') | parallel  --header : --result /tmp/parallel_results_test/testF true; 
  find /tmp/parallel_results_test/testF/*/*/*; rm -rf /tmp/parallel_results_test/testF*

echo "### Test --results --header : piped - non-existing column header"; 
  mkdir -p /tmp/parallel_results_test; 
  (printf "Col1\t\n"; printf "v1\tv2\tv3\n"; perl -e 'print "backslash\\tab\tslash/null\0eof\n"') | parallel --header : --result /tmp/parallel_results_test/testG true; find /tmp/parallel_results_test/testG/; rm -rf /tmp/parallel_results_test/testG*

EOF
