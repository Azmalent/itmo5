include("core.jl")

e = ℯ
oo = Inf

eqnRegex = let eqnexp(name) = string("(?<$(name)>", raw"(?:\{.*\})|(?:[^\s]+))"),
    sub_then_sup = string("(?:sub\\s+", eqnexp("a1"), "\\s+sup\\s+", eqnexp("b2"), ")"),
    sup_then_sub = string("(?:sup\\s+", eqnexp("b1"), "\\s+sub\\s+", eqnexp("a2"), ")"),
    indices = "(?:(?:$(sub_then_sup)|$(sup_then_sub))\\s+)?"
    string("^\\s*int\\s+", indices, eqnexp("ex"), "\$") |> Regex
end

eqnRules = Dict(
    "{" => "(",
    "}" => ")",
    r"\s+ sup  \s+"x => "^",
    r"\s+ over \s+"x => "/"
)


function eqnToJulia(ex)
    for rule ∈ eqnRules
        ex = replace(ex, rule)
    end
    Meta.parse(ex)
end


function calculate(int::Expr, (a, b))
    @eval f(x) = $int

    ε = eps(Float64)
    if !isfinite(f(a))
        a += ε
    end
    if !isfinite(f(b))
        b -= ε
    end

    result = f(b) - f(a)
    isfinite(result) ? result : error("функция не интегрируема на заданном интервале.")
end

calculate(int::Expr, bounds::Nothing) = int

calculate(::Nothing, _) = error("неизестный интеграл.")


function wrapInf(x)
    x == Inf  && return :oo
    x == -Inf && return :(-oo)
    x
end
wrap(ex::Expr) = "($(walk(wrapInf, ex)))"
wrap(x) = "$(wrapInf(x))"


try
    print("Введите выражение Eqn: \n> ")
    int = readline()
    m = match(eqnRegex, int)
    m==nothing && error("некорректный ввод.")

    a, b = defaultTo(m["a1"], m["a2"]), defaultTo(m["b1"], m["b2"])
    if (a, b) == (nothing, nothing)
        bounds = nothing
    else
        α, β = eqnToJulia(a), eqnToJulia(b)
        bounds = eval(α), eval(β)
    end

    ex = eqnToJulia(m["ex"])
    integral = integrate(ex, :x)
    result = calculate(integral, bounds)

    if bounds ≠ nothing
        ascii_bounds = " _$(wrap(bounds[1])) ^$(wrap(bounds[2]))"
        result_rounded = round(result * 1000) / 1000
        eq_sign = result_rounded == result ? "=" : "~~"
        print(string("int", ascii_bounds, "$(wrap(ex))dx $(eq_sign) ", result_rounded))
    else
        print(string("int", "$(wrap(ex))dx = ", result))
    end
catch e
    if e isa Meta.ParseError
        println("Ошибка парсинга выражения: $(e.msg)")
    elseif e isa ErrorException
        println("Ошибка: $(e.msg)")
    else
        rethrow()
    end
end

print("\nНажмите любую клавишу")
readline()
nothing