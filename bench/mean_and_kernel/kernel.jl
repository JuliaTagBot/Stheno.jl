@benchset "kernel" begin

    @benchset "ZeroKernel{Float64}()" begin
        create_benchmarks(ZeroKernel{Float64}(); grads=false)
    end
    # @benchset "OneKernel()" begin
    #     create_benchmarks(OneKernel(); grads=false)
    # end
    # @benchset "SEKernel" begin
    #     @benchset "Real CPU" create_benchmarks(SEKernel())
        # @benchset "Real GPU" create_benchmarks(
        #     SEKernel();
        #     x=randn(Float32), x′=randn(Float32),
        #     x̄s=[CuArray{Float32}(randn(N)) for N in Ns()],
        #     x̄′s=[CuArray{Float32}(randn(N)) for N in Ns()],
        # )

    #     for D in Ds()
    #         @benchset "ColVecs (D=$D) CPU" create_benchmarks(
    #             SEKernel();
    #             x=randn(D), x′=randn(D),
    #             x̄s=[ColVecs(randn(D, N)) for N in Ns()],
    #             x̄′s=[ColVecs(randn(D, N)) for N in Ns()],
    #         )
    #     end

    #     # See https://github.com/FluxML/Zygote.jl/issues/44
    #     @benchset "SEKernel Almost-Toeplitz" create_benchmarks(
    #         SEKernel();
    #         x=randn(), x′=randn(),
    #         x̄s=[range(-randn(), step=randn(), length=N) for N in Ns()],
    #         x̄′s=[range(-randn(), step=randn(), length=N) for N in Ns()],
    #     )

    #     δ = randn()
    #     @benchset "SEKernel Toeplitz" create_benchmarks(
    #         SEKernel();
    #         x=randn(), x′=randn(),
    #         x̄s=[range(-randn(), step=δ, length=N) for N in Ns()],
    #         x̄′s=[range(-randn(), step=δ, length=N) for N in Ns()],
    #     )
    # end

    # @benchset "PerEQ" begin
    #     @benchset "Real CPU" create_benchmarks(PerEQ())
    #     # @benchset "Real GPU" create_benchmarks(PerEQ();
    #     #     x = randn(Float32), x′=randn(Float32),
    #     #     x̄s=[CuArray{Float32}(randn(N)) for N in Ns()],
    #     #     x̄′s=[CuArray{Float32}(randn(N)) for N in Ns()],
    #     # )
    # end
end
