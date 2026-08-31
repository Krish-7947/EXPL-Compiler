%{
	#include <stdlib.h>
	#include <stdio.h>
    #include <string.h>
	#include "exprtree.h"
	#include "exprtree.c"
    void yyerror(char const *s);
    #include "symbolTable.h"
    #include "symbolTable.c"
    #include "typecheck.c"
	int yylex(void);
    extern FILE *yyin;
    FILE *fp;
    FILE *intermediate;
%}

%union {
    struct tnode *node;
}

%token <node> START END READ WRITE PLUS MINUS MUL DIV MOD ASSGN NUM ID
%token <node> IF THEN ELSE ENDIF WHILE DO ENDWHILE EQ NEQ LE GE LT GT
%token <node> BREAK CONT DECL ENDDECL INT STR STRVAL

%nonassoc LT GT LE GE
%right EQ NEQ
%left PLUS MINUS
%left MUL DIV MOD
%right ASSGN

%type <node> program Slist Stmt InputStmt OutputStmt AsgStmt expr id
%type <node> BrkStmt ContStmt IfStmt WhileStmt Declarations DeclList
%type <node> Type Decl VarList 

%%

program: Declarations START Slist END   {
                                                $$ = $3;
                                                printSymbolTable();
                                            }
       | Declarations START END         {$$ = $2;}
       ;

Slist: Slist Stmt       {$$ = createTree(TYPE_VOID, 0, NODE_CONNECTOR, NULL, $1, $2, NULL);}
    | Stmt              {$$ = $1;}
    ;

Stmt: InputStmt         {$$ = $1;}
    | OutputStmt        {$$ = $1;}
    | AsgStmt           {$$ = $1;}
    | IfStmt            {$$ = $1;}
    | WhileStmt         {$$ = $1;}
    | BrkStmt           {$$ = $1;}
    | ContStmt          {$$ = $1;}
    ;

Declarations: DECL DeclList ENDDECL
            | DECL ENDDECL
            ;

DeclList: DeclList Decl
        | Decl
        ;

Decl: Type VarList ';'
    ;

Type: INT   {declaration_type = TYPE_INT;}
    | STR   {declaration_type = TYPE_STR;}
    ;

VarList: VarList ',' ID     {GInstall($3->varname, declaration_type, 1);}
       | ID                 {GInstall($1->varname, declaration_type, 1);}
       ;

IfStmt: IF '(' expr ')' THEN Slist ELSE Slist ENDIF ';'     {
                                                                typecheck($3->type, TYPE_BOOL, 'e');
                                                                $$ = createTree(TYPE_VOID, 0, NODE_IF_ELSE, NULL, $3, $8, $6);
                                                            }
      | IF '(' expr ')' THEN Slist ENDIF ';'                {
                                                                typecheck($3->type, TYPE_BOOL, 'i');
                                                                $$ = createTree(TYPE_VOID, 0, NODE_IF, NULL, $3, $6, NULL);
                                                            }
      ;

WhileStmt: WHILE '(' expr ')' DO Slist ENDWHILE ';'         {
                                                                typecheck($3->type, TYPE_BOOL, 'w');
                                                                $$ = createTree(TYPE_VOID, 0, NODE_WHILE, NULL, $3, $6, NULL);
                                                            }
         ;
BrkStmt: BREAK ';'                  {$$ = createTree(TYPE_VOID, 0, NODE_BREAK, NULL, NULL, NULL, NULL);}
       ;

ContStmt: CONT ';'                  {$$ = createTree(TYPE_VOID, 0, NODE_CONT, NULL, NULL, NULL, NULL);}
        ;

InputStmt: READ '(' id ')' ';'      {$$ = createTree(TYPE_VOID, 0, NODE_READ, NULL, $3, NULL, NULL);}
         ;

OutputStmt: WRITE '(' expr ')' ';'  {$$ = createTree(TYPE_VOID, 0, NODE_WRITE, NULL, $3, NULL, NULL);}
          ;

AsgStmt: id ASSGN expr ';'          {
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
     | expr MOD expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = createTree(TYPE_INT, 0, NODE_MOD, NULL, $1, $3, NULL);
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
     | STRVAL           {$$ = $1;}
     | id		{$$ = $1;}
     ;

id: ID                  {
                            $1->Gentry = GLookup($1->varname);
                            if($1->Gentry == NULL) {
                                printf("Variable '%s' not declared!", $1->varname);
                                exit(1);
                            }
                            $1->type = $1->Gentry->type;
                            $$ = $1;
                        }
  ;

%%

void yyerror(char const *s) {
    printf("Error : %s\n",s);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Please provide an input filename\n");
        exit(1);
    } else {
        fp = fopen(argv[1], "r");
        if (!fp) {
            printf("Invalid input file\n");
            exit(1);
        } else {
            yyin = fp;
        }
    }
    yyparse();
    return 0;
}