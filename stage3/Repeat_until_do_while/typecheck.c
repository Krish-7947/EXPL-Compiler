void typecheck(int t1, int t2, char c) {
    switch(c) {
        case 'w': if(t1 != t2) {
                      yyerror("Expected Boolean in WHILE check");
                      exit(1);
                  }
                  break;
        case 'e': if(t1 != t2) {
                      yyerror("Expected Boolean in IF ELSE check");
                      exit(1);
                  }
                  break;
        case 'r': if(t1 != t2) {
                      yyerror("Expected Boolean in REPEAT UNTIL check");
                      exit(1);
                  }
                  break;
        case 'd': if(t1 != t2) {
                      yyerror("Expected Boolean in DO WHILE check");
                      exit(1);
                  }
                  break;
        case 'i': if(t1 != t2) {
                      yyerror("Expected Boolean in IF check");
                      exit(1);
                  }
                  break;
        case 'a': if(t1 != TYPE_INT || t2 != TYPE_INT) {
                      yyerror("Invalid type for arithmetic operation");
                      exit(1);
                  }
                  break;
        case 'b': if(t1 != TYPE_INT || t2 != TYPE_INT) {
                      yyerror("Invalid type for logical operation");
                      exit(1);
                  }
                  break;
        case '=': if(t1 != t2) {
                      yyerror("Invalid type for assignment operation");
                      exit(1);
                  }
                  break;
    }
}