%option noyywrap

%{
    #include <stdio.h>
%}
%%

\/\/[^\n]* {printf("Single line:\n%s\n",yytext);}
\/\*[^*]*\*\/ {printf("Multi line:\n%s\n",yytext);}
.|\n {}

%%

int main(int argc, char *argv[])
{
    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if (fp)
            yyin = fp;
    }

    yylex();

    return 0;
}