% in hw3-1,
% source is a 30000 x 3000 matrix,
% and target is a 20000 x 2000 matrix

X_src = zeros(50000, 5000);
X_tgt = zeros(50000, 5000);
X_tgt_answer = zeros(50000, 5000);

[users, items, scores] = textread('../test1/source.txt', '%d %d %f');
for i = 1:size(users),
    X_src(users(i)+1, items(i)+1) = scores(i);
end;

[users, items, scores] = textread('../test1/train.txt', '%d %d %f');
for i = 1:size(users),
    X_tgt(users(i)+1, items(i)+1) = scores(i);
end;

[users, items, scores] = textread('../test1/train.txt', '%d %d %f');
for i = 1:size(users),
    X_tgt_answer(users(i)+1, items(i)+1) = scores(i);
end;

% calculate avg
avg = 0;
avg_cnt = 0;
for i = 1:50000,
    for j = 1:5000,
        if X_src(i, j) > 0,
            avg = avg + X_src(i, j);
            avg_cnt = avg_cnt + 1;
        end;
    end;
end;
avg = avg / avg_cnt;
disp(sprintf('avg %f', avg));

% sub sampling X_src_sub
X_src_sub = zeros(5000, 500);
sample_x = randsample(50000, 5000);
sample_y = randsample(5000, 500);
% fill in X_src_sub_full
for i = 1:5000,
    for j = 1:500,
        X_src_sub(i, j) = X_src(sample_x(i), sample_y(j));
        if X_src_sub(i, j) < 1e-2,
            X_src_sub(i, j) = avg;
        end; % if
    end; % for j
end; % for i

for k = [5],
    for l = [5],
        for ks = 1:1,
            [X_tgt_predict] = codebook(X_src_sub, X_tgt, X_tgt_answer, k, l, 20);
        end; %for ks
        %[X_tgt_predict] = codebook(X_src, X_tgt, X_tgt_answer, k, l, 20);
    end; % for l
end; % for k

