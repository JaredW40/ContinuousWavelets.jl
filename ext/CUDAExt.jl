module CUDAExt

using ContinuousWavelets: ZPBoundary, SymBoundary
using ContinuousWavelets, CUDA

function ContinuousWavelets.reflect(Y::CuArray, bt)
    n1 = size(Y, 1)
    if typeof(bt) <: ZPBoundary
        base2 = ceil(Int, log2(n1))
        padding = fill!(similar(Y, 2^(base2) - n1, size(Y)[2:end]...), 0)
        x = cat(Y, padding, dims = 1)
    elseif typeof(bt) <: SymBoundary
        x = cat(Y, reverse(Y, dims = 1), dims = 1)
    else
        x = Y
    end
    return x
end

end