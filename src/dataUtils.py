import sys
import time
import random


def loadRatingList(ratingFile):
    ratingList = []
    with open(ratingFile, 'r') as f:
        for line in f:
            user, item, rating = line.strip().split()
            user, item, rating = int(user), int(item), float(rating)
            ratingList.append([user, item, rating])
    return ratingList



def loadQueryList(queryFile):
    queryList = []
    with open(queryFile, 'r') as f:
        for line in f:
            user, item, _ = line.strip().split()
            user, item = int(user), int(item)
            queryList.append([user, item, _])
    return queryList




def writeEntryListFile(filename, entryList):
    with open(filename, 'w') as f:
        for i in range(len(entryList)):
            print(entryList[i], file=f)



def writeRatingListFile(filename, ratingList):
    with open(filename, 'w') as f:
        for i in range(len(ratingList)):
            for j in range(len(ratingList[i])):
                print(ratingList[i][j], end=' ', file=f)
            print('', file=f)



# random split data into train, validation set
def splitValidData(ratingList, trainingRate):
    trRatingList = []
    valRatingList = []
    ratingLen = len(ratingList)
    random.shuffle(ratingList)
    trRatingList = ratingList[:int(ratingLen * trainingRate)]
    valRatingList = ratingList[int(ratingLen * trainingRate):ratingLen]
    return trRatingList, valRatingList


# random split data into cross validation chunks
def splitCrossValidData(ratingList, crossValidSize):
    crossValidList = [[] for i in range(crossValidSize)]
    ratingLen = len(ratingList)
    for i in range(ratingLen):
        crossValidList[i%crossValidSize].append(ratingList[i])
    return crossValidList



# random split data to let the users sparated and items overlaid
def splitDataWithItemsOverlaid(ratingList, userRate, itemRate, itemOverRate):
    sourceRatingList = []
    targetRatingList = []
    userSet = set()
    itemSet = set()
    for i in range(len(ratingList)):
        user, item, _ = ratingList[i]
        userSet.add(user)
        itemSet.add(item)
    userList = list(userSet)
    itemList = list(itemSet)
    userLen = len(userList)
    itemLen = len(itemList)
    random.shuffle(userList)
    random.shuffle(itemList)
    srcUserSet = set(userList[:int(userLen * userRate)])
    tarUserSet = set(userList[int(userLen * userRate):userLen])
    srcItemSet = set(userList[:int(itemLen * itemRate/(1.0-itemOverRate))])
    tarItemSet = set(userList[itemLen - int(itemLen * (1-itemRate)/(1.0-itemOverRate)):itemLen])
    overItemSet = set(userList[itemLen - int(itemLen * (1-itemRate)/(1.0-itemOverRate)):int(itemLen * itemRate/(1.0 - itemOverRate))])
    for i in range(len(ratingList)):
        user, item, _ = ratingList[i]
        if user in srcUserSet and (item in srcItemSet or item in overItemSet):
            sourceRatingList.append(ratingList[i])
        if user in tarUserSet and (item in tarItemSet or item in overItemSet):
            targetRatingList.append(ratingList[i])
    return sourceRatingList, targetRatingList, list(srcUserSet), list(tarUserSet), list(srcItemSet), list(tarItemSet), list(overItemSet)



# make the id mapping from source to target and vice versa
def makeSrcTarIdMapping(sourceList, targetList):
    src2tarUserMap = {}
    src2tarItemMap = {}
    tar2srcUserMap = {}
    tar2srcItemMap = {}
    srcUserSet = set()
    srcItemSet = set()
    tarUserSet = set()
    tarItemSet = set()
    srcUserMaxId = 0
    srcItemMaxId = 0
    tarUserMaxId = 0
    tarItemMaxId = 0
    # find the max user, item id and user, item set
    for i in range(len(sourceList)):
        user, item, _ = sourceList[i]
        srcUserSet.add(user)
        srcItemSet.add(item)
        if user > srcUserMaxId:
            srcUserMaxId = user
        if item > srcItemMaxId:
            srcItemMaxId = item
    for i in range(len(targetList)):
        user, item, _ = targetList[i]
        tarUserSet.add(user)
        tarItemSet.add(item)
        if user > tarUserMaxId:
            tarUserMaxId = user
        if item > tarItemMaxId:
            tarItemMaxId = item
    # make mapping
    userMapIndex = tarUserMaxId + 1
    itemMapIndex = tarItemMaxId + 1
    for user in srcUserSet:
        src2tarUserMap[user] = userMapIndex
        userMapIndex += 1
    for item in srcItemSet:
        src2tarItemMap[item] = itemMapIndex
        itemMapIndex += 1
    userMapIndex = srcUserMaxId + 1
    itemMapIndex = srcItemMaxId + 1
    for user in tarUserSet:
        tar2srcUserMap[user] = userMapIndex
        userMapIndex += 1
    for item in tarItemSet:
        tar2srcItemMap[item] = itemMapIndex
        itemMapIndex += 1
    del srcUserSet
    del srcItemSet
    del tarUserSet
    del tarItemSet
    return src2tarUserMap, src2tarItemMap, tar2srcUserMap, tar2srcItemMap



