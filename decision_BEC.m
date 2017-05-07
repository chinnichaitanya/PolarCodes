function decoded_bit = decision_BEC(likelihood)
    if likelihood == 0
        decoded_bit = 1;
    elseif likelihood == Inf
        decoded_bit = 0;
    else
        decoded_bit = nan;
    end
end