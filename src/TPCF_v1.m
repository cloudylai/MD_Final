function [val_RMSE, val_pred, test_RMSE, test_pred ] = TPCF_v2(R , R_val, RT, d ,ind_u_train , ind_v_train , RU,ind_u_RU,ind_v_RU , RI , ind_u_RI,ind_v_RI , RN,ind_u_RN,ind_v_RN,alpha,beta,input_n_user,input_n_item,input_aux_n_user,input_aux_n_item,flag)
val_RMSE = [];
val_pred = [];
test_RMSE = [];
test_pred = [];
alpha_u = 0.00; alpha_v = 0.00;
[val_RMSE, val_pred, test_RMSE, test_pred] = learn(R, R_val,RT, d ,ind_u_train , ind_v_train, RU,ind_u_RU,ind_v_RU , RI , ind_u_RI,ind_v_RI, RN,ind_u_RN,ind_v_RN,alpha,beta,input_n_user,input_n_item,input_aux_n_user,input_aux_n_item,flag);

end

function [val_RMSE, val_pred, test_RMSE, test_pred ] = learn(R, R_val,RT, d ,ind_u_train , ind_v_train, RU,ind_u_RU,ind_v_RU , RI , ind_u_RI,ind_v_RI, RN,ind_u_RN,ind_v_RN,alpha,beta,input_n_user,input_n_item,input_aux_n_user,input_aux_n_item,flag)
randn('state',0);
rand('state',0);
test_RMSE = [];
%n_user = max(max(RI(:,1)),max(RU(:,1))) - min(R(:,1)) + 1;
%n_item = max(max(RU(:,2)),max(RI(:,1))) - min(R(:,1)) + 1;
%% ?? %%
n_user = max(max(max(R(:,1)),max(RU(:,1))),max(RN(:,1))) - min(min(min(R(:,1)),min(RU(:,1))), min(RN(:,1))) + 1;
n_item = max(max(max(R(:,2)),max(RI(:,2))),max(RN(:,2))) - min(min(min(R(:,2)),min(RI(:,2))), min(RN(:,2))) + 1;

aux_n_user = max(max(RN(:,1)),max(RN(:,1))) - min(RN(:,1)) + 1;
aux_n_item = max(max(RN(:,2)),max(RN(:,2))) - min(RN(:,2)) + 1;

%n_user = input_n_user;
%n_item = input_n_item;

%aux_n_user = input_aux_n_user;
%aux_n_item = input_aux_n_item;

%% ??? %%
%n_user = max(max(max(R(:,1)),max(RU(:,1))),max(RN(:,1)));
%n_item = max(max(max(R(:,2)),max(RI(:,2))),max(RN(:,2)));

%aux_n_user = max(RN(:,1));
%aux_n_item = max(RN(:,2));

mean_r = mean(R(:,3));
mean_r_aux = mean(RN(:,3));

[n_user,n_item]
l_u = 0.1*randn(n_user,d);
l_v = 0.1*randn(n_item,d);
g_u  = rand(n_user , d) ;
g_v  = rand(n_item , d) ;

l_u_aux = 0.1*randn(n_user,d);
l_v_aux = 0.1*randn(n_item,d);

g_u_aux  = 1*rand(n_user , d) ;
g_v_aux  = 1*rand(n_item , d) ;

%% ?? %%
%l_u_aux = 0.1*randn(aux_n_user,d);
%l_v_aux = 0.1*randn(aux_n_item,d);

%g_u_aux = 1*rand(aux_n_user,d);
%g_v_aux = 1*rand(aux_n_item,d);
%%

m_u =  mean(l_u) + (alpha)*mean(l_u_aux);
m_v =  mean(l_v)  + (alpha) *mean(l_v_aux);

cov_u = ((l_u - repmat(m_u,size(l_u,1),1))' *  (l_u - repmat(m_u,size(l_u,1),1)) + diag(sum(g_u,1)'))./n_user ;
cov_v = ((l_v - repmat(m_v,size(l_v,1),1))' *  (l_v - repmat(m_v,size(l_v,1),1)) + diag(sum(g_v,1)'))./n_item;
cov_u = cov_u + (alpha) * ((l_u_aux - repmat(m_u,size(l_u_aux,1),1))' *  (l_u_aux - repmat(m_u,size(l_u_aux,1),1)) + diag(sum(g_u_aux,1)'))./aux_n_user;
cov_v = cov_v + (alpha) * ((l_v_aux - repmat(m_v,size(l_v_aux,1),1))' *  (l_v_aux - repmat(m_v,size(l_v_aux,1),1)) + diag(sum(g_v_aux,1)'))./aux_n_item;

