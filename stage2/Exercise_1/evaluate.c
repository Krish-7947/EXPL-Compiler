int e, e1, e2;

int memory[26];

int evaluate(struct tnode *t)
{
    int number;
    if (t == NULL)
    {
        return 0;
    }
    else if (t->nodetype == NODE_CONNECTOR)
    {
        evaluate(t->left);
        evaluate(t->right);
        return 0;
    }

    switch (t->nodetype)
    {
    case NODE_NUM:
        return t->val;
    case NODE_ID:
        number = t->varname[0] - 'a';
        return memory[number];

    case NODE_PLUS:
        e1 = evaluate(t->left);
        e2 = evaluate(t->right);
        return e1 + e1;
    case NODE_MINUS:
        e1 = evaluate(t->left);
        e2 = evaluate(t->right);
        return e1 - e2;
    case NODE_MUL:
        e1 = evaluate(t->left);
        e2 = evaluate(t->right);
        return e1 * e2;
    case NODE_DIV:
        e1 = evaluate(t->left);
        e2 = evaluate(t->right);
        return e1 / e2;

    case NODE_ASSGN:
        number = t->left->varname[0] - 'a';
        e = evaluate(t->right);
        memory[number] = e;
        return 0;

    case NODE_WRITE:
        e = evaluate(t->left);
        printf("%d\n", e);
        break;

    case NODE_READ:
        number = t->left->varname[0] - 'a';
        printf("Enter the value of %c : ", t->left->varname[0]);
        scanf("%d", &memory[number]);
        break;
    }
}
