%{
	#include <stdlib.h>
	#include <stdio.h>
    #include <string.h>
	int yylex(void);
	extern FILE *yyin;
	FILE *fp;
	FILE *intermediate;
	void exitStatementPrint();
	void yyerror(const char *);
	#include "exprtree.h"
    #include "codegen.c"
	#include "exprtree.c"
    #include "typecheck.c"
    #include "initialize.c"
%}

%union
{
	struct tnode *node;
}
%token <node> START END READ WRITE PLUS MINUS MUL DIV ASSGN NUM ID
%token <node> IF THEN ELSE ENDIF WHILE DO ENDWHILE EQ NEQ LE GE LT GT
%left PLUS MINUS
%left MUL DIV
%right ASSGN
%nonassoc LT GT LE GE
%right EQ NEQ

%type <node> program Slist Stmt InputStmt OutputStmt AsgStmt expr IfStmt WhileStmt

%%

program: START Slist END ';'    {
                                    $$ = $2;
                                    initialize();
                                    codegen($2);
                                    exitStatementPrint();
                                }
       | START END ';'          {$$ = NULL;}
       ;

Slist: Slist Stmt       {$$ = createTree(TYPE_VOID, 0, NODE_CONNECTOR, NULL, $1, $2, NULL);}
    | Stmt              {$$ = $1;}
    ;

Stmt: InputStmt         {$$ = $1;}
    | OutputStmt        {$$ = $1;}
    | AsgStmt           {$$ = $1;}
    | IfStmt            {$$ = $1;}
    | WhileStmt         {$$ = $1;}
    ;

IfStmt: IF '(' expr ')' THEN Slist ELSE Slist ENDIF ';'     {
                                                                typecheck($3->type, TYPE_BOOL, 'e');
                                                                $$ = createTree(TYPE_VOID, 0, NODE_IF_ELSE, NULL, $3, $8, $6);
                                                            }
      | IF '(' expr ')' THEN Slist ENDIF ';'                {
                                                                typecheck($3->type, TYPE_BOOL, 'i');
                                                                $$ = createTree(TYPE_VOID, 0, NODE_IF, NULL, $3, $6, NULL);
                                                            }

WhileStmt: WHILE '(' expr ')' DO Slist ENDWHILE ';'         {
                                                                typecheck($3->type, TYPE_BOOL, 'w');
                                                                $$ = createTree(TYPE_VOID, 0, NODE_WHILE, NULL, $3, $6, NULL);
                                                            }

InputStmt: READ '(' ID ')' ';'      {$$ = createTree(TYPE_VOID, 0, NODE_READ, NULL, $3, NULL, NULL);}
         ;

OutputStmt: WRITE '(' expr ')' ';'  {$$ = createTree(TYPE_VOID, 0, NODE_WRITE, NULL, $3, NULL, NULL);}
          ;

AsgStmt: ID ASSGN expr ';'          {
                                        typecheck($1->type, $3->type, '=');
                                        $$ = createTree(TYPE_VOID, 0, NODE_ASSGN, NULL, $1, $3, NULL);
                                    }
       ;

expr : expr PLUS expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = createTree(TYPE_INT, 0, NODE_PLUS, NULL, $1, $3, NULL);
                        }
     | expr MINUS expr  {
                            typecheck($1->type, $3->type, 'a');
                            $$ = createTree(TYPE_INT, 0, NODE_MINUS, NULL, $1, $3, NULL);
                        }
     | expr MUL expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = createTree(TYPE_INT, 0, NODE_MUL, NULL, $1, $3, NULL);
                        }
     | expr DIV expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = createTree(TYPE_INT, 0, NODE_DIV, NULL, $1, $3, NULL);
                        }
     | expr LT expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = createTree(TYPE_BOOL, 0, NODE_LT, NULL, $1, $3, NULL);
                        }
     | expr GT expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = createTree(TYPE_BOOL, 0, NODE_GT, NULL, $1, $3, NULL);
                        }
     | expr LE expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = createTree(TYPE_BOOL, 0, NODE_LE, NULL, $1, $3, NULL);
                        }
     | expr GE expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = createTree(TYPE_BOOL, 0, NODE_GE, NULL, $1, $3, NULL);
                        }
     | expr NEQ expr    {
                            typecheck($1->type, $3->type, 'b');
                            $$ = createTree(TYPE_BOOL, 0, NODE_NEQ, NULL, $1, $3, NULL);
                        }
     | expr EQ expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = createTree(TYPE_BOOL, 0, NODE_EQ, NULL, $1, $3, NULL);
                        }
     | '(' expr ')'	{$$ = $2;}
     | NUM		{$$ = $1;}
     | ID		{$$ = $1;}
     ;


%%

void exitStatementPrint(){
    fprintf(intermediate, "MOV R2, \"Exit\"\n");
	fprintf(intermediate, "PUSH R2\n");
	fprintf(intermediate, "PUSH R2\n");
	fprintf(intermediate, "PUSH R2\n");
	fprintf(intermediate, "PUSH R2\n");
	fprintf(intermediate, "PUSH R2\n");
	fprintf(intermediate, "CALL 0\n");
}

void yyerror(char const *s)
{
	printf("Error : %s\n",s);
    exit(1);
}

int main(int argc,char *argv[])
{
	if(argc<2)
	{
		printf("You must give input filename as argument.\n");
		exit(1);
	}
	else
	{
		fp = fopen(argv[1],"r");
        if(!fp) {
            printf("Invalid input file\n");
            exit(1);
        }
        else {
            yyin = fp;
        }
	}
	yyparse();
    fclose(fp);
    fclose(intermediate);
	return 0;
}
