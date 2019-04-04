using Espresso: @simple_rule

const NUM_PHS = [:a, :n]    # Эти символы в паттернах должны соответствовать числам
integralTable = []

addMatch!(x::Symbol) = Expr(:ref, :match, QuoteNode(x))

function addMatch!(ex::Expr)
    for (i, x) ∈ enumerate(ex.args)
        if i == 1 && ex.head == :call 
            continue
        elseif x isa Symbolic
            ex.args[i] = addMatch!(x)
        end
    end
    ex
end

addMatch(ex::Expr) = Expr(:->, :match, addMatch!(ex))

macro integration_rule(pat, rpat, condition = nothing)
    conditions = Any[m -> m[p] isa Number for p ∈ NUM_PHS if contains(p, pat)]
    if condition ≠ nothing
        condition = condition |> addMatch |> eval
        push!(conditions, condition)
    end

    fullCondition = _ -> true
    if !isempty(conditions)
        fullCondition = match -> all(f -> f(match), conditions)
    end

    rule = Rule(pat, rpat, fullCondition)
    push!(integralTable, rule)
    nothing
end

@simple_rule    (+)(x)     x
@simple_rule    (*)(x)     x
@simple_rule    x - -y     x + y
@simple_rule    x + -y     x - y

@integration_rule   x       x^2 / 2
@integration_rule   1/x     log(x)
@integration_rule   x^n     x^(n+1) / (n+1)       n ≠ -1
@integration_rule   a^x     a^x / log(a)
@integration_rule   exp(x)  e^x
@integration_rule   e^x     e^x
@integration_rule   exp(-x) -e^(-x)
@integration_rule   e^(-x)  -e^(-x)

@integration_rule   sin(x)  -cos(x)
@integration_rule   cos(x)  sin(x)
@integration_rule   1 / sin(x)^2      -cot(x)
@integration_rule   1 / cos(x)^2      tan(x)

@integration_rule   log(x)            x*log(x) - x
@integration_rule   1/(x*log(x))      log(log(x))
@integration_rule   x * log(x)        x^2 * (log(x)/2 - 1/4)
@integration_rule   x^n * log(x)      x^(n+1) * (log(x)/(n+1) - 1/(n+1)^2)