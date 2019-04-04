const Symbolic = Union{Expr, Symbol}
const Value = Union{Symbolic, Number}

struct Rule
    pat
    rpat
    check
end