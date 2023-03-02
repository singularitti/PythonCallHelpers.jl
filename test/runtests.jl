using PythonCallHelpers
using Test

@testset "PythonCallHelpers.jl" begin
    @testset "Test subtyping from `Any`" begin
        @pymutable T Any o
        @test supertype(T) == Any
        @test fieldnames(T) == (:o,)
    end

    @testset "Test subtyping from an abstract type" begin
        abstract type MyType end
        @pyimmutable My MyType o
        @test supertype(My) == MyType
        @test fieldnames(My) == (:o,)
    end
end
