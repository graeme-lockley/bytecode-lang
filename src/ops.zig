pub const Op = enum(u8) {
    PUSH, // I
    PUSHL, // I
    PUSHI, // I
    PUSHS, // S
    STORE, // I
    STOREL, // I

    CALL, // I
    RET, // I
    DISCARD,

    PRINTLN,
    PRINTB,
    PRINTI,
    PRINTS,

    EQI,
    NEQI,
    LTI,
    LEI,
    GTI,
    GEI,

    ADDI,
    SUBTRACTI,
    MULTIPLYI,
    DIVIDEI,
    MODULUSI,

    JMP, // I
    JMP_EQ_ZERO, // I
    JMP_NEQ_ZERO, // I
};
