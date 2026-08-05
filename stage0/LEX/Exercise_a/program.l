%option noyywrap
%{
#include <stdio.h>
int words = 0, lines = 0, chars = 0;
%}

letter [a-zA-Z0-9]
word {letter}+

%%

{word} {
    words++;
    chars += yyleng;
}

" " {
    chars++;
}

\t {
    chars++;
}

\n {
    lines++;
}

. {
    chars++;
}

%%

int main(int argc, char *argv[])
{
    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if (fp)
            yyin = fp;
    }

    yylex();

    printf("Number of words : %d\n", words);
    printf("Number of lines : %d\n", lines);
    printf("Number of characters : %d\n", chars);

    return 0;
}