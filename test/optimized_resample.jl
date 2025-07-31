using ParticleDA

nrank = 5
n_particle = 10

resampled_indices = sample_indices(n_particle, k=5, p=0.99)
println("Resampled Indices: ", resampled_indices)

resampled_indices = ParticleDA.optimized_resample!(resampled_indices, nrank)
println("Optimized Resampled Indices: ", resampled_indices)