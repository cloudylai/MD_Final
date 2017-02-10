#include<stdio.h>
#include<time.h>
#include<stdlib.h>
#include<assert.h>
#include<string.h>
#include<float.h>
#include<math.h>
#include<vector>

using namespace std;

class Parameter{
    public:
	/***********************************************************************************/
	static const int nFEATURE = 5;
	static const constexpr double learningRate = 0.004;//0.0025;//0.0000003;
	static double featureReg, userMappingReg, itemMappingReg;
	static const int MONITER_ITERATION_NUM = 20;


	static const int ID_START_IS_ONE = 1;
	/***********************************************************************************/

	static void dumpParameter(){
		//print setting
		fprintf(stderr, "nFEATURE = %d\n", nFEATURE);
		fprintf(stderr, "learningRate = %lf\n", learningRate);
		fprintf(stderr, "featureReg = %lf\n", featureReg);
		fprintf(stderr, "userMappingReg = %lf, itemMappingReg = %lf\n", userMappingReg, itemMappingReg);
		fprintf(stderr, "MONITER_ITERATION_NUM = %d\n", MONITER_ITERATION_NUM);
	}
};


void dealWithID(int& anID){
	if(Parameter::ID_START_IS_ONE){
		assert(anID >= 1);
		--anID;
		return;
	}
	assert(0);
}

inline double pow2(double x){
	return x*x;
}

class RatingList{
    public:
	
	class RatingTuple{
	    public:
		int userID, itemID;
		double rating, originalRating;
		RatingTuple(int a, int b, double c, double d):userID(a),itemID(b),rating(c), originalRating(d){}
	};

	vector<RatingTuple> ratingList;
	int maxUidP1, maxIidP1;
	double maxValue, minValue;
	

	RatingList(const char* fileName = ""){
		if(fileName[0] == '\0'){//dummy RatingList
			maxUidP1 = 0;
			maxIidP1 = 0;
			maxValue = 0;
			minValue = 0;
			return;
		}
		maxUidP1= 0, maxIidP1 = 0;
		FILE* fp = fopen(fileName, "r");
		assert(NULL != fp);
		int u, i;
		double r;
		assert(NULL != fp);
		maxValue = -1000000;	//just a small value
		minValue =  1000000;    //just a large value
		while(fscanf(fp, "%d %d %lf", &u,&i,&r) == 3){
			//start from 1, shift to 0
			dealWithID(u);
			dealWithID(i);

			RatingTuple x(u,i,r,r);
			ratingList.push_back(x);
			maxUidP1 = maxUidP1 >= u+1? maxUidP1: u+1;
			maxIidP1 = maxIidP1 >= i+1? maxIidP1: i+1;

			if(r > maxValue) maxValue = r;
			if(r < minValue) minValue = r;
		}
		assert(-1 == fscanf(fp, "%d", &u));
		fprintf(stderr, "%s: maxUidP1 %d, maxIidP1 %d\n", fileName, maxUidP1, maxIidP1);
		fclose(fp);
	}
};



void getMeanVar_scaleTraining(RatingList& training, double& globalMean, double& globalVariance){
	double squareSum = 0;
	globalMean = 0;
	for(vector<RatingList::RatingTuple>::iterator it = training.ratingList.begin(); it != training.ratingList.end(); it++){
		globalMean += it->rating;
		squareSum += it->rating * it->rating;
	}
	globalMean /= (double)training.ratingList.size();
	globalVariance = sqrt(squareSum/(double)training.ratingList.size() - globalMean*globalMean);
		
	for(vector<RatingList::RatingTuple>::iterator it = training.ratingList.begin(); it != training.ratingList.end(); it++)
		it->rating = (it->rating - globalMean)/globalVariance;
}


class MatrixFactorizationData{
    public:
	static const int nFEATURE = Parameter::nFEATURE;
	RatingList training, validation, testing;
	double globalMean, globalVariance;
	
	const char* trainingName, *validationName, *testingName;
	double (*userFeature)[nFEATURE], (*itemFeature)[nFEATURE], (*userFeatureStep)[nFEATURE], (*itemFeatureStep)[nFEATURE];
	double (*userFeaturePast)[nFEATURE], (*itemFeaturePast)[nFEATURE];
	double (*userBestFeature)[nFEATURE], (*itemBestFeature)[nFEATURE];

