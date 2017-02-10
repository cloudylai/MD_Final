clc ; close all ; clear all;
RMSE = [];
MAE = [];
d = 10;
alpha = [1];
beta = [0.05];

query_time = 10;
query_size = 50;

for a = 1 : numel(alpha)
    for b = 1 : numel(beta)
        for iii = 1 : 1
            switch iii
				%% load different data %%
                %case 1,  load ../data/netflix_movie_data0001.mat
                %case 2,  load ../data/netflix_movie_data001.mat
                %case 3,  load ../data/netflix_movie_data002.mat
                %case 5,  load ../data/netflix_movie_data003.mat
                %case 6,  load ../data/netflix_movie_data004.mat
				case 1, load ../gendata/test1/target2_1.mat
				case 2, load ../gendata/test2/target2_1.mat
				case 3, load ../gendata/test3/target2_1.mat
            end
            fprintf('a = %d, b = %d, iii = %d\n',a,b,iii);
            
			%% data preprocess %%
			% change indices to Matlab (1~) format
			train_rating(:, 1:2) = train_rating(:, 1:2) + 1;
			val_rating(:, 1:2) = val_rating(:, 1:2) + 1;
			test_rating(:, 1:2) = test_rating(:, 1:2) + 1;
			source_rating(:, 1:2) = source_rating(:, 1:2) + 1;
			
			target_user = target_user + 1;
			target_item = target_item + 1;
			source_user = source_user + 1;
			source_item = source_item + 1;
						
			RI = repmat(train_rating, 1);
			RU = repmat(train_rating, 1);
			RN = [];
			
			%n_user = max(RI(:,1)) - min(train_rating(:,1)) + 1;
			%n_item = max(RU(:,2)) - min(train_rating(:,2)) + 1;			
			
			%% ?? %
			n_user = max(max(train_rating(:,1)), max(source_rating(:,1))) - min(min(train_rating(:,1)), min(source_rating(:,1))) + 1;
			n_item = max(max(train_rating(:,2)), max(source_rating(:,2))) - min(min(train_rating(:,2)), min(source_rating(:,2))) + 1;
			
			%aux_n_user = max(source_rating(:,1)) - min(source_rating(:,1)) + 1;
			%aux_n_item = max(source_rating(:,2)) - min(source_rating(:,2)) + 1;
			
			%% ??? %%
			%n_user = max(max(train_rating(:,1)));
			%n_item = max(max(train_rating(:,2)));
			
            for i = 1 : n_user
                if mod(i,500) == 0
                    fprintf('cache the index so that we don"t need to perform find every time... %d/%d\n',i,n_user);
                end
                ind_u_train{i} = find(train_rating(:,1) == i);
                ind_u_RU{i} = find(RU(:,1) == i);
                ind_u_RI{i} = find(RI(:,1) == i);
            end
            for i = 1 : n_item
                if mod(i,500) == 0
                    fprintf('cache the index so that we don"t need to perform find every time... %d/%d\n',i,n_item);
                end
                ind_v_train{i} = find(train_rating(:,2) == i);
                ind_v_RU{i} = find(RU(:,2) == i);
                ind_v_RI{i} = find(RI(:,2) == i);
            end
								
			
			%% active learning %%
			% record: [query_number, val_RMSE, test_RMSE]
			record = [];		
			
			% strategy 1: RU = train_rating, RI = train_rating, RN = query_rating, random query
			%disp(size(source_rating));
			%disp(size(source_user));
			pool_rating = repmat(source_rating, 1);
			pool_user = repmat(source_user, 1);
			%disp(size(pool_rating));
			%disp(size(pool_user));
			new_pool_rating = [];
			new_pool_user = [];
			for t = 1 : query_time
				fprintf(1, 'active learning %d:\npool rating size = %d, user size = %d\n', t, size(pool_rating, 1), size(pool_user, 2));
				s_t = cputime;
				[query_rating, new_pool_rating, new_pool_user] = activeQuery(train_rating, test_rating, pool_rating, pool_user, query_size, 'random');
				%disp(size(query_rating));
				%disp(size(new_pool_rating));
				%disp(size(new_pool_user));
				e_t = cputime;
				fprintf(1, 'querying cost time: %f\n', e_t - s_t);
				RN = [RN; query_rating];
				pool_rating = new_pool_rating;
				pool_user = new_pool_user;
				
				%% ?? %%
				aux_n_user = max(RN(:,1)) - min(RN(:,1)) + 1;
				aux_n_item = max(RN(:,2)) - min(RN(:,2)) + 1;
				
				%% ??? %%
				%n_user = max(max(train_rating(:,1)), max(RN(:,1)));
				%n_item = max(max(train_rating(:,2)), max(RN(:,2)));
				
				%aux_n_user = max(RN(:,1));
				%aux_n_item = max(RN(:,2));
			
				for i = 1 : aux_n_user
					%if mod(i,500) == 0
					%	fprintf('cache the index so that we don"t need to perform find every time... %d/%d\n',i,n_user);
					%end
					ind_u_RN{i} = find(RN(:,1) == i);
				end
				for i = 1 : aux_n_item
					%if mod(i,500) == 0
					%	fprintf('cache the index so that we don"t need to perform find every time... %d/%d\n',i,n_item);
					%end
					ind_v_RN{i} = find(RN(:,2) == i);
				end
