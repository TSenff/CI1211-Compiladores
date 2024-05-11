# Compilador PASCAL-MEPA
> Esse compilador transforma código Pascal para uma versão simplificada da linguagem MEPA.

## Materiais de Consulta
- [Projeto base](https://www.inf.ufpr.br/bmuller/#/ci1211) do professor Bruno Müller.
- [Livro](https://www.ic.unicamp.br/~tomasz/ilp/) do professor Tomasz Kowaltowski da Unicamp.

## Funcionalidades do Compilador
- [X] Permite declaração de variaveis.
- [X] Permite variaveis Inteiras.
- [ ] Permite variaveis Booleanas.
- [X] Permite atribuição de valores para variaveis.
- [X] Permite calculos basicos (+, -, *, /) em comandos de atribuição.
- [X] Permite parenteses em calculos basicos em comandos de atribuição.
- [X] Permite estrutura de comando if-else.
- [X] Permite estrutura de comando while.
- [X] Permite a criação de procedimentos sem parametros.
- [X] Permite a criação de procedimentos com parametros por valor.
- [X] Permite a criação de procedimentos com parametros por referencia.
- [ ] Permite a criação de funções.
- [ ] Permite o uso do comando read().
- [ ] Permite o uso do comando write().

Duvidas:
 - O que a busca deve fazer quando encontrar mais de um identificador de outra forma?
 - Quando um procedimento espera receber um parametro como referencia ele transforma todas as variaveis usadas na expresão em referencias.