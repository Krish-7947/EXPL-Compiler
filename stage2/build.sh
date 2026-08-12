echo "1. Compiling Lex..."
lex exprtree.l

echo "2. Compiling Yacc..."
yacc -d exprtree.y

echo "3. Compiling C files..."
gcc y.tab.c lex.yy.c -o compiler

echo "4. Running the compiler on test.txt..."
./compiler test.txt

echo "========================================"
echo "intermediate.xsm is ready for the XSM simulator."
echo "========================================"