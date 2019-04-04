using PyCall
pushfirst!(PyVector(pyimport("sys")["path"]), "", "./core/", "./src/core/")
@pyimport plotwindow

module Context
    const pi = Base.pi
    const e = Base.ℯ
    const oo = Inf

    help() = Main.help()
    file() = Main.file()

    function get(x::Symbol)   
        val = try 
            Base.eval(Context, x)
        catch e
            if isa(e, UndefVarError)
                error("variable $(e.var) not defined.")
            end
        end
        val
    end

    function set(x::Main.Symbolic, value)
        if x ∈ [:pi, :e, :oo]
            error("$(x) is a constant and cannot be redefined.")
        end
        thunk = Main.createThunk(value)
        eval( :($x = $thunk) )
    end

    eval!(x) = error("eval! can only accept variables (you passed: $(typeof(x)))")
    function eval!(x::Symbol) 
        value = eval( Context.get(x) )
        set(x, value)
    end

    eval(int::Main.Integral) = Main.evalIntegral(int)
    eval(t::Main.Thunk) = eval(t.expr)

    function eval(x::Symbol)
        val = try 
            Base.eval(Context, x)
        catch e
            if isa(e, UndefVarError)
                error("variable $(e.var) not defined.")
            end
        end
        val
    end

    function eval(expr::Expr)
        if expr.head == :call && expr.args[1] == :eval!
            return eval!(expr)
        end

        eval_expr = copy(expr)
        if expr.head == :call
            if expr.args[1] == :plot
                return plot(expr.args[2:end]...)
            end
            evalThunk(x) = x
            evalThunk(t::Main.Thunk) = eval(t)
            args = map(evalThunk ∘ eval, expr.args[2:end])
            eval_expr.args = [expr.args[1], args...]
        end

        Base.eval(Context, eval_expr)
    end

    function plot(args...)
        n = length(args)
        if (n < 3 || n % 3 != 0) 
            error("plot() requires a number of arguments divisible by 3 (you passed $n)")
        end
        
        plots = []
        data = [args[i:i+2] for i in 1:3:n]
        for (expr, a, b) in data
            a, b = eval(a), eval(b)
            step = (b - a) / 100
            xs, ys = @eval begin 
                local func(x) = $expr
                local xs, ys = [], []
                for x in $a:$step:$b
                    try 
                        y = func(x)
                        push!(xs, x)
                        push!(ys, y)
                    catch e
                        !isa(e, DomainError) && rethrow()
                    end
                end
                @assert length(xs) == length(ys)
                xs, ys
            end
            push!(plots, (xs, ys, "y = $expr"))
        end

        Main.plotwindow.createPlot(plots)
    end 

    # Evals all eager parts of expression
    eagerCalc(x) = x
    function eagerCalc(ex::Expr)
        if ex.head == :call && length(ex.args) == 2
            func, arg = ex.args[1], ex.args[2]
            if func == :eval
                return eval(arg)
            elseif func == :eval!
                return eval!(arg)
            end
        end

        Expr(ex.head, map(eagerCalc, ex.args)...)
    end
end