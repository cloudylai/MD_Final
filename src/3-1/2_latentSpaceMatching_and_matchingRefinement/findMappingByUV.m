function varargout = findMappingByUV(varargin) 

	mode = varargin{1};
	P1 = varargin{2};
	Q1 = varargin{3};
	P2 = varargin{4};
	Q2 = varargin{5};
	TOP_K = varargin{6};

	K = size(P1,2);
	assert(K == size(Q1,2));
	assert(K == size(P2,2));
	assert(K == size(Q2,2));

	[userSide1 itemSide1] = getMatchingTargetMatrix(P1, Q1);
	[userSide2 itemSide2] = getMatchingTargetMatrix(P2, Q2);

	if strcmp(mode, 'ChooseParameter')
		assert(length(varargin) == 6);
		nOut = 4;
		assert(nargout == nOut);
		nCandidate = 10; % not affecting output now

		mex -g -v CXXFLAGS="\$CXXFLAGS -fopenmp -Wall" LDFLAGS="\$LDFLAGS -fopenmp -Wall" findMapping_match.cpp
		[candidates_U bestIdxOfEachDimension_U signList_U] = findMapping(userSide1(:,1:TOP_K), userSide2(:,1:TOP_K), nCandidate, 'User');
		[candidates_V bestIdxOfEachDimension_V signList_V] = findMapping(itemSide1(:,1:TOP_K), itemSide2(:,1:TOP_K), nCandidate, 'Item');
		varargout = cell(1,nOut);
		varargout{1} = bestIdxOfEachDimension_U;
		varargout{2} = bestIdxOfEachDimension_V;
		varargout{3} = signList_U;
		varargout{4} = signList_V;
	elseif strcmp(mode, 'FinalResult')
		nCandidate = varargin{7};
		signList_U = varargin{8};
		signList_V = varargin{9};
		signList_U = signList_U(:)';
		signList_V = signList_V(:)';
		assert(length(varargin) == 9);
		nOut = 2;
		assert(nargout == nOut);

		candidates_U = myknnsearch(userSide1(:,1:TOP_K), bsxfun(@times, userSide2(:,1:TOP_K), double(signList_U(1:TOP_K))), nCandidate);
		candidates_V = myknnsearch(itemSide1(:,1:TOP_K), bsxfun(@times, itemSide2(:,1:TOP_K), double(signList_V(1:TOP_K))), nCandidate);
		varargout = cell(1,nOut);
		varargout{1} = candidates_U;
		varargout{2} = candidates_V;
	else
		assert(false);
	end


end


function [userSide itemSide] = getMatchingTargetMatrix(P, Q)
	[a b c] = svd(P,0);
	[d e f] = svd(Q,0);

	[x y z] = svd(b*c'*f*e',0);


	U = a*x;
	D = y;
	V = d*z;
	nu = size(U,1);
	nv = size(V,1);
	U = U .* sqrt(nu);
	D = D ./ (sqrt(nu*nv));
	V = V .* sqrt(nv);

	userSide = U * sqrt(D);
	itemSide = V * sqrt(D);
end

%function corresponding_candidateB_indices = findMapping(A, B, nCandidate)
%assert(size(A,2) == size(B,2));
%for i = 1:size(A,2)
%	if ~isSameSign(A(:,i), B(:,i))
%		B(:,i) = -B(:,i);
%	end
%end
%
%corresponding_candidateB_indices = myknnsearch(A, B, nCandidate); % for each row in A, find the top neighbors in B
%corresponding_candidateB_indices = corresponding_candidateB_indices';  
%
%end


%function yes = isSameSign(v1, v2)
%assert(size(v1,2) == 1 && size(v2,2) == 1);
%v1 = sort(v1);
%v2 = sort(v2);
%	function dis = getDis(tmp1, tmp2)
%	L1 = length(tmp1) - 1;
%	L2 = length(tmp2) - 1;
%	idx = 1 + [0:L1]/L1*L2;
%	tmp = tmp1(:)' - interp1(tmp2, idx);
%%	tmp = quantile(tmp1,[0:0.01:1]) - quantile(tmp2,[0:0.01:1]);
%	dis = tmp*tmp';
%	end
%d1 = getDis(v1, v2);
%d2 = getDis(v1, -v2(end:-1:1));
%if d1 <= d2
%	yes = true;
%else
%	yes = false;
%end
%end



