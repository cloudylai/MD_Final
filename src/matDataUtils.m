%% Strategy1: make mix2, mix5: use target with source aux %%
%{
fprintf(1, 'make test1 mat file ...\n');
targetTrainFile = '../gendata/test1/target_1.tr.txt';
targetValidFile = '../gendata/test1/target_1.val.txt';
targetTestFile = '../gendata/test1/target_1.te.txt';
sourceTrainFile = '../gendata/test1/source_taridx_1.tr.txt';
sourceValidFile = '../gendata/test1/source_taridx_1.val.txt';
train_rating = [];
val_rating = [];
test_rating = [];
RU = [];
RI = [];
RN = [];

fprintf(1, 'load file data...\n');

train_rating = dlmread(targetTrainFile, ' ');
train_rating = train_rating(:, 1:3);
%% mix2 %% 
%RU = repmat(train_rating, 1);
%RI = repmat(train_rating, 1);
%%
disp(size(train_rating));

%disp(train_rating(1,1));
%disp(train_rating(1,2));
%disp(train_rating(1,3));
%disp(train_rating(1,4));

val_rating = dlmread(targetValidFile, ' ');
val_rating = val_rating(:, 1:3);
disp(size(val_rating));

test_rating = dlmread(targetTestFile, ' ');
test_rating = test_rating(:, 1:3);
disp(size(test_rating));

tr_RN = dlmread(sourceTrainFile, ' ');
tr_RN = tr_RN(:, 1:3);
val_RN = dlmread(sourceValidFile, ' ');
val_RN = val_RN(:, 1:3);
RN = [tr_RN; val_RN];
disp(size(RN));

RU = repmat(train_rating, 1);
RI = repmat(train_rating, 1);
RU = [RU; val_RN];
RI = [RI; val_RN];
disp(size(RU));


fprintf(1, 'dump mat file data...\n');
save('../gendata/test1/mix_5.mat', 'train_rating', 'val_rating', 'test_rating', 'RU', 'RI', 'RN');
%}


%% Strategy2: make mix3, mix4: use source with target aux %%
%{
fprintf(1, 'make test1 mat file ...\n');
targetTrainFile = '../gendata/test1/target_1.tr.txt';
targetValidFile = '../gendata/test1/target_1.val.txt';
targetTestFile = '../gendata/test1/target_1.te.txt';
sourceTrainFile = '../gendata/test1/source_taridx_1.tr.txt';
sourceValidFile = '../gendata/test1/source_taridx_1.val.txt';
train_rating = [];
val_rating = [];
test_rating = [];
RU = [];
RI = [];
RN = [];

fprintf(1, 'load file data...\n');

src_train_rating = dlmread(sourceTrainFile, ' ');
src_val_rating = dlmread(sourceValidFile, ' ');
train_rating = [src_train_rating; src_val_rating];
train_rating = train_rating(:, 1:3);
% mix3 %
%RU = repmat(train_rating, 1);
%RI = repmat(train_rating, 1);
%%
disp(size(train_rating));

%disp(train_rating(1,1));
%disp(train_rating(1,2));
%disp(train_rating(1,3));
%disp(train_rating(1,4));

val_rating = dlmread(targetValidFile, ' ');
val_rating = val_rating(:, 1:3);
disp(size(val_rating));

test_rating = dlmread(targetTestFile, ' ');
test_rating = test_rating(:, 1:3);
disp(size(test_rating));

RN = dlmread(targetTrainFile, ' ');
% mix 4 %
RU = repmat(RN, 1);
RI = repmat(RN, 1);
RN = RN(:, 1:3);
disp(size(RN));

fprintf(1, 'dump mat file data...\n');
save('../gendata/test1/mix_4.mat', 'train_rating', 'val_rating', 'test_rating', 'RU', 'RI', 'RN');
%}