# for FM model, map user, item id to column id 
def makeUserItemMapping(ratingList):
    maxUserId = -1
    maxItemId = -1
    userColMap = {}
    itemColMap = {}
    colUserMap = {}
    colItemMap = {}
    # find max user, item id
    for i in range(len(ratingList)):
        user, item, _ = ratingList[i]
        if user > maxUserId:
            maxUserId = user
        if item > maxItemId:
            maxItemId = item
    # make user, item mapping
    for i in range(len(ratingList)):
        user, item, _ = ratingList[i]
        userColMap[user] = user
        itemColMap[item] = item + maxUserId + 1
        colUserMap[user] = user
        colItemMap[item + maxUserId + 1] = item
    return userColMap, itemColMap, colUserMap, colItemMap





# ratingList: [user column index, item column index, (rating)]
# fileType: train: training file with libSVM format; test: testing file with libSVM
def tar2SVMliteFile(svmliteFile, ratingList, fileType):
    stringList = []
    if fileType == 'train':
        # make user, item to writing string
        for i in range(len(ratingList)):
            user, item, rating = ratingList[i]
            wrstr = str(rating) + ' ' + str(user) + ':1 ' + str(item) + ':1'
            stringList.append(wrstr)
    if fileType == 'test':
        # make user, item to writing string
        for i in range(len(ratingList)):
            user, item, _ = ratingList[i]
            wrstr = '0.0 ' + str(user)+ ':1 ' + str(item) + ':1'
            stringList.append(wrstr)
    # write results
    with open(svmliteFile, 'w') as f:
        for i in range(len(stringList)):
            print(stringList[i], file=f)



# ratingList: [user column index, item column index, (rating)]
# fileType: train: training file with libSVM format; test: testing file with libSVM
def tarSrc2SVMliteFile(svmliteFile, ratingList, domainList, maxUserItemCol, fileType):
    stringList = []
    if fileType == 'train':
        # make user, item, domain to writing string
        for i in range(len(ratingList)):
            user, item, rating = ratingList[i]
            domain = domainList[i]
            # map domain to column index
            domain += maxUserItemCol + 1
            wrstr = str(rating) + ' ' + str(user) + ':1 ' + str(item) + ':1 ' + str(domain) + ':1'
            stringList.append(wrstr)
    if fileType == 'test':
        # make user, item, domain to writing string
        for i in range(len(ratingList)):
            user, item, _ = ratingList[i]
            domain = domainList[i]
            # map domain to column index
            domain += maxUserItemCol + 1
            wrstr = '0.0 ' + str(user) + ':1 ' + str(item) + ':1 ' + str(domain) + ':1'
            stringList.append(wrstr)
    # write results
    with open(svmliteFile, 'w') as f:
        for i in range(len(stringList)):
            print(stringList[i], file=f)



def writeMapFile(mapFile, mapping):
    with open(mapFile, 'w') as f:
        for key, value in mapping.items():
            print(str(key)+' '+str(value), file=f)



def writePrediction(predFile, predIdList, ratingList):
    assert len(predIdList) == len(ratingList)
    with open(predFile, 'w') as f:
        for i in range(len(predIdList)):
            user, item = predIdList[i]
            rating = ratingList[i]
            print(str(user)+' '+str(item)+' '+str(rating), file=f)
