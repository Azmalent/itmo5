include("core/core.jl")
include("integration/integration.jl")
include("grammar/grammar.jl")
include("repl.jl")

using .Context;

println(INFO_STYLE, "Welcome! Use EQN format for input.")
println(INFO_STYLE, "Enter ? for help.")

if !isempty(ARGS)
    for arg in ARGS
        file(arg)
    end
end

while true
    repl()
end