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

### Logical Op Expression

Now let's look at logical operators.  These are a little more complex as they involve branching due to the nature of short-circuiting.

```rebo-repl
> let { compilerDis } = import("./compiler.rebo")

> compilerDis("print(true || false || true);")
[ [ 0, "PUSHI", 1]
, [ 5, "JMP_NEQ_ZERO", 40]
, [10, "PUSHI", 0]
, [15, "JMP_NEQ_ZERO", 40]
, [20, "PUSHI", 1]
, [25, "JMP_NEQ_ZERO", 40]
, [30, "PUSHI", 0]
, [35, "JMP", 45]
, [40, "PUSHI", 1]
, [45, "PRINTB"]
]

> compilerDis("print(true && false && true);")
[ [ 0, "PUSHI", 1]
, [ 5, "JMP_EQ_ZERO", 40]
, [10, "PUSHI", 0]
, [15, "JMP_EQ_ZERO", 40]
, [20, "PUSHI", 1]
, [25, "JMP_EQ_ZERO", 40]
, [30, "PUSHI", 1]
, [35, "JMP", 45]
, [40, "PUSHI", 0]
, [45, "PRINTB"]
]
```

These examples are a little contrived however the mechanism is sound.

## Function Declaration

The exact mechanism surrounding function declaration is a little more complex as it is necessary to describe the layout of the stack frame.  It is worthwhile to note that there are essentially 2 registers that are used to manage the interpreter's execution - the instruction pointer (`IP`) and local base pointer (`LBP`).

- `IP` is the instruction pointer and is used to keep track of the current instruction being executed.
- `LBP` is the local base pointer and is used to keep track of the current stack frame.

The stack frame is a collection of values placed onto the stack used to store the return state when, the function's results, function arguments and function local variables.  The stack frame is created when a function is called and is destroyed when the function returns.

Using some ASCII art, and the stack growing downwards, a typical stack frame might look like this:

```
+-------------------------------------+
| Argument 1                          | <- LBP - 2
+-------------------------------------+
| Argument 2                          | <- LBP - 1
+-------------------------------------+
| Function Result                     | <- LBP
+-------------------------------------+
| IP of instruction following return  | <- LBP + 1
+-------------------------------------+
| Previous LBP                        | <- LBP + 2
+-------------------------------------+
| Local 1                             | <- LBP + 3
+-------------------------------------+
| Local 2                             | <- LBP + 4
+-------------------------------------+
| Local 3                             | <- LBP + 5
+-------------------------------------+
```

It is the responsibility of the compiler to generate the correct instructions to manage the stack frame.  The bytecode will need to include instructions to create the function result and push each of the arguments. Invoking `CALL` will automatically cause the function result, `IP` and `LBP` to be pushed and the setting of `IP` and `LBP` in the function.  The operation `RET` will pop the `IP` and `LBP` and arguments off of the stack and return to the calling function with the function result on the top of the stack.


Let's see this in action!

```rebo-repl
> let { compilerDis } = import("./compiler.rebo")

> compilerDis("var x = 10; fn add(a) { return a + x; } print(add(3));")
[ [ 0, "PUSHI", 10]
, [ 5, "JMP", 31]
, [10, "PUSHL", -1]
, [15, "PUSH", 0]
, [20, "ADDI"]
, [21, "STOREL", 0]
, [26, "RET", 1]
, [31, "PUSHI", 3]
, [36, "CALL", 10]
, [41, "PRINTI"]
]
```

## Statements

Let's look at some scenarios that involve statements.

### Assignment

The first scenario is a simple assignment where we are updating a global variable.

```rebo-repl
> let { compilerDis } = import("./compiler.rebo")

> compilerDis("var x = 10; x = x + 1; print(x);")
[ [ 0, "PUSHI", 10]
, [ 5, "PUSH", 0]
, [10, "PUSHI", 1]
, [15, "ADDI"]
, [16, "STORE", 0]
, [21, "PUSH", 0]
, [26, "PRINTI"]
]
```

The second scenario is where we are updating a local variable.

```rebo-repl
> let { compilerDis } = import("./compiler.rebo")

> compilerDis("fn inc(a) { var x = 1; x = x + a; return x; } print(inc(10));")
[ [ 0, "JMP", 41]
, [ 5, "PUSHI", 1]
, [10, "PUSHL", 3]
, [15, "PUSHL", -1]
, [20, "ADDI"]
, [21, "STOREL", 3]
, [26, "PUSHL", 3]
, [31, "STOREL", 0]
, [36, "RET", 1]
, [41, "PUSHI", 10]
, [46, "CALL", 5]
, [51, "PRINTI"]
]
```

The final scenario is where we update an argument.

```rebo-repl
> let { compilerDis } = import("./compiler.rebo")

> compilerDis("fn inc(a) { a = a + 1; return a; } print(inc(10));")
[ [ 0, "JMP", 36]
, [ 5, "PUSHL", -1]
, [10, "PUSHI", 1]
, [15, "ADDI"]
, [16, "STOREL", -1]
, [21, "PUSHL", -1]
, [26, "STOREL", 0]
, [31, "RET", 1]
, [36, "PUSHI", 10]
, [41, "CALL", 5]
, [46, "PRINTI"]
]
```

### Block Statement

Although the block statement is not a statement in itself, it is a collection of statements.  The compiler will generate the instructions for each statement in the block.  Further to that, all local declarations will need to removed off of the stack.

```rebo-repl
> let { compilerDis } = import("./compiler.rebo")

> compilerDis("{ var x = 10; var y = x + 4 ; print(y); }")
[ [ 0, "PUSHI", 10]
, [5, "PUSHL", 0]
, [10, "PUSHI", 4]
, [15, "ADDI"]
, [16, "PUSHL", 1]
, [21, "PRINTI"]
, [22, "DISCARD"]
, [23, "DISCARD"]
]
```

### If Statement

There are two forms of an if statement - without an else and with an else.

```rebo-repl
> let { compilerDis } = import("./compiler.rebo")

> compilerDis("if (true) println(1); println(3);")
[ [ 0, "PUSHI", 1]
, [ 5, "JMP_EQ_ZERO", 17]
, [10, "PUSHI", 1]
, [15, "PRINTI"]
, [16, "PRINTLN"]
, [17, "PUSHI", 3]
, [22, "PRINTI"]
, [23, "PRINTLN"]
]

> compilerDis("if (true) { println(1); } else println(2); println(3);")
[ [ 0, "PUSHI", 1]
, [ 5, "JMP_EQ_ZERO", 22]
, [10, "PUSHI", 1]
, [15, "PRINTI"]
, [16, "PRINTLN"]
, [17, "JMP", 29]
, [22, "PUSHI", 2]
, [27, "PRINTI"]
, [28, "PRINTLN"]
, [29, "PUSHI", 3]
, [34, "PRINTI"]
, [35, "PRINTLN"]
]
```

### While Statement

The while statement is a little more complex as it involves a loop.  The compiler will need to generate the instructions to jump back to the start of the loop if the condition is true.

```rebo-repl
> let { compilerDis } = import("./compiler.rebo")

> compilerDis("var x = 0; while (x < 10) { println(x); x = x + 1; }")
[ [0, "PUSHI", 0]
, [5, "PUSH", 0]
, [10, "PUSHI", 10]
, [15, "LTI"]
, [16, "JMP_EQ_ZERO", 49]
, [21, "PUSH", 0]
, [26, "PRINTI"]
, [27, "PRINTLN"]
, [28, "PUSH", 0]
, [33, "PUSHI", 1]
, [38, "ADDI"]
, [39, "STORE", 0]
, [44, "JMP", 5]
]
```
