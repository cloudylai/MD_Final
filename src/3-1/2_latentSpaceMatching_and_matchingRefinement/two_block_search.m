function [map_U map_V] = two_block_search(train1_raw, valid1_raw, test1_raw, U1, V1, train2_raw, U2, V2, TRIED_MAX_K, nCandidate)
TRIED_MAX_K
nCandidate

%if matlabpool('size') == 0 % for parallel computing
%	matlabpool
%end

original_trainRMSE = getTestingRMSE(train1_raw, U1, V1', mean(train1_raw(:,3)), std(train1_raw(:,3),1))
original_validRMSE = getTestingRMSE(valid1_raw, U1, V1', mean(train1_raw(:,3)), std(train1_raw(:,3),1))
% original_testRMSE = getTestingRMSE(test1_raw, U1, V1', mean(train1_raw(:,3)), std(train1_raw(:,3),1))


train2_mean = mean(train2_raw(:,3));
train2_std = std(train2_raw(:,3),1);
clear train2_raw;

%%%%%%%%% parameter K selection%%%%%%%
[bestIdxOfEachDimension_U bestIdxOfEachDimension_V signList_U signList_V] = findMappingByUV('ChooseParameter', U1, V1, U2, V2, TRIED_MAX_K);

list = zeros(TRIED_MAX_K,1);
for d = 1:TRIED_MAX_K
	tmp1 = bestIdxOfEachDimension_U(d,:);
	tmp2 = bestIdxOfEachDimension_V(d,:);
	list(d) = getTestingRMSE(train1_raw, U2(tmp1,:), V2(tmp2,:)',mean(train1_raw(:,3)),std(train1_raw(:,3),1));
end
list'
[list bestK_pred] = min(list);
for d = 1:TRIED_MAX_K
	list(d) = getMappingAccuracy_singleSide(bestIdxOfEachDimension_U(d,:), size(U2,1), 'User');
end 
[list bestK_U_real] = max(list);
for d = 1:TRIED_MAX_K
	list(d) = getMappingAccuracy_singleSide(bestIdxOfEachDimension_V(d,:), size(V2,1), 'Item');
end
[list bestK_V_real] = max(list);
display(['bestK_pred: ' num2str(bestK_pred)]); 
display(['bestK_U_real: ' num2str(bestK_U_real)]); 
display(['bestK_V_real: ' num2str(bestK_V_real)]); 
%%%%%%%end parameter selection%%%%%%%%%

[candidates_U candidates_V] = findMappingByUV('FinalResult', U1,V1,U2,V2,bestK_pred,nCandidate, signList_U, signList_V);
nUser = size(U1, 1);
nItem = size(V1, 1);
clear U1; 
clear V1; 

map_U = candidates_U(:,1);
map_V = candidates_V(:,1);

ucoverage = getCoverage_singleSide(candidates_U, size(U2,1), 'User')
vcoverage = getCoverage_singleSide(candidates_V, size(V2,1), 'Item')


W_train1_user_item = sparse(train1_raw(:,1), train1_raw(:,2), ones(size(train1_raw(:,1))) );
W_train1_item_user = W_train1_user_item';

train_normalized = sparse(train1_raw(:,1), train1_raw(:,2), (train1_raw(:,3)-train2_mean)/train2_std);

trainRMSE = getTestingRMSE(train1_raw, U2(map_U,:), V2(map_V,:)', train2_mean, train2_std)
validRMSE = getTestingRMSE(valid1_raw, U2(map_U,:), V2(map_V,:)', train2_mean, train2_std)
% testRMSE = getTestingRMSE(test1_raw, U2(map_U,:), V2(map_V,:)', train2_mean, train2_std)
getMappingAccuracy(map_U, size(U2,1), map_V, size(V2,1));


last_map_U = -ones(size(map_U));
last_map_V = -ones(size(map_V));


meanAveragePrecision_U = nan;
meanAveragePrecision_V = nan;


while 1

	tic;

	noChange_users = find(last_map_U == map_U);
	noChange_items = find(last_map_V == map_V);

	last_map_U = map_U;
	last_map_V = map_V;
	
	meanAveragePrecision_U = zeros(size(map_U));
	parfor userID = 1:nUser
		itemsRatedByTheUser = find(W_train1_item_user(:,userID) ~= 0);
		if(length(itemsRatedByTheUser) == 0)
			continue
		end

		[result_uc ranking_uc] = updateU(userID, train_normalized, map_V, U2, V2, itemsRatedByTheUser, nCandidate, candidates_U, noChange_items, map_U(userID));
		map_U(userID) = result_uc;

		idx = find(ranking_uc == getCorrespondingAnserIndex(userID, size(U2,1), 'User'));
		assert(length(idx) <= 1);
		if(length(idx) == 1)
			meanAveragePrecision_U(userID) = 1.0/idx;
		end
	end
	trainRMSE = getTestingRMSE(train1_raw, U2(map_U,:), V2(map_V,:)', train2_mean, train2_std)
	validRMSE = getTestingRMSE(valid1_raw, U2(map_U,:), V2(map_V,:)', train2_mean, train2_std)
	% testRMSE = getTestingRMSE(test1_raw, U2(map_U,:), V2(map_V,:)', train2_mean, train2_std)
	getMappingAccuracy(map_U, size(U2,1), map_V, size(V2,1));
	usedUserCount = length(find(getCorrespondingAnserIndex([1:nUser]', size(U2,1), 'User') <= size(U2,1)))
	meanAveragePrecision_U = sum(meanAveragePrecision_U) / usedUserCount
	meanAveragePrecision_V
	
	meanAveragePrecision_V = zeros(size(map_V));
	parfor itemID = 1:nItem
		usersRatedByTheItem = find(W_train1_user_item(:,itemID) ~= 0);
		if(length(usersRatedByTheItem) == 0)
			continue
		end
		[result_ic ranking_ic] = updateV(itemID, train_normalized, map_U, U2, V2, usersRatedByTheItem, nCandidate, candidates_V, noChange_users, map_V(itemID));
		map_V(itemID) = result_ic;

		idx = find(ranking_ic == getCorrespondingAnserIndex(itemID, size(V2,1), 'Item'));
		assert(length(idx) <= 1);
		if(length(idx) == 1)
			meanAveragePrecision_V(itemID) = 1.0/idx;
		end
	end
	trainRMSE = getTestingRMSE(train1_raw, U2(map_U,:), V2(map_V,:)', train2_mean, train2_std)
	validRMSE = getTestingRMSE(valid1_raw, U2(map_U,:), V2(map_V,:)', train2_mean, train2_std)
	% testRMSE = getTestingRMSE(test1_raw, U2(map_U,:), V2(map_V,:)', train2_mean, train2_std)
	getMappingAccuracy(map_U, size(U2,1), map_V, size(V2,1));
	usedItemCount = length(find(getCorrespondingAnserIndex([1:nItem]', size(V2,1), 'Item') <= size(V2,1)))
	meanAveragePrecision_U
	meanAveragePrecision_V = sum(meanAveragePrecision_V)/usedItemCount

	toc;

	if(isequal(last_map_U, map_U) && isequal(last_map_V, map_V))
		break;
	end

end

end


function [result_uc ranking_uc] = updateU(userID, train, map_V, U, V, itemsRatedByTheUser, nCandidate, candidates_U, noChange_items, current_uc)
ALPHA = 1;

%if(length(setdiff(itemsRatedByTheUser, noChange_items)) == 0)
%	result_uc = current_uc;
%	return;
%end


err_fixedUser = repmat(train(userID, itemsRatedByTheUser), nCandidate,1) - U(candidates_U(userID,:),:) * V(map_V(itemsRatedByTheUser),:)';
MSE_column_tmp = sum(err_fixedUser.^2,2);
MSE_column_tmp = MSE_column_tmp ./ (length(itemsRatedByTheUser));

prob = exp(-MSE_column_tmp * ALPHA);
prob = prob ./ sum(prob(:));

assert(length(unique(prob)) == length(prob));
[tmp idx] = sort(prob(:), 'descend');
result_uc = candidates_U(userID, idx(1));
ranking_uc = candidates_U(userID, idx);
end



function [result_ic ranking_ic] = updateV(itemID, train, map_U, U, V, usersRatedByTheItem, nCandidate, candidates_V, noChange_users, current_ic)
ALPHA = 1;

%if(length(setdiff(usersRatedByTheItem, noChange_users)) == 0)
%	result_ic = current_ic;
%	return;
%end

err_fixedItem = repmat(train(usersRatedByTheItem, itemID), 1, nCandidate) - U(map_U(usersRatedByTheItem),:) * V(candidates_V(itemID,:),:)';
MSE_row_tmp = sum(err_fixedItem.^2, 1);
MSE_row_tmp = MSE_row_tmp ./ (length(usersRatedByTheItem));

prob = exp(-MSE_row_tmp * ALPHA);
prob = prob ./ sum(prob(:));

assert(length(unique(prob)) == length(prob));
[tmp idx] = sort(prob(:), 'descend');
result_ic = candidates_V(itemID, idx(1));
ranking_ic = candidates_V(itemID, idx);
end


function idx = getCorrespondingAnserIndex(idx, lengthInR2, type)
	assert(isscalar(lengthInR2));
	if isequal(type,'User')
		lenP1 = 50001;
	else
		assert(isequal(type,'Item'))
		lenP1 = 5001;
	end
	idx = lenP1 - idx;
	%idx = (lengthInR2 + 1 - idx);		%for others
	%idx = (lengthInR2/9*10 + 1 - idx);	%for partialSplit
end

function getMappingAccuracy(map_U, lengthInR2_U, map_V, lengthInR2_V)
	acc_u = getMappingAccuracy_singleSide(map_U, lengthInR2_U, 'User');
	acc_v = getMappingAccuracy_singleSide(map_V, lengthInR2_V, 'Item');
	display(['acc_u ' num2str(acc_u)]);
	display(['acc_v ' num2str(acc_v)]);
end

function acc = getMappingAccuracy_singleSide(map, lengthInR2, type)
	tmp = [map(:) getCorrespondingAnserIndex([1:length(map)]', lengthInR2, type)];
	idx = find(tmp(:,2) <= lengthInR2);
	tmp = tmp(idx,:);
	acc = sum(tmp(:,1) == tmp(:,2))/length(tmp);
end

function coverage = getCoverage_singleSide(candidates, lengthInR2, type)
	coverage = 0.0;
	count = 0;
	for i = 1:size(candidates,1)
		answer = getCorrespondingAnserIndex(i, lengthInR2, type);
		tmp = length(find(candidates(i,:) == answer));
		assert(tmp <= 1);
		if(answer <= lengthInR2)
			coverage = coverage + tmp;
			count = count + 1;
		end
	end
	coverage = coverage/ count;
end
