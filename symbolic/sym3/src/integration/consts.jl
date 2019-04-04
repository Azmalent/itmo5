using Match

# Returns constant multiplier
# It's assumed that expression is simplified
consts(x) = (1, x)
function consts(ex::Expr)
    _ex = copy(ex)
    c = consts!(_ex)
    @match length(_ex.args[2:end]) begin
        0 => (c, 1)
        1 => (c, _ex.args[2])
        _ => (c, simplify(_ex))
    end
end

consts!(x) = 1
function consts!(ex::Expr)
    op = ex.args[1]
    args = ex.args[2:end]
    
    if op == :* 
        constants, new_args = partition(args, x -> isa(x, Number))
        ex.args = [op, new_args...]
        
        inner_consts = [consts!(a) for a ∈ new_args]
        return reduce(*, vcat(constants, inner_consts); init=1)
    elseif op == :/
        #TODO: improve (?)
        if args[1] isa Number
            ex.args[2] = 1
            return args[1] / consts!(args[2])
        elseif args[2] isa Number
            ex.args[3] = 1
            return consts!(args[1]) / args[2]
        end
    end
        
    1
end