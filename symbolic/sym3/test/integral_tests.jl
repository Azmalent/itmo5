include("../src/core.jl")
include("../src/integration.jl")

using Test

new = createIntegral

@testset "Validation" begin
    # Everything ok
    @test new(:(x-1), :x) ≠ nothing
    # Differential with no vars
    @test_throws ErrorException new(:(x-1), :(10 + 4*3))
    # Differential with multiple vars
    @test_throws ErrorException new(:(x^2), :(x*y))
end

@testset "Indefinite" begin
    calc(args...) = eval(new(args...))
    @test calc(:(sin(x)), :x) == :(-cos(x))
end

@testset "Definite" begin 

end