	inline void allocateMemory(int maxUidP1, int maxIidP1){
		userFeature = new double[maxUidP1][nFEATURE];
		userFeatureStep = new double[maxUidP1][nFEATURE];
		userFeaturePast = new double[maxUidP1][nFEATURE];
		itemFeature = new double[maxIidP1][nFEATURE];
		itemFeatureStep = new double[maxIidP1][nFEATURE];
		itemFeaturePast = new double[maxIidP1][nFEATURE];
		userBestFeature = new double[maxUidP1][nFEATURE];
		itemBestFeature = new double[maxIidP1][nFEATURE];
	}
	

	void randomInitializeFeature(int maxUidP1, int maxIidP1){
		for(int i = 0; i < maxUidP1; ++i){
			for(int j = 0; j < nFEATURE; ++j){
				userFeature[i][j] = ((double)rand()/RAND_MAX/10 - 0.05)/nFEATURE;
			}
		}
		for(int i = 0; i < maxIidP1; ++i){
			for(int j = 0; j < nFEATURE; ++j){
				itemFeature[i][j] = ((double)rand()/RAND_MAX/10 - 0.05)/nFEATURE;
			}
		}
	}

	MatrixFactorizationData(const char* trainFile, const char* validFile, const char* testFile):training(trainFile), validation(validFile), testing(testFile){
		{
			int i;
			for(i = (int)strlen(trainFile)-1; i >= 0;--i)
				if(trainFile[i] == '/')
					break;
			trainingName = &trainFile[i+1];

			for(i = (int)strlen(validFile)-1; i >= 0;--i)
				if(validFile[i] == '/')
					break;
			validationName = &validFile[i+1];

			for(i = (int)strlen(testFile)-1; i >= 0;--i)
				if(testFile[i] == '/')
					break;
			testingName = &testFile[i+1];
		}

		Parameter:: dumpParameter();

		//some data: last time frame => no data in training
		if(training.maxUidP1 < validation.maxUidP1)
			training.maxUidP1 = validation.maxUidP1;
		if(training.maxUidP1 < testing.maxUidP1)
			training.maxUidP1 = testing.maxUidP1;
		if(training.maxIidP1 < validation.maxIidP1)
			training.maxIidP1 = validation.maxIidP1;
		if(training.maxIidP1 < testing.maxIidP1)
			training.maxIidP1 = testing.maxIidP1;
	
		fprintf(stderr, "train: maxUidP1 %d maxIidP1 %d\n", training.maxUidP1, training.maxIidP1);
		fprintf(stderr, "valid: maxUidP1 %d maxIidP1 %d\n", validation.maxUidP1, validation.maxIidP1);
		fprintf(stderr, "test: maxUidP1 %d maxIidP1 %d\n", testing.maxUidP1, testing.maxIidP1);
		fprintf(stderr, "train: max%lf min%lf\n", training.maxValue, training.minValue);
		fprintf(stderr, "valid: max%lf min%lf\n", validation.maxValue, validation.minValue);
		fprintf(stderr, "test: max%lf min%lf\n", testing.maxValue, testing.minValue);

//		assert(training.maxValue == validation.maxValue && training.minValue == validation.minValue);
//		assert(training.maxValue == testing.maxValue && training.minValue == testing.minValue);
		assert(training.maxUidP1 >= validation.maxUidP1 && training.maxIidP1 >= validation.maxIidP1);
		assert(training.maxUidP1 >= testing.maxUidP1 && training.maxIidP1 >= testing.maxIidP1);
	
		allocateMemory(training.maxUidP1, training.maxIidP1);
		
		globalMean = 0, globalVariance = 1;
		getMeanVar_scaleTraining(training, globalMean, globalVariance);
		fprintf(stderr, "globalMean = %lf, globalVariance = %lf\n", globalMean, globalVariance);

		randomInitializeFeature(training.maxUidP1, training.maxIidP1);
	}


