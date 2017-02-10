import sys

def readFile(filename):
	_file = open(filename, "r")
	resultList = list()
	while True:
		line = _file.readline()
		if not line:
			break
		line = line.strip().split()
		resultList.append(line)
	_file.close()
	return resultList

def print2File(filename, testList, resultList):
	_file = open(filename, "w")
	for index in range(len(testList)):
		_file.write(testList[index][0]+" "+testList[index][1]+" "+resultList[index][0]+"\n")
	_file.close()

if __name__ == '__main__':
	if len(sys.argv)<4:
		print("usage : python afterprocessTest.py [test filename] [result filename] [output filename]")
		exit(1)
	targetFilename = sys.argv[1]
	resultFilename = sys.argv[2]
	outputFilename = sys.argv[3]

	testList = readFile(targetFilename)
	resultList = readFile(resultFilename)
	print2File(outputFilename, testList, resultList)

