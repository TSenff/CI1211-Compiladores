#ifndef GENERIC_STACK_H_
#define GENERIC_STACK_H_
#include <stdlib.h>

/*
* A simple generic implementation of Stack
*/

typedef struct stack_gen{
    void* data;
    struct stack_gen *next;
}stack_gen;

/**
 * Initializes a stack empty stack. (Only for consistency)
 * @return NULL
*/
struct stack_gen* initialize_stack();

/**
 * Remove the top of the stack
 * @param struct stack_gen **s Adress of Pointer to generic stack
 * @return Top of stack
*/
void* pop(struct stack_gen **s);

/**
 * Adds a new element to the top of the stack
 * @param struct stack_gen **s Adress of Pointer to generic stack
 * @param void *e Pointer to new element
 * @return 1 on success, 0 on failure
*/
int push(struct stack_gen **s, void *e);

/**
 * Shows the top of the stack
 * @param struct stack_gen *s Pointer to generic stack
*/
void* peek(struct stack_gen *s);

/**
 * Verifies if the stack is empty
 * @param struct stack_gen *s Pointer to generic stack
 * @return 1 if empty, 0 if not
*/
int is_empty(struct stack_gen *s);

/**
 * Frees memory of the stack and its element
 * @param struct stack_gen *s Pointer to generic stack
 * @param void (*f)(void*) Function that frees the element type of the stack
*/
void free_stack(struct stack_gen *s, void (*f)(void*));

#endif