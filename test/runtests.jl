using ContinuousWavelets, Wavelets, Interpolations, LinearAlgebra
using Test, Documenter
using FFTW
using Logging, Random

inGithubAction = get(() -> "", ENV, "JULIA_IN_GITHUB_ACTION") == "true"
inGithubActionOnMac = get(() -> "", ENV, "JULIA_IN_GITHUB_ACTION_ON_MAC") == "macOS-latest"
ENV["LINES"] = "9"
ENV["COLUMNS"] = "60"

const GROUP = get(ENV, "GROUP", "All")

@testset "ContinuousWavelets.jl" begin
    if (inGithubAction && !inGithubActionOnMac)
        doctest(ContinuousWavelets)
    end
    include("basicTypesAndNumber.jl")
    include("deltaSpikes.jl")
    include("utilsTests.jl")
    include("defaultProperties.jl")
    include("inversionTests.jl")

    if GROUP in ("All", "CUDA")
        try
            using CUDA, BenchmarkTools
            include("CUDATests.jl")
        catch e
            @info "CUDA not available in this environment -- skipping CUDATests.jl" exception=e
        end
    end

    if GROUP in ("All", "Metal")
        try
            using Metal, BenchmarkTools
            include("MetalTests.jl")
        catch e
            @info "Metal not available in this environment -- skipping MetalTests.jl" exception=e
        end
    end
end
# TODO:
#       test averaging types
#            various extra dimensions
#            inverse is actually functional