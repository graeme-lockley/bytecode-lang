# Parser

The parser is responsible for converting the input source code into an abstract syntax tree (AST). The AST is a tree representation of the source code that can be used to generate the output code.



## Scanner

The scanner is responsible for converting the input source code into a sequence of tokens. The scanner reads the input source code character by character and groups the characters into tokens.

The scanner definition is described below:

```
tokens
    Identifier = id {digit | id};
    LiteralInt = ['-'] digits;
    LiteralString = '"' {char | '\' ('n' | '"' | ("x" digits ';'))} '"';

comments
   "//" {!cr};

whitespace
  chr(0)-' ';

fragments
  digit = '0'-'9';
  digits = digit {digit};
  id = 'A'-'Z' + 'a'-'z' + '_';
  cr = chr(10);
  char = chr(32)-chr(38) + chr(40)-chr(91) + chr(93)-chr(255);
```

The following scenarios illustrate the scanner's behavior.

```rebo-repl
> let { scan } = import("./parser.rebo")

> scan("123 -10 0")
[ { kind: "LiteralInt", value: 123, start: 0, end: 3 }
, { kind: "LiteralInt", value: -10, start: 4, end: 7 }
, { kind: "LiteralInt", value: 0, start: 8, end: 9 }
]

> scan("a Hello a1 A1")
[ { kind: "Identifier", value: "a", start: 0, end: 1 }
, { kind: "Identifier", value: "Hello", start: 2, end: 7 }
, { kind: "Identifier", value: "a1", start: 8, end: 10 }
, { kind: "Identifier", value: "A1", start: 11, end: 13 }
]

> scan("\"Hello World\"")
[ { kind: "LiteralString", value: "Hello World", start: 0, end: 13 } ]
```

A number of tokens are pushed into the scanner from the grammar which are loosely described as symbols and keywords.

```rebo-repl
> let scan(input) =
.    import("./parser.rebo").scan(input) 
.    |> map(fn (token) = token.kind)

> scan(", || && = == != < <= > >= + - * / % { } ;")
[ "Comma", "BarBar", "AmpersandAmpersand", "Equals", "EqualsEquals", "BangEquals", "LessThan", "LessEquals", "GreaterThan", "GreaterEquals", "Plus", "Minus", "Star", "Slash", "Percentage", "LCurley", "RCurley", "Semicolon" ]

> scan("true false if else while return print println var fn")
[ "True", "False", "If", "Else", "While", "Return", "Print", "Println", "Var", "Fn" ]
```

The scanner also supports comments and whitespace. Comments are ignored by the scanner, and whitespace is used to separate tokens.

```rebo-repl
> let { scan } = import("./parser.rebo")

> scan("123 // comment\n 456")
[ { kind: "LiteralInt", value: 123, start: 0, end: 3 }
, { kind: "LiteralInt", value: 456, start: 16, end: 19 }
]
```

## Grammar

The grammar for this language is described using the following definition with the lexical definitions from above.

```
program: {declaration} EOF;

declaration: functionDecl | statement;

functionDecl: "fn" Identifier "(" [Identifier {"," Identifier}] ")" block;

variableDecl: "var" Identifier "=" expression ";";

block: "{" {statement} "}";

statement:
    block
  | "if" "(" expression ")" statement ["else" statement]
  | "while" "(" expression ")" statement
  | "return" expression ";"
  | ("print" | "println") "(" [expression {"," expression}] ")" ";"
  | variableDecl
  | Identifier ("=" expression | "(" [expression {"," expression}] ")" ) ";"
  ;

expression: andExpression {"||" andExpression};
andExpression: relOpExpression {"&&" relOpExpression};
relOpExpression: addExpression {("==" | "!=" | "<" | "<=" | ">" | ">=") addExpression};
addExpression: mulExpression {("+" | "-") mulExpression};
mulExpression: term {("*" | "/" | "%") term};
term: LiteralInt | "true" | "false" | LiteralString | Identifier ["(" [expression {"," expression}])]| "(" expression ")";
```

The grammar defines the structure of the language. The grammar is used by the parser to generate the abstract syntax tree (AST) from the input source code.  The parser is a recursive descent parser with a function a function for each of the non-terminal symbols in the grammar.  These functions accept a `Scanner` as input and returns the AST node for the non-terminal symbol.

### Program

```rebo-repl
> let Parser = import("./parser.rebo")

> Parser.using("fn fib(n) { return n; }\nvar x = 100; print(fib(x));", Parser.program)
[ { kind: "Fn"
  , name: "fib"
  , params: [ "n" ]
  , body: [ { kind: "Return", expr: { kind: "Identifier", value: "n" } } ] 
  }
, { kind: "Var", name: "x", value: { kind: "LiteralInt", value: 100 } }
, { kind: "Print"
  , args: [ { kind: "Call", name: "fib", args: [ { kind: "Identifier", value: "x" } ]} ]
  }
]
```

