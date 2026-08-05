%{
    #include<stdio.h>
    #include<string.h>
    int nesting=0;
    int yyerror();
    int yylex();
    char* makeExpression(char*, char*, char*);
%}

%union {
    char *word;
}
%token WORD NL
%left '+' '-'
%left '*' '/'
%type <word> expr

%%

    start
    : expr NL {printf("%s\n",$<word>1);return 0;}
    ;

    expr
    : expr '*' expr {$<word>$=makeExpression("*",$<word>1,$<word>3);}
    | expr '-' expr {$<word>$=makeExpression("-",$<word>1,$<word>3);}
    | expr '+' expr {$<word>$=makeExpression("+",$<word>1,$<word>3);}
    | expr '/' expr {$<word>$=makeExpression("/",$<word>1,$<word>3);}
    | '(' expr ')' {$<word>$=$<word>2;}
    | WORD {$<word>$=$<word>1;}
    ;

%%

char* makeExpression(char* a, char* b, char* c){
    char *new_str = (char*)malloc(strlen(a) + strlen(b) + strlen(c) + 3);
    strcpy(new_str, a);
    strcat(new_str, " ");
    strcat(new_str, b);
    strcat(new_str, " ");
    strcat(new_str, c);
    return new_str;
}

int yyerror() {
    printf("\nInvalid Input!\n");
    return 0;
}

int main() {
    printf("Enter an expression : ");
    yyparse();
    return 0;
}
