%{
    #include<stdio.h>
    int nesting=0;
    int yyerror();
    int yylex();
%}

%union {
    char op;
    char *word;
}
%token WORD NL
%left '+' '-'
%left '*' '/'
%type <word> expr

%%

start: expr NL {printf("\n");return 0;}
     ;

expr: expr '*' expr {printf("%c ", $<op>2);}
    | expr '-' expr {printf("%c ", $<op>2);}
    | expr '+' expr {printf("%c ", $<op>2);}
    | expr '/' expr {printf("%c ", $<op>2);}
    | '(' expr ')' {}
    | WORD {$<word>$=$<word>1;printf("%s ", $<word>1);}
    ;

%%

int yyerror() {
    printf("\nInvalid Input!\n");
    return 0;
}

int main() {
    printf("Enter an expression : ");
    yyparse();
    return 0;
}
