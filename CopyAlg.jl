using Pkg
using Arpack
using GraphRecipes
using Plots
using DelimitedFiles
using LinearAlgebra
using SparseArrays
using Random

#adj. matrix
data = readdlm("hlfMsg.txt", Int64)
n = 1260
A = sparse(convert(Vector{Int64}, data[:,1]),
           convert(Vector{Int64}, data[:,2]), 1, n, n)
A = max.(A, A');

#Time
#i is Person, k is target which is mutual friend of Person 1 and 2
function time_last(data::Array{Int64,2}, i::Int64, k::Int64)
    y = findall(data.==i);
    y_idx = length(y);

    if y[y_idx][2] == 2 #target is in adjacent column
        col = 1;
    else
        col = 2;
    end

    dm_target = data[y[y_idx][1], col];
    while dm_target != k
        y_idx = y_idx-1;

        if y[y_idx][2] == 2
            col = 1;
        else
            col = 2;
        end

        dm_target = data[y[y_idx][1], col];
    end

    end_time = 1085119730;
    t = (end_time-data[y[y_idx][1], 3])/86400; #convert sec to d
    if t < 1
        t = 1;
    end
    return t
end

#function similarity()
#A is adj. matrix, i is Person 1, j is Person 2, k is mutual friend
#For loop needed instead of k in header
function similarity(data::Array{Int64,2}, A::SparseMatrixCSC{Int64,Int64}, i::Int64, j::Int64)
    start_time = 1082040961;
    end_time = 1085119730;
    t_interval = (end_time-start_time)/86400; #sec to d

    sim = 0;
    (r,c) = size(A);
    for k = 1:r
        if k!=i && k!=j && A[k,i]!=0 && A[k,j]!=0 #dms to mf is not 0
            i_sim = (A[k,i]/t_interval)*(A[k,i]/time_last(data,i,k)); #f1*(dms[t]i,m)/time_last)i+f2*(dms[t]j,m)/time_last)j
            j_sim = (A[k,j]/t_interval)*(A[k,j]/time_last(data,j,k));
            sim = sim + i_sim + j_sim;
        end
    end
    return sim
end
# Sum(f1*(dms[t]i,m)/time_last)i+f2*(dms[t]j,m)/time_last)j)


#We need to get to get an interval of time
#Time is incoroparated already with time_last and frequency
#Frequency will change with new time interval


#similarity matrix
S = zeros(n,n);
for i in 1:n
    for j in i+1:n
        S[i,j] = similarity(data,A,i,j);
    end
end
S = max.(S, S');

#Avg time msg
start_time = 1082040961;
end_time = 1085119730;
total_time = (end_time - start_time)/86400;

(r,c) = size(data); #r = total msgs

avgtime_per_msg = total_time/r;  #days/msg

#Can se find function possibly to get all values above threshold



#L is list of [i,j,timestamp], future
L
