
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "simbol_table.h"

extern int num_vars;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
%token LABEL TYPE ARRAY OF PROCEDURE FUNCTION GOTO
%token IF THEN ELSE WHILE DO AND OR DIV NOT

%%

programa    :{
               gera_codigo (NULL, "INPP");
             }
             PROGRAM IDENT
             ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
             bloco PONTO 
             {
               // Da onde tirar o valor de DMEM???
               //gera_codigo_int (NULL, "DMEM", );
               gera_codigo (NULL, "PARA");
             }
;

bloco       :
              parte_declara_vars
              {
              }

              comando_composto
              ;




parte_declara_vars: VAR declara_vars { deslocamento = 0;}
                  |
;


declara_vars: declara_vars declara_var
            | declara_var
;

declara_var : { }
              lista_id_var DOIS_PONTOS
              tipo
              { 
               gera_codigo_int (NULL, "AMEM", num_vars);
               num_vars = 0;
              }
              PONTO_E_VIRGULA
;

tipo        : IDENT {add_tipo_vs(tabela_simbolos, token);   }
;

lista_id_var: lista_id_var VIRGULA IDENT {
                                             /* insere ultima vars na tabela de simbolos */
                                             push(&tabela_simbolos,cria_registro_vs(token,desconhecido,nivel_lexico,deslocamento)); 
                                             num_vars++; 
                                             deslocamento++;
                                          }
               | IDENT  {
                           /* insere vars na tabela de s�mbolos */
                           push(&tabela_simbolos,cria_registro_vs(token,desconhecido,nivel_lexico,deslocamento));  
                           num_vars++;
                           deslocamento++;
                        }
;

lista_idents: lista_idents VIRGULA IDENT
            | IDENT
;


comando_composto: T_BEGIN comandos T_END

comandos:
;


%%

int main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;




   if (argc<2 || argc>2) {
         printf("usage compilador <arq>a %d\n", argc);
         return(-1);
      }

   fp=fopen (argv[1], "r");
   if (fp == NULL) {
      printf("usage compilador <arq>b\n");
      return(-1);
   }


/* -------------------------------------------------------------------
 *  Inicia a Tabela de S�mbolos
 * ------------------------------------------------------------------- */
   yyin=fp;
   yyparse();

   return 0;
}
