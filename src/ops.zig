pub const Op = enum(u8) {
    PUSH, // I
    PUSHI, // I
    PUSHS, // S

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
};
