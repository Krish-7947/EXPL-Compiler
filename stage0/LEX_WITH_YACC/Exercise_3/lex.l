%option noyywrap
%{
    #include "y.tab.h"
%}

op [*+-/()]
word [a-zA-Z]+

%%

{op} {return yytext[0];}
{word} {yylval.word=strdup(yytext);return WORD;}
\n {return NL;}

%%