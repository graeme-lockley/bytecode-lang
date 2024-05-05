# Compiler

The compiler is responsible for translating the parsed abstract syntax tree (AST) into bytecode. Part of the compiler's responsibility is to ensure that the program is well typed and references to all variables and functions are valid.

The bytecode is a simple stack-based bytecode.

```rebo-repl
> let { compilerDis } = import("./compiler.rebo")

> compilerDis("var x = 10;")
[ [ 0, "PUSHI", 10]
]
```

Global variables are stored on the stack and then referenced off of the stack.

```rebo-repl
> let { compilerDis } = import("./compiler.rebo")

> compilerDis("var x = 10; var y = x;")
[ [ 0, "PUSHI", 10]
, [ 5, "PUSH", 0]
]
```

In this example, the value of `x` is in position `0` on the stack whilst the value of `y` is in position `1` on the stack.