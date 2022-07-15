for i in lista*
do
    python3 -c "import sys; sys.stdout.write(open(sys.argv[1]).read())" $i > x$i
done