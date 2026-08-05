%option noyywrap
%{
    #include "y.tab.h"
%}

op [*+-/()]
word [a-zA-Z]+

%%

{op} {yylval.op=yytext[0];return yytext[0];}
{word} {yylval.word=strdup(yytext);return WORD;}
\n {return NL;}

%%