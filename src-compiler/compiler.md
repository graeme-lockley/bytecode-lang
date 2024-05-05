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

Let's take this example a little further and compile the code to print both `x` and `y`.

```rebo-repl
> let { compilerDis } = import("./compiler.rebo")

> compilerDis("var x = 10; var y = x; println(\"x: \", x, \", y: \", y);")
[ [ 0, "PUSHI", 10]
, [ 5, "PUSH", 0]
, [10, "PUSHS", "x: "]
, [18, "PRINTS"]
, [19, "PUSH", 0]
, [24, "PRINTI"]
, [25, "PUSHS", ", y: "]
, [35, "PRINTS"]
, [36, "PUSH", 1]
, [41, "PRINTI"]
, [42, "PRINTLN"]
]
```

This is the basis of all the compiler does. It takes the AST and generates a sequence of instructions that can be executed by the interpreter.