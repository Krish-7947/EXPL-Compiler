%{
	#include <stdlib.h>
	#include <stdio.h>
    #include <string.h>
    void yyerror(char const *s);
	#include "exprtree.h"
    #include "symboltable.h"
    #include "typecheck.h"
	#include "ast.c"
    #include "symboltable.c"
    #include "codegen.c"
    #include "initialize.c"
    #include "typecheck.c"

    int yylex(void);
    extern FILE *yyin;
    extern int lineno;
    FILE *fp;
    FILE *intermediate;
    void print(int);
    struct Paramstruct *argList1, *argList2;
    int declCount = 0, defCount = 0; // Definition and Declaration count of functions

    // For testing
    int testing = 0; // can use to test ASTree
%}

%union {
    struct ASTNode *nptr;
}

%token <nptr> START END READ WRITE PLUS MINUS MUL DIV MOD ASSGN NUM ID
%token <nptr> IF THEN ELSE ENDIF WHILE DO ENDWHILE EQ NEQ LE GE LT GT
%token <nptr> BREAK CONT DECL ENDDECL INT STR STRVAL MAIN RETURN AMP

%nonassoc LT GT LE GE
%right EQ NEQ
%left PLUS MINUS
%left MUL DIV MOD
%right ASSGN

%type <nptr> program Slist Stmt InputStmt OutputStmt AsgStmt expr id
%type <nptr> BrkStmt ContStmt IfStmt WhileStmt Type GDeclBlock FDefBlock FType
%type <nptr> MainBlock GDeclList GDecl GIdList GId ParamList FDef
%type <nptr> LDeclBlock Body Param LDecList LDecl IdList RetStmt
%type <nptr> ExprList func FName

%%

program: GDeclBlock FDefBlock MainBlock {fclose(intermediate);}
       | GDeclBlock MainBlock           {fclose(intermediate);}
       | MainBlock                      {fclose(intermediate);}
       ;

GDeclBlock: DECL GDeclList ENDDECL      {initialize();}
          | DECL ENDDECL                {initialize();}
          ;

GDeclList: GDeclList GDecl
         | GDecl
         ;

GDecl: Type GIdList ';'
     ;

Type: INT   {declarationType = TYPE_INT; retType = TYPE_INT;}
    | STR   {declarationType = TYPE_STR; retType = TYPE_STR;}
    ;

FType: INT   {FDeclarationType = TYPE_INT;}
     | STR   {FDeclarationType = TYPE_STR;}
     ;


GIdList: GIdList ',' GId
       | GId
       ;

GId: ID '(' ParamList ')'       {
                                    declCount++;
                                    checkAvailability($1->name, 1);
                                    GInstall($1->name, declarationType, -1, Phead);
                                    Phead = NULL;
                                    Ptail = NULL;
                                }
   | MUL ID '(' ParamList ')'   {
                                    declCount++;
                                    checkAvailability($2->name, 1);
                                    GInstall($2->name, ptrType(declarationType), -1, Phead);
                                    Phead = NULL;
                                    Ptail = NULL;
                                }
   | ID                         {
                                    checkAvailability($1->name, 1);
                                    GInstall($1->name, declarationType, 1, NULL);
                                }
   | MUL ID                     {
                                    checkAvailability($2->name, 1);
                                    GInstall($2->name, ptrType(declarationType), 1, NULL);
                                }
   | ID '[' NUM ']'             {
                                    checkAvailability($1->name, 1);
                                    if($3->value.intval < 1) {
                                        yyerror("Invalid array size");
                                    }
                                    GInstall($1->name, declarationType, $3->value.intval, NULL);
                                }
   ;


FDefBlock: FDefBlock FDef
         | FDef
         ;

FDef: Type FName '(' ParamList ')' '{' LDeclBlock Body '}' {
                                                            defCount++;
                                                            Gtemp = GLookup($2->name);

                                                            if(Gtemp == NULL) {
                                                                yyerror("Function not declared");
                                                            }

                                                            if(Gtemp->type != retType) {
                                                               yyerror("Function type does not match declaration");
                                                            }

                                                            argList1 = Phead;
                                                            argList2 = Gtemp->paramlist;

                                                            while(argList1 != NULL && argList2 != NULL) {
                                                                if(argList1->type != argList2->type) {
                                                                    yyerror("Conflict in argument types");
                                                                }

                                                                if(strcmp(argList1->name, argList2->name)) {
                                                                    yyerror("Conflict in argument names");
                                                                }

                                                                argList1 = argList1->next;
                                                                argList2 = argList2->next;
                                                            }

                                                            if ((argList1 != NULL) || (argList2 != NULL)) {
                                                                yyerror("Not enough arguments");
                                                            }

                                                            if(testing) {
                                                                printLSymbolTable();
                                                            } else {
                                                                fprintf(intermediate, "F%d:\n",Gtemp->flabel);
                                                                fprintf(intermediate, "PUSH BP\n");
                                                                fprintf(intermediate, "MOV BP,SP\n");

                                                                Ltemp = Lhead;
                                                                while(Ltemp != NULL) {
                                                                    if(Ltemp->binding > 0)
                                                                        fprintf(intermediate, "PUSH R0\n");
                                                                    Ltemp = Ltemp->next;
                                                                }

                                                                codegen($8);
                                                            }

                                                            Phead = NULL;
                                                            Ptail = NULL;
                                                            Lhead = NULL;
                                                            Ltail = NULL;
                                                        }
    ;

