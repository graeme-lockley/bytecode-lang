# bytecode-lang

This project consists of a number of implementations of a simple language that
compiles to bytecode. The language is a simple imperative language with a C-like
syntax. The bytecode is a simple stack-based bytecode.

The purpose of this project is to try our different techniques to implement and
byte code interpreter.

## Language

The language is a simple imperative language with a C-like syntax. The language
has the following features:

- Variables of type int
- Arithmetic operations: +, -, *, /
- Assignment
- If statements
- While loops
- Functions
- Function calls
- Return statements

The language has a simple syntax. Here is an example program:

```
fn fib(n) {
  if (n <= 1)
    return n;

  return fib(n - 1) + fib(n - 2);
}

fn main() {
  let n = 0;

  while (n < 10) {
    print("fib(", n, ") = ", fib(n));
    n = n + 1;
  }
}
```

 A little more of the language and it's [*Rebo*](https://github.com/graeme-lockley/rebo-lang) compiler implementation is described in the [executable test cases](./src-compiler/parser.md).  On this page you will find a description of the language's lexical structure, syntax, AST and the compiler itself.

## Implementations

The project contains the following implementations:

- Interpreter that interprets the parsed abstract syntax tree directly.
