#!/bin/bash
[ $1 ] && [ -f $1 ]
for i in $1
do
    #pegar o nome do arquivo
    nome=$(basename $i)
    python3 -c "import sys; sys.stdout.write(open(sys.argv[1]).read())" $i > x$i
    rm $i
    mv x$i $i
done