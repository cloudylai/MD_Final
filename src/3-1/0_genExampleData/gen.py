import random
random.seed(1)

records = open('rating').read().strip().split('\n')
numRecords = len(records)
numTest = int(numRecords * 0.05)
numR1_valid = int(numRecords * 0.025)
numR2_valid = int(numRecords * 0.025)
numR1_train = int(numRecords * 0.4)
numR2_train = numRecords - numTest - numR1_valid - numR2_valid - numR1_train


idx = range(numRecords)
random.shuffle(idx)

idxTest = idx[0:numTest]
idx = idx[numTest:]

idxR2_valid = idx[0:numR2_valid]
idx = idx[numR2_valid:]

idxR1_valid = idx[0:numR1_valid]
idx = idx[numR1_valid:]

idxR2_train = idx[0:numR2_train]
idx = idx[numR2_train:]

idxR1_train = idx[0:numR1_train]



def reverseRecord(aRecord):
	tmp = aRecord.split('\t')
	uID = int(tmp[0])
	iID = int(tmp[1])
	return str(2001-uID) + '\t' + str(1001-iID) + '\t' + tmp[2]

with open('test.example', 'w') as test:
	for i in idxTest:
		test.write(records[i] + '\n')
with open('R1_train.example', 'w') as R1_train:
	for i in idxR1_train:
		R1_train.write(records[i] + '\n')
with open('R2_train.example', 'w') as R2_train:
	for i in idxR2_train:
		R2_train.write(reverseRecord(records[i]) + '\n')
with open('R1_valid.example', 'w') as R1_valid:
	for i in idxR1_valid:
		R1_valid.write(records[i] + '\n')
with open('R2_valid.example', 'w') as R2_valid:
	for i in idxR2_valid:
		R2_valid.write(reverseRecord(records[i]) + '\n')


