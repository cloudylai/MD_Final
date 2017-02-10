python pickValidation.py ../test1/train.txt ../test1/train_train.txt ../test1/train_test.txt 0.1
python pickValidation.py ../test2/train.txt ../test2/train_train.txt ../test2/train_test.txt 0.1
python pickValidation.py ../test3/train.txt ../test3/train_train.txt ../test3/train_test.txt 0.1
#baseline
#split train valid
# python pickValidation.py ../test1/train_train.txt ../test1/ctwTargetTrain.txt ../test1/ctwTargetValid.txt 0.1
# python pickValidation.py ../test1/source.txt ../test1/ctwSourceTrain.txt ../test1/ctwSourceValid.txt 0.2
#preprocess test: ?=>0
# python preprocessTest.py ../test1/test.txt ../test1/ctwTest.txt

#============================ baseline libmf ============================
mkdir ../model
mkdir ../output
cd libmf-2.01/
./mf-train -k 500 -t 40 -l2 0.02 -p  ../../test1/train_test.txt ../../test1/train_train.txt ../model/model1.txt
./mf-train -k 500 -t 40 -l2 0.02 -v 5  ../../test1/train_train.txt
# ./mf-predict ../../test1/ctwTest.txt ../model/model1.txt ../output/pred1.txt
# ./mf-predict ../../test1/train_test.txt ../model/model1.txt ../output/pred1.txt
cd ..
# python afterprocessTest.py ../test1/ctwTest.txt output/pred1.txt output/pred1_final.txt

#============================ baseline libfm ============================
# bash crossValidFM.sh ../test1/train_train.txt 1000 cross1
cd libfm-1.42.src/
# ./scripts/triple_format_to_libfm.pl -in ../../test1/train_train.txt -target 2 -separator "\t"
# ./scripts/triple_format_to_libfm.pl -in ../../test1/train_test.txt -target 2 -separator "\t"
./scripts/triple_format_to_libfm.pl -in ../../test1/train_train.txt,../../test1/train_test.txt -target 2 -separator "\t"
./bin/libFM -task r -train ../../test1/train_train.txt.libfm --test ../../test1/train_test.txt.libfm -dim "1,1,8" -init_stdev 0.001 -iter 1000
./bin/libFM -task r -train ../../test1/train_train.txt.libfm --test ../../test1/train_test.txt.libfm -dim "1,1,8" -iter 1000 -out ../output/pred_libfm1.txt 
./bin/libFM -task r -train ../../test1/train_train.txt.libfm --test ../../test1/train_test.txt.libfm -dim "1,1,8" -iter 1000 -method sgd -learn_rate 0.001 -regular ’0.01,0.01,0.02’ -init_stdev 0.1
./bin/libFM -task r -train ../../test1/train_train.txt.libfm --test ../../test1/train_test.txt.libfm -dim "1,1,8" -iter 1000 -method mcmc -init_stdev 0.1

