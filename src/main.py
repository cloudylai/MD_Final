import sys
import time

import dataUtils


DATA_PATH_PREFIX = '../data/'
GEN_DATA_PATH_PREFIX = '../gendata/'
ANSWER_PATH_PREFIX = '../data/answer/'



def main():
    ## make data: source and target (as different) using target extended indices ##
    testDir = sys.argv[1]
    targetTrainFile = DATA_PATH_PREFIX + testDir + '/' + 'train.txt'
    targetTestFile = ANSWER_PATH_PREFIX + testDir +  '_answer.txt'
    targetTrainTrainFile = DATA_PATH_PREFIX + testDir + '/' + 'train_train.txt'
    targetTrainTestFile = DATA_PATH_PREFIX + testDir + '/' + 'train_test.txt'
    sourceRatingFile = DATA_PATH_PREFIX + testDir + '/' + 'source.txt'
    targetGenTrainFile = GEN_DATA_PATH_PREFIX + testDir + '/' + 'target2.tr.txt'
    targetGenValidFile = GEN_DATA_PATH_PREFIX + testDir + '/' + 'target2.val.txt'
    targetGenTestFile = GEN_DATA_PATH_PREFIX + testDir + '/' + 'target2.te.txt'
    targetGenSourceFile = GEN_DATA_PATH_PREFIX + testDir + '/' + 'target2.src.txt'
    targetSrcUserFile = GEN_DATA_PATH_PREFIX + testDir + '/' + 'target2.src.user'
    targetSrcItemFile = GEN_DATA_PATH_PREFIX + testDir + '/' + 'target2.src.item'
    targetTarUserFile = GEN_DATA_PATH_PREFIX + testDir + '/' + 'target2.tar.user'
    targetTarItemFile = GEN_DATA_PATH_PREFIX + testDir + '/' + 'target.tar.item'
    
    print("load data ...")
    st = time.time()
    targetTrainList = dataUtils.loadRatingList(targetTrainFile)
    targetTestList = dataUtils.loadRatingList(targetTestFile)
    targetTrainTrainList = dataUtils.loadRatingList(targetTrainTrainFile)
    targetTrainTestList = dataUtils.loadRatingList(targetTrainTestFile)
    sourceList = dataUtils.loadRatingList(sourceRatingFile)
    et = time.time()
    print("target train train:", len(targetTrainTrainList), "train test:", len(targetTrainTestList), "test:", len(targetTestList))
    print("source:", len(sourceList))
    print("cost time:", et - st)
    print("combine and process ...")
    st = time.time()
    src2tarUserMap, src2tarItemMap, tar2srcUserMap, tar2srcItemMap = dataUtils.makeSrcTarIdMapping(sourceList, targetTrainList + targetTestList)
    # use target index
    srcTarIdxList = [[src2tarUserMap[user], src2tarItemMap[item], rating] for user, item, rating in sourceList]
    targetUserList = [user for user in tar2srcUserMap.keys()]
    targetItemList = [item for item in tar2srcItemMap.keys()]
    sourceUserList = [user for user in src2tarUserMap.values()]
    sourceItemList = [item for item in src2tarItemMap.values()]
    et = time.time()
    print("cost time:", et - st)
    print("write data ...")
    st = time.time()
    dataUtils.writeRatingListFile(targetGenSourceFile, srcTarIdxList)
    dataUtils.writeRatingListFile(targetGenTrainFile, targetTrainTrainList)
    dataUtils.writeRatingListFile(targetGenValidFile, targetTrainTestList)
    dataUtils.writeRatingListFile(targetGenTestFile, targetTestList)
    dataUtils.writeEntryListFile(targetTarUserFile, targetUserList)
    dataUtils.writeEntryListFile(targetTarItemFile, targetItemList)
    dataUtils.writeEntryListFile(targetSrcUserFile, sourceUserList)
    dataUtils.writeEntryListFile(targetSrcItemFile, sourceItemList)
    et = time.time()
    print("cost time:", et - st)

    ## make data: source and target with items overlaid using target indices ##
    '''
    testDir = sys.argv[1]
    targetTrainFile = DATA_PATH_PREFIX + testDir + '/' + 'train.txt'
    targetTestFile = ANSWER_PATH_PREFIX + testDir + '_answer.txt'
    targetGenTrainFile = GEN_DATA_PATH_PREFIX + testDir + '/' + 'target1.tr.txt'
    targetGenTestFile = GEN_DATA_PATH_PREFIX + testDir + '/' + 'target1.te.txt'
    targetGenSourceFile = GEN_DATA_PATH_PREFIX + testDir + '/' + 'target1.src.txt'
    targetSrcUserFile = GEN_DATA_PATH_PREFIX + testDir + '/' + 'target1.src.user'
    targetSrcItemFile = GEN_DATA_PATH_PREFIX + testDir + '/' + 'target1.src.item'
    targetTarUserFile = GEN_DATA_PATH_PREFIX + testDir + '/' + 'target1.tar.user'
    targetTarItemFile = GEN_DATA_PATH_PREFIX + testDir + '/' + 'target1.tar.item'
    targetOverItemFile = GEN_DATA_PATH_PREFIX + testDir + '/' + 'target1.over.item'
    userSplitRate = 0.7
    itemSplitRate = 0.7
    itemOverSplitRate = 0.025
    trainSplitRate = 0.5
    
    print("load data ...")
    st = time.time()
    targetTrainList = dataUtils.loadRatingList(targetTrainFile)
    targetTestList = dataUtils.loadRatingList(targetTestFile)
    targetList = targetTrainList + targetTestList
    et = time.time()
    print("target train:", len(targetTrainList), "test:", len(targetTestList), "all:", len(targetList))
    print("cost time:", et - st)
    print("split and process ...")
    st = time.time()
    targetSourceList, targetTargetList, sourceUserList, targetUserList, sourceItemList, targetItemList, overlayItemList = dataUtils.splitDataWithItemsOverlaid(targetList, userSplitRate, itemSplitRate, itemOverSplitRate)
    print("gen. target source:", len(targetSourceList), "target:", len(targetTargetList))
    print("user source:", len(sourceUserList), "target:", len(targetUserList))
    print("item source:", len(sourceItemList), "target:", len(targetItemList), "over:", len(overlayItemList))
    targetGenTrainList, targetGenTestList = dataUtils.splitValidData(targetTargetList, trainSplitRate)
    print("gen. target train:", len(targetGenTrainList), "test:", len(targetGenTestList))
    maxTrainUId = max([uid for uid, iid, r in targetGenTrainList])
    maxTrainIId = max([iid for uid, iid, r in targetGenTrainList])
    maxTestUId = max([uid for uid, iid, r in targetGenTestList])
    maxTestIId = max([iid for uid, iid, r in targetGenTestList])
    print("max train uid:", maxTrainUId, "iid:", maxTrainIId)
    print("max test uid:", maxTestUId, "iid:", maxTestIId)
    # filling the valid data with the largest index
    if maxTrainUId < maxTestUId or maxTrainIId < maxTestIId:
        targetGenTrainList.append([maxTestUId, maxTestIId, 0.0])
    et = time.time()
    print("cost time:", et - st)
    print("write data ...")
    st = time.time()
    dataUtils.writeRatingListFile(targetGenSourceFile, targetSourceList)
    dataUtils.writeRatingListFile(targetGenTrainFile, targetGenTrainList)
    dataUtils.writeRatingListFile(targetGenTestFile, targetGenTestList)
    dataUtils.writeEntryListFile(targetTarUserFile, targetUserList)
    dataUtils.writeEntryListFile(targetTarItemFile, targetItemList)
    dataUtils.writeEntryListFile(targetSrcUserFile, sourceUserList)
    dataUtils.writeEntryListFile(targetSrcItemFile, sourceItemList)
    dataUtils.writeEntryListFile(targetOverItemFile, overlayItemList)
    et = time.time()
    print("cost time:", et - st)
    '''
    ## make mf data: target only ##
    '''
    testDir = sys.argv[1] + '/'
    sourceRatingFile = DATA_PATH_PREFIX + testDir + 'source.txt'
    targetTrainFile = DATA_PATH_PREFIX + testDir + 'train.txt'
    targetTestFile = DATA_PATH_PREFIX + testDir + 'test.txt'
    targetGenTrainFile = GEN_DATA_PATH_PREFIX + testDir + 'target_1.tr.txt'
    targetGenValidFile = GEN_DATA_PATH_PREFIX + testDir + 'target_1.val.txt'
    targetGenTestFile = GEN_DATA_PATH_PREFIX + testDir + 'target_1.te.txt'
    splitRate = 0.7
    # make training data for libmf model
    print("load data ...")
    st = time.time()
    targetAllTrainList = dataUtils.loadRatingList(targetTrainFile)
    targetTestList = dataUtils.loadQueryList(targetTestFile)
    et = time.time()
    print("cost time:", et - st)
    # split data into training valid data
    print("split and process ...")
    st = time.time()
    targetTrainList, targetValidList = dataUtils.splitValidData(targetAllTrainList, splitRate)
    #print("Debug: tr 0:", targetTrainList[0], "val 0:", targetValidList[0])
    maxTrainUId = max([uid for uid, iid, r in targetTrainList])
    maxTrainIId = max([iid for uid, iid, r in targetTrainList])
    maxValidUId = max([uid for uid, iid, r in targetValidList])
    maxValidIId = max([iid for uid, iid, r in targetValidList])
    print("max train uid:", maxTrainUId, "iid:", maxTrainIId)
    print("max valid uid:", maxValidUId, "iid:", maxValidIId)
    # filling the valid data with the largest index
    if maxTrainUId < maxValidUId or maxTrainIId < maxValidIId:
        targetTrainList.append([maxValidUId, maxValidIId, 0.0])
        
    # change the missing symbol to 0
    for i in range(len(targetTestList)):
        targetTestList[i][2] = 0.0
    et = time.time()
    print("cost time:", et - st)

    # write data
    print("write data ...")
    st = time.time()
    dataUtils.writeRatingListFile(targetGenTrainFile, targetTrainList)
    dataUtils.writeRatingListFile(targetGenValidFile, targetValidList)
    dataUtils.writeRatingListFile(targetGenTestFile, targetTestList)
    et = time.time()
    print("cost time:", et - st)
    '''

    ## make mf data: source only ##
    '''
    testDir = sys.argv[1] + '/'
    sourceRatingFile = DATA_PATH_PREFIX + testDir + 'source.txt'
    targetTrainFile = DATA_PATH_PREFIX + testDir + 'train.txt'
    targetTestFile = DATA_PATH_PREFIX + testDir + 'test.txt'
    sourceGenTrainFile = GEN_DATA_PATH_PREFIX + testDir + 'source_1.tr.txt'
    sourceGenValidFile = GEN_DATA_PATH_PREFIX + testDir + 'source_1.val.txt'
    splitRate = 0.7
    # make training data for libmf model
    print("load data ...")
    st = time.time()
    sourceAllTrainList = dataUtils.loadRatingList(sourceRatingFile)
    et = time.time()
    print("cost time:", et - st)
    # split data into training valid data
    print("split and process ...")
    st = time.time()
    sourceTrainList, sourceValidList = dataUtils.splitValidData(sourceAllTrainList, splitRate)
    #print("Debug: tr 0:", targetTrainList[0], "val 0:", targetValidList[0])
    maxTrainUId = max([uid for uid, iid, r in sourceTrainList])
    maxTrainIId = max([iid for uid, iid, r in sourceTrainList])
    maxValidUId = max([uid for uid, iid, r in sourceValidList])
    maxValidIId = max([iid for uid, iid, r in sourceValidList])
    print("max train uid:", maxTrainUId, "iid:", maxTrainIId)
    print("max valid uid:", maxValidUId, "iid:", maxValidIId)
    # filling the valid data with the largest index
    if maxTrainUId < maxValidUId or maxTrainIId < maxValidIId:
        sourceTrainList.append([maxValidUId, maxValidIId, 0.0])
    et = time.time()        
    print("cost time:", et - st)

    # write data
    print("write data ...")
    st = time.time()
    dataUtils.writeRatingListFile(sourceGenTrainFile, sourceTrainList)
    dataUtils.writeRatingListFile(sourceGenValidFile, sourceValidList)
    et = time.time()
    print("cost time:", et - st)
    '''

    ## split data: 5-fold cross validation data (target only)  ##
    '''
    testDir = sys.argv[1] + '/'
    targetTrainFile = DATA_PATH_PREFIX + testDir + 'train.txt'
    targetTestFile = DATA_PATH_PREFIX + testDir + 'test.txt'
    targetTrainTrainFile = DATA_PATH_PREFIX + testDir + 'train_train.txt'
    targetGenCVFile = GEN_DATA_PATH_PREFIX + testDir + 'train_train_cv'
    splitCVSize = 5
    # make training data for libmf model
    print("load data ...")
    st = time.time()
    targetTrainList = dataUtils.loadRatingList(targetTrainFile)
    targetTrainTrainList = dataUtils.loadRatingList(targetTrainTrainFile)
    et = time.time()
    print("cost time:", et - st)
    # split data into 5-flod cross validation
    targetTrainCVList = dataUtils.splitCrossValidData(targetTrainTrainList, splitCVSize)
    maxTrainUId = max([uid for uid, iid, r in targetTrainList])
    maxTrainIId = max([iid for uid, iid, r in targetTrainList])
    for i in range(splitCVSize):
        maxValidUId = max([uid for uid, iid, r in targetTrainCVList[i]])
        maxValidIId = max([iid for uid, iid, r in targetTrainCVList[i]])
        print("max train uid:", maxTrainUId, "iid:", maxTrainIId)
        print("max valid uid:", maxValidUId, "iid:", maxValidIId)
        if maxValidUId < maxTrainUId or maxValidIId < maxTrainIId:
            targetTrainCVList[i].append([maxTrainUId, maxValidIId, 0.0])
        dataUtils.writeRatingListFile(targetGenCVFile+'_'+str(i)+'.txt', targetTrainCVList[i])
    '''
    
    ## make mf data:  target and source (as different users/items) ##
    '''    
    testDir = sys.argv[1] + '/'
    targetTestFile = DATA_PATH_PREFIX + testDir + 'test.txt'
    targetGenTrainFile = GEN_DATA_PATH_PREFIX + testDir + 'target_1.tr.txt'
    targetGenValidFile = GEN_DATA_PATH_PREFIX + testDir + 'target_1.val.txt'
    targetGenTestFile = GEN_DATA_PATH_PREFIX + testDir + 'target_1.te.txt'
    sourceGenTrainFile = GEN_DATA_PATH_PREFIX + testDir + 'source_1.tr.txt'
    sourceGenValidFile = GEN_DATA_PATH_PREFIX + testDir + 'source_1.val.txt'
    srcTarIdxTrainFile = GEN_DATA_PATH_PREFIX + testDir + 'source_taridx_1.tr.txt'
    srcTarIdxValidFile = GEN_DATA_PATH_PREFIX + testDir + 'source_taridx_1.val.txt'
    mixGenTrainFile = GEN_DATA_PATH_PREFIX + testDir + 'mix_1.tr.txt'
    mixGenValidFile = GEN_DATA_PATH_PREFIX + testDir + 'mix_1.val.txt'
    mixGenTestFile = GEN_DATA_PATH_PREFIX + testDir + 'mix_1.te.txt'
    userMapFile = GEN_DATA_PATH_PREFIX + testDir + 'src2tar_user_map_1.txt'
    itemMapFile = GEN_DATA_PATH_PREFIX + testDir + 'src2tar_item_map_1.txt'
    # make training data for libmf model
    print("load data ...")
    st = time.time()
    targetTrainList = dataUtils.loadRatingList(targetGenTrainFile)
    targetValidList = dataUtils.loadRatingList(targetGenValidFile)
    targetTestList = dataUtils.loadQueryList(targetTestFile)
    sourceTrainList = dataUtils.loadRatingList(sourceGenTrainFile)
    sourceValidList = dataUtils.loadRatingList(sourceGenValidFile)
    et = time.time()
    print("cost time:", et - st)
    print("combine and process ...")
    st = time.time()
    src2tarUserMap, src2tarItemMap, tar2srcUserMap, tar2srcItemMap = dataUtils.makeSrcTarIdMapping(sourceTrainList + sourceValidList, targetTrainList + targetValidList + targetTestList)
    # use target index !
    tarAddTrainList = [[src2tarUserMap[user], src2tarItemMap[item], rating] for user, item, rating in sourceTrainList]
    tarAddValidList = [[src2tarUserMap[user], src2tarItemMap[item], rating] for user, item, rating in sourceValidList]

    # change the missing symbol to 0
    for i in range(len(targetTestList)):
        targetTestList[i][2] = 0.0
    et = time.time()
    print("cost time:", et - st)
    
    # write data
    print("write data ...")
    st = time.time()
    dataUtils.writeRatingListFile(srcTarIdxTrainFile, tarAddTrainList)
    dataUtils.writeRatingListFile(srcTarIdxValidFile, tarAddValidList)
    dataUtils.writeRatingListFile(mixGenTrainFile, targetTrainList + tarAddTrainList)
    dataUtils.writeRatingListFile(mixGenValidFile, targetValidList + tarAddValidList)
    dataUtils.writeRatingListFile(mixGenTestFile, targetTestList)
    dataUtils.writeMapFile(userMapFile, src2tarUserMap)
    dataUtils.writeMapFile(itemMapFile, src2tarItemMap)
    et = time.time()
    print("cost time:", et - st)
    
    '''
    ## make libSVM-like data: target only ##
    '''
    testDir = sys.argv[1] + '/'
    targetTestFile = DATA_PATH_PREFIX + testDir + 'test.txt'
    targetGenTrainFile = GEN_DATA_PATH_PREFIX + testDir + 'target_1.tr.txt'
    targetGenValidFile = GEN_DATA_PATH_PREFIX + testDir + 'target_1.val.txt'
    targetGenTestFile = GEN_DATA_PATH_PREFIX + testDir + 'target_1.te.txt'
    targetSVMTrainFile = GEN_DATA_PATH_PREFIX + testDir + 'target_1.tr.txt.libsvm'
    targetSVMValidFile = GEN_DATA_PATH_PREFIX + testDir + 'target_1.val.txt.libsvm'
    targetSVMTestFile = GEN_DATA_PATH_PREFIX + testDir + 'target_1.te.txt.libsvm'
    # make training data for libfm model
    print("load data ...")
    st = time.time()
    targetTrainList = dataUtils.loadRatingList(targetGenTrainFile)
    targetValidList = dataUtils.loadRatingList(targetGenValidFile)
    targetTestList = dataUtils.loadQueryList(targetTestFile)
    targetDataList = targetTrainList + targetValidList + targetTestList
    et = time.time()
    print("cost time:", et - st)
    # make user, item mapping
    userColMap, itemColMap, colUserMap, colItemMap = dataUtils.makeUserItemMapping(targetDataList)
    # make column index rating
    targetSVMTrList = [[userColMap[user], itemColMap[item], rating] for user, item, rating in targetTrainList]
    targetSVMValList = [[userColMap[user], itemColMap[item], rating] for user, item, rating in targetValidList]
    targetSVMTeList = [[userColMap[user], itemColMap[item], _] for user, item, _ in targetTestList]
    dataUtils.tar2SVMliteFile(targetSVMTrainFile, targetSVMTrList, 'train')
    dataUtils.tar2SVMliteFile(targetSVMValidFile, targetSVMValList, 'train')
    dataUtils.tar2VMliteFile(targetSVMTestFile, targetSVMTeList, 'test')
    '''

    ## make libSVM-like data: target and source (as different users/items) ##
    '''
    testDir = sys.argv[1] + '/'
    targetTestFile = DATA_PATH_PREFIX + testDir + 'test.txt'
    targetGenTrainFile = GEN_DATA_PATH_PREFIX + testDir + 'target_1.tr.txt'
    targetGenValidFile = GEN_DATA_PATH_PREFIX + testDir + 'target_1.val.txt'
    targetGenTestFile = GEN_DATA_PATH_PREFIX + testDir + 'target_1.te.txt'
    sourceGenTrainFile = GEN_DATA_PATH_PREFIX + testDir + 'source_1.tr.txt'
    sourceGenValidFile = GEN_DATA_PATH_PREFIX + testDir + 'source_1.val.txt'
    mixSVMTrainFile = GEN_DATA_PATH_PREFIX + testDir + 'mix_1.tr.txt.libsvm'
    mixSVMTarValFile = GEN_DATA_PATH_PREFIX + testDir + 'mix_1.tar_val.txt.libsvm'
    mixSVMValidFile = GEN_DATA_PATH_PREFIX + testDir + 'mix_1.val.txt.libsvm'
    mixSVMTestFile = GEN_DATA_PATH_PREFIX + testDir + 'mix_1.te.txt.libsvm'
    userMapFile = GEN_DATA_PATH_PREFIX + testDir + 'src2tar_user_map_1.txt'
    itemMapFile = GEN_DATA_PATH_PREFIX + testDir + 'src2tar_item_map_1.txt'
    # make training data for libmf model
    print("load data ...")
    st = time.time()
    targetTrainList = dataUtils.loadRatingList(targetGenTrainFile)
    targetValidList = dataUtils.loadRatingList(targetGenValidFile)
    targetTestList = dataUtils.loadQueryList(targetTestFile)
    sourceTrainList = dataUtils.loadRatingList(sourceGenTrainFile)
    sourceValidList = dataUtils.loadRatingList(sourceGenValidFile)
    et = time.time()
    print("cost time:", et - st)
    print("combine and process ...")
    st = time.time()
    src2tarUserMap, src2tarItemMap, tar2srcUserMap, tar2srcItemMap = dataUtils.makeSrcTarIdMapping(sourceTrainList + sourceValidList, targetTrainList + targetValidList + targetTestList)
    # use target index !
    tarAddTrainList = [[src2tarUserMap[user], src2tarItemMap[item], rating] for user, item, rating in sourceTrainList]
    tarAddValidList = [[src2tarUserMap[user], src2tarItemMap[item], rating] for user, item, rating in sourceValidList]

    allDataList = targetTrainList + targetValidList + targetTestList + tarAddTrainList + tarAddValidList

    # change the missing symbol to 0
    for i in range(len(targetTestList)):
        targetTestList[i][2] = 0.0

    # make user, item mapping
    userColMap, itemColMap, colUserMap, colItemMap = dataUtils.makeUserItemMapping(allDataList)
    maxColId = max(list(userColMap.values()) + list(itemColMap.values()))

    # make column index rating
    targetSVMTrList = [[userColMap[user], itemColMap[item], rating] for user, item, rating in targetTrainList]
    targetSVMValList = [[userColMap[user], itemColMap[item], rating] for user, item, rating in targetValidList]
    tarAddSVMTrList = [[userColMap[user], itemColMap[item], rating] for user, item, rating in tarAddTrainList]
    tarAddSVMValList = [[userColMap[user], itemColMap[item], rating] for user, item, rating in tarAddValidList]
    targetSVMTeList = [[userColMap[user], itemColMap[item], _] for user, item, _ in targetTestList]

    # make domain list
    trainDomainList = [0 for i in range(len(targetSVMTrList))] + [1 for i in range(len(tarAddSVMTrList))]
    validTarDomainList = [0 for i in range(len(targetSVMValList))]
    validDomainList = [0 for i in range(len(targetSVMValList))] + [1 for i in range(len(tarAddSVMValList))]
    testDomainList = [0 for i in range(len(targetSVMTeList))]
    et = time.time()
    print("cost time:", et - st)
    
    # write data
    print("write data ...")
    st = time.time()
    dataUtils.tarSrc2SVMliteFile(mixSVMTrainFile, targetSVMTrList + tarAddSVMTrList, trainDomainList, maxColId, 'train')
    dataUtils.tarSrc2SVMliteFile(mixSVMTarValFile, targetSVMValList, validTarDomainList, maxColId, 'train')
    dataUtils.tarSrc2SVMliteFile(mixSVMValidFile, targetSVMValList + tarAddSVMValList, validDomainList, maxColId, 'train')
    dataUtils.tarSrc2SVMliteFile(mixSVMTestFile, targetSVMTeList, testDomainList, maxColId, 'test')
    dataUtils.writeMapFile(userMapFile, src2tarUserMap)
    dataUtils.writeMapFile(itemMapFile, src2tarItemMap)
    et = time.time()
    print("cost time:", et - st)
    '''
    




if __name__ == '__main__':
    main()
