
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
unsigned int var_cont;
int *n;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
%token LABEL TYPE ARRAY OF PROCEDURE FUNCTION GOTO
%token IF THEN ELSE WHILE DO AND OR NOT DIV MAIS MENOS ASTERISCO
%token NUMERO IGUAL DIFERENTE MENOR  MENOR_IGUAL  MAIOR_IGUAL  MAIOR 
%token WRITE READ

%%

programa    :{
               gera_codigo (NULL, "INPP");
             }
             PROGRAM IDENT
             ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
             bloco 
            {gera_codigo (NULL, "PARA");}
;

bloco       :
              parte_declara_vars
              parte_declara_procedimento
              comando_composto 
               {

                     n = pop(&pilha_var_cont);
                     ts_deleta_simbolos_dmem(&tabela_simbolos, *n);
                     if(*n)
                        gera_codigo_unsig_int (NULL, "DMEM", *n);
                     free(n);
               }
;

parte_declara_procedimento: subrotinas parte_declara_procedimento
                           |
;

subrotinas : declara_procedimento |
             declara_funcao


declara_procedimento :  PROCEDURE {
                                    novos_rotulos();
                                    // Aumenta o nivel lexico
                                    nivel_lexico++;
   
                                    // Desvia pro final
                                    gera_codigo_str(NULL,"DSVS",rotulo_fim());
                                    
                                    //Rotulo inicial do procedimento
                                    gera_codigo_int(rotulo_ini(),"ENPR",nivel_lexico);

                                 } 
                        IDENT 
                        {
                           push(&tabela_simbolos,cria_registro_proc(token,nivel_lexico,rotulo_ini()));
                        }
                        ABRE_PARENTESES {num_pf = 0;} declara_parametros_formais { add_desloc_pf(tabela_simbolos);}
                        FECHA_PARENTESES PONTO_E_VIRGULA 
                        {
                           
                           // Salva o numero de parametros em uma pilha para retorno
                           n = malloc(sizeof(int));
                           if(n == NULL)
                              exit(-1);
                           
                           *n = num_pf;
                           push(&pilha_procedimento,n);

                           // Adiciona
                           add_pf_proc(tabela_simbolos, num_pf);
                        }
                        bloco
                        {
                           // Reduz nivel lexico
                           nivel_lexico--;

                           // Pega o numero de parametros do procedimento
                           n = (int*)pop(&pilha_procedimento);
                           
                           // Comando de retorno
                           gera_codigo_int_int(NULL,"RTPR",nivel_lexico,*n);
                           
                           // Remove os parametros formais da tabela de simbolos se existem
                           if(*n) 
                              ts_deleta_pfs(&tabela_simbolos);

                           // Desaloca o numero de parametros do procedimento
                           free(n);
                           
                           // Rotulo de saida
                           gera_codigo(rotulo_fim(),"NADA");

                           // Remove o rotulo sem desalocar o nome do rotulo_ini()
                           remove_rotulos_procedimento();
                        }  
;

declara_funcao : FUNCTION
;

declara_parametros_formais : declara_parametros_formais PONTO_E_VIRGULA declara_parametro_formal
                           | declara_parametro_formal 
;

declara_parametro_formal : VAR {flag_pf_reference = 1;} parametro_formal 
                           | {flag_pf_reference = 0;} parametro_formal 
;

parametro_formal : lista_id_pf DOIS_PONTOS tipo_pf 
;

lista_id_pf: lista_id_pf VIRGULA id_pf 
            |id_pf
;

id_pf: IDENT   {
                  /* insere vars na tabela de simbolos */
                  push(&tabela_simbolos,cria_registro_pf(token,desconhecido,nivel_lexico,0,flag_pf_reference));  
                  num_pf++;
               }
;

tipo_pf: IDENT {add_tipo_pf(tabela_simbolos, token);}
;


parte_declara_vars: VAR declara_vars { deslocamento = 0;} |
            {  
               // Salva o valor 
               n = malloc(sizeof(int));
               if(n == NULL)
                  exit(-1);
               *n = 0;
               push(&pilha_var_cont,n);
            }
;

declara_vars: declara_vars declara_var
            | declara_var
;

