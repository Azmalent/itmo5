# Return x, or default value if it's nothing
defaultTo(x, default) = x ≠ nothing ? x : default

# Clear collection (seems to be pretty efficient)
clear(collection) = filter(_ -> false, collection)
clear!(collection) = filter!(_ -> false, collection)

# To string + add brackets if it's an expression
wrap(x) = string(x)
wrap(ex::Expr) = "($(string(ex)))"

# Map expression (skips first argument for CALL expressions) 
walk(f, leaf) = f(leaf)
function walk(f, ex::Expr)
    new_ex = copy(ex)
    if ex.head == :call 
        op, args = new_ex.args[1], new_ex.args[2:end]
        new_ex.args = [op, [walk(f, x) for x ∈ args]...]
    else
        println(ex)
        map!(x -> walk(f, x), new_ex.args)
    end
    new_ex
end

# Find an element in expression
contains(x, ex) = x == ex
function contains(x, ex::Expr) 
    found = false
    walk(y -> found |= y==x, ex)
    found
end

# Split a collection by predicate
function partition(xs, pred)
    a, b = [], []
    for x ∈ xs
        push!(pred(x) ? a : b, x)
    end
    a, b
end

# Flatten nested array
flatten(x) = x
flatten(xs::Array) = vcat([flatten(x) for x ∈ xs]...)