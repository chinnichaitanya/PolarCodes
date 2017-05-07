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
plot(1:N, z_N, '*');
title('Bhattacharya parameters for re-constructed channels');
xlabel('Channel index, i');
ylabel('Bhattacharya parameter');

% find the smallest K among the N-Bhattacharya values %
first_K_indices = get_k_smallest_indices(z_N, K);

% %% read the messages from 'msg.txt' %%
% messages = cell(1, 0);
% msgfile = fopen('msg.txt');
% fileline = fgetl(msgfile);
% while ischar(fileline)
%     messages{1, end+1} = fileline;
%     fileline = fgetl(msgfile);
% end
% fclose(msgfile);
% 
% %% encoding %%
% codewords = cell(1, 0);
% for msgstr = messages
%     mx = [];
%     for i = 1:length(msgstr{1,1})
%         % get individual message bits %
%         mx(i) = str2double(msgstr{1,1}(i));
%     end
%     
%     % input U to the first K best indices %
%     U = zeros(1, N);
%     U(first_K_indices) = mx;
%     % encoding %
%     cx = U*GN;
%     cx = mod(cx, 2);
% 
%     % store the codeword in cell %
%     code = cell(1, 1);
%     for j = 1:length(cx)
%         code{1, 1}(j) = int2str(cx(j));
%     end
%     % store each code in a cell %
%     codewords{1, end+1} = code{1, 1};
% end
% 
% %% store the encoded messages into 'codeword.txt' file %%
% codefile = fopen('codeword.txt', 'w');
% for codestr = codewords
%    fprintf(codefile, '%s\n', codestr{1, 1});
% end
% fclose(codefile);
