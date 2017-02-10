function [X_tgt_predict] = codebook(X_src, X_tgt, X_tgt_answer, k, l, ITER)

addpath('./');

[U_src, S, V_src] = onmtf(X_src, k, l, 20);
% U: p-by-k
% S: k-by-l
% V: n-by-l
p_src = size(X_src, 1);
n_src = size(X_src, 2);

for i = 1:p_src,
    [M, I] = max(U_src(i,:)); % M for max valud and I for index
    for j = 1:k,
        if j == I,
            U_src(i, j) = 1;
        else,
            U_src(i, j) = 0;
        end;
    end;
end;

for i = 1:n_src,
    [M, I] = max(V_src(i,:)); % M for max valud and I for index
    for j = 1:l,
        if j == I,
            V_src(i, j) = 1;
        else,
            V_src(i, j) = 0;
        end;
    end;
end;

disp(sprintf('[codebook] Create B...'));
B_tmp1 = U_src' * X_src * V_src;
B_tmp2 = U_src' * ones(p_src, 1) * ones(1, n_src) * V_src;

B = zeros(k, l);

for i = 1:k,
    for j = 1:l,
        if B_tmp2(i, j) == 0,
            disp(sprintf('[B] i %d j %d', i, j));
            B(i, j) = 0;
        else,
            B(i, j) = B_tmp1(i, j) / B_tmp2(i, j);
        end; % if B_tmp2(i, j) == 0
    end; % for j = 1:l
end; % for i = 1:k
disp(sprintf('[codebook] Finish creating B...'));
disp(B(1,:));

p_tgt = size(X_tgt, 1);
n_tgt = size(X_tgt, 2);

U_tgt = zeros(p_tgt, k);
V_tgt = zeros(n_tgt, l);

disp(sprintf('[codebook] Start creating list...'));
% construct list
U_tgt_list = {};
U_tgt_list{p_tgt} = [];
V_tgt_list = {};
V_tgt_list{n_tgt} = [];
U_tgt_answer_list = {};
U_tgt_answer_list{p_tgt} = [];
V_tgt_answer_list = {};
V_tgt_answer_list{n_tgt} = [];
for i = 1:p_tgt,
    for j = 1:n_tgt,
        if X_tgt(i, j) == 1,
            U_tgt_list{i} = [U_tgt_list{i}, j];
            V_tgt_list{j} = [V_tgt_list{j}, i];
        end; % if X_tgt
        if X_tgt_answer(i, j) == 1,
            U_tgt_answer_list{i} = [U_tgt_answer_list{i}, j];
            V_tgt_answer_list{j} = [V_tgt_answer_list{j}, i];
        end; % if X_tgt_answer
    end; % for j
end; % for i
disp(sprintf('[codebook] Finish creating list.'));

% construct a mask matrix W, same dimention as X_tgt
% W for mask meaning which element is viewed and ehich is not
W = zeros(p_tgt, n_tgt);
for i = 1:p_tgt,
    for j = 1:n_tgt,
        if X_tgt(i, j) ~= 0,
            W(i, j) = 1;
        end; % if X_tgt(i, j) ~= 0
    end; % for j = 1:n_tgt
end; % for i = 1:p_tgt

fileID = fopen('exp.txt',  'a');

