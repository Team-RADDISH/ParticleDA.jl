###################################
### Last Update: 29 Oct 20
###################################
### ''Simulation of Optimal Proposal''
### Code follows method/notation in Dietrich & Newsam (96)
###################################

using Distributions
using LinearAlgebra
using FFTW
using Random
using SpecialFunctions

####################################################################
####################################################################

Random.seed!(123)

#### Parameters for Covariance Function
struct f_th
    σ::Float64
    λ::Float64
    ν::Float64
end

#### Parameters for Grid
struct f_gr
    p::Int ## Number of Grid Points Along x-axis is (p+1)
    q::Int ## Number of Grid Points Along y-axis is (q+1)
    P::Float64
    Q::Float64 ## 2D-Field is rectangle [0,P]x[0,Q]
end

#### Parameters for Stations
struct f_st
  st_ij::Array{Int64,2} ## the position of the stations on the grid
                        ## i.e station positions determined using 2 co-ordinates
   st_p::Array{Int64,1} ## the no of grid point occupied by each station
                        ## i.e station positions determined using 1 co-ordinate
end

####################################################################
#### Example #######################################################

th = f_th(1.0, 1.0, 0.5)

gr = f_gr(20, 20, 40.0, 40.0)

###################################################
#### Example ######################################

p = gr.p; q = gr.q; P = gr.P; Q = gr.Q

Dx = P/p; Dy = Q/q ## Grid Steps Along x and y Directions

###################################################
#### Example ######################################

#### In real case Stations will be read from a file containing co-ordinates;
#### here, I delect position of n2 Stations at random from all grid nodes

n2 = 3; n1 = (p+1)*(q+1)

grid_F = fill(0,(n1,2))

#### the loop contructs 2-dim co-ordinates for all grid points
for j in 0:q

  for i in 0:p

    grid_F[j*(p+1)+i+1,:] = [i, j]

  end

end
####

st_p = sample(1:n1,n2,replace=false)

st_ij = grid_F[st_p,:]

st = f_st(st_ij, st_p)

###################################################
#### Example ######################################

#### I simulate some arbitrary values to be used as observations of height
#### I give an example value to the standard deviation Sobs;
#### I only consider a single time instance

Yobs_t = rand(Normal(0,1), n2)
#### the ordering in the observations is in tandem with the ordering
#### of the stations in variable st

Sobs = 0.01

###################################################
###################################################

#### Example Specification of (Matern) Covariance Function
function R(x::Float64, y::Float64, th::f_th)

  ρ = hypot(x, y)
  if iszero(ρ)
    float(one(x))
  else
    th.σ^2 * 2^(1 - th.ν) / gamma(th.ν) * (ρ / th.λ)^th.ν * besselk(th.ν, ρ / th.λ)
  end

end

###################################################
###################################################

#### Specification of 'Extented' Covariance Function
#### following Method/Notation in Dietrich & Newsam (96)
function bar_R(x::Float64, y::Float64, th, gr)

  P = gr.P; Q = gr.Q

  bar_Cov = 0.0

  if ( (0<=x) & (x<=P) & (0<=y) & (y<=Q) )

    bar_Cov = R(x, y, th)

  elseif ( (P<=x) & (x<=2*P) & (0<=y) & (y<=Q) )

    bar_Cov = R(2*P-x, y, th)

  elseif ( (0<=x) & (x<=P) & (Q<=y) & (y<=2*Q) )

    bar_Cov = R(x, 2*Q-y, th)

  elseif ( (P<=x) & (x<=2*P) & (Q<=y) & (y<=2*Q) )

    bar_Cov = R(2*P-x, 2*Q-y, th)

  end

  return(bar_Cov)

end

###################################################
###################################################

#### Obtain (4pq)x(1) Vector bar_rho
#### following Method/Notation in Dietrich & Newsam (96)
function f_bar_rho(th, gr)

  p = gr.p; q = gr.q; P = gr.P; Q = gr.Q

  Dx = P/p; Dy = Q/q

  bar_rho = zeros(4*p*q)

  #########

  for j in 0:(2*q-1)

    for i in 0:(2*p-1)

      bar_rho[(j*2*p)+(i+1)] = bar_R(i*Dx, j*Dy, th, gr)

    end

  end

  #########

  return(bar_rho)

