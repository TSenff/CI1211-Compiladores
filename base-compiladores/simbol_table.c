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

registro_ts *cria_registro_proc(char* ident, int nivel_lexico, char *rotulo, enum Var_type retorno){
    registro_ts *reg = malloc(sizeof(registro_ts));
    if (reg == NULL)
        exit(-1);
    reg->categoria = pr;
    strcpy(reg->identificador, ident);
    reg->data.proc.nivel_lexico = nivel_lexico;
    reg->data.proc.rotulo       = rotulo;
    reg->data.proc.retorno      = retorno;
    //Não inicializados ainda
    reg->data.proc.num_param = -1;
    reg->data.proc.info      = NULL;
    return reg;
}

registro_ts *cria_registro_pf(char* ident,enum Var_type tipo, int nivel_lexico, int deslocamento, int referencia){
    registro_ts *reg = malloc(sizeof(registro_ts));
    if (reg == NULL)
        exit(-1);

    reg->categoria = pf;
    strcpy(reg->identificador, ident);
    reg->data.param_f.deslocamento    = deslocamento;
    reg->data.param_f.nivel_lexico    = nivel_lexico;
    reg->data.param_f.info.tipo       = desconhecido;
    reg->data.param_f.info.referencia = referencia;
    
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

void add_tipo_pf(stack_gen *ts, char *token){
    registro_ts *reg;
    enum Var_type vt = convert_token_var_type(token);
    
    stack_gen *t = ts;

    while(t != NULL){
        reg = (registro_ts*)t->data;

        // Se o registro não for um parametro formal para
        if (reg->categoria != pf)
            break;   

        // Se a o parametro formal já tiver um tipo para 
        if (reg->data.param_f.info.tipo != desconhecido)
            break;        
        
        // Adiciona tipo no parametro
        reg->data.param_f.info.tipo = vt;

        // Pega o proximo registro
        t = t->next;
    }
}

void add_ret_proc(stack_gen *ts, char *token){
    registro_ts *reg;
    enum Var_type retorno = convert_token_var_type(token);
    
    stack_gen *t = ts;

    while(t != NULL){
        reg = (registro_ts*)t->data;

        // Ao pegar o primeiro procedimento adiciona retorno e sai
        if (reg->categoria == pr){
            if (reg->data.proc.retorno != desconhecido){
                imprimeErro("add_ret_proc() não encontrou um procedimento valido");
                exit(1);            
            }
            reg->data.proc.retorno = retorno; 
            return;   
        }
        // Pega o proximo registro
        t = t->next;
    }
    
    imprimeErro("add_ret_proc() encontrou null na tabela de simbolos");
    exit(1);
}


void add_desloc_pf(stack_gen *ts){
    registro_ts *reg;
    stack_gen *t = ts;
    int desl = -4;

    while(t != NULL){
        reg = (registro_ts*)t->data;
        // Se o registro não for um parametro formal com deslocamento zerado
        if (reg->categoria != pf && reg->data.param_f.deslocamento == 0)
            break;        
        
        reg->data.param_f.deslocamento = desl;
        desl--;

        // Pega o proximo registro
        t = t->next;
    }
}

int add_pf_proc(stack_gen *ts, int num_pf){
    registro_ts *reg;    
    stack_gen *t = ts;
    int flag = 1, pf_cont = num_pf;
    struct info_param *info = malloc(sizeof(struct info_param)*num_pf);
    if (info == NULL)
        exit(-1);

    while(t != NULL && flag){
        reg = (registro_ts*)t->data;
        switch (reg->categoria){
            case pf:
                info[num_pf-1].referencia = reg->data.param_f.info.referencia;
                info[num_pf-1].tipo       = reg->data.param_f.info.tipo;
                break;
            case pr:
                reg->data.proc.info = info;
                reg->data.proc.num_param = pf_cont;
                flag = 0;
                break;
            default:
                exit(-1);
                break;
        }

        // Pega o proximo registro
        num_pf--;
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

void ts_deleta_simbolos_dmem(stack_gen **ts, int del){
    // Se não ha variaveis para deletar retorna
    if (!del)
        return;

    stack_gen **t = ts;
    stack_gen *s = *t;
    stack_gen *q = NULL;

    // Se o primeiro simbolo da pilha for um procedimento, ignora os proximos n procedimentos
    while (s != NULL && ((registro_ts*)peek(s))->categoria == pr){
        q = s;
        s = s->next;
    }
    // Se q é nulo então, pop em ts é suficiente
    if (q == NULL){
        while (*ts != NULL && ((registro_ts*)peek(*ts))->categoria == vs){
            pop(ts);
        }
        return;
    }
    
    // Se ignoramos N procedimentos encontraremos um grupo de VS, remove todas
    while (s != NULL && ((registro_ts*)peek(s))->categoria == vs){
        //leak de memoria
        pop(&s);
    }
    // Como ts não foi modificado precisamos apenas ligar q com o novo valor de s
    q->next = s;

}

void ts_deleta_pfs(stack_gen **ts){

    stack_gen **t = ts;
    stack_gen *s = *t;
    stack_gen *q = NULL;

    // Se o primeiro simbolo da pilha for um procedimento, ignora os proximos n procedimentos
    while (s != NULL && ((registro_ts*)peek(s))->categoria == pr){
        q = s;
        s = s->next;
    }

    // Se q é nulo então, pop em ts é suficiente
    if (q == NULL){
        while (*ts != NULL && ((registro_ts*)peek(*ts))->categoria == pf){
            pop(ts);
        }
        return;
    }
    
    // Se ignoramos N procedimentos encontraremos um grupo de PF, remove todas
    while (s != NULL && ((registro_ts*)peek(s))->categoria == pf){
        //leak de memoria
        pop(&s);
    }
    // Como ts não foi modificado precisamos apenas ligar q com o novo valor de s
    q->next = s;

}

registro_ts *busca(stack_gen *ts, char *ident){
    stack_gen *t = ts;
    while (t != NULL && strcmp(ident, ((registro_ts*)t->data)->identificador )){
        t = t->next;
    }

    if (t == NULL)
        return NULL;


    return  (registro_ts*)peek(t);
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

