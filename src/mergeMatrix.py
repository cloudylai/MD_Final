import sys
import time
import copy

def buildMapTable(userFile, itemFile):
	#read user mapping
	_file = open(userFile, "r")
	userSource2Target= dict()
	index = 0
	lines = _file.readlines()
	for line in lines:
		line = line.strip()
		line = str(int(line)-1)
		userSource2Target[line] = str(index)
		index += 1
	_file.close()

	#read item mapping
	_file2 = open(itemFile, "r")
	itemSource2Target= dict()
	index = 0
	lines = _file2.readlines()
	for line in lines:
		line = line.strip()
		line = str(int(line)-1)
		itemSource2Target[line] = str(index)
		index += 1
	_file2.close()

	return userSource2Target, itemSource2Target

def readMatrix(filename):
	_file = open(filename, "r")
	resultDict = dict()
	lines = _file.readlines()
	for line in lines:
		line = line.strip().split()
		if not line[0] in resultDict:
			resultDict[line[0]] = dict()
		resultDict[line[0]][line[1]] = line[2]
	_file.close()
	return resultDict

def mappingMatrix(sourceMatrix, targetMatrix, userSource2Target, itemSource2Target):
	for userKey in sourceMatrix:
		if not userKey in userSource2Target:
			continue
		for itemKey in sourceMatrix[userKey]:
			if not itemKey in itemSource2Target:
				continue
			userMap = userSource2Target[userKey]
			itemMap = itemSource2Target[itemKey]
			if userMap in targetMatrix and itemMap in targetMatrix[userMap]:
				continue
			if not userMap in targetMatrix:
				targetMatrix[userMap] = dict()
			targetMatrix[userMap][itemMap] = sourceMatrix[userKey][itemKey]
	return targetMatrix

def mappingMatrix_v2(sourceMatrix, targetMatrix, userSource2Target, itemSource2Target):
	targetMatrixCopy = copy.deepcopy(targetMatrix)

	for userKey in sourceMatrix:
		if not userKey in userSource2Target:
			continue
		for itemKey in sourceMatrix[userKey]:
			if not itemKey in itemSource2Target:
				continue
			userMap = userSource2Target[userKey]
			itemMap = itemSource2Target[itemKey]
			if userMap in targetMatrixCopy and itemMap in targetMatrixCopy[userMap]:
				continue
			if userMap in targetMatrix and itemMap in targetMatrix[userMap]:
				targetMatrix[userMap][itemMap] = (targetMatrix[userMap][itemMap]+sourceMatrix[userKey][itemKey])/2
				continue
			if not userMap in targetMatrix:
				targetMatrix[userMap] = dict()
			targetMatrix[userMap][itemMap] = sourceMatrix[userKey][itemKey]
	return targetMatrix

def print2File(filename, targetMatrix):
	_file = open(filename, "w")
	for userKey in targetMatrix:
		for itemKey in targetMatrix[userKey]:
			_file.write(userKey+"\t"+itemKey+"\t"+targetMatrix[userKey][itemKey]+"\n")
	_file.close()

if __name__ == '__main__':
	if len(sys.argv)<6:
		print("usage : python margeMatrix.py [source filename] [target filename] [user mapping filename] [item mapping filename] [output filename]")
		exit(1)
	sourceFilename = sys.argv[1]
	targetFilename = sys.argv[2]
	userMapFilename = sys.argv[3]
	itemMapFilename = sys.argv[4]
	outputFilename = sys.argv[5]
	total_start_time = time.time()
	start_time = time.time()

	print("Build table")
	userSource2Target, itemSource2Target = buildMapTable(userMapFilename, itemMapFilename)
	print("Cost time : "+str(time.time()-start_time)+" secs")
	start_time = time.time()

	print("Read source matrix")
	sourceMatrix = readMatrix(sourceFilename)
	print("Cost time : "+str(time.time()-start_time)+" secs")
	start_time = time.time()

	print("Read target Matrix")
	targetMatrix = readMatrix(targetFilename)
	print("Cost time : "+str(time.time()-start_time)+" secs")
	start_time = time.time()

	print("Mapping Matrix")
	targetMatrix = mappingMatrix_v2(sourceMatrix, targetMatrix, userSource2Target, itemSource2Target)
	print("Cost time : "+str(time.time()-start_time)+" secs")

	print2File(outputFilename, targetMatrix)
	print("Total cost time : "+str(time.time()-total_start_time)+" secs")

