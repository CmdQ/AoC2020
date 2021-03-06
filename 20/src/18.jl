using Utils

const Num = Int

function parse_file(f)
    collect(eachline(f))
end

function load()
    open(joinpath(@__DIR__, "18.txt"), "r") do f
        parse_file(f)
    end
end

isnodigit = !isdigit

is_paren(c) = c == '(' || c == ')'

function find_matching(s, from)
    @assert s[from] == '('
    level = 1
    while true
        cand = findnext(is_paren, s, from + 1)
        level -= s[cand] == ')' ? 1 : -1
        level == 0 && return cand
        from = cand
    end
end

function tokenize_l2r(expr)
    re = []
    cursor = 1
    while cursor <= length(expr)
        if expr[cursor] == '('
            close = find_matching(expr, cursor)
            push!(re, tokenize_l2r(expr[cursor+1:close-1]))
            cursor = close + 1
        elseif expr[cursor] == '+'
            push!(re, :plus)
            cursor += 1
        elseif expr[cursor] == '*'
            push!(re, :times)
            cursor += 1
        elseif isdigit(expr[cursor])
            after = something(findnext(isnodigit, expr, cursor), length(expr) + 1)
            push!(re, parse(Int, expr[cursor:after-1]))
            cursor = after
        else
            cursor += 1
        end
    end
    re
end

evaluate_l2r(term::Int) = term

function evaluate_l2r(terms::Array)
    acc = evaluate_l2r(terms[1])
    i = 2
    while i <= length(terms)
        if terms[i] == :plus
            acc += evaluate_l2r(terms[i + 1])
        elseif terms[i] == :times
            acc *= evaluate_l2r(terms[i + 1])
        end
        i += 2
    end
    acc
end

function reduce_stack(ops, operands)
    while true
        len = length(ops)
        if len == 0
            @assert length(operands) == 1
            return operands[1]
        elseif len >= 1 && ops[end] == :plus
            push!(operands, pop!(operands) + pop!(operands))
            pop!(ops)
        elseif len >= 2 && ops[end] == :times == ops[end - 1]
            keep = pop!(operands)
            push!(operands, pop!(operands) * pop!(operands))
            push!(operands, keep)
            pop!(ops)
        else
            push!(operands, pop!(operands) * pop!(operands))
            @assert pop!(ops) == :times
        end
    end
end

function evaluate(terms::Array)
    stack = Num[]
    for t in terms
        if isa(t, Num)
            push!(stack, t)
        else
            a = pop!(stack)
            b = pop!(stack)
            push!(stack, t == :+ ? a + b : a * b)
        end
    end

    only(stack)
end

function tokenize(expr)
    expr = replace(expr, " " => "")
    operands = Union{Num,Symbol}[]
    ops = Symbol[]

    cursor::Num = 1
    while cursor <= length(expr)
        if expr[cursor] == '('
            push!(ops, :open)
        elseif expr[cursor] == ')'
            while true
                top = pop!(ops)
                top == :open && break
                push!(operands, top)
            end
        elseif isdigit(expr[cursor])
            after = something(findnext(isnodigit, expr, cursor), length(expr) + 1)
            push!(operands, parse(Num, expr[cursor:after-1]))
            cursor = after
            continue
        elseif expr[cursor] == '+'
            push!(ops, :+)
        elseif expr[cursor] == '*'
            while !isempty(ops) && ops[end] == :+
                push!(operands, pop!(ops))
            end
            push!(ops, :*)
        end
        cursor += 1
    end

    while !isempty(ops)
        push!(operands, pop!(ops))
    end

    operands
end

function ex1(eqs)
    sum(eq -> tokenize_l2r(eq) |> evaluate_l2r, eqs)
end

function ex2(eqs)
    sum(eq -> tokenize(eq) |> evaluate, eqs)
end

eqs = load()

println("Sum of equations: ", ex1(eqs))
println("With precedence: ", ex2(eqs))







using Test

@testset "Operation Order" begin
@test find_matching("(3+5)", 1) == 5
@test find_matching("((3+5))", 1) == 7
@test find_matching("((3+5))", 1) == 7
@test find_matching("((3+5))", 2) == 6

@testset "example 1" begin
        @test ex1(parse_file(IOBuffer("1 + 2 * 3 + 4 * 5 + 6"))) == 71
        @test ex1(parse_file(IOBuffer("1 + (2 * 3) + (4 * (5 + 6))"))) == 51
        @test ex1(parse_file(IOBuffer("2 * 3 + (4 * 5)"))) == 26
        @test ex1(parse_file(IOBuffer("5 + (8 * 3 + 9 + 3 * 4 * 3)"))) == 437
        @test ex1(parse_file(IOBuffer("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"))) == 12240
        @test ex1(parse_file(IOBuffer("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"))) == 13632
    end

    @testset "example 2" begin
        @test ex2(parse_file(IOBuffer("1 + (2 * 3) + (4 * (5 + 6))"))) == 51
        @test ex2(parse_file(IOBuffer("2 * 3 + (4 * 5)"))) == 46
        @test ex2(parse_file(IOBuffer("5 + (8 * 3 + 9 + 3 * 4 * 3)"))) == 1445
        @test ex2(parse_file(IOBuffer("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"))) == 669060
        @test ex2(parse_file(IOBuffer("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"))) == 23340
    end

    @testset "results" begin
        @test ex1(eqs) == 12956356593940
        @test ex2(eqs) == 94240043727614
    end
end
