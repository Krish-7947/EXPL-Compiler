%option noyywrap

%{
    #include <stdio.h>
    int ints = 0;
    int floats = 0;
%}

num [0-9]+
fnum [0-9]+"."[0-9]+

%%
{num} {
        ints++;
    }
{fnum} {
        floats++;
    }
[ \t\n]+ {}

%%

int main(int argc, char *argv[])
{
    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if (fp)
            yyin = fp;
    }

    yylex();

    printf("Number of integers: %d\n", ints);
    printf("Number of floats %d\n", floats);

    return 0;
}