end

###################################################
#### Example ######################################

####bar_rho = f_bar_rho(th, gr)

###################################################
###################################################

#### Construct W Operation on (4pq)x1 Vector V
#### W is 2D Discrete Fourier Transform
#### following Method/Notation in Dietrich & Newsam (96);
#### V is (4pq)x1; result is (4pq)x1
function f_W(V, gr)

  p = gr.p; q = gr.q

  WV = zeros(4*p*q)

  #### Re-arrange (4pq)x(1) Vector V into an (2p)x(2q) matrix
  #### by using first 2p-elements of V as 1st column,
  #### next 2p-elements as 2nd column, and so on.
  bar_E = reshape(V, (2*p,2*q))

  #### Use Julia's 2D-FFT tranform
  E = sqrt(4*p*q)*ifft(bar_E)
  #### E is in general a Complex-Value (2p)x(2q) Matrix

  #### Re-arrange (2p)x(2q) matrix E
  #### into an (4pq)x1 matrix, by using 1st column of E,
  #### then 2nd column of E, and so on.
  WV = reshape(E,(4*p*q))

  return(WV)

end

###################################################
#### Example ######################################

####[bar_rho f_W(bar_rho, gr)]

###################################################
###################################################

#### Construct WH Operation on (4pq)x1 Vector V
#### WH is 2D Inverse Discrete Fourier Transform
#### following Method/Notation in Dietrich & Newsam (96);
#### V is (4pq)x1; result is (4pq)x1
function f_WH(V, gr)

  p = gr.p; q = gr.q

  WHV = zeros(4*p*q)

  #### Re-arrange (4pq)x(1) Vector V into an (2p)x(2q) matrix
  #### by using first 2p-elements of V as 1st column,
  #### next 2p-elements as 2nd column, and so on.
  E = reshape(V, (2*p,2*q))

  #### Use Julia's 2D-IFFT tranform
  bar_E = (1.0/sqrt(4*p*q))*fft(E)
  #### bar_E is in general a Complex-Value (2p)x(2q) Matrix

  #### Re-arrange (2p)x(2q) matrix bar_E
  #### into an (4pq)x1 matrix, by using 1st column of bar_E,
  #### then 2nd column of bar_E, and so on.
  WHV = reshape(bar_E,(4*p*q))

  return(WHV)

end

###################################################
#### Example ######################################

####V = bar_rho; WV = f_W(V,gr); WHWV = f_WH(WV,gr);

#### CHECK!! ######################################

####[V WV WHWV] ## Since WH*W = I, for any V, it should be V = WHWV!!

###################################################
###################################################

###################################################
###################################################
####
#### Construct Covariance Matrix on Original Grid
#### following Method/Notation in Dietrich & Newsam (96)
#### This Function is Needed only for Testing!!
####function f_R11(th, gr)
####
####  p = gr.p; q = gr.q; P = gr.P; Q = gr.Q
####
####  Dx = P/p; Dy = Q/q; n1 = (p+1)*(q+1)
####
####  R11 = zeros(n1, n1)
####
####  for m in 0:q
####
####    for l in 0:p
####
####      for j in 0:q
####
####        for i in 0:p
####
####          d1 = m*(p+1)+l+1; d2 = j*(p+1)+i+1
####
####          R11[d1,d2] = R(abs(l*Dx-i*Dx), abs(m*Dy-j*Dy), th)
####
####        end
####
####      end
####
####    end
####
####  end
####
####  return(R11)
####
####end
####
###################################################
#### Example ######################################
####
####R11 = f_R11(th, gr)
####
#### Construct Covariance Matrix on Extended Grid
#### following Method/Notation in Dietrich & Newsam (96)
#### This Function is Needed only for Testing!!
####function f_bar_R11(th, gr)
####
####  p = gr.p; q = gr.q; P = gr.P; Q = gr.Q
####
####  Dx = P/p; Dy = Q/q; bar_n1 = 4*p*q
####
####  bar_R11 = zeros(bar_n1, bar_n1)
####
####  for m in 0:(2*q-1)
####
####    for l in 0:(2*p-1)
####
####      for j in 0:(2*q-1)
####
####        for i in 0:(2*p-1)
####
####          d1 = m*2*p+l+1; d2 = j*2*p+i+1
####
####          bar_R11[d1,d2] = bar_R(abs(l*Dx-i*Dx), abs(m*Dy-j*Dy), th, gr)
####
####        end
####
####      end
####
####    end
####
####  end
####
####  return(bar_R11)
####
####end
####
###################################################
#### Example ######################################
####
####bar_R11 = f_bar_R11(th, gr)
####
###################################################
###################################################

