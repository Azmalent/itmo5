using Crayons: Crayon
using Match: @match
using PyCall: PyError

INFO_STYLE = Crayon(foreground = :blue)
INPUT_STYLE  = Crayon(foreground = :light_yellow)
FILE_INPUT_STYLE = Crayon(foreground = :magenta)
OUTPUT_STYLE = Crayon(foreground = :white, bold=false)
ERROR_STYLE  = Crayon(foreground = :red)

function help()
    println(INFO_STYLE, "Input uses EQN format.")
    println(OUTPUT_STYLE, """
        \t▪ Use curly brackets
        \t▪ Use 'over' for division and 'sup' for power""")
    println(INFO_STYLE, "Math functions:")
    println(OUTPUT_STYLE, """
        \tsqrt   log     log2    log10   exp
        \tsin    cos    tan    cot    sec    csc
        \tsinh   cosh   tanh   coth   sech   csch
        \tasin   acos   atan   acot   asec   acsc
        \tasinh  acosh  atanh  acoth  asech  acsch""")
    println(INFO_STYLE, "Other functions:")
    println(OUTPUT_STYLE, """
        \t▪ compute(x): evaluate the symbol x or an expression.
        \t▪ compute!(x): same as above, but also sets the value of x.
        \t▪ file(filename): execute commands from specified file.""")
    println(INFO_STYLE, "\nCall exit() to close REPL.")
end

function process_line(line)
    nline = strip(line)
    if nline == "?" 
        help()
    else
        ex = parseEqn(nline)
        repl_dispatch(ex)
    end
end

function file(filename)
    lines = filter(!isempty, [strip(ln) for ln in readlines(filename)])
    for line ∈ lines
        println(FILE_INPUT_STYLE, "> $(line)")
        process_line(line)
    end
end

function repl()
    print(INPUT_STYLE, "> ")
    try
        input = readline()
        process_line(input)
    catch e
        println(ERROR_STYLE,       
            if isa(e, Meta.ParseError) || isa(e, PyError)
                "Parsing error: $(e.msg)"
            elseif isa(e, MethodError) 
                "Signature error in function '$(e.f)'\nPassed args: " * join(["$(a)::$(typeof(a))" for a in e.args], ", ")
            elseif isa(e, SystemError)
                "System error $(e.errnum): $(e.prefix)"
            elseif isa(e, DomainError)
                "Domain error with $(e.val):\n$(e.msg)"
            elseif isa(e, ErrorException)
                "Error: $(e.msg)"
            elseif isa(e, StackOverflowError)
                "Error: stack overflow"
            else
                rethrow()
            end) 
    end
end    

repl_dispatch(::Nothing) = nothing
repl_dispatch(x) = println(OUTPUT_STYLE, x)

function repl_dispatch(x::Symbol)
    value = Context.get(x)
    println(OUTPUT_STYLE, string(value))
end

function repl_dispatch(ex::Assignment)
    l, r = ex.lvalue, ex.rvalue
    if isa(l, Expr)
        Context.eval(:($l = $r))
        println(OUTPUT_STYLE, "$l = $r")
    else
        Context.set(l, r)
        val = Context.get(l)
        println(OUTPUT_STYLE, "$l = $(string(val))")
    end
end

function repl_dispatch(int::Integral)
    result = Context.eval(int)
    println(OUTPUT_STYLE, string(result))
end

function repl_dispatch(ex::Expr)
    @assert ex.head == :call 

    result = Context.eval(Context.eagerCalc(ex))
    if result ≠ nothing 
        println(OUTPUT_STYLE, string(result))
    end
end