%	            if iii == 1
%   	             flag = 1;
%       	     else
%           	     flag = 0;
%            	end
				flag = 0;
				%% train models %%
				s_t = cputime;
				[val_rmse, val_pred, test_rmse, test_pred ] =TPCF_v1(train_rating , val_rating, test_rating, d ,ind_u_train , ind_v_train , RU,ind_u_RU,ind_v_RU , RI , ind_u_RI,ind_v_RI , RN,ind_u_RN,ind_v_RN,alpha(a),beta(b),n_user,n_item,aux_n_user,aux_n_item,flag);
				e_t = cputime;
				fprintf(1, 'learning cost time: %f\n', e_t - s_t);
				RMSE = [RMSE];
				MAE = [MAE];
			
				%% record %%
				record = [record; [t * query_size, val_rmse, test_rmse]];
			end
			
			%% change indices back from the Matlab format
			train_rating(:, 1:2) = train_rating(:, 1:2) - 1;
			val_rating(:, 1:2) = val_rating(:, 1:2) - 1;
			test_rating(:, 1:2) = test_rating(:, 1:2) - 1;
			source_rating(:, 1:2) = source_rating(:, 1:2) - 1;
			
			target_user = target_user - 1;
			target_item = target_item - 1;
			source_user = source_user - 1;
			source_item = source_item - 1;
			
			RI(:, 1:2) = RI(:, 1:2) - 1;
			RU(:, 1:2) = RU(:, 1:2) - 1;
			RN(:, 1:2) = RN(:, 1:2) - 1;
			
			%% dump results %%
			switch iii
				case 1,
					dlmwrite('../results/test1/pred_record_1.txt', record, ' ');
					dlmwrite('../results/test1/pred_valid_1.txt', val_pred, ' ');
					dlmwrite('../results/test1/pred_1.txt', test_pred, ' ');
				case 2, 
					dlmwrite('../results/test2/pred_record_1.txt', record, ' ');
					dlmwrite('../results/test2/pred_valid_1.txt', val_pred, ' ');
					dlmwrite('../results/test2/pred_1.txt', test_pred, ' ');
				case 3, 
					dlmwrite('../results/test3/pred_record_1.txt', record, ' ');
					dlmwrite('../results/test3/pred_valid_1.txt', val_pred, ' ');
					dlmwrite('../results/test3/pred_1.txt', test_pred, ' ');
			end
        end
    end
end