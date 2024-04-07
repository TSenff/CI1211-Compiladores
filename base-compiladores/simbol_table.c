#include "simbol_table.h"

registro_ts *cria_registro_vs(char* ident,enum Var_type tipo, int nivel_lexico, int deslocamento){
    registro_ts *reg = malloc(sizeof(registro_ts));
    if (reg == NULL)
        exit(-1);
    reg->categoria = vs;
    strcpy(reg->identificador, ident);
    reg->data.vs.deslocamento = deslocamento;
    reg->data.vs.nivel_lexico = nivel_lexico;
    reg->data.vs.tipo = desconhecido;
    return reg;

}

/**
 * Converte um token em um enum Var_type equivalente, caso desconhecido devolve desconhecido
*/
enum Var_type convert_token_var_type(char *token){
    if (!strcmp(token,"integer"))
        return inteiro;

    if (!strcmp(token,"boolean"))
        return boolean;
    
    return desconhecido;
}

/**
 * Adiciona o tipo das variaveis que estão sem tipo
*/
void add_tipo_vs(stack_gen *ts, char *token){
    registro_ts *reg;
    enum Var_type vt = convert_token_var_type(token);
    
    stack_gen *t = ts;

    while(t != NULL){
        reg = (registro_ts*)t->data;

        // Se o registro não for de uma variavel simples para
        if (reg->categoria != vs)
            break;   

        // Se a a variavel simples já tiver um tipo para 
        if (reg->data.vs.tipo != desconhecido)
            break;        
        
        // Adiciona tipo na variavel
        reg->data.vs.tipo = vt;

        // Pega o proximo registro
        t = t->next;
    }
}

void print_ts(stack_gen *ts){
    stack_gen *t = ts;

    while (t != NULL){
        printf("ID :: %s",((registro_ts*)t->data)->identificador);
        printf("  | TYPE :: %s \n", ((registro_ts*)t->data)->data.vs.tipo ? "INTEGER": "DESCONHECIDO");
        t = t->next;
    }
    
}


registro_ts *busca(stack_gen *ts, char *ident){
    stack_gen *t = ts;

    while (t != NULL && strcmp(ident, ((registro_ts*)t->data)->identificador ))
        t = t->next;
    
    return  (registro_ts*)t->data;
}


unsigned int ts_conta_vs(stack_gen *ts){
    unsigned int cont = 0;
    stack_gen *t = ts;

    while (t != NULL){
        if ( ((registro_ts*)t->data)->categoria == vs)
            cont++;
        t = t->next;
    }
    
    return  cont;
}

