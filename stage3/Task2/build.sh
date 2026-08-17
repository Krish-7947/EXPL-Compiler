echo "1. Compiling Lex..."
lex exprtree.l

echo "2. Compiling Yacc..."
yacc -d exprtree.y

echo "3. Compiling C files..."
gcc y.tab.c lex.yy.c -o compiler

echo "-----------------------------------------"
echo "Ready to go...!"
echo "-----------------------------------------"