#### Construct Covariance between Stations and Extended Grid
#### following Method/Notation in Dietrich & Newsam (96);
#### result is matrix of dimnesions n2xbar_n1
function f_bar_R21(th, st, gr)

  st_ij = st.st_ij; n2 = size(st_ij)[1];
  ## No of Stations

  p = gr.p; q = gr.q; P = gr.P; Q = gr.Q

  Dx = P/p; Dy = Q/q

  bar_R21 = zeros(n2, 4*p*q)

  for m in 1:n2

    for j in 0:(2*q-1)

      for i in 0:(2*p-1)

        d2 = j*2*p+i+1

        bar_R21[m,d2] = bar_R(abs(st_ij[m,1]-i)*Dx, abs(st_ij[m,2]-j)*Dy, th, gr)

      end

    end

  end

  return(bar_R21)

end

###################################################
#### Example ######################################

####bar_R21 = f_bar_R21(th, st, gr)

###################################################
###################################################

#### Construct Covariance between Observations
#### following Method/Notation in Dietrich & Newsam (96);
#### result is matrix of dimnesions n2xn2
function f_R22(th, st, Sobs, gr)

  st_ij = st.st_ij; n2 = size(st_ij)[1]
  ## No of Stations

  p = gr.p; q = gr.q; P = gr.P; Q = gr.Q

  Dx = P/p; Dy = Q/q

  ############

  R22 = zeros(n2, n2)

  for i in 1:n2

    xi = st_ij[i,1]
    yi = st_ij[i,2]

    for j in 1:n2

      xj = st_ij[j,1]
      yj = st_ij[j,2]

      R22[i,j] = R(abs(xj-xi)*Dx,abs(yj-yi)*Dy,th)

      if (i==j)

        R22[i,j] = R22[i,j] + Sobs^2

      end

    end

  end

  return(R22)

end

###################################################
#### Example ######################################

####R22 = f_R22(th, st, Sobs, gr)

###################################################
###################################################

#### Construct Covariance between Original Grid & Station Positions
#### following Method/Notation in Dietrich & Newsam (96)
#### result is matrix of dimnesions n1xn2
function f_R12(th, st, gr)

  st_ij = st.st_ij; n2 = size(st_ij)[1]
  ## No of Stations

  p = gr.p; q = gr.q; P = gr.P; Q = gr.Q

  Dx = P/p; Dy = Q/q; n1 = (p+1)*(q+1)

  R12 = zeros(n1, n2)

  for m in 1:n2

    for j in 0:q

      for i in 0:p

        d1 = j*(p+1)+i+1

        R12[d1,m] = R(abs(st_ij[m,1]-i)*Dx, abs(st_ij[m,2]-j)*Dy, th)

      end

    end

  end

  return(R12)

end

###################################################
#### Example ######################################

####R12 = f_R12(th, st, gr)

###################################################
###################################################
####
#### Construct K Matrix
#### following Method/Notation in Dietrich & Newsam (96)
####function f_K(th, st, gr)
####
####  st_ij = st.st_ij; n2 = size(st_ij)[1]
####  ## No of Stations
####
####  p = gr.p; q = gr.q
####
####  bar_rho = f_bar_rho(th, gr)
####
####  Lambda = sqrt(4*p*q)*Diagonal(real.(f_W(bar_rho, gr)))
####  #### THEORY CHECKPOINT:
####  #### All values in Lambda must be POSITIVE;
####  #### OTHERWISE, the METHOD FAILS!!!
####
####  bar_R21 = f_bar_R21(th, st, gr); bar_R12 = bar_R21'
####
####  WHbar_R12 = zeros(Complex, 4*p*q, n2)
####  for i in 1:n2
####
####    WHbar_R12[:,i] = f_WH(bar_R12[:,i], gr)
####
####  end
####
####  KH = Lambda^(-1/2)*WHbar_R12
####
####  K = KH' ## this gives Cnjugate Transpose
####
####  return(K)
####
####end
####
###################################################
### Example #######################################

