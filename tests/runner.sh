#!/bin/bash

MYHOME=$(dirname $0)

rm "$MYHOME"/*.temp

for SRC in "$MYHOME"/*.src
do
    echo $SRC
    rebo "$MYHOME"/../src-compiler/main.rebo "$SRC"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to compile $SRC"
        exit 1
    fi

    OUT=$(echo $SRC | sed 's/\.src/\.temp/')

    "$MYHOME"/../zig-out/bin/bytecode-lang $(echo "$SRC" | sed 's/\.src/\.bc/') | tee "$OUT"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to execute $SRC"
        exit 1
    fi

    if [ ! -f "$OUT" ]; then
        echo "Error: No output file $OUT"
        exit 1
    fi

    EXPECTED=$(echo $SRC | sed 's/\.src/\.out/')
    if [ ! -f "$EXPECTED" ]; then
        echo "Error: No expected output file $EXPECTED"
        exit 1
    else
        grep -v "^debug:" "$OUT" > "$OUT".temp
        diff "$OUT".temp "$EXPECTED"
        if [ $? -ne 0 ]; then
            echo "Error: Output $OUT is different from expected output $EXPECTED"
            exit 1
        fi
    fi

    rm "$MYHOME"/*.temp
done

