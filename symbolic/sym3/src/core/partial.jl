# Partial application
function papply(ex)
    n = 0
    missing_args = Expr(:tuple)
    function add_arg(x)
        n += 1
        push!(missing_args.args, x)
        x
    end

    f(x) = x
    function f(ex::Expr)
        if ex.head ≠ :... || ex.args[1] ≠ :_ 
            return ex
        end
        x = Symbol('_', n)
        arg = :($(x)...)
        add_arg(arg)
    end
    function f(x::Symbol)
        x ≠ :_ && return x
        arg = Symbol('_', n)
        add_arg(arg)
    end

    ex = walk(f, ex)
    n > 0 ? eval(Expr(:->, missing_args, ex)) : ex
end