int count = -1;
extern FILE *intermediate;

int getReg()
{
    if (count < 20)
    {
        count++;
        return count;
    }
    printf("Out of registers/n");
    exit(1);
}

void freeReg()
{
    if (count >= 0)
    {
        count--;
    }
}

int codeGen(struct tnode *t)
{
    int r1, r2, r3, number, status = 0;

    if (t == NULL){
        return -1;
    }
    else if(t->nodetype == NODE_CONNECTOR){
        codeGen(t->left);
        codeGen(t->right);
    }

    switch(t->nodetype){
        case NODE_NUM:
            r1 = getReg();
            fprintf(intermediate,"MOV R%d, %d\n",r1,t->val);
            return r1;
        case NODE_ID:
            r1 = getReg();
            number = 4096 + t->varname[0] - 'a';
            fprintf(intermediate, "MOV R%d, [%d]\n",r1,number);
            return r1;

        case NODE_PLUS:
            r1 = codeGen(t->left);
            r2 = codeGen(t->right);
            fprintf(intermediate, "ADD R%d, R%d\n",r1,r2);
            freeReg();
            return r1;
        case NODE_MINUS:
            r1 = codeGen(t->left);
            r2 = codeGen(t->right);
            fprintf(intermediate, "SUB R%d, R%d\n",r1,r2);
            freeReg();
            return r1;
        case NODE_MUL:
            r1 = codeGen(t->left);
            r2 = codeGen(t->right);
            fprintf(intermediate, "MUL R%d, R%d\n",r1,r2);
            freeReg();
            return r1;
        case NODE_DIV:
            r1 = codeGen(t->left);
            r2 = codeGen(t->right);
            fprintf(intermediate, "DIV R%d, R%d\n",r1,r2);
            freeReg();
            return r1;
        
        case NODE_ASSGN:
            number = 4096 + t->left->varname[0] - 'a';
            r2 = codeGen(t->right);
            fprintf(intermediate,"MOV [%d], R%d\n",number,r2);
            freeReg();
            return 0;
        
        case NODE_WRITE:
            for (int i = 0; i <= count; i++)
                fprintf(intermediate, "PUSH R%d\n", i);
            status = count;

            fprintf(intermediate, "MOV R0,\"Write\"\n");
            fprintf(intermediate, "PUSH R0\n");
            fprintf(intermediate, "MOV R0,-2\n");
            fprintf(intermediate, "PUSH R0\n");

            r1 = codeGen(t->left);
            fprintf(intermediate, "PUSH R%d\n", r1);
            freeReg();
            fprintf(intermediate, "ADD SP,2\n");
            fprintf(intermediate, "CALL 0\n");
            fprintf(intermediate, "SUB SP,5\n");

            for (int i = status; i >= 0; i--)
                fprintf(intermediate, "POP R%d\n", i);
            count = status;
            break;

        case NODE_READ:
            number = 4096 + t->left->varname[0] - 'a';
            for (int i = 0; i <= count; i++)
                fprintf(intermediate, "PUSH R%d\n", i);
            status = count;

            fprintf(intermediate, "MOV R0,\"Read\"\n");
            fprintf(intermediate, "PUSH R0\n"); 
            fprintf(intermediate, "MOV R0,-1\n");
            fprintf(intermediate, "PUSH R0\n");
            fprintf(intermediate, "MOV R0,%d\n", number);
            fprintf(intermediate, "PUSH R0\n");
            fprintf(intermediate, "ADD SP,2\n");
            fprintf(intermediate, "CALL 0\n");
            fprintf(intermediate, "SUB SP,5\n");

            for (int i = status; i >= 0; i--)
                fprintf(intermediate, "POP R%d\n", i);
            count = status;
            break;
    }
}
