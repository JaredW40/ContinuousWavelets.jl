using ContinuousWavelets, Wavelets, Interpolations, LinearAlgebra
using Test, Documenter
using FFTW
using Logging, Random

try
    using CUDA
    using BenchmarkTools
catch
end

inGithubAction = get(() -> "", ENV, "JULIA_IN_GITHUB_ACTION") == "true"
inGithubActionOnMac = get(() -> "", ENV, "JULIA_IN_GITHUB_ACTION_ON_MAC") == "macOS-latest"
# these make sure that the printing width/length is kept to a reasonable amout for actually reading the docs
ENV["LINES"] = "9"
ENV["COLUMNS"] = "60"
@testset "ContinuousWavelets.jl" begin
    if (inGithubAction && !inGithubActionOnMac)
        doctest(ContinuousWavelets)
    end
    include("basicTypesAndNumber.jl")
    include("deltaSpikes.jl")
    include("utilsTests.jl")
    include("defaultProperties.jl")
    include("inversionTests.jl")

    if Base.@isdefined(CUDA) && CUDA.functional()
        include("gpu_tests.jl")
    end
end
# TODO:
#       test averaging types
#            various extra dimensions
#            inverse is actually functional
