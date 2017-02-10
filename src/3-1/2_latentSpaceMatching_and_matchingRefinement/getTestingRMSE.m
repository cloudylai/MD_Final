function [realRMSE, normalizedRMSE] = getTestingRMSE(R_raw, U, V, training_mean, training_standardDev)
U_list = U(R_raw(:,1), :);
V_list = V(:, R_raw(:,2))';
prediction = sum(U_list .* V_list, 2) * training_standardDev + training_mean;
err = R_raw(:,3) - prediction;
realRMSE = sqrt(err' * err /size(err, 1));
normalizedRMSE = realRMSE / std(R_raw(:,3),1);