declara_var : { }
              lista_id_var DOIS_PONTOS
              tipo
              { 
               gera_codigo_int (NULL, "AMEM", num_vars);
               // Salva o valor para DMEM
               n = malloc(sizeof(int));
               if(n == NULL)
                  exit(-1);
               *n = num_vars;
               push(&pilha_var_cont,n);

               // Reseta valor
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

comando:  ident_op PONTO_E_VIRGULA  |
         comando_repetitivo|
         comando_condicional|
         proc_write |
         proc_read
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

comando_condicional: IF ABRE_PARENTESES condicao FECHA_PARENTESES THEN {
                           /*Verif condicao*/
                           cria_rotulo();
                           gera_codigo_str(NULL,"DSVF",rotulo_fim());
                        }
                        comando_bloco_singular 
                        if_end
                        {remove_rotulo();}
;

if_end : ELSE{
            // Sai do if
            cria_rotulo();
            gera_codigo_str(NULL,"DSVS",rotulo_fim());
            // Rotulo de entrada do else
            gera_codigo(rotulo_ini(),"NADA");
         } 
         comando_bloco_singular {
            // Rotulo de Saida
            gera_codigo(rotulo_fim(),"NADA");
            remove_rotulo();
         }
         |
         {
            // Rotulo de Saida
            gera_codigo(rotulo_fim(),"NADA");
         } 
;

comando_bloco_singular:  
                     T_BEGIN comandos T_END |
                     comando  

; 

proc_write: WRITE ABRE_PARENTESES lista_ids_write FECHA_PARENTESES PONTO_E_VIRGULA
;

lista_ids_write:   lista_ids_write VIRGULA lista_id_write |
                   lista_id_write
;

lista_id_write: expressao_simples {gera_codigo(NULL,"IMPR");}
;

proc_read: READ ABRE_PARENTESES lista_ids_read FECHA_PARENTESES PONTO_E_VIRGULA
;

lista_ids_read:   lista_ids_read VIRGULA lista_id_read |
                  lista_id_read
;

lista_id_read: IDENT {
   temp = busca(tabela_simbolos,token);
   switch(temp->categoria){
      case vs:
         gera_codigo(NULL,"LEIT");
         gera_codigo_int_int(NULL,"ARMZ",temp->data.vs.nivel_lexico,temp->data.vs.deslocamento);
         break; 
   default:
      imprimeErro("IDENT invalido em read");
      exit(-1);
   }
   }
;


ident_op: IDENT {l_side = busca(tabela_simbolos, token);} ident_op_rec
;

ident_op_rec : atribuicao | chama_procedimento
;

atribuicao:  ATRIBUICAO expressao {  
         switch(l_side->categoria){
            case vs: 
               gera_codigo_int_int(NULL,"ARMZ",l_side->data.vs.nivel_lexico,l_side->data.vs.deslocamento);
               break;
            case pf:
               if(l_side->data.param_f.info.referencia){
                  gera_codigo_int_int(NULL,"ARMI",l_side->data.param_f.nivel_lexico,l_side->data.param_f.deslocamento);
               }
               else{
                  gera_codigo_int_int(NULL,"ARMZ",l_side->data.param_f.nivel_lexico,l_side->data.param_f.deslocamento);
               }
               break;
            default:
               exit(1);
               break;
         } 
      } 
;

chama_procedimento: ABRE_PARENTESES {num_vars = 0;} lista_parametros_reais FECHA_PARENTESES {
                        // Desativa flag
                        flag_pr_reference = 0; 
                        gera_codigo_str_int(NULL,"CHPR",l_side->data.proc.rotulo,nivel_lexico);
                     }
;

lista_parametros_reais: lista_parametros_reais VIRGULA parametro_real
                        | parametro_real
                        |
;

parametro_real:   {
                     flag_pr_reference = l_side->data.proc.info[num_vars].referencia;
                     num_vars++;
                  } 
                  expressao_simples 

expressao: expressao_simples |
           condicao
;
condicao: expressao_simples IGUAL expressao_simples        {gera_codigo(NULL,"CMIG");}|
          expressao_simples DIFERENTE expressao_simples    {gera_codigo(NULL,"CMDG");}|
          expressao_simples MENOR expressao_simples        {gera_codigo(NULL,"CMMA");}|
          expressao_simples MENOR_IGUAL expressao_simples  {gera_codigo(NULL,"CMAG");}|
          expressao_simples MAIOR expressao_simples        {gera_codigo(NULL,"CMME");}|
          expressao_simples MAIOR_IGUAL expressao_simples  {gera_codigo(NULL,"CMEG");}


expressao_simples: expressao_simples MAIS termo  { gera_codigo(NULL,"SOMA"); } |
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

               switch(temp->categoria){

                  case pf:
                     // Verifica se guarda um endereço ou não
                     if(temp->data.param_f.info.referencia){
                        // Se está sendo passado como parametro real por referencia
                        if(flag_pr_reference){
                           gera_codigo_int_int(NULL,"CRVL",temp->data.param_f.nivel_lexico,temp->data.param_f.deslocamento);
                        }
                        else{
                           gera_codigo_int_int(NULL,"CRVI",temp->data.param_f.nivel_lexico,temp->data.param_f.deslocamento);
                        }                     
                     }
                     else{
                        if(flag_pr_reference){
                           gera_codigo_int_int(NULL,"CREN",temp->data.param_f.nivel_lexico,temp->data.param_f.deslocamento);
                        }
                        else{
                           gera_codigo_int_int(NULL,"CRVL",temp->data.param_f.nivel_lexico,temp->data.param_f.deslocamento);
                        }
                     }
                     break;
                  case vs: 
                     // Se está sendo passado como parametro real por referencia
                     if(flag_pr_reference){
                        gera_codigo_int_int(NULL,"CREN",temp->data.vs.nivel_lexico,temp->data.vs.deslocamento);
                     }
                     else{
                        gera_codigo_int_int(NULL,"CRVL",temp->data.vs.nivel_lexico,temp->data.vs.deslocamento);
                     }

                     break;
                  default:
                     imprimeErro("Tipo invalido em expressao_simples");
                     exit(1);
                     break;
               } 
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
