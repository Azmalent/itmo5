const Maybe{T} = Union{T, Nothing} where T

const Symbolic = Union{Expr, Symbol}

struct Bounds
    a :: Number
    b :: Number
end

struct Integral 
    expr   :: Union{Symbolic, Number}  
    diff   :: Symbolic
    bounds :: Maybe{Bounds}
end

createIntegral(expr, diff::Symbol, bounds = nothing) = Integral(expr, diff, bounds)
function createIntegral(expr, diff::Expr, bounds = nothing)
    # We need to validate that the differential contains ONE AND ONLY ONE variable
    vars = 0
    f(x) = nothing
    f(x::Symbol) = (vars += 1)
    walk(f, diff)

    if vars ≠ 1
        error("the differential must contain strictly one variable.")
    end

    Integral(expr, diff, bounds)
end

struct Thunk
    expr :: Expr 
end

createThunk(x) = x

# Eagerly evaluate eval() calls
function createThunk(ex::Expr)
    new_ex = Context.eagerCalc(ex)
    root_eager = ex.head == :call && ex.args[1] ∈ [:eval, :eval!]
    root_eager ? new_ex : Thunk(new_ex)
end

const Value = Union{Symbolic, Number, Integral, Thunk}

struct Assignment
    lvalue :: Union{Symbolic, Integral}
    rvalue :: Value
end

#-------------------------------------------------------------------------#

# string conversion overload
using Base: string
Base.string(t::Thunk) = Base.string(t.expr)

Base.string(bounds::Bounds) = "_$(wrap(bounds.a))^$(wrap(bounds.b))"

function Base.string(int::Integral)
    bounds = int.bounds ≠ nothing ? Base.string(int.bounds) : ""
    "int$(bounds) $(wrap(int.expr))*d$(wrap(int.diff))"
end
