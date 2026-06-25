using BenchmarkTools

@testset "GPU vs CPU" begin
    cuda_available = @isdefined(CUDA) && CUDA.functional()
    if cuda_available
        
        waveTypes = (morl, dog2, paul2, Morse(3,20,1))
        β = 2
        boundaries = (PerBoundary(), SymBoundary())
        averagingLength = 2
        extraOctaves = 0
        xSizes = (512, 2048, 8192)
        
        @testset "xSz=$xSize, boundary=$boundary, wave=$wave" for xSize in xSizes,
            boundary in boundaries,
            wave in waveTypes

            wfc = wavelet(wave, β = β, boundary = boundary,
                averagingLength = averagingLength,
                extraOctaves = extraOctaves)

            # CPU arrays: 
            xr_cpu  = randn(Float32, xSize)
            xc_cpu  = randn(ComplexF32, xSize)

            # GPU arrays: 
            xr_gpu  = CuArray(xr_cpu)
            xc_gpu  = CuArray(xc_cpu)


            # Compute daughters on CPU, then move to GPU: 
            daughters_cpu, ω = with_logger(ConsoleLogger(stderr, Logging.Error)) do
                computeWavelets(xSize, wfc)
            end
            daughters_gpu = CuArray(Float32.(daughters_cpu))

            # CPU transforms:
            yr_cpu = with_logger(ConsoleLogger(stderr, Logging.Error)) do
                cwt(xr_cpu, wfc, Float32.(daughters_cpu))
            end
            yc_cpu = with_logger(ConsoleLogger(stderr, Logging.Error)) do
                cwt(xc_cpu, wfc, copy(Float32.(daughters_cpu)))
            end

            # GPU transforms: 
            yr_gpu = with_logger(ConsoleLogger(stderr, Logging.Error)) do
                cwt(xr_gpu, wfc, daughters_gpu)
            end
            yc_gpu = with_logger(ConsoleLogger(stderr, Logging.Error)) do
                cwt(xc_gpu, wfc, CuArray(Float32.(daughters_cpu)))
            end


            # Correctness: Check that the GPU result matches the CPU result. 
            @test Array(yr_gpu) ≈ convert.(eltype(yr_gpu), yr_cpu)  rtol=1e-3
            @test Array(yc_gpu) ≈ convert.(eltype(yc_gpu), yc_cpu)  rtol=1e-3

            # Make sure that element types are preserved. 
            @test eltype(Array(yr_gpu)) <: Union{Float32, ComplexF32}
            @test eltype(Array(yc_gpu)) <: Union{Float32, ComplexF32}
            @test eltype(yr_cpu) <: Union{Float32, ComplexF32}
            @test eltype(yc_cpu) <: Union{Float32, ComplexF32}

            # Compare the speed: 
            daughters_cpu_bench = Float32.(daughters_cpu)
            t_cpu = @belapsed cwt($xr_cpu, $wfc, copy($daughters_cpu_bench))
            t_gpu = @belapsed begin
                cwt($xr_gpu, $wfc, copy($daughters_gpu))
                CUDA.synchronize()
            end

            @info "CWT speed: wave=$(wave), xSize=$(xSize), boundary=$(boundary)" cpu_time=t_cpu gpu_time=t_gpu speedup=t_cpu/t_gpu
        end
    else
        @warn "CUDA not available or not functional, skipping GPU tests"
    end
end