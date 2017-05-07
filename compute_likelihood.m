function likelihood_val = compute_likelihood(Y, U, N, index)
    likelihood_val = 1;
    if N == 1
        if Y == 1
            likelihood_val = 0;
        elseif Y == 0
            likelihood_val = Inf;
        else
            % erasure %
            likelihood_val = 1;
        end        
    else
        %fprintf('Ho\n');
        if mod(index, 2) == 1
            u_odd = U(1:2:index-2);
            u_even = U(2:2:index-1);

            L1 = compute_likelihood(Y(1:N/2), mod(u_odd + u_even, 2), N/2, (index+1)/2);
            L2 = compute_likelihood(Y((N/2)+1:N), u_even, N/2, (index+1)/2);

            if((L1 == 0 && L2 == 0) || (L1 == Inf && L2 == Inf))
                likelihood_val = Inf;
            elseif((L1 == 0 && L2 == Inf) || (L1 == Inf && L2 == 0))
                likelihood_val = 0;
            elseif((L1 == 1 && L2 == Inf) || (L1 == Inf && L2 == 1))
                likelihood_val = 1;
            else
                likelihood_val = (L1*L2 + 1)/(L1+L2);
            end 
        end

        if mod(index, 2) == 0
            u_odd = U(1:2:index-3);
            u_even = U(2:2:index-2);
            
            L1 = compute_likelihood(Y(1:N/2), mod(u_odd + u_even, 2), N/2, (index+1)/2);
            L2 = compute_likelihood(Y((N/2)+1:N), u_even, N/2, (index+1)/2);

            if(U(index-1) == 0)
                likelihood_val = L2 * L1;
            else
                likelihood_val = L2 / L1;
            end        
        end
    end
end
