#!/bin/sh

histfile="$HOME/.cache/dmenu_calc.log"

history="$(cat "$histfile" 2>/dev/null)"

eq=$(printf "%s" "$history" | dmenu -fn "Monospace 10" -p "write equation: ")
if [ "$eq" != "\n" ] && [ "$eq" != "" ]; then
    printf "%s\n" "$eq" >> "$histfile"
    ret=$(python3 -c "
from tokenize import tokenize, untokenize, NUMBER, STRING, NAME, OP
from io import BytesIO
from decimal import Decimal, getcontext
from math import *
getcontext().prec = 6

def float_sucks(s):
    # Stolen from: https://docs.python.org/3.7/library/tokenize.html#examples
    result = []
    g = tokenize(BytesIO(s.encode('utf-8')).readline)  # tokenize the string
    for toknum, tokval, _, _, _ in g:
        if toknum == NUMBER:  # replace NUMBER tokens
            result.extend([
                (NAME, 'Decimal'),
                (OP, '('),
                (STRING, repr(tokval)),
                (OP, ')')
            ])
        else:
            result.append((toknum, tokval))
    return untokenize(result).decode('utf-8')


res = float_sucks(\"$eq\")
exec(f'print({res})')
")
    notify-send -u low -t 5000 "Result" "$ret";
fi

