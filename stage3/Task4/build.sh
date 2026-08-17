echo "1. Compiling Lex..."
lex exprtree.l

echo "2. Compiling Yacc..."
yacc -d exprtree.y

echo "3. Compiling C files..."
gcc y.tab.c lex.yy.c -o compiler

echo "4. Creating target.xsm..."
./compiler sample_input2.txt

echo "5. Compiling and running ltranslate to create final machine code..."
lex ltranslate.l
gcc lex.yy.c
./a.out

echo "-----------------------------------------"
echo "Ready to go...!"
echo "-----------------------------------------"