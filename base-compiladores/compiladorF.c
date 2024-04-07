#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"

stack_gen *tabela_simbolos;
simbolos simbolo, relacao;
char token[TAM_TOKEN];
int nivel_lexico;
int deslocamento;
int num_vars = 0;
//int nl;

FILE* fp=NULL;

void check_fp(){
  if (fp == NULL) {
    fp = fopen ("MEPA", "w");
  }
}

void gera_codigo (char* rot, char* comando){
  check_fp();

  if ( rot == NULL ) {
    fprintf(fp, "     %s\n", comando);
  } else {
    fprintf(fp, "%s: %s \n", rot, comando);
  }

  fflush(fp);
}

void gera_codigo_str (char* rot, char* comando, char* str){
  check_fp();

  if ( rot == NULL ) {
    fprintf(fp, "     %s %s\n", comando, str);
  } else {
    fprintf(fp, "%s: %s %s\n", rot, comando, str);
  }
  
  fflush(fp);
}

void gera_codigo_int (char* rot, char* comando, int a){
  check_fp();

  if ( rot == NULL ) {
    fprintf(fp, "     %s %i\n", comando, a);
  } else {
    fprintf(fp, "%s: %s %i\n", rot, comando, a);
  }
  
  fflush(fp);
}

void gera_codigo_int_int (char* rot, char* comando, int a, int b){
  check_fp();

  if ( rot == NULL ) {
    fprintf(fp, "     %s %i %i\n", comando, a, b);
  } else {
    fprintf(fp, "%s: %s %i %i\n", rot, comando, a, b);
  }
  
  fflush(fp);
}

int imprimeErro ( char* erro ) {
  fprintf (stderr, "Erro na linha %d - %s\n", nl, erro);
  exit(-1);
}