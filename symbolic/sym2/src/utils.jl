defaultTo(x, default) = x ≠ nothing ? x : default

walk(f, leaf) = f(leaf)
function walk(f, ex::Expr)
    new_ex = copy(ex)
    new_ex.args = [walk(f, x) for x ∈ new_ex.args]
    new_ex
end

contains(x, ex) = x == ex
function contains(x, ex::Expr) 
    found = false
    walk(y -> found |= y==x, ex)
    found
end

function partition(xs, pred)
    a, b = [], []
    for x ∈ xs
        push!(pred(x) ? a : b, x)
    end
    a, b
end