### Declaration

```rebo-repl
> let Parser = import("./parser.rebo")

> Parser.using("fn fib(n) { return n; }", Parser.declaration)
{ kind: "Fn"
, name: "fib"
, params: [ "n" ]
, body: [ { kind: "Return", expr: { kind: "Identifier", value: "n" } } ]
} 

> Parser.using("var x = 100;", Parser.declaration)
{ kind: "Var", name: "x", value: { kind: "LiteralInt", value: 100 } }
```

### Function Decl

```rebo-repl
> let Parser = import("./parser.rebo")

> Parser.using("fn fib(n) { return n; }", Parser.functionDecl)
{ kind: "Fn"
, name: "fib"
, params: [ "n" ]
, body: [ { kind: "Return", expr: { kind: "Identifier", value: "n" } } ]
} 
```

### Variable Decl

```rebo-repl
> let Parser = import("./parser.rebo")

> Parser.using("var x = 100;", Parser.variableDecl)
{ kind: "Var", name: "x", value: { kind: "LiteralInt", value: 100 } }
```

### Statement and Block

```rebo-repl
> let Parser = import("./parser.rebo")

> Parser.using("{}", Parser.statement)
{ kind: "Block", stmts: [] }

> Parser.using("if (true) {}", Parser.statement)
{ kind: "If"
, guard: { kind: "LiteralBool", value: true }
, then: { kind: "Block", stmts: [] }
}

> Parser.using("if (true) {} else {}", Parser.statement)
{ kind: "If"
, guard: { kind: "LiteralBool", value: true }
, then: { kind: "Block", stmts: [] }
, else: { kind: "Block", stmts: [] }
}

> Parser.using("while (true) {}", Parser.statement)
{ kind: "While"
, guard: { kind: "LiteralBool", value: true }
, body: { kind: "Block", stmts: [] }
}

> Parser.using("return true;", Parser.statement)
{ kind: "Return"
, expr: { kind: "LiteralBool", value: true }
}

> Parser.using("print();", Parser.statement)
{ kind: "Print"
, args: [] 
}

> Parser.using("print(1);", Parser.statement)
{ kind: "Print"
, args: 
  [ { kind: "LiteralInt", value: 1 }
  ]
}

> Parser.using("print(1, 2, 3);", Parser.statement)
{ kind: "Print"
, args:
  [ { kind: "LiteralInt", value: 1 }
  , { kind: "LiteralInt", value: 2 }
  , { kind: "LiteralInt", value: 3 }
  ]
}

> Parser.using("var x = 100;", Parser.statement)
{ kind: "Var", name: "x", value: { kind: "LiteralInt", value: 100 } }

> Parser.using("x = 100;", Parser.statement)
{ kind: "Assign", name: "x", value: { kind: "LiteralInt", value: 100 } }

> Parser.using("x();", Parser.statement)
{ kind: "Call", name: "x", args: [] }

> Parser.using("x(1);", Parser.statement)
{ kind: "Call"
, name: "x"
, args: 
  [ { kind: "LiteralInt", value: 1 }
  ]
}

> Parser.using("x(1, 2, 3);", Parser.statement)
{ kind: "Call"
, name: "x"
, args: 
  [ { kind: "LiteralInt", value: 1 }
  , { kind: "LiteralInt", value: 2 }
  , { kind: "LiteralInt", value: 3 }
  ]
}
```

### Expression

```rebo-repl
> let Parser = import("./parser.rebo")

> Parser.using("true", Parser.expression)
{ kind: "LiteralBool", value: true }

> Parser.using("true || false || true", Parser.expression)
{ kind: "Or", 
  exprs: [
    { kind: "LiteralBool", value: true }
  , { kind: "LiteralBool", value: false }
  , { kind: "LiteralBool", value: true } 
  ]
}
```

### And Expression

```rebo-repl
> let Parser = import("./parser.rebo")

> Parser.using("true", Parser.expression)
{ kind: "LiteralBool", value: true }

> Parser.using("true && false && true", Parser.expression)
{ kind: "And"
, exprs: [
    { kind: "LiteralBool", value: true }
  , { kind: "LiteralBool", value: false }
  , { kind: "LiteralBool", value: true }
  ]
}
```

### Rel Op Expression

