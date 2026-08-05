%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int level = 0, maxLevel = 0;
FILE *fp;

int yylex();
void yyerror(const char *s);
%}

%token IF ID

%%

program
    : stmts
    ;

stmt
    : IF
      {
          level++;
          if(level > maxLevel)
              maxLevel = level;
          printf("Entered IF -> Level %d\n", level);
      }
      '(' ID ')' block
      {
          printf("Exited IF -> Level %d\n", level);
          level--;
      }
    | ID ';'
    ;

block
    : '{' stmts '}'
    | stmt
    ;

stmts
    : stmts stmt
    | stmt
    |
    ;

%%

int yylex()
{
    char str[100];

    if(fscanf(fp, "%s", str) != 1)
        return 0;

    if(strcmp(str, "if") == 0)
        return IF;

    if(strcmp(str, "(") == 0) return '(';
    if(strcmp(str, ")") == 0) return ')';
    if(strcmp(str, "{") == 0) return '{';
    if(strcmp(str, "}") == 0) return '}';
    if(strcmp(str, ";") == 0) return ';';

    return ID;
}

void yyerror(const char *s)
{
    printf("Syntax Error\n");
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

    yyparse();

    printf("Maximum Nesting Level = %d\n", maxLevel);

    fclose(fp);
    return 0;
}