	void calculateGeneralError(const RatingList& inList, double& theRMSE, double& theMAE, const double meanOfModel, const double varianceOfModel){
		theRMSE = 0;
		theMAE = 0;
		for(vector<RatingList::RatingTuple>::const_iterator it = inList.ratingList.begin(); it != inList.ratingList.end(); it++){
			int userID = it->userID, itemID = it->itemID;
			double epsilon = 0;
			for(int j = 0; j < nFEATURE; ++j)
				epsilon += userFeature[userID][j] * itemFeature[itemID][j];
	
			epsilon *= varianceOfModel;
			epsilon += meanOfModel - it->rating;

			//clipped penalty
/*			if(it->originalRating == inList.maxValue && epsilon > 0)
				epsilon = 0;
			if(it->originalRating == inList.minValue && epsilon < 0)
				epsilon = 0;*/
			
			theRMSE += epsilon*epsilon;
			theMAE += fabs(epsilon);
		}
		theRMSE = sqrt(theRMSE/(double)inList.ratingList.size());
		theMAE /= (double)inList.ratingList.size();
	}

	void calculateTrainingError(double& theRMSE, double& theMAE, double& objectiveValue){
		objectiveValue = 0;
		for(int userID = 0; userID < training.maxUidP1; ++userID)
			for(int k = 0; k < nFEATURE; ++k)
				objectiveValue += pow2(userFeature[userID][k]);
		for(int itemID = 0; itemID < training.maxIidP1; ++itemID)
			for(int k = 0; k < nFEATURE; ++k)
				objectiveValue += pow2(itemFeature[itemID][k]);
		objectiveValue *= Parameter::featureReg;
		calculateGeneralError(training, theRMSE, theMAE, 0, 1);
		objectiveValue += theRMSE * theRMSE * (double)training.ratingList.size();
		theRMSE *= globalVariance;
		theMAE *= globalVariance;
	}
	void calculateValidError(double& theRMSE, double& theMAE){
		calculateGeneralError(validation, theRMSE, theMAE, globalMean, globalVariance);
	}
	void calculateTestError(double& theRMSE, double& theMAE){
		calculateGeneralError(testing, theRMSE, theMAE, globalMean, globalVariance);
	}

	void dumpPrediction(){
		char tmpName[100];
		sprintf(tmpName, "pred_%s", validationName);
		FILE *validPred = fopen(tmpName, "w");
		for(vector<RatingList::RatingTuple>::iterator it = validation.ratingList.begin(); it != validation.ratingList.end(); it++){
			double pred = 0;
			for(int k = 0; k < nFEATURE; ++k)
				pred += userFeature[it->userID][k]*itemFeature[it->itemID][k];
			pred = pred*globalVariance + globalMean;
			fprintf(validPred, "%lf\n", pred);
		}
		fclose(validPred);


		sprintf(tmpName, "pred_%s", testingName);
		FILE *testPred = fopen(tmpName, "w");
		for(vector<RatingList::RatingTuple>::iterator it = testing.ratingList.begin(); it != testing.ratingList.end(); it++){
			double pred = 0;
			for(int k = 0; k < nFEATURE; ++k)
				pred += userFeature[it->userID][k]*itemFeature[it->itemID][k];
			pred = pred*globalVariance + globalMean;
			fprintf(testPred, "%lf\n", pred);
		}
		fclose(testPred);
	}

	void dumpModel(const char* modelName){
		FILE *model = fopen(modelName, "w");
		fprintf(model, "UserLatent\n");
		for(int i = 0; i < training.maxUidP1; ++i){
			for(int j = 0; j < nFEATURE; ++j)
				fprintf(model, " %lf", userFeature[i][j]);
			fprintf(model, "\n");
		}
		fprintf(model, "ItemLatent\n");
		for(int i = 0; i < training.maxIidP1; ++i){
			for(int j = 0; j < nFEATURE; ++j)
				fprintf(model, " %lf", itemFeature[i][j]);
			fprintf(model, "\n");
		}
		fclose(model);
	}
};


class CombinedMatrixFactorization{
    public:
	/***********************************************************************************/
	static const int nFEATURE = Parameter::nFEATURE;
	static const int MONITER_ITERATION_NUM = Parameter::MONITER_ITERATION_NUM;
	/***********************************************************************************/

