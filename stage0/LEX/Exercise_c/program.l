%option noyywrap

%{
    #include <stdio.h>
    int ans = 0;    
%}

correctWord A[a-zA-Z][a-zA-Z]

%%
{correctWord} {printf("%s\n",yytext);}
[a-zA-Z]+ {}
.|\n|\t|" " {}

%%

int main(int argc, char *argv[])
{
    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if (fp)
            yyin = fp;
    }

    yylex();

    return 0;
}