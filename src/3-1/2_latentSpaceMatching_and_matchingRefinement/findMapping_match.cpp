#include "mex.h"
#include <math.h>
#include <string.h>
#include <omp.h>
#include <vector>
#include <algorithm>
  
using namespace std;

#define assert( isOK, mes )       {if(!(isOK)){mexPrintf("line: %d %s\n", __LINE__, mes); mexEvalString("drawnow;"); mexErrMsgTxt("assert failed");}}

void getMat(const mxArray* pm, vector<vector<double> >& mat){
	assert(mxGetNumberOfDimensions(pm) == 2, "must be two d array");
	int m = mxGetM(pm);
	int n = mxGetN(pm);
	double *mat_m = mxGetPr(pm);
	mat.resize(m);
	for(int i = 0; i < m; ++i){
		mat.at(i).resize(n);
		for(int j = 0; j < n; ++j)
			mat.at(i).at(j) = mat_m[i+m*j];
	}
}

void get1dMat(const mxArray* pm, vector<double>& mat){
	assert(mxGetNumberOfDimensions(pm) == 2, "must be two d array");
	int m = mxGetM(pm);
	int n = mxGetN(pm);
	assert(m == 1 || n == 1, "must be 1-d");
	double *mat_m = mxGetPr(pm);
	m = m>=n? m:n;
	mat.resize(m);
	for(int i = 0; i < m; ++i){
		mat.at(i) = mat_m[i];
	}
}

double getDouble(const mxArray* pm){
	assert(mxGetNumberOfDimensions(pm) == 2, "must be two d array");
	int m = mxGetM(pm);
	int n = mxGetN(pm);
	assert(m == 1 && n == 1, "must be scalar");
	double *mat_m = mxGetPr(pm);
	return mat_m[0];
}

inline double pow2(double x){
	return x*x;
}

inline unsigned getMinIdx(double arr[], unsigned length){
	assert(length >= 1, "array Lens wrong");
	unsigned idx = 0;
	for(unsigned i = 1; i < length; ++i){
		if(arr[i] <= arr[idx])
			idx = i;
	}
	return idx;
}

inline int getAnswerIndexInB(int indexInA, int sizeOfB, const char* matchingType){
	//C index: start from 0
	//int ans = indexInA;
	//int ans = sizeOfB - 1 - indexInA; 		//for others
	//int ans = sizeOfB/9*10 - 1 - (indexInA);	//for partialSplit
	int ans;
	if(strcmp(matchingType, "User") == 0)
		ans = 50000-1-indexInA;
	else if(strcmp(matchingType, "Item") == 0)
		ans = 5000-1-indexInA;
	else
		assert(0, "matchingType error");
	assert(ans >= 0, "index error");
	return ans;
}

