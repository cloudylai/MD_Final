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
		print("usage : python pickValidation.py [input filename] [output train filename] [output valid filename] [valid rate(0~1)]")
		exit(1)
	targetFilename = sys.argv[1]
	trainFilename = sys.argv[2]
	validFilename = sys.argv[3]
	# trainRate = float(sys.argv[4])
	validRate = float(sys.argv[4])

	resultList = readFile(targetFilename)
	random.shuffle(resultList)
	# trainNum = int(trainRate*len(resultList))
	validNum = int(validRate*len(resultList))
	validList = resultList[:validNum]
	trainList = resultList[validNum:]
	print2File(trainFilename, trainList)
	print2File(validFilename, validList)


