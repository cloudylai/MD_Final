SIZE_U = 2000;
SIZE_V = 1000;
RANK = 5;

R = randn(SIZE_U,RANK) * diag(1.1.^[1:RANK]) * randn(RANK,SIZE_V);

nRating = SIZE_U * SIZE_V;
nObserved = int32(nRating * 0.05);

idx = randsample(nRating, nObserved);
[i j] = ind2sub(size(R), idx);

f = fopen('rating', 'w');
fprintf(f, '%d	%d	%f\n', [i'; j'; R(idx)']); 
fclose(f);

