using Espresso: simplify, matchex, rewrite, set_default_placeholders


using Match: @match

set_default_placeholders(Set([:x, :y, :a, :b, :n]))

integrate(ex::Value, x::Symbolic = :x) = simplify ∘ _integrate ∘ simplify

function _integrate(n, x) 
    @match n begin
        0 => 0
        1 => x
        n::Number => Expr(:call, :*, n, x)
        _ => tableIntegral(n, x)
    end
end

function _integrate(ex::Expr, x)
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
        pat = Expr(:call, :*, rule.pat, :(d(x)))
        match = matchex(pat, int; allow_ex = true, exact = false)

        if match ≠ nothing && rule.check(match)
            return rewrite(ex, rule.pat, rule.rpat)
        end
    end

    nothing
end
 