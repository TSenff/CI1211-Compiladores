#ifndef SIMBOL_TABLE_H_
#define SIMBOL_TABLE_H_

#include "generic_stack.h"
#include "compilador.h"
#include <stdio.h>
#include <string.h>

enum Type {vs, pf, pr};
enum Var_type {desconhecido, inteiro, boolean};

// Struct parta guardar informação de tipo e passagem em PF e PROC
typedef struct info_param{
        enum Var_type tipo;
        int referencia;
}info_param;

// Structs para armazenar informações dos tipos de simbolos

typedef struct variavel_simples{
        enum Var_type tipo;
        int nivel_lexico;
        int deslocamento;
}variavel_simples;

typedef struct parametros_formais{
        int nivel_lexico;
        int deslocamento;
        struct info_param info;
}parametros_formais;

typedef struct procedimentos{
        int nivel_lexico;
        char *rotulo;
        int num_param;
        struct info_param *info;
}procedimentos;


// Struct usado na pilha da tabela de simbolos, Type categoria marca qual forma a union deve levar
typedef struct registro_tabela_simbolos{
    enum Type categoria;
    char identificador[TAM_TOKEN];
    union{
        variavel_simples vs;
        parametros_formais param_f;
        procedimentos proc;
    }data;
}registro_ts;

registro_ts *cria_registro_vs(char* ident,enum Var_type tipo, int nivel_lexico, int deslocamento);
registro_ts *cria_registro_proc(char* ident, int nivel_lexico, char *rotulo);

void add_tipo_vs(stack_gen *ts, char *token);
int add_pf_registro(stack_gen *ts, int num_pf);

void ts_deleta_simbolos_dmem(stack_gen **ts, int del);

registro_ts *busca(stack_gen *ts, char *ident);

void print_ts(stack_gen *ts);



#endif
