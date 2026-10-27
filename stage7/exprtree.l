%{
	#include <stdlib.h>
	#include <stdio.h>
    #include <string.h>
    void yyerror(char const *s);
	#include "y.tab.h"
	#include "exprtree.h"
    #include "data_structures/typetable.h"

	int number, lineno = 1;
    struct Typetable* temp;
    char *variable;
%}

id [a-zA-Z_][0-9a-zA-Z_]*
str \"(\\.|[^\\\"])*\"

%%

[0-9]+	    {
                number = atoi(yytext);
                union Constant *value = (union Constant*)malloc(sizeof(union Constant));
                value->intval = number;
                yylval.nptr = TreeCreate(TLookup("integer"), NODE_NUM, NULL, value, NULL, NULL, NULL, NULL);
                return NUM;
            }
"main"      {return MAIN;}
"return"    {return RETURN;}
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
"decl"      {return DECL;}
"enddecl"   {return ENDDECL;}
"type"      {return TYPE;}
"endtype"   {return ENDTYPE;}
"class"     {return CLASS;}
"endclass"  {return ENDCLASS;}
"breakpoint"    {
                    yylval.nptr = TreeCreate(TLookup("integer"), NODE_BRKPT, NULL, NULL, NULL, NULL, NULL, NULL);
                    return BREAKPOINT;
                }
"NULL"          {
                    yylval.nptr = TreeCreate(TLookup("integer"), NODE_NULL, NULL, NULL, NULL, NULL, NULL, NULL);
                    return NILL;
                }
"=="[ ]*"NULL" 	{
                    yylval.nptr = TreeCreate(TLookup("integer"), NODE_NULL, NULL, NULL, NULL, NULL, NULL, NULL);
                    return DEQNILL;
		}
"!="[ ]*"NULL" 	{
                    yylval.nptr = TreeCreate(TLookup("integer"), NODE_NULL, NULL, NULL, NULL, NULL, NULL, NULL);
                    return NEQNILL;
		}
"free"          {return FREE;}
"initialize"    {return INIT;}
"delete"    {return DELETE;}
"self"      {
                yylval.nptr = TreeCreate(NULL, NODE_SELF, NULL, NULL, NULL, NULL, NULL, NULL);
                return SELF;
            }
"new"       {
                yylval.nptr = TreeCreate(TLookup("integer"), NODE_NEW, NULL, NULL, NULL, NULL, NULL, NULL);
                return NEW;
            }
"alloc"     {
                yylval.nptr = TreeCreate(TLookup("integer"), NODE_ALLOC, NULL, NULL, NULL, NULL, NULL, NULL);
                return ALLOC;
            }
"int"       {return INT;}
"str"       {return STR;}
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
"%"         {return MOD;}
"="         {return ASSGN;}
{id}        {
                variable = strdup(yytext);
                yylval.nptr = TreeCreate(TLookup("integer"), NODE_ID, variable, NULL, NULL, NULL, NULL, NULL);
                return ID;
            }
{str}       {
                variable = strdup(yytext);
                union Constant *value = (union Constant*)malloc(sizeof(union Constant));
                value->strval = variable;
                yylval.nptr = TreeCreate(TLookup("string"), NODE_STRVAL, NULL, value, NULL, NULL, NULL, NULL);
                return STRVAL;
            }
[ \t]	    {}
\n          {lineno++;}
[{}()\[\];,.]  {return *yytext;}
.	    {
                yyerror("unknown character\n");
                exit(1);
            }

%%

int yywrap(void) {
    return 1;
}