	inline static double robustDifference(double x){
		assert(x >= 0);
		return atan(x);
	}
	inline static double robustDifference_derivative(double x){
		assert(x >= 0);
		return 1 / (1+x*x);
	}
	static double calculateObjectiveValue(MatrixFactorizationData& mfData1, MatrixFactorizationData& mfData2, vector<int> userMapping, vector<int> itemMapping, double objectiveValueOf1, double objectiveValueOf2){
		double objectiveValue = objectiveValueOf1 + objectiveValueOf2;
		const double userMappingReg = Parameter::userMappingReg;
		const double itemMappingReg = Parameter::itemMappingReg;
		const RatingList& training1 = mfData1.training;

		double userDifferenceSum = 0;
		for(int userID = 0; userID < training1.maxUidP1; ++userID){
			double norm = 0;
			for(int k = 0; k < nFEATURE; ++k){
				double tmp = mfData1.userFeature[userID][k] - mfData2.userFeature[userMapping.at(userID)][k];
				norm += pow2(tmp);
			}
			userDifferenceSum += robustDifference(norm);
		}
		double itemDifferenceSum = 0;
		for(int itemID = 0; itemID < training1.maxIidP1; ++itemID){
			double norm = 0;
			for(int k = 0; k < nFEATURE; ++k){
				double tmp = mfData1.itemFeature[itemID][k] - mfData2.itemFeature[itemMapping.at(itemID)][k];
				norm += pow2(tmp);
			}
			itemDifferenceSum += robustDifference(norm);
		}
		objectiveValue += userDifferenceSum * userMappingReg + itemDifferenceSum * itemMappingReg;

		return objectiveValue;
	}

