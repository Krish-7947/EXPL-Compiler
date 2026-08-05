%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

int yylex();
void yyerror(const char *s);
%}

%token LETTER DIGIT

%%

program
    : variable
    ;

variable
    : LETTER rest
    ;

rest
    : rest LETTER
    | rest DIGIT
    |
    ;

%%

int yylex()
{
    int c = getchar();

    if(c == EOF || c == '\n' || c == ' ' || c == '\t')
        return 0;

    if(isalpha(c))
        return LETTER;

    if(isdigit(c))
        return DIGIT;

    return c;
}

void yyerror(const char *s)
{
    printf("Invalid Variable\n");
}

int main(int argc, char *argv[])
{
    printf("Enter a variable name : ");

    if(yyparse() == 0)
        printf("Valid Variable\n");

    return 0;
}