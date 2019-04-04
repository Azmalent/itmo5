using PyCall
using Match

pushfirst!(PyVector(pyimport("sys")["path"]), "", "./grammar/", "./src/grammar/")
@pyimport eqn

function parseEqn(input)
    obj = eqn.parse(input)
    eqnToJulia(obj)
end

eqnToJulia(x) = x
eqnToJulia(::Nothing) = nothing
eqnToJulia(str::AbstractString) = Meta.parse(str) 

function eqnToJulia(n::Real)
    integer = trunc(Int, n) 
    decimal = n - integer
    decimal == 0 ? integer : n
end

function eqnToJulia(obj::PyObject)
    @match obj[:__class__][:__name__] begin
        "EqnAssignment" => eqnAssignment(obj)
        "EqnExpression" => eqnExpression(obj)
        "EqnFunction"   => eqnFunction(obj)
        "EqnIntegral"   => eqnIntegral(obj)
        _ => Meta.ParseError("Unknown PyObject type.")
    end
end

function eqnExpression(obj)
    addBrackets(x) = x
    addBrackets(ex::Expr) = "($(string(ex)))"
    args = map(addBrackets ∘ eqnToJulia, obj[:args])
    exprString = join(args, " ")
    Meta.parse(exprString)
end

function eqnAssignment(obj)
    lvalue = eqnToJulia(obj[:lvalue])
    rvalue = eqnToJulia(obj[:rvalue])
    Assignment(lvalue, rvalue)
end

function eqnFunction(obj)
    name = Symbol(obj[:name])
    args = [eqnToJulia(x) for x in obj[:args]]
    Expr(:call, name, args...)
end

function eqnIntegral(obj)
    ex = eqnToJulia(obj[:intexpr])
    diff = eqnToJulia(obj[:diff])
    
    a, b = eqnToJulia(obj[:a]), eqnToJulia(obj[:b])
    bounds = isa(a, Nothing) ? nothing : Bounds(a, b)
    createIntegral(ex, diff, bounds)
end