	static void updateModel(MatrixFactorizationData& mfData1, MatrixFactorizationData& mfData2, vector<int> userMapping, vector<int> itemMapping){
		const RatingList& training1 = mfData1.training;
		const RatingList& training2 = mfData2.training;
		const double learningRate = Parameter::learningRate;
		const double featureReg = Parameter::featureReg;
		const double userMappingReg = Parameter::userMappingReg;
		const double itemMappingReg = Parameter::itemMappingReg;
		for(int userID = 0; userID < training1.maxUidP1; ++userID)
			for(int k = 0; k < nFEATURE; ++k)
				mfData1.userFeatureStep[userID][k] = -featureReg*mfData1.userFeature[userID][k];
		for(int itemID = 0; itemID < training1.maxIidP1; ++itemID)
			for(int k = 0; k < nFEATURE; ++k)
				mfData1.itemFeatureStep[itemID][k] = -featureReg*mfData1.itemFeature[itemID][k];
		for(int userID = 0; userID < training2.maxUidP1; ++userID)
			for(int k = 0; k < nFEATURE; ++k)
				mfData2.userFeatureStep[userID][k] = -featureReg*mfData2.userFeature[userID][k];
		for(int itemID = 0; itemID < training2.maxIidP1; ++itemID)
			for(int k = 0; k < nFEATURE; ++k)
				mfData2.itemFeatureStep[itemID][k] = -featureReg*mfData2.itemFeature[itemID][k];


		for(int userID = 0; userID < training1.maxUidP1; ++userID){
			double norm = 0;
			for(int k = 0; k < nFEATURE; ++k){
				double tmp = mfData1.userFeature[userID][k] - mfData2.userFeature[userMapping.at(userID)][k];
				norm += pow2(tmp);
			}
			double derivative = robustDifference_derivative(norm);
			for(int k = 0; k < nFEATURE; ++k){
				double tmp = mfData1.userFeature[userID][k] - mfData2.userFeature[userMapping.at(userID)][k];
				mfData1.userFeatureStep[userID][k] -= userMappingReg * tmp * derivative;
				mfData2.userFeatureStep[userMapping.at(userID)][k] -= userMappingReg * (-tmp) * derivative;
			}
		}
		for(int itemID = 0; itemID < training1.maxIidP1; ++itemID){
			double norm = 0;
			for(int k = 0; k < nFEATURE; ++k){
				double tmp = mfData1.itemFeature[itemID][k] - mfData2.itemFeature[itemMapping.at(itemID)][k];
				norm += pow2(tmp);
			}
			double derivative = robustDifference_derivative(norm);
			for(int k = 0; k < nFEATURE; ++k){
				double tmp = mfData1.itemFeature[itemID][k] - mfData2.itemFeature[itemMapping.at(itemID)][k];
				mfData1.itemFeatureStep[itemID][k] -= itemMappingReg * tmp * derivative;
				mfData2.itemFeatureStep[itemMapping.at(itemID)][k] -= itemMappingReg * (-tmp) * derivative;
			}
		}


		for(vector<RatingList::RatingTuple>::const_iterator it = training1.ratingList.begin(); it != training1.ratingList.end(); it++){
			int userID = it->userID, itemID = it->itemID;
			double rating = it->rating;
			double epsilon = -rating;
			for(int k = 0; k < nFEATURE; ++k)
				epsilon += mfData1.userFeature[userID][k] * mfData1.itemFeature[itemID][k];
			for(int k = 0; k < nFEATURE; ++k){
				double tmp1 = mfData1.userFeature[userID][k], tmp2 = mfData1.itemFeature[itemID][k];
				mfData1.userFeatureStep[userID][k] -= epsilon * tmp2;
				mfData1.itemFeatureStep[itemID][k] -= epsilon * tmp1;
			}
		}
		for(vector<RatingList::RatingTuple>::const_iterator it = training2.ratingList.begin(); it != training2.ratingList.end(); it++){
			int userID = it->userID, itemID = it->itemID;
			double rating = it->rating;
			double epsilon = -rating;
			for(int k = 0; k < nFEATURE; ++k)
				epsilon += mfData2.userFeature[userID][k] * mfData2.itemFeature[itemID][k];
			for(int k = 0; k < nFEATURE; ++k){
				double tmp1 = mfData2.userFeature[userID][k], tmp2 = mfData2.itemFeature[itemID][k];
				mfData2.userFeatureStep[userID][k] -= epsilon * tmp2;
				mfData2.itemFeatureStep[itemID][k] -= epsilon * tmp1;
			}
		}

		double preRMSE1, preMAE1, preObjectiveValueOf1;
		double preRMSE2, preMAE2, preObjectiveValueOf2;
		mfData1.calculateTrainingError(preRMSE1, preMAE1, preObjectiveValueOf1);
		mfData2.calculateTrainingError(preRMSE2, preMAE2, preObjectiveValueOf2);
		double preObjective = calculateObjectiveValue(mfData1, mfData2, userMapping, itemMapping, preObjectiveValueOf1, preObjectiveValueOf2);

		double learningRateNow = learningRate;

		for(int userID = 0; userID < training1.maxUidP1; ++userID){
			for(int k = 0; k < nFEATURE; ++k)
				mfData1.userFeaturePast[userID][k] = mfData1.userFeature[userID][k];
		}
		for(int itemID = 0; itemID < training1.maxIidP1; ++itemID){
			for(int k = 0; k < nFEATURE; ++k)
				mfData1.itemFeaturePast[itemID][k] = mfData1.itemFeature[itemID][k];
		}
		for(int userID = 0; userID < training2.maxUidP1; ++userID){
			for(int k = 0; k < nFEATURE; ++k)
				mfData2.userFeaturePast[userID][k] = mfData2.userFeature[userID][k];
		}
		for(int itemID = 0; itemID < training2.maxIidP1; ++itemID){
			for(int k = 0; k < nFEATURE; ++k)
				mfData2.itemFeaturePast[itemID][k] = mfData2.itemFeature[itemID][k];
		}

		//line search
		while(1){
			for(int userID = 0; userID < training1.maxUidP1; ++userID){
				for(int k = 0; k < nFEATURE; ++k){
					assert(!isnan((float)mfData1.userFeatureStep[userID][k]));
					mfData1.userFeature[userID][k] = mfData1.userFeaturePast[userID][k] + learningRateNow * mfData1.userFeatureStep[userID][k];
				}
			}
			for(int itemID = 0; itemID < training1.maxIidP1; ++itemID)
				for(int k = 0; k < nFEATURE; ++k){
					assert(!isnan((float)mfData1.itemFeatureStep[itemID][k]));
					mfData1.itemFeature[itemID][k] = mfData1.itemFeaturePast[itemID][k] + learningRateNow * mfData1.itemFeatureStep[itemID][k];
				}
			for(int userID = 0; userID < training2.maxUidP1; ++userID){
				for(int k = 0; k < nFEATURE; ++k){
					assert(!isnan((float)mfData2.userFeatureStep[userID][k]));
					mfData2.userFeature[userID][k] = mfData2.userFeaturePast[userID][k] + learningRateNow * mfData2.userFeatureStep[userID][k];
				}
			}
			for(int itemID = 0; itemID < training2.maxIidP1; ++itemID)
				for(int k = 0; k < nFEATURE; ++k){
					assert(!isnan((float)mfData2.itemFeatureStep[itemID][k]));
					mfData2.itemFeature[itemID][k] = mfData2.itemFeaturePast[itemID][k] + learningRateNow * mfData2.itemFeatureStep[itemID][k];
				}

			double nowRMSE1, nowMAE1, nowObjectiveValueOf1;
			double nowRMSE2, nowMAE2, nowObjectiveValueOf2;
			mfData1.calculateTrainingError(nowRMSE1, nowMAE1, nowObjectiveValueOf1);
			mfData2.calculateTrainingError(nowRMSE2, nowMAE2, nowObjectiveValueOf2);

			double nowObjective = calculateObjectiveValue(mfData1, mfData2, userMapping, itemMapping, nowObjectiveValueOf1, nowObjectiveValueOf2);
			if(nowObjective <= preObjective)
				break;
			learningRateNow /= 2;
			fprintf(stderr, "preRMSE1 %lf preRMSE2 %lf, nowRMSE1 %lf nowRMSE2 %lf, learningRateNow = %lf\n", preRMSE1, preRMSE2, nowRMSE1, nowRMSE2,learningRateNow);
		}

	}
/*
	destructor
*/

