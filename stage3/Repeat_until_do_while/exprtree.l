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
	    yylval.node = createTree(TYPE_INT,number,NODE_NUM,NULL,NULL,NULL,NULL);
	    return NUM;
	    }

"begin"     {return START;}
"end"       {return END;}
"read"      {return READ;}
"write"     {return WRITE;}
"if"        {return IF;}
"then"      {return THEN;}
"else"      {return ELSE;}
"endif"     {return ENDIF;}
"while"     {return WHILE;}
"do"        {return DO;}
"endwhile"  {return ENDWHILE;}
"break"     {return BREAK;}
"continue"  {return CONT;}
"repeat"    {return REPEAT;}
"until"     {return UNTIL;}
"=="        {return EQ;}
"!="        {return NEQ;}
"<="        {return LE;}
">="        {return GE;}
"<"         {return LT;}
">"         {return GT;}
"+"         {return PLUS;}
"-"         {return MINUS;}
"*"         {return MUL;}
"/"         {return DIV;}
"="         {return ASSGN;}

[a-z]   {
            variable = (char*)malloc(sizeof(yytext));
            strcpy(variable,yytext);
            yylval.node = createTree(TYPE_INT,0,NODE_ID,variable,NULL,NULL,NULL);
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
