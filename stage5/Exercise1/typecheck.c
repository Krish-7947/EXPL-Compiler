int checkAvailability(char *name, int global)
{
    if (global)
    {
        Gtemp = GLookup(name);
        if (Gtemp != NULL)
        {
            yyerror("Re-initialization of variable/function");
        }
    }
    else
    {
        Ltemp = LLookup(name);
        Ptemp = PLookup(name);
        if (Ptemp != NULL || Ltemp != NULL)
        {
            yyerror("Re-initialization of variable");
        }
    }

    return 1;
}

void assignType(struct ASTNode* node, int code) {
    // Code 0 - Local or Global Variable
    // Code 1 - Function
    // Code 2 - Array

    Ltemp = LLookup(node->name);
    if(Ltemp != NULL && code == 0) {
        node->Lentry = Ltemp;
        node->type = Ltemp->type;
    } else {
        Gtemp = GLookup(node->name);
        if(Gtemp != NULL) {
            node->Gentry = Gtemp;
            node->type = Gtemp->type;

            if(code == 1 && Gtemp->size != -1) {
                yyerror("conflict in ID NodeType : Expected Function");
            }
            if(code == 0 && Gtemp->size == -1) {
                yyerror("Function used as a variable");
            }
        } else {
            if(code == 1)
                yyerror("Function not declared!");
            else
                yyerror("Variable not declared!");
        }
    }

    return;
}

void typecheck(int t1, int t2, char c)
{
    switch (c)
    {
    case 'w':
        if (t1 != t2)
        {
            yyerror("Expected Boolean in WHILE check");
        }
        break;
    case 'e':
        if (t1 != t2)
        {
            yyerror("Expected Boolean in IF ELSE check");
        }
        break;
    case 'i':
        if (t1 != t2)
        {
            yyerror("Expected Boolean in IF check");
        }
        break;
    case 'a':
        if (t1 != TYPE_INT || t2 != TYPE_INT)
        {
            yyerror("Invalid type for arithmetic operation");
        }
        break;
    case 'b':
        if (t1 != TYPE_INT || t2 != TYPE_INT)
        {
            yyerror("Invalid type for comparing (<, >, <=..) operation");
        }
        break;
    case '=':
        if (t1 != t2)
        {
            yyerror("Invalid type for assignment operation");
        }
        break;
    }
}

int ptrType(int t) {
    if(t == TYPE_INT) return TYPE_INTPTR;
    if(t == TYPE_STR) return TYPE_STRPTR;
    yyerror("Invalid base type for pointer");
    return -1;
}

int derefType(int t) {
    if(t == TYPE_INTPTR) return TYPE_INT;
    if(t == TYPE_STRPTR) return TYPE_STR;
    yyerror("Dereferencing a non-pointer variable");
    return -1;
}

/* p: formal parameters from the declaration, a: actual arguments (in call order) */
void checkArguments(struct Paramstruct *p, struct ASTNode *a) {
    while(p != NULL && a != NULL) {
        if(p->type != a->type) {
            yyerror("Argument type mismatch in function call");
        }
        p = p->next;
        a = a->arglist;
    }
    if(p != NULL || a != NULL) {
        yyerror("Wrong number of arguments in function call");
    }
}