ParamList: ParamList ',' Param
         | Param
         | {$$ = NULL;}
         ;

Param: FType ID         {
                            checkAvailability($2->name, 0);
                            PInstall($2->name, FDeclarationType);
                        }
     | FType MUL ID     {
                            checkAvailability($3->name, 0);
                            PInstall($3->name, ptrType(FDeclarationType));
                        }
     ;

FName: ID       {$$ = $1;}
     | MUL ID   {retType = ptrType(declarationType); $$ = $2;}
     ;

MainBlock: Type MAIN '(' ')' '{' LDeclBlock Body '}'   {
                                                            if(defCount != declCount) {
                                                                yyerror("All functions declared need to be defined");
                                                            }

                                                            if(declarationType != TYPE_INT) {
                                                                yyerror("Main return type should be of integer type");
                                                            }

                                                            if(testing) {
                                                                printGSymbolTable();
                                                                printLSymbolTable();
                                                            } else {
                                                                fprintf(intermediate, "MAIN:\n");
                                                                fprintf(intermediate, "PUSH BP\n");
                                                                fprintf(intermediate, "MOV BP,SP\n");

                                                                Ltemp = Lhead;
                                                                while (Ltemp != NULL)
                                                                {
                                                                    fprintf(intermediate, "PUSH R0\n");
                                                                    Ltemp = Ltemp->next;
                                                                }

                                                                codegen($7);
                                                            }

                                                            Lhead = NULL;
                                                            Ltail = NULL;
                                                        }
         ;

LDeclBlock: DECL LDecList ENDDECL   {InstallParamsInLocal();}
          | DECL ENDDECL            {InstallParamsInLocal();}
          |                         {InstallParamsInLocal();}
          ;

LDecList: LDecList LDecl
        | LDecl
        ;

LDecl: FType IdList ';'
     ;

IdList: ID                  {
                                checkAvailability($1->name, 0);
                                LInstall($1->name, FDeclarationType);
                            }
      | MUL ID              {
                                checkAvailability($2->name, 0);
                                LInstall($2->name, ptrType(FDeclarationType));
                            }
      | IdList ',' ID       {
                                checkAvailability($3->name, 0);
                                LInstall($3->name, FDeclarationType);
                            }
      | IdList ',' MUL ID   {
                                checkAvailability($4->name, 0);
                                LInstall($4->name, ptrType(FDeclarationType));
                            }
      ;

Body: START Slist RetStmt END   {$$ = TreeCreate(TYPE_VOID, NODE_CONNECTOR, NULL, NULL, NULL, $2, $3, NULL);}
    | START RetStmt END         {$$ = $2;}
    ;

RetStmt: RETURN expr ';'    {
                                if(retType == $2->type) {
                                    $$ = TreeCreate(TYPE_VOID, NODE_RET, NULL, NULL, NULL, $2, NULL, NULL);
                                } else {
                                    yyerror("Return type mismatch");
                                }
                            }
       ;

Slist: Slist Stmt       {$$ = TreeCreate(TYPE_VOID, NODE_CONNECTOR, NULL, NULL, NULL, $1, $2, NULL);}
    | Stmt              {$$ = $1;}
    ;

Stmt: InputStmt         {$$ = $1;}
    | OutputStmt        {$$ = $1;}
    | AsgStmt           {$$ = $1;}
    | IfStmt            {$$ = $1;}
    | WhileStmt         {$$ = $1;}
    | BrkStmt           {$$ = $1;}
    | ContStmt          {$$ = $1;}
    | func ';'          {$$ = TreeCreate(TYPE_VOID, NODE_EXPRSTMT, NULL, NULL, NULL, $1, NULL, NULL);}
    ;

IfStmt: IF '(' expr ')' THEN Slist ELSE Slist ENDIF ';'     {
                                                                typecheck($3->type, TYPE_BOOL, 'e');
                                                                $$ = TreeCreate(TYPE_VOID, NODE_IF_ELSE, NULL, NULL, NULL, $3, $8, $6);
                                                            }
      | IF '(' expr ')' THEN Slist ENDIF ';'                {
                                                                typecheck($3->type, TYPE_BOOL, 'i');
                                                                $$ = TreeCreate(TYPE_VOID, NODE_IF, NULL, NULL, NULL, $3, $6, NULL);
                                                            }
      ;