for ks = 1:1, % repeat 1 times, and find the best one as output

    disp(sprintf('[codebook] ks %d', ks));
    fprintf(fileID, '[codebook] ks %d\n', ks);

    V_tgt = zeros(n_tgt, l);
    for i = 1:n_tgt,
        r = randi(l);
        V_tgt(i, r) = 1;
    end; % for i = 1:n_tgt

    for iter = 1:ITER,

        change = false;

        disp(sprintf('[codebook] k %d l %d iter %d', k, l, iter));
        fprintf(fileID, '[codebook] k %d l %d iter %d\n', k, l, iter);
        V_tmp = B * V_tgt';
        for i = 1:p_tgt,
            mi_value = 1e9;
            mi_index = 0;
            for j = 1:k,
                v = X_tgt(i,:) - V_tmp(j,:);
                res = 0;
                for ii = 1:size(U_tgt_list{i}, 2),
                    idx = U_tgt_list{i}(ii);
                    res = res + power(v(idx), 2);
                end; % for
                if res < mi_value,
                    mi_value = res;
                    mi_index = j;
                end; % if res < mi_value
            end; % for j = 1:k
            if U_tgt(i,mi_index) ~= 1,
                change = true;
            end; % if U_tgt(i,mi_index) ~= 1
            U_tgt(i,:) = zeros(1,k);
            U_tgt(i,mi_index) = 1;
            if mod(i, 100) == 0,
                disp(sprintf('[codebook] Finish i %d', i));
            end; % if
        end; % for i = 1:p_tgt
        disp(sprintf('[codebook] Finish modify U_tgt'));

        U_tmp = U_tgt * B;
        for i = 1:n_tgt,
            mi_value = 1e9;
            mi_index = 0;
            for j = 1:l,
                v = X_tgt(:,i) - U_tmp(:,j);
                %res = v' * diag(W(:,i)) * v;
                res = 0;
                for ii = 1:size(V_tgt_list{i}, 2),
                    idx = V_tgt_list{i}(ii);
                    res = res + power(v(idx), 2);
                end; % for
                if res < mi_value,
                    mi_value = res;
                    mi_index = j;
                end, % if res < mi_value
            end; % for j = 1:l
            if V_tgt(i,mi_index) ~= 1,
                change = true;
            end; % if U_tgt(i,mi_index) ~= 1
            V_tgt(i,:) = zeros(1,l);
            V_tgt(i,mi_index) = 1;
        end; % for i = 1:n_tgt
        disp(sprintf('[codebook] Finish modify V_tgt'));

        % calculate final solution
        X_tgt_predict = zeros(p_tgt, n_tgt);
        tmp = U_tgt * B * V_tgt';
        for i = 1:p_tgt,
            for j = 1:n_tgt,
                if W(i, j) == 1,
                    %X_tgt_predict(i, j) = X_tgt(i, j);
                    X_tgt_predict(i, j) = tmp(i, j);
                else,
                    X_tgt_predict(i, j) = tmp(i, j);
                end; % if W(i, j) == 1
            end; % for j = 1:n_tgt
        end; % for i = 1:p_tgt
        disp(sprintf('[codebook] Finish calculate solution'));

        rmse = 0;
        rmse_cnt = 0;
        for i = 1:size(X_tgt, 1),
            for j = 1:size(X_tgt, 2),
                if X_tgt(i, j) > 0,
                    rmse = rmse + power(X_tgt(i, j) - X_tgt_predict(i, j), 2);
                    rmse_cnt = rmse_cnt + 1;
                end; % if X_tgt_answer ~= 0
            end; % for j = 1:size
        end; % for i = 1:size
        disp(sprintf('[codebook] rmse(train) %f', power(rmse / rmse_cnt, 0.5)));
        fprintf(fileID, '[codebook] rmse(train) %f\n', power(rmse / rmse_cnt, 0.5));

        rmse = 0;
        rmse_cnt = 0;
        for i = 1:size(X_tgt_answer, 1),
            for j = 1:size(X_tgt_answer, 2),
                if X_tgt_answer(i, j) > 0,
                    rmse = rmse + power(X_tgt_answer(i, j) - X_tgt_predict(i, j), 2);
                    rmse_cnt = rmse_cnt + 1;
                end; % if X_tgt_answer ~= 0
            end; % for j = 1:size
        end; % for i = 1:size
        disp(sprintf('[codebook] rmse(test) %f', power(rmse / rmse_cnt, 0.5)));
        fprintf(fileID, '[codebook] rmse(test) %f\n', power(rmse / rmse_cnt, 0.5));

        if ~change,
            break;
        end;

    end; % for iter = 1:ITER

end; % for ks



