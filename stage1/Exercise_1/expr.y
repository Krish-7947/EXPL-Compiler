%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "exprtree.h"
    #include "exprtree.c"

    int yylex(void);
    extern FILE *yyin;
    void yyerror(char const *s);
    FILE* fp;
%}

%union {
    struct tnode *no;
}

%token <no> NUM
%type <no> expr program

%left '+' '-'
%left '*' '/'

%%

program : expr '\n' {
            printf("\n--- Tree Created Successfully ---\n");
            printf("Prefix : ");
            prefix($1);
            printf("\nPostfix: ");
            postfix($1);
            printf("\n");
            exit(0);
        }
        ;

expr : expr '+' expr    { $$ = makeOperatorNode('+', $1, $3); }
     | expr '-' expr    { $$ = makeOperatorNode('-', $1, $3); }
     | expr '*' expr    { $$ = makeOperatorNode('*', $1, $3); }
     | expr '/' expr    { $$ = makeOperatorNode('/', $1, $3); }
     | '(' expr ')'     { $$ = $2; }
     | NUM              { $$ = $1; }
     ;

%%

void yyerror(char const *s) {
    printf("yyerror: %s\n", s);
}

int main(int argc, char *argv[])
{
    if(argc != 2)
    {
        printf("Invalid!!\n", argv[0]);
        return 1;
    }

    fp = fopen(argv[1], "r");

    if(fp == NULL)
    {
        printf("Cannot open file %s\n", argv[1]);
        return 1;
    }
    yyin = fp;

    yyparse();

    fclose(fp);
    return 0;
}