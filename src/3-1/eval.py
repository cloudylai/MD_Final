import sys

def readFile(filename):
	resultList = list()
	_file = open(filename, "r")
	while True:
		line = _file.readline().strip()
		if not line:
			break
		resultList.append(int(line))
	return resultList

if __name__ == '__main__':
	if len(sys.argv)<2:
		print("usage : python eval.py [match file name]")
		exit(1)
	matchFile = sys.argv[1]
	resultList = readFile(matchFile)

	counter = 0
	for index in range(len(resultList)):
		if resultList[index] == len(resultList)-index:
			counter += 1
	print("Accuracy = "+str(float(counter)/len(resultList)))