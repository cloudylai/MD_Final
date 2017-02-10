import sys
from sklearn.metrics import mean_squared_error
from math import sqrt

def readMatrix(filename):
	_file = open(filename, "r")
	resultList = list()
	lines = _file.readlines()
	for line in lines:
		line = line.strip().split()
		resultList.append(float(line[2]))
	_file.close()
	return resultList

def readPred(filename):
	_file = open(filename, "r")
	resultList = list()
	lines = _file.readlines()
	for line in lines:
		line = line.strip().split()
		resultList.append(float(line[0]))
	_file.close()
	return resultList

if __name__ == '__main__':
	if len(sys.argv)<3:
		print("usage : python margeMatrix.py [answer filename] [pred filename]")
		exit(1)
	ansFilename = sys.argv[1]
	predFilename = sys.argv[2]

	ansList = readMatrix(ansFilename)
	predList = readPred(predFilename)

	rms = sqrt(mean_squared_error(ansList, predList))

	print("RMSE = "+str(rms))
