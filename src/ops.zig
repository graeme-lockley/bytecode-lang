pub const Op = enum(u8) {
    PUSH, // I
    PUSHI, // I
    PUSHS, // S
    STOREG, // I

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
