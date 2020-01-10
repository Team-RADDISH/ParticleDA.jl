module Matrix_ls

# Solve the well-conditioned linear system
# Sum( m(i,j)*a(j) ) == v(i) for a(:)
# by Gauss-Seidel method.
function gs!(m::AbstractMatrix{T},         # coefficient matrix
             v::AbstractVector{T},         # values
             a::AbstractVector{T}) where T # answers
    n = length(a) # model size
    @assert length(v) == n
    @assert size(m) == (n, n)
    tolerance = 1e-6
    a0 = zeros(T, n)
    fill!(a, 0)
    iter = 0
    m_max = maximum(abs, m)

    while iter <= 10000
        @inbounds for i in 1:n
            wk = zero(T)
            @inbounds for j in 1:(i-1)
                wk += m[i,j] * a[j]
            end
            @inbounds for j in (i+1):n
                wk += m[i,j] * a[j]
            end
            a[i] = (v[i] - wk) / m[i,i]
        end
        if maximum(abs.(a0 .- a)) / m_max < tolerance
            return a
        end
        a0 .= a
        iter += 1
    end
    error("does not converge")
end

end # module