	static int startOptimizating(MatrixFactorizationData& mfData1, MatrixFactorizationData& mfData2, vector<int> userMapping, vector<int> itemMapping, int fixedIter){	
		assert((int)userMapping.size() == mfData1.training.maxUidP1);
		assert((int)itemMapping.size() == mfData1.training.maxIidP1);
		double trainingRMSE1, validationRMSE1, testingRMSE1, trainingMAE1, validationMAE1, testingMAE1, preValidationRMSE1 = DBL_MAX, bestValidationRMSE1 = DBL_MAX;
		double trainingRMSE2, trainingMAE2;
		double objectiveValueOf1, objectiveValueOf2;
		int iter = 1, bestIter = -1;

		while(1){
			//calculate all 
			mfData1.calculateTrainingError(trainingRMSE1, trainingMAE1, objectiveValueOf1);
			mfData1.calculateValidError(validationRMSE1, validationMAE1);
			mfData1.calculateTestError(testingRMSE1, testingMAE1);
			mfData2.calculateTrainingError(trainingRMSE2, trainingMAE2, objectiveValueOf2);
			fprintf(stderr, "currentIter = %d, bestIter = %d\n", iter, bestIter);
			fprintf(stderr, "trainRMSE1 = %lf(MAE %lf), valRMSE1 %lf(MAE %lf), testRMSE1 %lf(MAE %lf), trainRMSE2 = %lf(MAE %lf)\n", trainingRMSE1, trainingMAE1, validationRMSE1, validationMAE1, testingRMSE1, testingMAE1, trainingRMSE2, trainingMAE2);
			
			
			//save the currently best model
			if(bestValidationRMSE1 > validationRMSE1){
				bestValidationRMSE1 = validationRMSE1;
				bestIter = iter;
				for(int i = 0; i < mfData1.training.maxUidP1; ++i){
					for(int j = 0; j < nFEATURE; ++j)
						mfData1.userBestFeature[i][j] = mfData1.userFeature[i][j];
				}
				for(int i = 0; i < mfData1.training.maxIidP1; ++i){
					for(int j = 0; j < nFEATURE; ++j)
						mfData1.itemBestFeature[i][j] = mfData1.itemFeature[i][j];
				}
				for(int i = 0; i < mfData2.training.maxUidP1; ++i){
					for(int j = 0; j < nFEATURE; ++j)
						mfData2.userBestFeature[i][j] = mfData2.userFeature[i][j];
				}
				for(int i = 0; i < mfData2.training.maxIidP1; ++i){
					for(int j = 0; j < nFEATURE; ++j)
						mfData2.itemBestFeature[i][j] = mfData2.itemFeature[i][j];
				}

			}

			//stop criterion
			if(fixedIter == 0){	//look at validation to stop
				if(preValidationRMSE1 - 1e-7 <= validationRMSE1 && iter > (bestIter+MONITER_ITERATION_NUM))
					break;
			}
			else{
				if(iter == fixedIter)
					break;
			}

			preValidationRMSE1 = validationRMSE1;
			
			updateModel(mfData1, mfData2, userMapping, itemMapping);

			++iter;
		}
	
		
		printf("end iter: %d, bestIter: %d\n", iter, bestIter);
		mfData1.calculateTrainingError(trainingRMSE1, trainingMAE1, objectiveValueOf1);
		mfData1.calculateValidError(validationRMSE1, validationMAE1);
		mfData1.calculateTestError(testingRMSE1, testingMAE1);
		mfData2.calculateTrainingError(trainingRMSE2, trainingMAE2, objectiveValueOf2);
		if(fixedIter != 0)
			printf("end Iter: trainRMSE1 = %lf(MAE %lf), valRMSE1 %lf(MAE %lf), testRMSE1 %lf(MAE %lf), trainRMSE2 = %lf(MAE %lf)\n", trainingRMSE1, trainingMAE1, validationRMSE1, validationMAE1, testingRMSE1, testingMAE1, trainingRMSE2, trainingMAE2);
	
		if(fixedIter == 0){//not the retrain, in retrain we can't look at testing RMSE to decide our model
			//copy the best mode back
			for(int i = 0; i < mfData1.training.maxUidP1; ++i){
				for(int j = 0; j < nFEATURE; ++j)
					mfData1.userFeature[i][j] = mfData1.userBestFeature[i][j];
			}
			for(int i = 0; i < mfData1.training.maxIidP1; ++i){
				for(int j = 0; j < nFEATURE; ++j)
					mfData1.itemFeature[i][j] = mfData1.itemBestFeature[i][j];
			}
			for(int i = 0; i < mfData2.training.maxUidP1; ++i){
				for(int j = 0; j < nFEATURE; ++j)
					mfData2.userFeature[i][j] = mfData2.userBestFeature[i][j];
			}
			for(int i = 0; i < mfData2.training.maxIidP1; ++i){
				for(int j = 0; j < nFEATURE; ++j)
					mfData2.itemFeature[i][j] = mfData2.itemBestFeature[i][j];
			}


			mfData1.calculateTrainingError(trainingRMSE1, trainingMAE1, objectiveValueOf1);
			mfData1.calculateValidError(validationRMSE1, validationMAE1);
			mfData1.calculateTestError(testingRMSE1, testingMAE1);
			mfData2.calculateTrainingError(trainingRMSE2, trainingMAE2, objectiveValueOf2);
			printf("reg = %lf, bestIter: trainRMSE1 = %lf(MAE %lf), valRMSE1 %lf(MAE %lf), testRMSE1 %lf(MAE %lf), trainRMSE2 = %lf(MAE %lf)\n", Parameter::featureReg, trainingRMSE1, trainingMAE1, validationRMSE1, validationMAE1, testingRMSE1, testingMAE1, trainingRMSE2, trainingMAE2);
		}

		char modelName[1000];
		if(fixedIter == 0)
			sprintf(modelName, "%s_vali_model.txt", mfData1.trainingName);
		else
			sprintf(modelName, "%s_retrain_model.txt", mfData1.trainingName);
		mfData1.dumpModel(modelName);
		mfData1.dumpPrediction();
		if(fixedIter == 0)
			sprintf(modelName, "%s_vali_model.txt", mfData2.trainingName);
		else
			sprintf(modelName, "%s_retrain_model.txt", mfData2.trainingName);
		mfData2.dumpModel(modelName);
		return bestIter;
	}
	
};


void readMappingIndex(const char* fileName, vector<int>& mapping){
        FILE *fp = fopen(fileName, "r");
        int n;
        while(fscanf(fp, "%d", &n) == 1){
		dealWithID(n);
                mapping.push_back(n);
        }
        fclose(fp);
}


double Parameter::featureReg;
double Parameter::userMappingReg;
double Parameter::itemMappingReg;

int main(int argc, char* argv[]){
	assert(argc == 10);
	//srand(10);

        const char *train1 = argv[1], *valid1 = argv[2], *test1 = argv[3], *train2 = argv[4];

        vector<int> userMapping, itemMapping;
        readMappingIndex(argv[5], userMapping);
        readMappingIndex(argv[6], itemMapping);

        Parameter::featureReg = atof(argv[7]);
        Parameter::userMappingReg = atof(argv[8]);
        Parameter::itemMappingReg = atof(argv[9]);

	printf("valid To stop\n");

	MatrixFactorizationData mfData1(train1, valid1, test1);
	MatrixFactorizationData mfData2(train2, "", "");
	CombinedMatrixFactorization::startOptimizating(mfData1, mfData2, userMapping, itemMapping, 0);
}
