% in hw3-2,
% source is a 30000 x 3000 matrix,
% and target is a 20000 x 2000 matrix

X_src = zeros(500, 500);
X_tgt = zeros(500, 1000);
X_tgt_answer = zeros(500, 1000);

[users, items, scores] = textread('../test3/source.txt', '%d %d %f');
for i = 1:size(users),
    X_src(users(i)+1, items(i)+1) = scores(i);
end;

[users, items, scores] = textread('../test3/train.txt', '%d %d %f');
for i = 1:size(users),
    X_tgt(users(i)+1, items(i)+1) = scores(i);
end;

[users, items, scores] = textread('../test3/train.txt', '%d %d %f');
for i = 1:size(users),
    X_tgt_answer(users(i)+1, items(i)+1) = scores(i);
end;

% calculate avg
avg = 0;
avg_cnt = 0;
for i = 1:500,
    for j = 1:500,
        if X_src(i, j) > 0,
            avg = avg + X_src(i, j);
            avg_cnt = avg_cnt + 1;
        end;
    end;
end;
avg = avg / avg_cnt;
disp(sprintf('avg %f', avg));

X_src_full = zeros(500, 500);

% fill in X_src_sub_full
for i = 1:500,
    for j = 1:500,
        X_src_full(i, j) = X_src(i, j);
        if X_src_full(i, j) < 1e-2,
            X_src_full(i, j) = avg;
        end; % if
    end; % for j
end; % for i

for k = [20],
    for l = [10],
        for ks = 1:1,
            %[X_tgt_predict] = codebook(X_src_sub, X_tgt, X_tgt_answer, k, l, 20);
            [X_tgt_predict] = codebook(X_src_full, X_tgt, X_tgt_answer, k, l, 20);
        end; %for ks
        %[X_tgt_predict] = codebook(X_src, X_tgt, X_tgt_answer, k, l, 20);
    end; % for l
end; % for k

