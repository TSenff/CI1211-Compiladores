
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
registro_ts *l_side, *temp;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
%token LABEL TYPE ARRAY OF PROCEDURE FUNCTION GOTO
%token IF THEN ELSE WHILE DO AND OR NOT DIV MAIS MENOS ASTERISCO
%token NUMERO IGUAL DIFERENTE MENOR  MENOR_IGUAL  MAIOR_IGUAL  MAIOR 

%%

programa    :{
               gera_codigo (NULL, "INPP");
             }
             PROGRAM IDENT
             ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
             bloco {
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

comando_composto: T_BEGIN comandos T_END PONTO 
;

comandos:   comandos comando 
            |comando   
            |
;

comando:  atribuicao PONTO_E_VIRGULA  |
         comando_repetitivo
;

comando_repetitivo:  WHILE {
                        novos_rotulos();
                        gera_codigo(rotulo_ini(),"NADA");
                     } 
                     condicao
                     DO {
                        gera_codigo_str(NULL,"DSVF",rotulo_fim());
                     }
                     T_BEGIN comandos T_END  {
                        gera_codigo_str(NULL,"DSVS",rotulo_ini());
                        gera_codigo(rotulo_fim(),"NADA");
                        remove_rotulos();
                     }
;

atribuicao: IDENT {l_side = busca(tabela_simbolos, token);} ATRIBUICAO expressao {
         gera_codigo_int_int(NULL,"ARMZ",l_side->data.vs.nivel_lexico,l_side->data.vs.deslocamento);
      } 
;


expressao: expressao_simples |
           condicao
;
condicao: expressao_simples IGUAL expressao_simples        {gera_codigo(NULL,"CMIG");}|
          expressao_simples DIFERENTE expressao_simples    {gera_codigo(NULL,"CMDG");}|
          expressao_simples MENOR expressao_simples        {gera_codigo(NULL,"CMMA");}|
          expressao_simples MENOR_IGUAL expressao_simples  {gera_codigo(NULL,"CMAG");}|
          expressao_simples MAIOR expressao_simples        {gera_codigo(NULL,"CMME");}|
          expressao_simples MAIOR_IGUAL expressao_simples  {gera_codigo(NULL,"CMEG");}


expressao_simples: expressao_simples MAIS termo { gera_codigo(NULL,"SOMA"); } |
                   expressao_simples MENOS termo { gera_codigo(NULL,"SUBT"); } | 
                   termo 
;

termo      : termo ASTERISCO prioridade  {gera_codigo(NULL,"MULT");}| 
             termo DIV prioridade        {gera_codigo(NULL,"DIVI"); }|
             prioridade 
;

prioridade  : ABRE_PARENTESES expressao_simples FECHA_PARENTESES ASTERISCO prioridade {gera_codigo(NULL,"MULT");}|
              ABRE_PARENTESES expressao_simples FECHA_PARENTESES MAIS prioridade      {gera_codigo(NULL,"SOMA");}| 
              ABRE_PARENTESES expressao_simples FECHA_PARENTESES MENOS prioridade     {gera_codigo(NULL,"MENOS");}| 
              ABRE_PARENTESES expressao_simples FECHA_PARENTESES DIV prioridade       {gera_codigo(NULL,"DIV");}| 
              ABRE_PARENTESES expressao_simples FECHA_PARENTESES {}| 
              fator 
;

fator      : NUMERO {gera_codigo_int(NULL,"CRCT",atoi(token)); } |
             IDENT {
               // Asume que é uma variavel Simples
               temp = busca(tabela_simbolos, token);
               if(temp->categoria != vs)
                  imprimeErro("Tipo invalido em atribuição");
               gera_codigo_int_int(NULL,"CRVL",temp->data.vs.nivel_lexico,temp->data.vs.deslocamento);
            } 

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
