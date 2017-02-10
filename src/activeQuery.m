function [query_rating, new_pool_rating, new_pool_user] = activeQuery(train_rating, test_rating, pool_rating, pool_user, query_size, strategy)
	% Active Query %
	if strcmp(strategy, 'random') == 1
		[query_rating, query_user, query_user_index] = RandomQuery(pool_rating, pool_user, query_size);
	else
		fprintf(1, 'Error: unknown active query strategy\n');
	end
	
	% Change pool: remove queried ratings, users %
	user_index = true(1, size(pool_user, 1));
	user_index(query_user_index) = false;
	new_pool_user = pool_user(user_index, :);
	rating_index = true(1, size(pool_rating, 1));
	for i = 1 : query_size
		rating_index(pool_rating(:,1) == pool_user(query_user_index(i))) = false;
	end
	new_pool_rating = pool_rating(rating_index, :);
end


function [query_rating, query_user, query_user_index] = RandomQuery(pool_rating, pool_user, query_size)
	query_rating = [];
	query_user = [];
	query_user_index = randperm(size(pool_user, 1), query_size);
	for i = 1 : query_size
		new_query_rating = pool_rating(pool_rating(:,1) == pool_user(query_user_index(i)), :);
		query_rating = [query_rating; new_query_rating];
		query_user = [query_user; pool_user(query_user_index(i))];
	end
end