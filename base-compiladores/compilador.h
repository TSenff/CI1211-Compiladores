#ifndef COMPILADOR_H_
#define COMPILADOR_H_

#define TAM_TOKEN 16

#include "simbol_table.h"
#include "rotulo.h"

typedef enum simbolos {
  simb_program, simb_var, simb_begin, simb_end,
  simb_identificador, simb_numero,
  simb_ponto, simb_virgula, simb_ponto_e_virgula, simb_dois_pontos,
  simb_atribuicao, simb_abre_parenteses, simb_fecha_parenteses, simb_label,
  simb_type, simb_array, simb_of, simb_procedure, simb_function, simb_goto,
  simb_if, simb_then, simb_else, simb_while, simb_do, simb_and, simb_or, simb_div, simb_not,
  simb_asterisco, simb_mais, simb_menos, simb_igual, simb_diferente, simb_menor, simb_menor_igual, simb_maior_igual,  simb_maior
} simbolos;


extern stack_gen *tabela_simbolos;
extern stack_gen *rotulos;
extern simbolos simbolo, relacao;
extern char token[TAM_TOKEN];
extern int nivel_lexico;
extern int deslocamento;
extern int num_vars;
extern int nl;


void gera_codigo (char* rot, char* comando);
void gera_codigo_str(char* rot, char* comando,char* str);
void gera_codigo_int (char* rot, char* comando, int a);
void gera_codigo_int_int (char* rot, char* comando, int a, int b);
int imprimeErro ( char* erro );
int yylex();

void yyerror(const char *s);

#endif