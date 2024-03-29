#ifndef SIMBOL_TABLE_H_
#define SIMBOL_TABLE_H_

#include "generic_stack.h"
#include "compilador.h"
#include <stdio.h>
#include <string.h>

enum Type {vs, pf, pr};
enum Var_type {desconhecido, inteiro };

typedef struct variavel_simples{
        enum Var_type tipo;
        int nivel_lexico;
        int deslocamento;
}variavel_simples;

typedef struct parametros_formais{
        int tipo;
        int nivel_lexico;
        int deslocamento;
        int passagem;
}parametros_formais;

typedef struct procedimentos{
        int tipo;
        int nivel_lexico;
        int rotulo;
        int aaaaaaahhhhhhhhh;
}procedimentos;

typedef struct registro_tabela_simbolos{
    enum Type categoria;
    char identificador[TAM_TOKEN];
    union{
        variavel_simples vs;
        parametros_formais type2;
        procedimentos type3;
    }data;
}registro_ts;

void add_tipo_vs(stack_gen *ts, char *token);

int ts_conta_vs(stack_gen *ts);

registro_ts *cria_registro_vs(char* ident,enum Var_type tipo, int nivel_lexico, int deslocamento);

void print_ts(stack_gen *ts);



#endif