WhileStmt: WHILE '(' expr ')' DO Slist ENDWHILE ';'         {
                                                                typecheck($3->type, TYPE_BOOL, 'w');
                                                                $$ = TreeCreate(TYPE_VOID, NODE_WHILE, NULL, NULL, NULL, $3, $6, NULL);
                                                            }
         ;
BrkStmt: BREAK ';'                  {$$ = TreeCreate(TYPE_VOID, NODE_BREAK, NULL, NULL, NULL, NULL, NULL, NULL);}
       ;

ContStmt: CONT ';'                  {$$ = TreeCreate(TYPE_VOID, NODE_CONT, NULL, NULL, NULL, NULL, NULL, NULL);}
        ;

InputStmt: READ '(' id ')' ';'      {$$ = TreeCreate(TYPE_VOID, NODE_READ, NULL, NULL, NULL, $3, NULL, NULL);}
         ;

OutputStmt: WRITE '(' expr ')' ';'  {$$ = TreeCreate(TYPE_VOID, NODE_WRITE, NULL, NULL, NULL, $3, NULL, NULL);}
          ;

AsgStmt: id ASSGN expr ';'          {
                                        typecheck($1->type, $3->type, '=');
                                        $$ = TreeCreate(TYPE_VOID, NODE_ASSGN, NULL, NULL, NULL, $1, $3, NULL);
                                    }
       ;

ExprList: ExprList ',' expr {
                                $3->arglist = $1;
                                $$ = $3;
                            }
        | expr              {$$ = $1;}
        |                   {$$ = NULL;}
        ;

expr : expr PLUS expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = TreeCreate(TYPE_INT, NODE_PLUS, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr MINUS expr  {
                            typecheck($1->type, $3->type, 'a');
                            $$ = TreeCreate(TYPE_INT, NODE_MINUS, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr MUL expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = TreeCreate(TYPE_INT, NODE_MUL, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr DIV expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = TreeCreate(TYPE_INT, NODE_DIV, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr MOD expr	{
                            typecheck($1->type, $3->type, 'a');
                            $$ = TreeCreate(TYPE_INT, NODE_MOD, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr LT expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TYPE_BOOL, NODE_LT, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr GT expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TYPE_BOOL, NODE_GT, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr LE expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TYPE_BOOL, NODE_LE, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr GE expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TYPE_BOOL, NODE_GE, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr NEQ expr    {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TYPE_BOOL, NODE_NEQ, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | expr EQ expr     {
                            typecheck($1->type, $3->type, 'b');
                            $$ = TreeCreate(TYPE_BOOL, NODE_EQ, NULL, NULL, NULL, $1, $3, NULL);
                        }
     | '(' expr ')'	{$$ = $2;}
     | NUM		{$$ = $1;}
     | MINUS NUM        {
                            $2->value.intval = -1*($2->value.intval);
                            $$ = $2;
                        }
     | STRVAL           {$$ = $1;}
     | id		    {$$ = $1;}
     | func             {$$ = $1;}
     | AMP id           {
                            if($2->nodetype != NODE_ID && $2->nodetype != NODE_ARRAY) {
                                yyerror("Cannot take address of this expression");
                            }
                            $$ = TreeCreate(ptrType($2->type), NODE_ADDR, NULL, NULL, NULL, $2, NULL, NULL);
                        }
     ;

func: ID '(' ExprList ')'   {
                                assignType($1, 1);
                                $1->nodetype = NODE_FUNC;
                                $1->ptr1 = reverseList($3);
                                checkArguments($1->Gentry->paramlist, $1->ptr1);
                                $$ = $1;
                            }
    ;

id: ID                  {
                            assignType($1, 0);
                            $$ = $1;
                        }
  | MUL ID              {
                            assignType($2, 0);
                            $$ = TreeCreate(derefType($2->type), NODE_DEREF, NULL, NULL, NULL, $2, NULL, NULL);
                        }
  | ID '[' NUM ']'      {
                            assignType($1, 2);
                            $$ = TreeCreate($1->type, NODE_ARRAY, NULL, NULL, NULL, $1, $3, NULL);
                        }
  | ID '[' id ']'       {
                            assignType($1, 2);
                            $$ = TreeCreate($1->type, NODE_ARRAY, NULL, NULL, NULL, $1, $3, NULL);
                        }
  ;

%%

void yyerror(char const *s) {
    printf("Error : %s at line %d\n", s, lineno);
    exit(1);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        yyerror("Please provide an input filename");
        exit(1);
    } else {
        fp = fopen(argv[1], "r");
        if (!fp) {
            yyerror("Invalid input file specified");
            exit(1);
        } else {
            yyin = fp;
        }
    }
    yyparse();
    return 0;
}

