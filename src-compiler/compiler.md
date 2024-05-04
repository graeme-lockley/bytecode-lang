# Compiler

The compiler is responsible for translating the parsed abstract syntax tree (AST) into bytecode. Part of the compiler's responsibility is to ensure that the program is well typed and references to all variables and functions are valid.

The bytecode is a simple stack-based bytecode.

```rebo-repl
> let { compilerDis } = import("./compiler.rebo")

> compilerDis("var x = 10;")
[ [ 0, "PUSHI", 10]
]
```
