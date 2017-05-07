function indices = get_k_smallest_indices(vector, k)
    [~, indices] = sort(vector, 'ascend');
    indices = indices(1:k);
end