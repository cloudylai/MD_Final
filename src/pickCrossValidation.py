import sys
import random

def readFile(filename):
	_file = open(filename, "r")
	resultList = list()
	while True:
		line = _file.readline()
		if not line:
			break
		line = line.strip().split()
		# resultList.append(str(int(line[0])+1)+"\t"+str(int(line[1])+1)+"\t"+line[2])
		resultList.append(str(line[0])+"\t"+str(line[1])+"\t"+line[2])
	_file.close()
	return resultList

def print2File(filename, targetList):
	_file = open(filename, "w")
	for result in targetList:
		_file.write(result+"\n")
	_file.close()

if __name__ == '__main__':
	if len(sys.argv)<5:
		print("usage : python pickCrossValidation.py [input filename] [output train filename] [output valid filename] [valid fold]")
		exit(1)
	targetFilename = sys.argv[1]
	trainFilename = sys.argv[2]
	validFilename = sys.argv[3]
	# trainRate = float(sys.argv[4])
	validFold = float(sys.argv[4])

	resultList = readFile(targetFilename)
	random.shuffle(resultList)
	# trainNum = int(trainRate*len(resultList))
	validNum = int(len(resultList)/validFold)
	startNum = 0
	print("Generate cross valid data:")
	for index in range(int(validFold)):
		validList = resultList[startNum:startNum+validNum]
		trainList = resultList[0:startNum]+resultList[startNum+validNum:]
		startNum += validNum
		print2File(trainFilename+str(index), trainList)
		print2File(validFilename+str(index), validList)


