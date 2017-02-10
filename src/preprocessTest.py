import sys

def readFile(filename):
	_file = open(filename, "r")
	resultList = list()
	while True:
		line = _file.readline()
		if not line:
			break
		line = line.strip().split()
		# resultList.append(str(int(line[0])+1)+"\t"+str(int(line[1])+1)+"\t0.0")
		resultList.append(str(line[0])+"\t"+str(line[1])+"\t0.0")
	_file.close()
	return resultList

def print2File(filename, targetList):
	_file = open(filename, "w")
	for result in targetList:
		_file.write(result+"\n")
	_file.close()

if __name__ == '__main__':
	if len(sys.argv)<3:
		print("usage : python preprocessTest.py [input filename] [output filename]")
		exit(1)
	targetFilename = sys.argv[1]
	testFilename = sys.argv[2]

	resultList = readFile(targetFilename)
	print2File(testFilename, resultList)

