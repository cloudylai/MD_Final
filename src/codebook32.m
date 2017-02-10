% in hw3-2,
% source is a 30000 x 3000 matrix,
% and target is a 20000 x 2000 matrix

X_src = zeros(30000, 3000);
X_tgt = zeros(20000, 2000);
X_tgt_answer = zeros(20000, 2000);

[users, items, scores] = textread('../test2/source.txt', '%d %d %f');
for i = 1:size(users),
    X_src(users(i)+1, items(i)+1) = scores(i);
end;

[users, items, scores] = textread('../test2/train.txt', '%d %d %f');
for i = 1:size(users),
    X_tgt(users(i)+1, items(i)+1) = scores(i);
end;

[users, items, scores] = textread('../test2/train.txt', '%d %d %f');
for i = 1:size(users),
    X_tgt_answer(users(i)+1, items(i)+1) = scores(i);
end;

% calculate avg
avg = 0;
avg_cnt = 0;
for i = 1:30000,
    for j = 1:3000,
        if X_src(i, j) > 0,
            avg = avg + X_src(i, j);
            avg_cnt = avg_cnt + 1;
        end;
    end;
end;
avg = avg / avg_cnt;
disp(sprintf('avg %f', avg));

% sub sampling X_src_sub
X_src_sub = zeros(3000, 300);
X_src_sub_full = zeros(3000, 300);
sample_x = randsample(30000, 3000);
sample_y = randsample(3000, 300);
% fill in X_src_sub_full
for i = 1:3000,
    for j = 1:300,
        X_src_sub(i, j) = X_src(sample_x(i), sample_y(j));
        if X_src_sub(i, j) < 1e-2,
            X_src_sub(i, j) = avg;
        end; % if
        X_src_sub_full(i, j) = X_src_sub(i, j);
    end; % for j
end; % for i
% fill in X_src
for i = 1:30000,
    for j = 1:3000,
        if X_src(i, j) < 1e-2,
            X_src(i, j) = avg;
        end;
    end;
end;

for k = [5],
    for l = [5],
        for ks = 1:1,
            %[X_tgt_predict] = codebook(X_src_sub, X_tgt, X_tgt_answer, k, l, 20);
            [X_tgt_predict] = codebook(X_src_sub, X_tgt, X_tgt_answer, k, l, 20);
        end; %for ks
        %[X_tgt_predict] = codebook(X_src, X_tgt, X_tgt_answer, k, l, 20);
    end; % for l
end; % for k