%% make mix6: cross validation data %%
%{
fprintf(1, 'make test1 mat file ...\n');
trainTrainCV0File = '../gendata/test1/train_train_cv_0.txt';
trainTrainCV1File = '../gendata/test1/train_train_cv_1.txt';
trainTrainCV2File = '../gendata/test1/train_train_cv_2.txt';
trainTrainCV3File = '../gendata/test1/train_train_cv_3.txt';
trainTrainCV4File = '../gendata/test1/train_train_cv_4.txt';
trainTestFile = '../data/test1/train_test.txt';
targetTestFile = '../gendata/test1/target_1.te.txt';
sourceTrainFile = '../gendata/test1/source_taridx_1.tr.txt';
sourceValidFile = '../gendata/test1/source_taridx_1.val.txt';

train_rating = [];
val_rating = [];
test_rating = [];
RU = [];
RI = [];
RN = [];

fprintf(1, 'load file data...\n');

cv0_rating = dlmread(trainTrainCV0File, ' ');
cv0_rating = cv0_rating(:, 1:3);
cv1_rating = dlmread(trainTrainCV1File, ' ');
cv1_rating = cv1_rating(:, 1:3);
cv2_rating = dlmread(trainTrainCV2File, ' ');
cv2_rating = cv2_rating(:, 1:3);
cv3_rating = dlmread(trainTrainCV3File, ' ');
cv3_rating = cv3_rating(:, 1:3);
cv4_rating = dlmread(trainTrainCV4File, ' ');
cv4_rating = cv4_rating(:, 1:3);

train_test_rating = dlmread(trainTestFile, '\t');
train_test_rating = train_test_rating(:, 1:3);
test_rating = dlmread(targetTestFile, ' ');
test_rating = test_rating(:, 1:3);

src_train_rating = dlmread(sourceTrainFile, ' ');
src_train_rating = src_train_rating(:, 1:3);
src_val_rating = dlmread(sourceValidFile, ' ');
src_val_rating = src_val_rating(:, 1:3);
%disp(size(src_train_rating));
%disp(size(src_val_rating));

train_rating = [cv1_rating; cv2_rating; cv3_rating; cv4_rating];
val_rating = repmat(cv0_rating, 1);
RU = repmat(train_rating, 1);
RU = [RU; src_val_rating];
RI = repmat(train_rating, 1);
RI = [RI; src_val_rating];
RN = [src_train_rating; src_val_rating];
fprintf('cv 0 chunk:\n');
disp(size(train_rating));
disp(size(val_rating));
disp(size(test_rating));
disp(size(RU));
disp(size(RI));
disp(size(RN));
save('../gendata/test1/mix_6_cv_0.mat', 'train_rating', 'val_rating', 'train_test_rating', 'test_rating', 'RU', 'RI', 'RN');

train_rating = [cv0_rating; cv2_rating; cv3_rating; cv4_rating];
val_rating = repmat(cv1_rating, 1);
RU = repmat(train_rating, 1);
RU = [RU; src_val_rating];
RI = repmat(train_rating, 1);
RI = [RI; src_val_rating];
RN = [src_train_rating; src_val_rating];
fprintf('cv 1 chunk:\n');
disp(size(train_rating));
disp(size(val_rating));
disp(size(test_rating));
disp(size(RU));
disp(size(RI));
disp(size(RN));
save('../gendata/test1/mix_6_cv_1.mat', 'train_rating', 'val_rating', 'train_test_rating', 'test_rating', 'RU', 'RI', 'RN');

train_rating = [cv0_rating; cv1_rating; cv3_rating; cv4_rating];
val_rating = repmat(cv2_rating, 1);
RU = repmat(train_rating, 1);
RU = [RU; src_val_rating];
RI = repmat(train_rating, 1);
RI = [RI; src_val_rating];
RN = [src_train_rating; src_val_rating];
fprintf('cv 2 chunk:\n');
disp(size(train_rating));
disp(size(val_rating));
disp(size(test_rating));
disp(size(RU));
disp(size(RI));
disp(size(RN));
save('../gendata/test1/mix_6_cv_2.mat', 'train_rating', 'val_rating', 'train_test_rating', 'test_rating', 'RU', 'RI', 'RN');

train_rating = [cv0_rating; cv1_rating; cv2_rating; cv4_rating];
val_rating = repmat(cv3_rating, 1);
RU = repmat(train_rating, 1);
RU = [RU; src_val_rating];
RI = repmat(train_rating, 1);
RI = [RI; src_val_rating];
RN = [src_train_rating; src_val_rating];
fprintf('cv 3 chunk:\n');
disp(size(train_rating));
disp(size(val_rating));
disp(size(test_rating));
disp(size(RU));
disp(size(RI));
disp(size(RN));
save('../gendata/test1/mix_6_cv_3.mat', 'train_rating', 'val_rating', 'train_test_rating', 'test_rating', 'RU', 'RI', 'RN');

train_rating = [cv0_rating; cv1_rating; cv2_rating; cv3_rating];
val_rating = repmat(cv4_rating, 1);
RU = repmat(train_rating, 1);
RU = [RU; src_val_rating];
RI = repmat(train_rating, 1);
RI = [RI; src_val_rating];
RN = [src_train_rating; src_val_rating];
fprintf('cv 4 chunk:\n');
disp(size(train_rating));
disp(size(val_rating));
disp(size(test_rating));
disp(size(RU));
disp(size(RI));
disp(size(RN));
save('../gendata/test1/mix_6_cv_4.mat', 'train_rating', 'val_rating', 'train_test_rating', 'test_rating', 'RU', 'RI', 'RN');
%}

%% Spilt data: make target all, target source, target train, target valid, target test 
fprintf(1, 'make target all mat file ...\n');
targetTrainFile = '../gendata/test1/target2.tr.txt';
targetValidFile = '../gendata/test1/target2.val.txt';
targetTestFile = '../gendata/test1/target2.te.txt';
sourceFile = '../gendata/test1/target2.src.txt';
targetUserFile = '../gendata/test1/target2.tar.user';
targetItemFile = '../gendata/test1/target2.tar.item';
sourceUserFile = '../gendata/test1/target2.src.user';
sourceItemFile = '../gendata/test1/target2.src.item';
%overlayItemFile = '../gendata/test1/target1.over.item';
train_rating = [];
val_rating = [];
test_rating = [];
source_rating = [];
RU = [];
RI = [];
RN = [];

fprintf(1, 'load file data...\n');

train_rating = dlmread(targetTrainFile, ' ');
train_rating = train_rating(:, 1:3);
disp(size(train_rating));

%disp(train_rating(1,1));
%disp(train_rating(1,2));
%disp(train_rating(1,3));
%disp(train_rating(1,4));

val_rating = dlmread(targetValidFile, ' ');
val_rating = val_rating(:, 1:3);
disp(size(val_rating));

test_rating = dlmread(targetTestFile, ' ');
test_rating = test_rating(:, 1:3);
disp(size(test_rating));

source_rating = dlmread(sourceFile, ' ');
source_rating = source_rating(:, 1:3);
disp(size(source_rating));

target_user = dlmread(targetUserFile);
target_item = dlmread(targetItemFile);
source_user = dlmread(sourceUserFile);
source_item = dlmread(sourceItemFile);
%overlay_item = dlmread(overlayItemFile);

fprintf(1, 'dump mat file data...\n');
save('../gendata/test1/target2_1.mat', 'train_rating', 'val_rating', 'test_rating', 'source_rating', 'target_user', 'target_item', 'source_user', 'source_item');