%function yes = isSameSign(v1, v2)
%assert(size(v1,2) == 1 && size(v2,2) == 1);
%%assert(isequal(size(v1), size(v2)) && size(v1,2) == 1); % work only for R1 R2 are of the same size
%m1 = [mean(v1) mean(v1.*abs(v1)) mean(v1.*abs(v1.^2))]
%m2 = [mean(v2) mean(v2.*abs(v2)) mean(v2.*abs(v2.^2))]
%
%%[mean(abs(v1))/mean(abs(v2)) sqrt(mean(v1.*v1)/mean(v2.*v2)) nthroot(mean(abs(v1).^3)/mean(abs(v2).^3), 3)]
%
%[val idx] = max(abs(m1));
%if sign(m1(idx)) == sign(m2(idx))
%	yes = true;
%else
%	yes = false;
%end
%
%end

function [idx bestIdxOfEachDimension signList] = findMapping(A, B, nCandidate, type)


nInstance = size(A,1);
nDimension = size(A,2);


% the transformMatrix is to evaluate whether the signs are solved correctly
%transformMatrix = B\A;
%transformMatrix = B(end:-1:(size(B,1)-size(A,1))+1,:)\A;				% for others
%transformMatrix = B(end:-1:(size(B,1)-size(A,1)*3/4)+1,:)\A(size(A,1)/4+1:end,:);	% for partialSplit
if isequal(type, 'User')
	lenP1 = 50001;
else
	assert(isequal(type, 'Item'))
	lenP1 = 5001;
end
commonA = A(lenP1-size(B,1):end,:);
commonB = B(end:-1:lenP1-size(A,1),:);
transformMatrix = commonB\commonA;
%B = B*transformMatrix;

[idx signList bestIdxOfEachDimension] = findMapping_match(A, B, nCandidate, type);
%signList = ones(nDimension, 1);
%dis_current = zeros(size(B,1), nInstance);
%idx = zeros(nInstance, nCandidate, nDimension);
%for dimension = 1:nDimension
%	tic;
%	dimension
%	d1 = zeros(nInstance, 1);
%	d2 = zeros(nInstance, 1);
%	parfor i = 1:nInstance
%		dis_positive_tmp = sort(dis_current(:,i) + (A(i, dimension) - B(:, dimension)).^2);
%		dis_negative_tmp = sort(dis_current(:,i) + (A(i, dimension) + B(:, dimension)).^2);
%		assert(nCandidate+1 == length(unique(dis_positive_tmp(1:nCandidate+1))));
%		assert(nCandidate+1 == length(unique(dis_negative_tmp(1:nCandidate+1))));
%		d1(i) = dis_positive_tmp(1);
%		d2(i) = dis_negative_tmp(1);
%	end
%	d1 = sum(d1); 
%	d2 = sum(d2);  
%	[d1 d2]
%	if d1 > d2
%		signList(dimension) = -1;
%		B(:, dimension) = -B(:, dimension);
%	end
%
%	display(['sign set to ' num2str(signList(dimension))]);
%	parfor i = 1:nInstance
%		dis_current(:,i) = dis_current(:,i) + (A(i, dimension) - B(:, dimension)).^2;
%		[dis_tmp_sorted idx_tmp] = sort(dis_current(:,i));
%		idx(i,:) = idx_tmp(1:nCandidate);
%	end
%	toc;
%end

diag(transformMatrix)'
wrongSignIndex = find(signList(:) ~= sign(diag(transformMatrix)))

end

function idx = myknnsearch(A, B, nNeighbors)
nDimension = size(A,2);
nInstance = size(A,1);
assert(size(B,2) == nDimension);
idx = zeros(nNeighbors, nInstance);
parfor i = 1:nInstance
	dis = zeros(size(B,1),1);
	for dimension = 1:size(A,2)
		dis = dis + (A(i, dimension) - B(:, dimension)).^2;
	end
	[dis_tmp idx_tmp] = sort(dis);
	assert(nNeighbors+1 == length(unique(dis_tmp(1:nNeighbors+1))));
	idx(:, i) = idx_tmp(1:nNeighbors);
end
idx = idx';
end
