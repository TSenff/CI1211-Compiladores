#include "generic_stack.h"


struct stack_gen* initialize_stack(){
    return NULL;
}

void* peek(struct stack_gen *s){
    return s->data;
}

void* pop(struct stack_gen **s){
    if (is_empty(*s))return NULL;
    struct stack_gen *r = *s;
    void *t = r->data;
    *s = r->next;
    free(r);
    return t;
}

int push(struct stack_gen **s, void *e){
    struct stack_gen *top = (struct stack_gen*)malloc(sizeof(struct stack_gen)); 
    if (top == NULL)return 0;
    top->data = e;
    top->next = *s;
    *s = top;
    return 1;
}

int is_empty(struct stack_gen *s){
    return s == NULL;
}

void free_stack(struct stack_gen *s, void (*f)(void*)){
    while(!is_empty(s))
        f(pop(&s));
}