```rebo-repl
> let Parser = import("./parser.rebo")

> Parser.using("true", Parser.expression)
{ kind: "LiteralBool", value: true }

> Parser.using("true == false", Parser.expression)
{ kind: "Equals"
, lhs: { kind: "LiteralBool", value: true }
, rhs: { kind: "LiteralBool", value: false }
}

> Parser.using("true != false", Parser.expression)
{ kind: "NotEquals"
, lhs: { kind: "LiteralBool", value: true }
, rhs: { kind: "LiteralBool", value: false }
}

> Parser.using("true < false", Parser.expression)
{ kind: "LessThan"
, lhs: { kind: "LiteralBool", value: true }
, rhs: { kind: "LiteralBool", value: false }
}

> Parser.using("true <= false", Parser.expression)
{ kind: "LessEquals"
, lhs: { kind: "LiteralBool", value: true }
, rhs: { kind: "LiteralBool", value: false }
}

> Parser.using("true > false", Parser.expression)
{ kind: "GreaterThan"
, lhs: { kind: "LiteralBool", value: true }
, rhs: { kind: "LiteralBool", value: false }
}

> Parser.using("true >= false", Parser.expression)
{ kind: "GreaterEquals"
, lhs: { kind: "LiteralBool", value: true }
, rhs: { kind: "LiteralBool", value: false }
}
```

### Add Op Expression

```rebo-repl
> let Parser = import("./parser.rebo")

> Parser.using("1", Parser.expression)
{ kind: "LiteralInt", value: 1 }

> Parser.using("1 + 2", Parser.expression)
{ kind: "Add"
, lhs: { kind: "LiteralInt", value: 1 }
, rhs: { kind: "LiteralInt", value: 2 }
}

> Parser.using("1 + 2 + 3", Parser.expression)
{ kind: "Add"
, lhs:
  { kind: "Add"
  , lhs: { kind: "LiteralInt", value: 1 }
  , rhs: { kind: "LiteralInt", value: 2 }
  }
, rhs: { kind: "LiteralInt", value: 3 }
}

> Parser.using("1 - 2", Parser.expression)
{ kind: "Subtract"
, lhs: { kind: "LiteralInt", value: 1 }
, rhs: { kind: "LiteralInt", value: 2 }
}

> Parser.using("1 - 2 - 3", Parser.expression)
{ kind: "Subtract"
, lhs:
  { kind: "Subtract"
  , lhs: { kind: "LiteralInt", value: 1 }
  , rhs: { kind: "LiteralInt", value: 2 } 
  }
, rhs: { kind: "LiteralInt", value: 3 }
}
```

### Mul Op Expression

```rebo-repl
> let Parser = import("./parser.rebo")

> Parser.using("1", Parser.expression)
{ kind: "LiteralInt", value: 1 }

> Parser.using("1 * 2", Parser.expression)
{ kind: "Multiply"
, lhs: { kind: "LiteralInt", value: 1 }
, rhs: { kind: "LiteralInt", value: 2 }
}

> Parser.using("1 * 2 * 3", Parser.expression)
{ kind: "Multiply"
, lhs:
  { kind: "Multiply"
  , lhs: { kind: "LiteralInt", value: 1 }
  , rhs: { kind: "LiteralInt", value: 2 }
  }
, rhs: { kind: "LiteralInt", value: 3 }
}

> Parser.using("1 / 2", Parser.expression)
{ kind: "Divide"
, lhs: { kind: "LiteralInt", value: 1 }
, rhs: { kind: "LiteralInt", value: 2 }
}

> Parser.using("1 / 2 / 3", Parser.expression)
{ kind: "Divide"
, lhs: 
  { kind: "Divide"
  , lhs: { kind: "LiteralInt", value: 1 }
  , rhs: { kind: "LiteralInt", value: 2 } 
  }
, rhs: { kind: "LiteralInt", value: 3 }
}

> Parser.using("1 % 2", Parser.expression)
{ kind: "Modulus"
, lhs: { kind: "LiteralInt", value: 1 }
, rhs: { kind: "LiteralInt", value: 2 }
}

> Parser.using("1 % 2 % 3", Parser.expression)
{ kind: "Modulus"
, lhs: 
  { kind: "Modulus"
  , lhs: { kind: "LiteralInt", value: 1 }
  , rhs: { kind: "LiteralInt", value: 2 }
  }
, rhs: { kind: "LiteralInt", value: 3 }
}
```

### Term

```rebo-repl
> let Parser = import("./parser.rebo")

> Parser.using("123", Parser.term)
{ kind: "LiteralInt", value: 123 }

> Parser.using("true", Parser.term)
{ kind: "LiteralBool", value: true }

> Parser.using("false", Parser.term)
{ kind: "LiteralBool", value: false }

> Parser.using("\"Hello world\"", Parser.term)
{ kind: "LiteralString", value: "Hello world" }

> Parser.using("x", Parser.term)
{ kind: "Identifier", value: "x" }

> Parser.using("x()", Parser.term)
{ kind: "Call", name: "x", args: [] }

> Parser.using("x(1)", Parser.term)
{ kind: "Call", name: "x", args: [{ kind: "LiteralInt", value: 1 }] }

> Parser.using("x(1, true)", Parser.term)
{ kind: "Call", name: "x", args: [{ kind: "LiteralInt", value: 1 }, { kind: "LiteralBool", value: true }] }

> Parser.using("(x)", Parser.term)
{ kind: "Identifier", value: "x" }
```
