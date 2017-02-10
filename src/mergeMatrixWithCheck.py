import sys
import random
import time

def buildMapTable(userFile, itemFile):
	#read user mapping
	_file = open(userFile, "r")
	userSource2Target= dict()
	#for reassign the repeated node
	candidateUserSourcelist = list(range(0,50000))
	# candidateUserSourcelist = list(range(0,3))
	for index in range(len(candidateUserSourcelist)):
		candidateUserSourcelist[index] = str(candidateUserSourcelist[index])
	# random.shuffle(candidateUserSourcelist)
	targetUserNeedReassign = list()
	index = 0
	lines = _file.readlines()
	for line in lines:
		line = line.strip()
		line = str(int(line)-1)
		if line in userSource2Target:
			targetUserNeedReassign.append(str(index))
		else:
			userSource2Target[line] = str(index)
			# candidateUserSourcelist.pop(candidateUserSourcelist.index(line))
		index += 1
	_file.close()
	# for node in targetUserNeedReassign:
	# 	userSource2Target[candidateUserSourcelist.pop()] = node

	#read item mapping
	_file2 = open(itemFile, "r")
	itemSource2Target= dict()
	#for reassign the repeated node
	candidateItemSourcelist = list(range(0,5000))
	# candidateItemSourcelist = list(range(0,3))
	for index in range(len(candidateItemSourcelist)):
		candidateItemSourcelist[index] = str(candidateItemSourcelist[index])
	# random.shuffle(candidateItemSourcelist)
	targetItemNeedReassign = list()
	index = 0
	lines = _file2.readlines()
	for line in lines:
		line = line.strip()
		line = str(int(line)-1)
		if line in itemSource2Target:
			targetItemNeedReassign.append(str(index))
		else:
			itemSource2Target[line] = str(index)
			# candidateItemSourcelist.pop(candidateItemSourcelist.index(line))
		index += 1
	_file2.close()
	# for node in targetItemNeedReassign:
	# 	itemSource2Target[candidateItemSourcelist.pop()] = node
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
	repeatKeyList = list()
	repeatKeyListAppend = repeatKeyList.append
	repeatMapList = list()
	repeatMapListAppend = repeatMapList.append
	for userKey in sourceMatrix:
		if not userKey in userSource2Target:
			continue
		userMap = userSource2Target[userKey]
		#check for repeat
		checkRepeat = False
		for itemKey in sourceMatrix[userKey]:
			if not itemKey in itemSource2Target:
				continue
			itemMap = itemSource2Target[itemKey]
			if userMap in targetMatrix and itemMap in targetMatrix[userMap]:
				repeatKeyListAppend(userKey)
				repeatMapListAppend(userMap)
				checkRepeat = True
				break

		if checkRepeat:
			continue
		#no repeat => add source elements to target matrix
		for itemKey in sourceMatrix[userKey]:
			if not itemKey in itemSource2Target:
				continue
			itemMap = itemSource2Target[itemKey]
			if not userMap in targetMatrix:
				targetMatrix[userMap] = dict()
			targetMatrix[userMap][itemMap] = sourceMatrix[userKey][itemKey]

	#iteratively remove repeat
	_stopStep = 100
	stopStep = _stopStep
	roundNum = 0
	while stopStep > 0 and len(repeatKeyList)>0:
		nowLen = len(repeatKeyList)
		print("["+str(roundNum)+"] Repeat Number(User) : "+str(len(repeatKeyList)))
		roundNum += 1
		tempRepeatKeyList = list(repeatKeyList)
		tempRepeatMapList = list(repeatMapList)
		repeatKeyList = list()
		repeatKeyListAppend = repeatKeyList.append
		repeatMapList = list()
		repeatMapListAppend = repeatMapList.append
		random.shuffle(tempRepeatMapList)

		#random assign to another map
		for index in range(len(tempRepeatKeyList)):
			userSource2Target[tempRepeatKeyList[index]] = tempRepeatMapList[index]
		for element in tempRepeatKeyList:
			userMap = userSource2Target[element]
			#check for repeat
			checkRepeat = False
			for itemKey in sourceMatrix[element]:
				if not itemKey in itemSource2Target:
					continue
				itemMap = itemSource2Target[itemKey]
				if userMap in targetMatrix and itemMap in targetMatrix[userMap]:
					repeatKeyListAppend(element)
					repeatMapListAppend(userMap)
					checkRepeat = True
					break

			if checkRepeat == True:
				continue
			#no repeat => add source elements to target matrix
			for itemKey in sourceMatrix[element]:
				if not itemKey in itemSource2Target:
					continue
				itemMap = itemSource2Target[itemKey]
				if not userMap in targetMatrix:
					targetMatrix[userMap] = dict()
				targetMatrix[userMap][itemMap] = sourceMatrix[element][itemKey]
		
		#stop condition
		if nowLen == len(repeatKeyList):
			stopStep -= 1
		else:
			stopStep = _stopStep

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
	targetMatrix = mappingMatrix(sourceMatrix, targetMatrix, userSource2Target, itemSource2Target)
	print("Cost time : "+str(time.time()-start_time)+" secs")

	print2File(outputFilename, targetMatrix)
	print("Total cost time : "+str(time.time()-total_start_time)+" secs")
