import sys

def readFile(filename, iterationNum):
	_file = open(filename, "r")
	totalValid = 0.0
	counter = 0
	while True:
		line = _file.readline()
		if not line:
			break
		line = line.strip().split()
		if len(line) < 2:
			continue

		if line[0] == "#Iter=" and line[1] == iterationNum:
			validAccu = line[3].split("=")[1]
			print(str(counter)+"\t"+validAccu)
			totalValid += float(validAccu)
			counter += 1
			continue
		if line[0] == "#Iter="+iterationNum:
			validAccu = line[2].split("=")[1]
			print(str(counter)+"\t"+validAccu)
			totalValid += float(validAccu)
			counter += 1
	print("=========================")
	print("avg =\t"+str(totalValid/counter))
	_file.close()

if __name__ == '__main__':
	if len(sys.argv)<3:
		print("usage : python readCrossValid.py [input filename] [iter]")
		exit(1)
	targetFilename = sys.argv[1]
	iterationNum = str(int(sys.argv[2])-1)
	print("====== Cross Valid ======")
	readFile(targetFilename, iterationNum)
