function [F, S, G] = onmtf(X, k, l, iter)

[p, n] = size(X);
F = zeros(p, k);
S = zeros(k, l);
G = zeros(n, l);

% [idx, C] = kmeans(X, k) will cluster row of X into k clusters
% input an n-by-p matrix X
% return an n-by-1 vector(idx), k-by-p centroid C

% initialize F, S, G
disp(sprintf('[onmtf] Start kmeans'));
[F_idx] = kmeans(X, k);
disp(sprintf('[onmtf] Finish kmeans'));
F_clu_size = zeros(k);
for i = 1:p,
    F(i, F_idx(i)) = 1;
    F_clu_size(F_idx(i)) = F_clu_size(F_idx(i)) + 1;
end;
for i = 1:p,
    for j = 1:k,
        F(i, j) = F(i, j) + 0.2;
    end;
end;

disp(sprintf('[onmtf] Start kmeans'));
[G_idx] = kmeans(X', l);
disp(sprintf('[onmtf] Finish kmeans'));
G_clu_size = zeros(l);
for i = 1:n,
    G(i, G_idx(i)) = 1;
    G_clu_size(G_idx(i)) = G_clu_size(G_idx(i)) + 1;
end;
for i = 1:n,
    for j = 1:l,
        G(i, j) = G(i, j) + 0.2;
    end;
end;

for i = 1:p,
    for j = 1:n,
        S(F_idx(i), G_idx(j)) = S(F_idx(i), G_idx(j)) + X(i, j);
    end;
end;
for i = 1:k,
    for j = 1,l;
        S(i, j) = S(i, j) / power(F_clu_size(i), 0.5) / power(G_clu_size(j), 0.5);
    end;
end;

while iter > 0,
    disp(sprintf('[onmtf] iter %d', iter));
    iter = iter - 1;
    disp(sprintf('[onmtf] Calculate update element'));
    % update G
    G_tmp1 = X' * F * S;
    G_tmp2 = G * G' * X' * F * S;
    % update F
    F_tmp1 = X * G * S';
    F_tmp2 = F * F' * X * G * S';
    % update S
    S_tmp1 = F' * X * G;
    S_tmp2 = F' * F * S * G' * G;
    disp(sprintf('[onmtf] Finish calculate update element'));
    for i = 1:n,
        for j = 1:l,
            if G_tmp2(i, j) == 0,
                G(i, j) = 0;
            else,
                G(i, j) = G(i, j) * G_tmp1(i, j) / G_tmp2(i, j);
            end;
        end;
    end;
    for i = 1:p,
        for j = 1:k,
            if F_tmp2(i, j) == 0,
                F(i, j) = 0;
            else,
                F(i, j) = F(i, j) * F_tmp1(i, j) / F_tmp2(i, j);
            end;
        end;
    end;
    for i = 1:k,
        for j = 1:l,
            if S_tmp2(i, j) == 0,
                S(i, j) = 0;
            else,
                S(i, j) = S(i, j) * S_tmp1(i, j) / S_tmp2(i, j);
            end;
        end;
    end;
end;
