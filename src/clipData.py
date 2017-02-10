import sys

def readFile(filename, userLimit, itemLimit):
	_file = open(filename, "r")
	resultList = list()
	while True:
		line = _file.readline()
		if not line:
			break
		line = line.strip().split()
		if int(line[0]) < userLimit and int(line[1]) < itemLimit:
			resultList.append(line[0]+"\t"+line[1]+"\t"+line[2])
	_file.close()
	return resultList

def print2File(filename, targetList):
	_file = open(filename, "w")
	for result in targetList:
		_file.write(result+"\n")
	_file.close()

if __name__ == '__main__':
	if len(sys.argv)<5:
		print("usage : python clipData.py [input filename] [output filename] [user limit] [item limit]")
		exit(1)
	targetFilename = sys.argv[1]
	testFilename = sys.argv[2]
	userLimit = int(sys.argv[3])
	itemLimit = int(sys.argv[4])

	resultList = readFile(targetFilename, userLimit, itemLimit)
	print2File(testFilename, resultList)