u = int32(R(:,1)); v = int32(R(:,2)); r = R(:,3) - mean_r;
if flag == 0
	%% Debug %%
	sum(r.^2);
	l_u(u,:).*g_v(v,:);
	(l_u(u,:).*g_v(v,:)).*l_u(u,:);
	sum((l_u(u,:).*g_v(v,:)).*l_u(u,:));
	sum(sum((l_u(u,:).*g_v(v,:)).*l_u(u,:)));
	l_v(v,:).*g_u(u,:);
	(l_v(v,:).*g_u(u,:)).*l_v(v,:);
	sum((l_v(v,:).*g_u(u,:)).*l_v(v,:));
	sum(sum((l_v(v,:).*g_u(u,:)).*l_v(v,:)));
	l_u(u,:).*l_v(v,:);
	sum(l_u(u,:).*l_v(v,:),2);
	r.*sum(l_u(u,:).*l_v(v,:),2);
	sum(r.*sum(l_u(u,:).*l_v(v,:),2));
	l_u(u,:).*l_v(v,:);
	sum((l_u(u,:).*l_v(v,:)),2);
	sum((l_u(u,:).*l_v(v,:)),2).^2;
	sum(sum((l_u(u,:).*l_v(v,:)),2).^2);
	g_u(u,:).*g_v(v,:);
	sum(g_u(u,:).*g_v(v,:));
	sum(sum(g_u(u,:).*g_v(v,:)));
	%% %%
    sigma = (sum(r.^2)  + sum(sum((l_u(u,:).*g_v(v,:)).*l_u(u,:))) + sum(sum((l_v(v,:).*g_u(u,:)).*l_v(v,:)))...
        - 2 * sum(r.*sum(l_u(u,:).*l_v(v,:),2)) + sum(sum((l_u(u,:).*l_v(v,:)),2).^2) + sum(sum(g_u(u,:).*g_v(v,:))))./size(R,1);
else
    sigma = 1;
    mean_r = 2.5;
end

%% ?? %%
%u = RN(:,1); v = RN(:,2); r = RN(:,3) - mean_r_aux;

aux_u = RN(:,1); aux_v = RN(:,2); aux_r = RN(:,3) - mean_r_aux;