#### K = f_K(th, st, gr)

##### Check!! #####################################

#### sort(eigen(bar_R11).values)
#### THEORY CHECKPOINT:
#### All eigenvalues of bar_R11 must be POSITIVE;
#### OTHERWISE, the METHOD FAILS!!!

#### A = bar_R21*inv(bar_R11)*(bar_R21)'

#### B = real.(K*K')

#### Check: Must Have A=B!!

####################################

#### bar_RR = [bar_R11 (bar_R21)'; bar_R21 R22]

#### THEORY CHECKPOINT:
#### All eigenvalues of bar_RR must be POSITIVE;
#### OTHERWISE, the METHOD FAILS!!!
#### sort(eigen(bar_RR).values)

#### Lambda = sqrt(4*p*q)*Diagonal(real.(f_W(bar_rho, gr)))

#### [sort(eigen(bar_R11).values) sort(eigen(Lambda).values)]
#### Check: The two colums must be the same !!

###################################################
###################################################
#### V is (n2)x1; result is (n1)x1
function f_A1_T(V, st_p, n1)

  n2 = length(V); A1_T_V = zeros(n1)

  for i in 1:n2

    A1_T_V[st_p[i]] = V[i]

  end

  return(A1_T_V)

end

###################################################
### Example #######################################

####V = rand(n2)

####A1_T_V = f_A1_T(V, st_p, n1)

###################################################
###################################################
#### U is (n1)x1; result is (n2)x1
function f_A1(U, st_p)

  n1 = length(U); n2 = length(st_p)

  A1_U = zeros(n2)

  for i in 1:n2

    A1_U[i] = U[st_p[i]]

  end

  return(A1_U)

end

###################################################
### Example #######################################

####U = rand(n1)

####A1_U = f_A1(U, st_p)

###################################################
###################################################
#### V is (n1)x1; result is (n1)x1
function f_Sigma(V, th, gr)

  p = gr.p; q = gr.q; n1 = (p+1)*(q+1); bar_n1 = 4*p*q

  ############

  bar_V = zeros(bar_n1)

  for j in 0:q

    bar_V[(j*2*p+1):(j*2*p+p+1)] = V[(j*(p+1)+1):((j+1)*(p+1))]

  end

  bar_rho = f_bar_rho(th, gr)

  Lambda = sqrt(bar_n1)*Diagonal(real.(f_W(bar_rho, gr)))
  #### THEORY CHECKPOINT:
  #### All values in Lambda must be POSITIVE;
  #### OTHERWISE, the METHOD FAILS!!!

  bar_Sigma_V = f_W(Lambda*f_WH(bar_V, gr),gr)

  ############

  Proj_Index = fill(0, n1)

  for j in 0:q

    Proj_Index[(j*(p+1)+1):((j+1)*(p+1))] = collect((j*2*p+1):(j*2*p+p+1))

  end

  Sigma_V = bar_Sigma_V[Proj_Index]

  return(real.(Sigma_V))

end

###################################################
### Example #######################################

####V = rand(n1); Sigma_V = f_Sigma(V, th, gr)

####maximum(abs.(R11*V-Sigma_V)) #### difference must be 0

###################################################
###################################################


####################################################################
####################################################################
### ALL FUNCTIONS SO FAR ARE STAND-ALONE ONES;
### THE ONE THAT FOLLOW NEED INTEGRATION WITH TUOMAS/MOSE CODE;
### THE POSITION ASSUMED IN THE CODE THAT FOLLOWS IS THAT WE ARE
### AT TIME t-1, AND HAVE N PARTICLES, EACH OF DIMENSION 3x(n1),
### REPRESENTING THE 3-DIMENSIONAL VECTOR FIELD ON A GRID OF n1 POSITIONS,
### AT TIME t-1.
### THE FUNCTIONS THE FOLLOW APPLY A SINGLE PARTICLE FILTER STEP.
### IN PARTICULAR, THE CODE THAT FOLLOWS DOES THE FOLLOWING:
### - IT SIMULATES THE OPTIMAL PROPOSAL FOR THE HEIGHT FIELD AT TIME t.
### - IT *DOES NOT* SIMULATE THE PROPOSAL FOR THE TWO VELOCITY FIELDS.
### - FOR THE LATTER PURPOSE THE CODE MUST BE COMBINED WITH THE CODE OF
###   OF TUOMAS/MOSE
###################################################################
####################################################################

