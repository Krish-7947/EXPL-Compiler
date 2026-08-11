%{
	#include <stdlib.h>
	#include <stdio.h>
    #include <string.h>
	#include "y.tab.h"
	#include "exprtree.h"
	void yyerror(const char *);
	int number;
    char *variable;
%}

%%

[0-9]+  {
	    number=atoi(yytext);
	    yylval.node = createTree(0,number,NODE_NUM,NULL,NULL,NULL);
	    return NUM;
	    }

"begin" {return START;}
"end"   {return END;}
"read"  {return READ;}
"write" {return WRITE;}
"+"     {return PLUS;}
"-"     {return MINUS;}
"*"     {return MUL;}
"/"     {return DIV;}
"="     {return ASSGN;}

[a-z]   {
            variable = (char*)malloc(sizeof(yytext));
            strcpy(variable,yytext);
            yylval.node = createTree(1,0,NODE_ID,variable,NULL,NULL);
            return ID;
        }

[ \n\t] {}
[();]   {return *yytext;}

.       {
            yyerror("Unknown character\n");
            exit(1);
        }

%%

int yywrap(void)
{
	return 1;
}