%% Debug %%
%sum(r.^2);
%size(l_u_aux)
%size(g_v)
%l_u_aux(u,:).*g_v(v,:);
%(l_u_aux(u,:).*g_v(v,:)).*l_u_aux(u,:);
%sum((l_u_aux(u,:).*g_v(v,:)).*l_u_aux(u,:));
%sum(sum((l_u_aux(u,:).*g_v(v,:)).*l_u_aux(u,:)));
%l_v_aux(v,:).*g_u_aux(u,:);
%sum((l_v_aux(v,:).*g_u_aux(u,:)));
%sum((l_v_aux(v,:).*g_u_aux(u,:)).*l_v_aux(v,:));
%sum(sum((l_v_aux(v,:).*g_u_aux(u,:)).*l_v_aux(v,:)));
%l_u_aux(u,:).*l_v_aux(v,:);
%sum(l_u_aux(u,:).*l_v_aux(v,:),2);
%r.*sum(l_u_aux(u,:).*l_v_aux(v,:),2);
%- 2 * sum(r.*sum(l_u_aux(u,:).*l_v_aux(v,:),2));
%l_u_aux(u,:).*l_v_aux(v,:);
%sum((l_u_aux(u,:).*l_v_aux(v,:)),2);
%sum((l_u_aux(u,:).*l_v_aux(v,:)),2).^2;
%sum(sum((l_u_aux(u,:).*l_v_aux(v,:)),2).^2);
%g_u_aux(u,:).*g_v_aux(v,:);
%sum(g_u_aux(u,:).*g_v_aux(v,:));
%sum(sum(g_u_aux(u,:).*g_v_aux(v,:)));
%%%%
sigma2 = (sum(r.^2)  + sum(sum((l_u_aux(u,:).*g_v(v,:)).*l_u_aux(u,:))) + sum(sum((l_v_aux(v,:).*g_u_aux(u,:)).*l_v_aux(v,:)))...
    - 2 * sum(r.*sum(l_u_aux(u,:).*l_v_aux(v,:),2)) + sum(sum((l_u_aux(u,:).*l_v_aux(v,:)),2).^2) + sum(sum(g_u_aux(u,:).*g_v_aux(v,:))))./size(RN,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
max_iter = 25;
max_step = 5;
max_prev_count = 5;
prev_count = 0;
%% for test3 %%
%RI(find(RI(:,3)<= 3) , 3) = 0;
%RI(find(RI(:,3)>3) , 3) = 1;
%RU(find(RU(:,3)<= 3) , 3) = 0;
%RU(find(RU(:,3)>3) , 3) = 1;
%% for test1, test2 %%
RI(find(RI(:,3) <= 0.5), 3) = 0;
RI(find(RI(:,3) > 0.5), 3) = 1;
RU(find(RU(:,3) <= 0.5), 3) = 0;
RU(find(RU(:,3) > 0.5), 3) = 1;


xi_u = RU; xi_v = RI;
A = l_u(xi_u(:,1) ,:);
B = l_v(xi_u(:,2) ,:);
C = g_u(xi_u(:,1) ,:);
D = g_v(xi_u(:,2) ,:);
%xi_u(:,3) = sqrt(sum(repmat(sum(A.*B,2),1,d).* A.*B + A.*A.*D + B.*B.*C + C.*D,2));
xi_u(:,3) = 0;
A = l_u(xi_v(:,1) ,:);
B = l_v(xi_v(:,2) ,:);
C = g_u(xi_v(:,1) ,:);
D = g_v(xi_v(:,2) ,:);
%xi_v(:,3) = sqrt(sum(repmat(sum(A.*B,2),1,d).* A.*B + A.*A.*D + B.*B.*C + C.*D,2));
xi_v(:,3) = 0;
best_val_rmse = 1000;
best_val_pred = [];
best_l_u = l_u;
best_l_v = l_v;
prev_rmse = 1000;
for iter = 1 : max_iter
    inv_u = inv(cov_u); inv_u_mul_m_u = inv_u * m_u';
    inv_v = inv(cov_v); inv_v_mul_m_v = inv_v * m_v';
    %%% e_step
    
    obj = 0;
    for e_step = 1 : max_step      
        for k =1 : 2
            fprintf('iter %d/%d e_step %d/%d...\n',iter,max_iter,(e_step-1) * 2 + k,max_step);
            parfor i  = 1 : n_user
                if flag == 0
                    ind = ind_u_train{i};
                    r = R(ind,3) - mean_r;
                    v_ind = R(ind  , 2);
                    temp  = 1./sigma .*(l_v(v_ind,:)'*l_v(v_ind,:) + diag(sum(g_v(v_ind,:),1))');
                    temp1 = 1./sigma .* sum(repmat(r,1,d).*l_v(v_ind,:),1)';
                    temp2 =  1./sigma .* sum(l_v(v_ind,:).^2 + g_v(v_ind,:),1);
                else
                    temp = 0; temp1 = 0; temp2 = 0;
                end
                ind = ind_u_RU{i};
                v_ind = RU(ind  , 2);
                r = RU(ind,3) ;
                r_aux = RU(ind,3) ;
                xi = xi_u(ind,3);
                temp = temp  +beta* (2 .* ((repmat(phi(xi),1,d).*l_v(v_ind,:))' * l_v(v_ind,:)) + 2 .* diag(sum(repmat(phi(xi) ,1,d).*g_v(v_ind,:),1)'));
                temp1= temp1 + beta*(sum(l_v(v_ind,:).*repmat(r_aux - 0.5, 1, d),1)');
                temp2 =temp2 + beta* sum(2.*repmat(phi(xi),1,d).*(l_v(v_ind,:).*l_v(v_ind,:) + g_v(v_ind,:)),1);
                ind = ind_u_RI{i};
                r_aux = RI(ind,3) ;
                v_ind = RI(ind  , 2);
                xi = xi_v(ind,3);
                temp = temp  + beta*(2 .* ((repmat(phi(xi),1,d).*l_v(v_ind,:))' * l_v(v_ind,:)) + 2 .* diag(sum(repmat(phi(xi) ,1,d).*g_v(v_ind,:),1)'));
                
                temp1= temp1 + beta*(sum(l_v(v_ind,:).*repmat(r_aux - 0.5, 1, d),1)');
                temp2 =temp2 + beta* sum(2.*repmat(phi(xi),1,d).*(l_v(v_ind,:).*l_v(v_ind,:) + g_v(v_ind,:)),1);
                l_u(i,:) = inv(inv_u +  temp ) *...
                    (inv_u_mul_m_u + temp1) ;
                g_u(i,:) = 1./(diag(inv_u)' +temp2 );
                
                
            end
            parfor i  = 1 : n_item
                if flag == 0
                    ind = ind_v_train{i};
                    r = R(ind,3) - mean_r;
                    u_ind = R(ind  , 1);
                    temp = 1./sigma .*(l_u(u_ind,:)'*l_u(u_ind,:) + diag(sum(g_u(u_ind,:),1))');
                    temp1 =1./sigma .* sum(repmat(r,1,d).*l_u(u_ind,:),1)';
                    temp2 =1./sigma .* sum(l_u(u_ind,:).^2 + g_u(u_ind,:),1);
                else
                    temp = 0 ;temp1 = 0; temp2= 0 ;
                end
                ind = ind_v_RU{i};
                r_aux    = RU(ind,3) ;
                r = RU(ind,3);
                u_ind = RU(ind  , 1);
                xi = xi_u(ind,3);
                temp  =  temp  +beta*( 2 .* ((repmat(phi(xi),1,d).*l_u(u_ind,:))' * l_u(u_ind,:)) + 2 .* diag(sum(repmat(phi(xi) ,1,d).*g_u(u_ind,:),1)'));
                temp1 =  temp1 + beta*(sum(l_u(u_ind,:).*repmat(r_aux - 0.5, 1, d),1)');
                temp2 =  temp2 + beta*sum(2.*repmat(phi(xi),1,d).*(l_u(u_ind,:).*l_u(u_ind,:) + g_u(u_ind,:)),1);
                ind = ind_v_RI{i};
                r_aux    = RI(ind,3) ;
                r = RI(ind,3);
                u_ind    = RI(ind  , 1);
                xi       = xi_v(ind,3);
                temp     =  temp  + beta*(2 .* ((repmat(phi(xi),1,d).*l_u(u_ind,:))' * l_u(u_ind,:)) + 2 .* diag(sum(repmat(phi(xi) ,1,d).*g_u(u_ind,:),1)'));
                temp1    =  temp1 + beta*(sum(l_u(u_ind,:).*repmat(r_aux - 0.5, 1, d),1)');
                temp2    =  temp2 +beta*sum(2.*repmat(phi(xi),1,d).*(l_u(u_ind,:).*l_u(u_ind,:) + g_u(u_ind,:)),1);
                l_v(i,:) = inv(inv_v + temp ) *....
                    (inv_v_mul_m_v + temp1) ;
                g_v(i,:) = 1./(diag(inv_v )' + temp2);
                
            end
            parfor i  = 1 : aux_n_user
                ind = ind_u_RN{i};
                r = RN(ind,3) - mean_r_aux;
                v_ind = RN(ind  , 2);
                temp  = 1./sigma2 .*(l_v_aux(v_ind,:)'*l_v_aux(v_ind,:) + diag(sum(g_v_aux(v_ind,:),1))');
                temp1 = 1./sigma2 .* sum(repmat(r,1,d).*l_v_aux(v_ind,:),1)';
                temp2 =  1./sigma2 .* sum(l_v_aux(v_ind,:).^2 + g_v_aux(v_ind,:),1);
                
                l_u_aux(i,:) = inv(inv_u +  temp ) *...
                    (inv_u_mul_m_u + temp1) ;
                g_u_aux(i,:) = 1./(diag(inv_u)' +temp2 );
                
                
            end
            parfor i  = 1 : aux_n_item
                ind = ind_v_RN{i};
                r = RN(ind,3) - mean_r_aux;
                u_ind = RN(ind  , 1);
                temp = 1./sigma2 .*(l_u_aux(u_ind,:)'*l_u_aux(u_ind,:) + diag(sum(g_u_aux(u_ind,:),1))');
                temp1 =1./sigma2 .* sum(repmat(r,1,d).*l_u_aux(u_ind,:),1)';
                temp2 =1./sigma2 .* sum(l_u_aux(u_ind,:).^2 + g_u_aux(u_ind,:),1);
                l_v_aux(i,:) = inv(inv_v + temp ) *....
                    (inv_v_mul_m_v + temp1) ;
                g_v_aux(i,:) = 1./(diag(inv_v )' + temp2);
                
            end
            
            A = l_u(xi_u(:,1) ,:);
            B = l_v(xi_u(:,2) ,:);
            C = g_u(xi_u(:,1) ,:);
            D = g_v(xi_u(:,2) ,:);
            xi_u(:,3) = sqrt(sum(repmat(sum(A.*B,2),1,d).* A.*B + A.*A.*D + B.*B.*C + C.*D,2));
            A = l_u(xi_v(:,1) ,:);
            B = l_v(xi_v(:,2) ,:);
            C = g_u(xi_v(:,1) ,:);
            D = g_v(xi_v(:,2) ,:);
            xi_v(:,3) = sqrt(sum(repmat(sum(A.*B,2),1,d).* A.*B + A.*A.*D + B.*B.*C + C.*D,2));
            
        end
    end
    %%%% m_step
    fprintf('variational M-step...\n');
    m_u =  (sum(l_u) + (alpha)*sum(l_u_aux))./(n_user + alpha * aux_n_user);
    m_v =  (sum(l_v)  + (alpha) *sum(l_v_aux))./(n_item + alpha * aux_n_item);
    
    
    temp_u = ((l_u - repmat(m_u,size(l_u,1),1))' *  (l_u - repmat(m_u,size(l_u,1),1)) + diag(sum(g_u,1)')) ;
    temp_v = ((l_v - repmat(m_v,size(l_v,1),1))' *  (l_v - repmat(m_v,size(l_v,1),1)) + diag(sum(g_v,1)'));
    temp_u1 = (alpha) * ((l_u_aux - repmat(m_u,size(l_u_aux,1),1))' *  (l_u_aux - repmat(m_u,size(l_u_aux,1),1)) + diag(sum(g_u_aux,1)'));
    temp_v1 = (alpha) * ((l_v_aux - repmat(m_v,size(l_v_aux,1),1))' *  (l_v_aux - repmat(m_v,size(l_v_aux,1),1)) + diag(sum(g_v_aux,1)'));
    cov_u = (temp_u + temp_u1)./(n_user + alpha *aux_n_user);
    cov_v = (temp_v + temp_v1)./(n_item + alpha *aux_n_item);
    [rmse, dummy]  = predict(R_val, l_u , l_v,mean_r);
    [rmse1, temp_val_pred]  = predict(R, l_u , l_v,mean_r);
    if rmse < best_val_rmse
        best_val_rmse = rmse;
		best_val_pred = temp_val_pred;
        best_l_u = l_u;
        best_l_v = l_v;
    end
    if rmse > prev_rmse
		prev_count = prev_count + 1;
		if prev_count > max_prev_count
			fprintf('early stopped !!!\n');
			break;
		end
    end
    prev_rmse = rmse;
    fprintf('val RMSE = %.5f , train RMSE = %.5f, best val RMSE = %.5f\n' , rmse,rmse1,best_val_rmse);
    u = R(:,1); v = R(:,2); r = R(:,3) - mean_r;
    sigma = (sum(r.^2)  + sum(sum((l_u(u,:).*g_v(v,:)).*l_u(u,:))) + sum(sum((l_v(v,:).*g_u(u,:)).*l_v(v,:)))...
        - 2 * sum(r.*sum(l_u(u,:).*l_v(v,:),2)) + sum(sum((l_u(u,:).*l_v(v,:)),2).^2) + sum(sum(g_u(u,:).*g_v(v,:))))./size(R,1);
    u = RN(:,1); v = RN(:,2); r = RN(:,3) - mean_r_aux;
    sigma2 = (sum(r.^2)  + sum(sum((l_u_aux(u,:).*g_v(v,:)).*l_u_aux(u,:))) + sum(sum((l_v_aux(v,:).*g_u_aux(u,:)).*l_v_aux(v,:)))...
        - 2 * sum(r.*sum(l_u_aux(u,:).*l_v_aux(v,:),2)) + sum(sum((l_u_aux(u,:).*l_v_aux(v,:)),2).^2) + sum(sum(g_u_aux(u,:).*g_v_aux(v,:))))./size(RN,1);
    if flag == 1
        sigma = 1;
    end
    
end
[val_RMSE, val_pred ] = predict(R_val, best_l_u, best_l_v, mean_r);
[test_RMSE, test_pred ]  = predict(RT, best_l_u , best_l_v,mean_r);
%%[val_RMSE, val_pred ]  = predict(RT_val, best_l_u, best_l_v, mean_r);
%%[test_RMSE, test_pred ] = predict(RT, best_l_u, best_l_v, mean_r);
fprintf('target val RMSE = %.5f\n', val_RMSE);
end
function acc = predict_lr(rating , l_u,l_v)
u = rating(:,1);
v = rating(:,2);
r = rating(:,3);
pred = sigm(sum(l_u(u,:).*l_v(v,:) , 2)) ;
pred = pred >= 0.5;
acc = sum(r==pred)/size(r,1);

end
function [rmse, pred]  = predict(rating , l_u , l_v,mean_r)

u = rating(:,1);
v = rating(:,2);
r = rating(:,3);
pred = sum(l_u(u,:).*l_v(v,:) , 2) + mean_r;
%pred(pred > 5) = 5;
%pred(pred < 1) = 1;

rmse = sqrt(sum((pred - r).^2)./size(u,1));
end

function x = phi(x)
x = (1./(2.*x)) .* (sigm(x) - 0.5);
x(find(isnan(x))) = 1/8;
end
function x = sigm(x)
x = 1./(1+exp(-x));
end