#### Calculation of the mean for the optimal proposal for the
#### Height Field at time t; it is assumed that INTEGRATION with TUOMAS/MOSE code
#### it is assumed that INTEGRATION with TUOMAS/MOSE code will provide the
#### (N)x(n1) field FH_t which is the push-forward of all N particles at time t-1
#### under the PDE dynamics; FH_t then considers only the (N)x(n1) matrix with
#### the values of the height field. Y_obs_t are the (n2)x1 data at time t.
#### THE RESULT IS A MATRIX (N)x(n1)
function Calculate_Mean(FH_t, th, st, Yobs_t, Sobs, gr)

  ######### Offline Calculations #########

  p = gr.p; q = gr.q; n1 = (p+1)*(q+1)

  st_ij = st.st_ij; st_p = st.st_p

  n2 = size(st_ij)[1]; N = size(FH_t)[1]
  ## No of Stations + No of Particles

  ##########################

  R22 = f_R22(th, st, Sobs, gr)

  invR22 = inv(R22)

  ##########################

  mu20 = Sobs^(-2)*(R22 - Diagonal(fill(Sobs^2,n2)))
  #### (n2)x(n2)

  mu21 = f_Sigma(f_A1_T(invR22*(mu20*Yobs_t), st_p, n1), th, gr)
  #### (n1)x1

  mu22 = f_Sigma((Sobs^(-2))*f_A1_T(Yobs_t, st_p, n1), th, gr)
  #### (n1)x1

  mu2 = mu22 - mu21
  #### (n1)x1
  ##########################

  mu1 = zeros(N, n1)

  mu  = zeros(N, n1)

  ##### the required mean is different for each of the N particles
  for i in 1:N

    mu10 = invR22*f_A1(FH_t[i,:],st_p)
    #### (n2)x1

    mu11 = f_Sigma(f_A1_T(mu10, st_p, n1), th, gr)
    #### (n1)x1

    mu1[i,:] = FH_t[i,:] - mu11
    #### (n1)x1

    mu[i,:] = mu1[i,:] + mu2
    #### (n1)x1

  end

  return(mu)

end

###################################################
### Example #######################################

####N = 10; FH_t = rand(N, n1)

####Calculate_Mean(FH_t, th, st, Yobs_t, Sobs, gr)

