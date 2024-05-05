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

For completeness, here is a version of the above code using `print` rather than `println`.  The difference in the generated code being that the final `PRINTLN` instruction is not emitted.

```rebo-repl
> let { compilerDis } = import("./compiler.rebo")

> compilerDis("var x = 10; var y = x; print(\"x: \", x, \", y: \", y);")
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
]
```

## Expression Scenarios

Now that we have the collective knowledge of the lexer, parser and compiler, let's look at some scenarios that involve expressions.


### Rel Op Expression

```rebo-repl
> let { compilerDis } = import("./compiler.rebo")

> compilerDis("print(10 == 20);")
[ [ 0, "PUSHI", 10]
, [ 5, "PUSHI", 20]
, [10, "EQI"]
, [11, "PRINTB"]
]

> compilerDis("print(10 != 20);")
[ [ 0, "PUSHI", 10]
, [ 5, "PUSHI", 20]
, [10, "NEQI"]
, [11, "PRINTB"]
]

> compilerDis("print(10 < 20);")
[ [ 0, "PUSHI", 10]
, [ 5, "PUSHI", 20]
, [10, "LTI"]
, [11, "PRINTB"]
]

> compilerDis("print(10 <= 20);")
[ [ 0, "PUSHI", 10]
, [ 5, "PUSHI", 20]
, [10, "LEI"]
, [11, "PRINTB"]
]

> compilerDis("print(10 > 20);")
[ [ 0, "PUSHI", 10]
, [ 5, "PUSHI", 20]
, [10, "GTI"]
, [11, "PRINTB"]
]

> compilerDis("print(10 >= 20);")
[ [ 0, "PUSHI", 10]
, [ 5, "PUSHI", 20]
, [10, "GEI"]
, [11, "PRINTB"]
]
```

### Add Op Expression

```rebo-repl
> let { compilerDis } = import("./compiler.rebo")

> compilerDis("print(10 + 20);")
[ [ 0, "PUSHI", 10]
, [ 5, "PUSHI", 20]
, [10, "ADDI"]
, [11, "PRINTI"]
]

> compilerDis("print(10 - 20);")
[ [ 0, "PUSHI", 10]
, [ 5, "PUSHI", 20]
, [10, "SUBTRACTI"]
, [11, "PRINTI"]
]
```

### Mul Op Expression

```rebo-repl
> let { compilerDis } = import("./compiler.rebo")

> compilerDis("print(10 * 20);")
[ [ 0, "PUSHI", 10]
, [ 5, "PUSHI", 20]
, [10, "MULTIPLYI"]
, [11, "PRINTI"]
]

> compilerDis("print(10 / 20);")
[ [ 0, "PUSHI", 10]
, [ 5, "PUSHI", 20]
, [10, "DIVIDEI"]
, [11, "PRINTI"]
]

> compilerDis("print(10 % 20);")
[ [ 0, "PUSHI", 10]
, [ 5, "PUSHI", 20]
, [10, "MODULUSI"]
, [11, "PRINTI"]
]
```