#============================ 3-1 paper ============================ 
#5 => 0.2061
#1.5=>0.2057
#0.5=>0.2055
#0.2=>0.2056
#0.05=>0.2057
#0  =>0.2052
python pickValidation.py ../test1/train_train.txt ../test1/ctwTargetTrain.txt ../test1/ctwTargetValid.txt 0.1
python processAdd1.py ../test1/ctwTargetTrain.txt ../test1/ctwTargetTrain.txt
python processAdd1.py ../test1/ctwTargetValid.txt ../test1/ctwTargetValid.txt
python pickValidation.py ../test1/source.txt ../test1/ctwSourceTrain.txt ../test1/ctwSourceValid.txt 0.1
python processAdd1.py ../test1/ctwSourceTrain.txt ../test1/ctwSourceTrain.txt
python processAdd1.py ../test1/ctwSourceValid.txt ../test1/ctwSourceValid.txt
python preprocessTest.py ../test1/test.txt ../test1/ctwTest.txt
python processAdd1.py ../test1/ctwTest.txt ../test1/ctwTest.txt
python processAdd1.py ../test1/train_test.txt ../test1/ctwTrain_test.txt
cd 3-1/1_MF
./MF 0 ../../../test1/ctwTargetTrain.txt ../../../test1/ctwTargetValid.txt ../../../test1/ctwTargetValid.txt &> ../../../test1/log_R1 &
./MF 0 ../../../test1/ctwSourceTrain.txt ../../../test1/ctwSourceValid.txt ../../../test1/ctwSourceValid.txt &> ../../../test1/log_R2 &
cat ctwTargetTrain.txt_vali_model.txt | ./toP.sh > R1_P
cat ctwTargetTrain.txt_vali_model.txt | ./toQ.sh > R1_Q
cat ctwSourceTrain.txt_vali_model.txt | ./toP.sh > R2_P
cat ctwSourceTrain.txt_vali_model.txt | ./toQ.sh > R2_Q

cd ../2_latentSpaceMatching_and_matchingRefinement
matlab
[idxP idxQ] = two_block_search(load('../../../test1/ctwTargetTrain.txt'), load('../../../test1/ctwTargetValid.txt'), load('../../../test1/ctwTest.txt'), load('../1_MF/R1_P'), load('../1_MF/R1_Q'), load('../../../test1/ctwSourceTrain.txt'), load('../1_MF/R2_P'), load('../1_MF/R2_Q'), 50, 500);
dlmwrite('idxP', idxP);
dlmwrite('idxQ', idxQ);
exit
mv idxP ../../../test1/idxP
mv idxQ ../../../test1/idxQ

python mergeMatrix.py ../test1/source.txt ../test1/train_train.txt ../test1/idxP ../test1/idxQ ../test1/mergedTrain.txt
python mergeMatrix.py ../test1/source.txt ../test1/train.txt ../test1/idxP_0_200 ../test1/idxQ_0_200 ../test1/mergedTrain3-1.txt
#paper + libmf
python pickValidation.py ../test1/mergedTrain.txt ../test1/ctwTrain_train.txt ../test1/ctwTrain_valid.txt 0.1
cd libmf-2.01/
./mf-train -k 100 -t 200 -p  ../../test1/ctwTrain_valid.txt ../../test1/ctwTrain_train.txt ../model/model2.txt
./mf-train -k 100 -t 200 -v 5 ../../test1/ctwTrain_train.txt
# ./mf-predict ../../test1/ctwTest.txt ../model/model1.txt ../output/pred1.txt
./mf-predict ../../test1/train_test.txt ../model/model2.txt ../output/pred2.txt
cd ..

#paper + libFM
python pickValidation.py ../test1/mergedTrain.txt ../test1/ctwTrain_train.txt ../test1/ctwTrain_valid.txt 0.1
cd libfm-1.42.src/
./scripts/triple_format_to_libfm.pl -in ../../test1/ctwTrain_train.txt -target 2 -separator "\t"
./scripts/triple_format_to_libfm.pl -in ../../test1/ctwTrain_valid.txt -target 2 -separator "\t"
./scripts/triple_format_to_libfm.pl -in ../../test1/train_test.txt -target 2 -separator "\t"
./bin/libFM -task r -train ../../test1/ctwTrain_train.txt.libfm --test ../../test1/train_test.txt.libfm -dim "1,1,8" -out ../output/pred_libfm1.txt -iter 1000 -method sgda -learn_rate 0.01 -init_stdev 0.1 -validation ../../test1/ctwTrain_valid.txt.libfm


./combinedMF ../../../test1/ctwTargetTrain.txt ../../../test1/ctwTargetValid.txt ../../../test1/ctwTrain_test.txt ../../../test1/ctwSourceTrain.txt ../../../test1/idxP_0_200 ../../../test1/idxQ_0_200 0 100 100