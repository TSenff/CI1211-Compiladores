#include "rotulo.h"

stack_gen *rotulos = NULL;
unsigned int counter = 0;


int cria_rotulo(){
    char *r;
    r = malloc(sizeof(char)*5);
    if(r == NULL)
        return 1;
    sprintf(r,"R%02i",counter);
    push(&rotulos,r);
    counter ++;
    return 0;
}


int novos_rotulos(){
    char *r;
    r = malloc(sizeof(char)*5);
    if(r == NULL)
        return 1;
    sprintf(r,"R%02i",counter);
    push(&rotulos,r);
    counter ++;

    r = malloc(sizeof(char)*5);
    if(r == NULL)
        return 1;
    sprintf(r,"R%02i",counter);
    push(&rotulos,r);
    counter ++;

    return 0;
}

int remove_rotulo(){
    free(pop(&rotulos));
}

int remove_rotulos_procedimento(){
    free(pop(&rotulos));
    pop(&rotulos);
}

int remove_rotulos(){
    free(pop(&rotulos));
    free(pop(&rotulos));
}

char *rotulo_ini(){
    return (char*) peek(rotulos->next);
}

char *rotulo_fim(){
    return (char*) peek(rotulos);
}