inline void getSortIdx(double valueArr[], int size, int outIndexArr[]){
	vector<pair<double, int> > tmp;
	for(int i = 0; i < size; ++i)
		tmp.push_back(pair<double, int>(valueArr[i], -i));

	sort(tmp.begin(), tmp.end());
	for(int i = 0; i < size; ++i){
		outIndexArr[i] = -tmp.at(i).second;
	}
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	omp_set_num_threads(omp_get_num_procs());

	//input
	assert(nrhs == 4, "nInput is wrong");
	assert(nlhs == 3, "nOutput is wrong");
	for(int i = 0; i < 3; ++i){
		assert(mxIsDouble(prhs[i]), "should be double array");
	}
	assert(mxIsChar(prhs[3]), "the last input should be string array");
	char* matchingType_tmp = mxArrayToString(prhs[3]);
	char matchingType[100];
	strcpy(matchingType, matchingType_tmp);
	mxFree(matchingType_tmp);
	mexPrintf("matchingType: %s\n", matchingType);

	vector<vector<double> > A, B;
	getMat(prhs[0], A);
	getMat(prhs[1], B);
	int nCandidate = (int)getDouble(prhs[2]);
	assert(A.at(0).size() == B.at(0).size(), "dimension not agree");	//dimension

	int nDimension = (int)A.at(0).size();

	int signList[nDimension];
	for(int d = 0; d < nDimension; ++d)
		signList[d] = 1;

	double** currentDistance = new double*[A.size()];
	int** resultIdx = new int*[A.size()];
	for(unsigned i = 0; i < A.size(); ++i){
		resultIdx[i] = new int[B.size()];
		currentDistance[i] = new double[B.size()];
		for(unsigned j = 0; j < B.size(); ++j)
			currentDistance[i][j] = 0;
	}


	int** bestIdxOfEachDimension = new int*[nDimension];
	for(int d = 0; d < nDimension; ++d)
		bestIdxOfEachDimension[d] = new int[A.size()];

	for(int d = 0; d < nDimension; ++d){
		double positive_result = 0;
		double negative_result = 0;
#pragma omp parallel for reduction(+:positive_result, negative_result) 
		for(unsigned i = 0; i < A.size(); ++i){
			double dis_positive_tmp[B.size()];
			double dis_negative_tmp[B.size()];
			for(unsigned j = 0; j < B.size(); ++j){
				dis_positive_tmp[j] = currentDistance[i][j] + pow2(A.at(i).at(d)-B.at(j).at(d));
				dis_negative_tmp[j] = currentDistance[i][j] + pow2(A.at(i).at(d)+B.at(j).at(d));
			}
			unsigned positive_minIdx = getMinIdx(dis_positive_tmp, (unsigned)B.size());
			unsigned negative_minIdx = getMinIdx(dis_negative_tmp, (unsigned)B.size());
			positive_result += dis_positive_tmp[positive_minIdx];
			negative_result += dis_negative_tmp[negative_minIdx];
		}
	//	mexPrintf("dimension = %d: %lf %lf\n", d, positive_result, negative_result);
	//	mexEvalString("drawnow;");
		if(positive_result > negative_result){
			signList[d] = -signList[d];
			for(unsigned i = 0; i < B.size(); ++i)
				B.at(i).at(d) = -B.at(i).at(d);
		}
		double acc = 0, map = 0;
		int count = 0;
#pragma omp parallel for reduction(+:acc, map, count)
		for(int i = 0; i < (int)A.size(); ++i){
			for(unsigned j = 0; j < B.size(); ++j)
				currentDistance[i][j] += pow2(A.at(i).at(d) - B.at(j).at(d));
			getSortIdx(currentDistance[i], (unsigned)B.size(), resultIdx[i]);

			bestIdxOfEachDimension[d][i] = resultIdx[i][0];

			int foundIdx = -1;
			double answerIdxInB = getAnswerIndexInB(i, B.size(), matchingType);
			if(answerIdxInB < B.size()){
				++count;
				for(int j = 0; j < (int)B.size(); ++j)
					if(resultIdx[i][j] == answerIdxInB){
						if(foundIdx == -1)
							foundIdx = j;
						else
							assert(0, "resultIdx is wrong");
					}
				if(foundIdx == 0)
					acc += 1;
				if(foundIdx != -1)
					map += 1.0/(foundIdx+1);
			}
		}
		acc /= count;
		map /= count;
		mexPrintf("dim %d (1~D): acc %lf, map %lf (count %d)\n", d+1, acc, map, count);
	}


	for(unsigned i = 0; i < A.size(); ++i){
		delete[] currentDistance[i];
	}
	delete[] currentDistance;

	//resultIdx of the last K
	plhs[0] = mxCreateNumericMatrix(A.size(), nCandidate, mxINT32_CLASS, mxREAL);
	int *mat_m = (int*)mxGetData(plhs[0]);
	for(int i = 0; i < (int)A.size(); ++i){
		for(int j = 0; j < nCandidate; ++j)
			mat_m[i + j * A.size()] = resultIdx[i][j] + 1; //for matlab index
		delete[] resultIdx[i];
	}
	delete[] resultIdx;

	//signList
	plhs[1] = mxCreateNumericMatrix(1, nDimension, mxINT32_CLASS, mxREAL);
	mat_m = (int*)mxGetData(plhs[1]);
	for(int d = 0; d < nDimension; ++d)
		mat_m[d] = signList[d];

	//resultIdx[i][0] of each dimension
	plhs[2] = mxCreateNumericMatrix(nDimension, A.size(), mxINT32_CLASS, mxREAL);
	mat_m = (int*)mxGetData(plhs[2]);
	for(int d = 0; d < nDimension; ++d)
		for(unsigned i = 0; i < A.size(); ++i){
			mat_m[d + i*nDimension] = bestIdxOfEachDimension[d][i] + 1; //for matlab index
		}
}

