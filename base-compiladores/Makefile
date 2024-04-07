 # -------------------------------------------------------------------
 #            Arquivo: Makefile
 # -------------------------------------------------------------------
 #              Autor: Bruno Müller Junior
 #               Data: 08/2007
 #      Atualizado em: [09/08/2020, 19h:01m]
 #
 # -------------------------------------------------------------------

$DEPURA=1

compilador: lex.yy.c compilador.tab.c compilador.o compilador.h simbol_table.o generic_stack.o rotulo.o
	gcc lex.yy.c compilador.tab.c compilador.o simbol_table.o generic_stack.o rotulo.o -o compilador -ll -ly -lc

lex.yy.c: compilador.l compilador.h
	flex compilador.l

compilador.tab.c: compilador.y compilador.h
	bison compilador.y -d -v

compilador.o : compilador.h compiladorF.c simbol_table.h generic_stack.h rotulo.h
	gcc -c compiladorF.c -o compilador.o

generic_stack.o : generic_stack.c generic_stack.h
	gcc -c generic_stack.c  -o generic_stack.o

simbol_table.o : simbol_table.c simbol_table.h generic_stack.h
	gcc -c simbol_table.c -o simbol_table.o

rotulo.o : rotulo.c rotulo.h generic_stack.h
	gcc -c rotulo.c -o rotulo.o

clean :
	rm -f *.o

purge : clean 
	rm -f compilador.tab.* lex.yy.c compilador.output compilador

run : clean
	./compilador teste1.pas

