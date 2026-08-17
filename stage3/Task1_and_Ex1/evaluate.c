int counter = -1, i, j, label = 0;
int whileStart = -1, whileEnd = -1;

int r1,r2,e;
int memory[26];

int evaluate(struct tnode *t)
{
    int r1, r2, r3, l1, l2, number, status = 0;
    int prevWhileStart, prevWhileEnd;

    if (t == NULL)
    {
        return -1;
    }
    else if (t->nodetype == NODE_CONNECTOR)
    {
        evaluate(t->left);
        evaluate(t->right);
        return -1;
    }

    switch (t->nodetype)
    {
    case NODE_NUM:
        return t->val;
    case NODE_ID:
        number = t->varname[0] - 'a';
        return memory[number];
    case NODE_PLUS:
        r1 = evaluate(t->left);
        r2 = evaluate(t->right);
        return r1 + r2;
    case NODE_MINUS:
        r1 = evaluate(t->left);
        r2 = evaluate(t->right);
        return r1 - r2;
    case NODE_MUL:
        r1 = evaluate(t->left);
        r2 = evaluate(t->right);
        return r1 * r2;
    case NODE_DIV:
        r1 = evaluate(t->left);
        r2 = evaluate(t->right);
        return r1 / r2;
    case NODE_LT:
        r1 = evaluate(t->left);
        r2 = evaluate(t->right);
        return r1 < r2;
    case NODE_GT:
        r1 = evaluate(t->left);
        r2 = evaluate(t->right);
        return r1 > r2;
    case NODE_LE:
        r1 = evaluate(t->left);
        r2 = evaluate(t->right);
        return r1 <= r2;
    case NODE_GE:
        r1 = evaluate(t->left);
        r2 = evaluate(t->right);
        return r1 >= r2;
    case NODE_EQ:
        r1 = evaluate(t->left);
        r2 = evaluate(t->right);
        return r1 == r2;
    case NODE_NEQ:
        r1 = evaluate(t->left);
        r2 = evaluate(t->right);
        return r1 != r2;
    case NODE_ASSGN:
        number = t->left->varname[0] - 'a';
        e = evaluate(t->right);
        memory[number] = e;
        return 0;
    case NODE_WRITE:
        e = evaluate(t->left);
        printf("%d\n", e);
        return 0;
        break;
    case NODE_READ:
        number = t->left->varname[0] - 'a';
        printf("Enter the value of %c : ", t->left->varname[0]);
        scanf("%d", &memory[number]);
        return 0;
        break;
    case NODE_IF:
        if(evaluate(t->left)){
            evaluate(t->right);
            return 0;
        }
        return 0;
        break;
    case NODE_IF_ELSE:
        if(evaluate(t->left))
        {
            evaluate(t->middle);
        }
        else
        {
            evaluate(t->right);
        }
        return 0;
        break;
    case NODE_WHILE:
        while(evaluate(t->left))
        {
            evaluate(t->right);
        }
        return 0;
        break;
    }
}