using Espresso: simplify, matchex, rewrite, set_default_placeholders
using Match: @match

set_default_placeholders(Set([:x, :y, :a, :b, :n]))

# Get the integration variable
integrationvar(diff::Symbol) = diff
function integrationvar(diff::Expr)
    var = nothing
    f(x) = nothing
    f(x::Symbol) = (var = x)
    walk(f, diff)

    @assert var ≠ nothing
    var
end

function evalIntegral(int::Integral)
    antiderivative = integrate(int.expr, int.diff)

    if int.bounds == nothing
        return antiderivative
    end

    var = integrationvar(int.diff)
    result = @eval Context begin 
        F($var) = $antiderivative

        a, b = eval($int.bounds.a), eval($int.bounds.b)
        ε = eps(Float64)
        if !isfinite(F(a))
            a = (a < b) ? (a + ε) : (a - ε)
        end
        if !isfinite(F(b))
            b = (b > a) ? (b - ε) : (b + ε)
        end
        F(b) - F(a)
    end

    if !isfinite(result) 
        error("function $(int.expr) cannot be integrated at ($(int.bounds.a), $(int.bounds.b)).")
    end
    
    result 
end

function integrate(n, x) 
    @match n begin
        0 => 0
        1 => x
        n::Number => Expr(:call, :*, n, x)
        _ => tableIntegral(n, x)
    end
end

function integrate(ex::Expr, x)
    if ex.head ≠ :call
        ArgumentError("ex must be a call expression") |> throw
    end

    op = ex.args[1]
    @match op begin 
        :+ || :- => Expr(:call, op, [integrate(a, x) for a ∈ ex.args[2:end]]...) 
        :* || :/ => 
            @match consts(ex) begin
                (0, _)  => 0
                (1, ex) => tableIntegral(ex, x)
                (n, ex) => Expr(:call, :*, n, tableIntegral(ex, x))
            end
        _ => tableIntegral(ex, x)
    end
end

function tableIntegral(ex::Value, x)
    int = :($(ex) * d($(x)))
    
    for rule ∈ integralTable
        pat = Expr(:call, :*, rule.left, :(d(x)))
        match = matchex(pat, int; allow_ex = true, exact = false)

        if match ≠ nothing && rule.condition(match)
            return rewrite(ex, rule.left, rule.right)
        end
    end

    nothing
end