###################################################
###################################################
#
# INPUT:
#### FH_t: an (N)x(n1) matrix where N is the number of particles
#### and n1 the size of the grid on the 2D-domain.
#### The i-th row of FH_t (referring to the i-th particle)
#### is the n1-dimensional Height field calculated after solving the PDE,
#### from time instance (t-1) to time t, using the i-th particle at time t-1 as initial condition.
#### th: Parameters in Covariance Function
#### st: Information about Stations
#### Yobs_t: n2-dimensional vector corresponding to the observations from the n2 stations
#### Sobs: Standard Deviation of Observations at Stations
#### gr: Parameters Specifying Regular Grid
# OUTPUT:
#### The numbers of particles N must be EVEN!!
function Sample_Height_Proposal(FH_t, th, st, Yobs_t, Sobs, gr)

  ######### Offline Calculations: #########
  ######### i.e. will be the same for 0->1, 1->2, t-1->t, etc. #########

  st_ij = st.st_ij; st_p = st.st_p

  n2 = size(st_ij)[1]; N = size(FH_t)[1]
  ## No of Stations + No of Particles

  p = gr.p; q = gr.q; P = gr.P; Q = gr.Q

  bar_n1 = 4*p*q; n1 = (p+1)*(q+1)

  Dx = P/p; Dy = Q/q

  bar_rho = f_bar_rho(th, gr)

  Lambda = sqrt(bar_n1)*Diagonal(real.(f_W(bar_rho, gr)))
  #### THEORY CHECKPOINT:
  #### All values in Lambda must be POSITIVE;
  #### OTHERWISE, the METHOD FAILS!!!

  bar_R21 = f_bar_R21(th, st, gr); bar_R12 = bar_R21'

  WHbar_R12 = zeros(Complex, bar_n1, n2)

  for i in 1:n2

    WHbar_R12[:,i] = f_WH(bar_R12[:,i], gr)

  end

  KH = Lambda^(-1/2)*WHbar_R12; K = KH' ## this gives Conjugate Transpose

  R22 = f_R22(th, st, Sobs, gr)

  L = cholesky(real.(R22-K*KH)).L
  #### THEORY CHECKPOINT:
  #### R22-K*KH must have POSITIVE EIGENVALUES,
  #### i.e. all(eigen(R22-K*KH).values)>0,
  #### OTHERWISE, the METHOD FAILS!!!

  R12 = f_R12(th, st, gr);

  R12_invR22 = R12*inv(R22)

  ##muZ1_C_Yobs = R12_invR22*Yobs_t

  Proj_Index = fill(0, n1)

  for j in 0:q

    Proj_Index[(j*(p+1)+1):((j+1)*(p+1))] = collect((j*2*p+1):(j*2*p+p+1))

  end

  ####

  Samples = zeros(N,n1)
  N0 = Int(N/2) ########## N must be even!

  ########################################
  ######### Online Calculations: ##########
  ######### here we need info from the data at time t, or/and a separate ##########
  ######### calculation for each particle. ##########
  means = Calculate_Mean(FH_t, th, st, Yobs_t, Sobs, gr)
  rng = Random.MersenneTwister(123)

  e1 = Vector{ComplexF64}(undef, bar_n1)
  e2 = Vector{ComplexF64}(undef, n2)

  for i in 0:(N0-1)

    @. e1 = complex(randn(rng), randn(rng))
    @. e2 = complex(randn(rng), randn(rng))

    bar_z1 = f_W(Lambda^(1/2)*e1, gr)
    z2 = (K*e1) + (L*e2)

    Rbar_z = real.([bar_z1; z2])
    Ibar_z = imag.([bar_z1; z2])

    Proj1 = [ Rbar_z[Proj_Index]; Rbar_z[(bar_n1+1):end] ]

    Proj2 = [ Ibar_z[Proj_Index]; Ibar_z[(bar_n1+1):end] ]

    ##Z1_C_Yobs_1 = muZ1_C_Yobs + Proj1[1:n1] - R12_invR22*Proj1[(n1+1):end]
    Z11 = Proj1[1:n1] - R12_invR22*Proj1[(n1+1):end]

    ##Z1_C_Yobs_2 = muZ1_C_Yobs + Proj2[1:n1] - R12_invR22*Proj2[(n1+1):end]
    Z12 = Proj2[1:n1] - R12_invR22*Proj2[(n1+1):end]

    ##Samples[2*i+1,:] = means[2*i+1,:] + Z1_C_Yobs_1
    Samples[2*i+1,:] = means[2*i+1,:] + Z11

    ##Samples[2*i+2,:] = means[2*i+2,:] + Z1_C_Yobs_2
    Samples[2*i+2,:] = means[2*i+2,:] + Z12

  end

  return(Samples)

end

####################################################################
####################################################################




###################################################
#### Example ######################################

N = 10; FH_t = rand(N, n1)

Ss = Sample_Height_Proposal(FH_t, th, st, Yobs_t, Sobs, gr)

####

Ss[1,st_p] - Yobs_t #### all the differences should be close to 0 if Sobs<<1

Ss[2,st_p] - Yobs_t #### all the differences should be close to 0 if Sobs<<1

Ss[3,st_p] - Yobs_t #### all the differences should be close to 0 if Sobs<<1

Ss[4,st_p] - Yobs_t #### all the differences should be close to 0 if Sobs<<1

####

Fs = zeros(N, q+1, p+1)

for i in 1:N

  Fs[i,:,:] = reshape(Ss[i,:], (p+1,q+1))'

end

i = 2

#heatmap(1:size(Fs[i,:,:],2),
#           1:size(Fs[i,:,:],1), Fs[i,:,:],
#           c=cgrad([:blue, :white,:red, :yellow]),
#           xlabel="x-axis", ylabel="y-axis",
#           title="")



#####!!!!!! Need to Check if I Combine in the Correct Way
#####!!!!!! the algorithm for the Simulation of the Conditional Field
#####!!!!!! and the Use of the Mean.

###################################################
###################################################
