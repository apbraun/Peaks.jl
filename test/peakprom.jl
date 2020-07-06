a = 3
b = 2
c = 1

fs = 100
T = 1/fs
f1 = 5
f2 = 10
f3 = 30

t = T:T:fs

x1 = a*sin.(2*pi*f1*T*t)+b*sin.(2*pi*f2*T*t)+c*sin.(2*pi*f3*T*t);

@testset "Peak prominence" begin
    @testset "Reciprocity" begin
        pi, pp = peakprom(x1, Maxima())
        ni, np = peakprom(-x1, Minima())

        @test pi == ni
        @test pp == np
    end


    @testset "Prominence values" begin
        i, p = peakprom(sin.(1e-5:1e-5:9*pi), Maxima())

        @test p[[1,5]] ≈ [1., 1.] atol=1e-4
        @test p[[2,3,4]] ≈ [2., 2., 2.] atol=1e-4
    end

    @testset "Minimum prominence" begin
        minprom = 1.5
        i, p = peakprom(sin.(1e-5:1e-5:9*pi), Maxima())
        mi, mp = peakprom(sin.(1e-5:1e-5:9*pi), Maxima(), 1, minprom)
        @test all(x -> x >= minprom, mp)
    end

    # issue #4
    let i, p
        i, p = peakprom(zeros(10), Maxima())
        @test isempty(i)
        @test isempty(p)
    end

    @testset "Strictbounds" begin
        si, sp = peakprom([1.,0,1,0,1], Maxima())
        nsi, nsp = peakprom([1.,0,1,0,1], Maxima(), 1, 0., false)
        @test si == [3]
        @test nsi == [1,3,5]
        @test sp == [1.]
        @test nsp == [0.,1.,0.]
    end

    @testset "Missings and NaNs" begin
        m1 = [0.,1,0,2,missing,2,0,1,0]
        n1 = [0.,1,0,2,NaN,2,0,1,0]
        mi, mp = peakprom(m1,Maxima())
        ni, np = peakprom(n1,Maxima())
        @test mp == [1.,1.]
        @test np == [1.,1.]
        mi, mp = peakprom(m1, Maxima(), 1, 1.5, false)
        ni, np = peakprom(n1, Maxima(), 1, 1.5, false)
        @test mp == [2.,2.]
        @test np == [2.,2.]
    end
end
