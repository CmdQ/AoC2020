#!/usr/bin/julia

function load()
    re = Int[]
    open("inputs/expense-report.txt", "r") do f
        for i in eachline(f)
            push!(re, parse(Int, i))
        end
    end
    re
end

function find_product2(r::Array{Int})
    for (o, a) in enumerate(r)
        for i = o+1:length(r)
            if a + r[i] == 2020
                return a * r[i]
            end
        end
    end
end

function find_product3(r::Array{Int})
    for (o, a) in enumerate(r)
        for i = o+1:length(r)
            for j = i+1:length(r)
                if a + r[i] + r[j] == 2020
                    return a * r[i] * r[j]
                end
            end
        end
    end
end

using DataStructures

function find(r::Array{Int}, n, start = 1, which = nil())::Union{Int,Nothing}
    if start <= length(r)
        current = r[start]
        extended = cons(current, which)
        with_current = sum(extended)
        if with_current == 2020 && n == 1
            return prod(extended)
        else
            re = find(r, n, start + 1, which)
            if isnothing(re)
                return find(r, n - 1, start + 1, extended)
            else
                re
            end
        end
    end
end

const expenses = load()
println("Product of 2: ", find_product2(expenses))
println("Product of 3: ", find_product3(expenses))









using Test

@testset begin
    a = [11, 222, 1010, 3333, 1010]
    b = [20, 11, 222, 1010, 3333, 2000]
    c = [11, 222, 1010, 3333, 1009, 55555, 1]
    d = [20, 11, 222, 2, 1010, 3333, 1998]

    @testset "2 loops" begin
        @test find_product2(a) == 1010 * 1010
        @test find_product2(b) == 20 * 2000
    end

    @testset "3 loops" begin
        @test find_product3(c) == 1009 * 1010
        @test find_product3(d) == 2 * 20 * 1998
    end

    @testset "recursive equivalence" begin
        @test find(a, 2) == find_product2(a)
        @test find(b, 2) == find_product2(b)
        @test find(c, 2) == find_product2(c)
        @test find(d, 2) == find_product2(d)

        @test find(a, 3) == find_product3(a)
        @test find(b, 3) == find_product3(b)
        @test find(c, 3) == find_product3(c)
        @test find(d, 3) == find_product3(d)
    end

    @testset "solutions" begin
        @test find_product2(expenses) == 692916
        @test find_product3(expenses) == 289270976
    end
end