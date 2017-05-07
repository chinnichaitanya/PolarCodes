%% clear environment %%
clear;
clc;

%% channel parameters %%
p = 0.3;
n = 6;
N = 2^n;

%% calculate the transpose matrices %%
% calculate FN %
F_prev = [1, 0; 1, 1];
for i=2:n
    F_next = [F_prev zeros(size(F_prev)); F_prev F_prev];
    F_prev = F_next;
end
FN = F_next;

% calculate bit-reversal matrix BN %
reversed_seq = bitrevorder(0:N-1);
BN = zeros(N, N);
for i=1:N
    BN(reversed_seq(i)+1, i) = 1;
end

% calculate the generator matrix %
GN = BN*FN;

%% BEC %%
R = capacity_bec(p) - 0.1;
K = floor(R*N);

% calculate z-values for (n+1)th layer
z_i = bhattacharya_bec(p);
for i=1:n
    z_2i = zeros(1, 2^i);
    for index=1:length(z_i)
        temp = bhattacharya_split(z_i(index));
        z_2i(2*index-1) = temp(1);
        z_2i(2*index) = temp(2);
    end
    z_i = z_2i;
end

% update the Bhattacharya values for indices in N %
z_N = z_2i;
% plot(1:N, z_N, '.');

% find the smallest K among the N-Bhattacharya values %
first_K_indices = get_k_smallest_indices(z_N, K);

%% read the received vector from 'rx.txt' %%
rx_vec = cell(1, 0);
decodefile = fopen('rx.txt');
fileline = fgetl(decodefile);
while ischar(fileline)
    rx_vec{1, end+1} = fileline;
    fileline = fgetl(decodefile);
end
fclose(decodefile);

%% decoding %%
estimated_codewords = cell(1, 0);
estimated_messages = cell(1, 0);
for rxstr = rx_vec
    cx = [];
    decoded_bits = nan(1, N);
    for i = 1:length(rxstr{1,1})
        % get individual message bits %
        cx(i) = str2double(rxstr{1,1}(i));
    end
    
    for j=1:length(cx)
        if sum(find(first_K_indices == j)) == 0
            % implies i is frozen bit %
            decoded_bits(j) = 0;
        else
            % not frozen bit %
            likelihood = compute_likelihood(cx, decoded_bits(1:j-1), N, j);
            decoded_bits(j) = decision_BEC(likelihood);
        end
    end
    
    % store the estimated codeword in cell %
    est_code = cell(1, 1);
    for j = 1:length(cx)
        est_code{1, 1}(j) = int2str(decoded_bits(j));
    end
    % store each estimated code in a cell %
    estimated_codewords{1, end+1} = est_code{1, 1};
    
    % store estimated message bits in cell %
    est_msg = cell(1, 1);
    for j = first_K_indices
        est_msg{1, 1}(j) = int2str(decoded_bits(j));
    end
    % store each estimated message in a cell %
    estimated_messages{1, end+1} = est_msg{1, 1};
end

%% store the decoded outputs into corresponding files %%
decodefile = fopen('decoder_code.txt', 'w');
for est_codestr = estimated_codewords
   fprintf(decodefile, '%s\n', est_codestr{1, 1});
end
fclose(decodefile);

demsgfile = fopen('decoder_msg.txt', 'w');
for est_msgstr = estimated_messages
    fprintf(demsgfile, '%s\n', est_msgstr{1, 1});
end
fclose(demsgfile);
