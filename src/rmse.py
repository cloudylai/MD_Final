import sys
import argparse
import math


def get_args():
    parser = argparse.ArgumentParser(description="calculate rmse in hw3")
    parser.add_argument("pred_file", help="test file")
    parser.add_argument("ansr_file", help="answer file")
    args = parser.parse_args()
    return args


if (__name__ == '__main__'):

    args = get_args()

    f1 = open(args.pred_file, 'r')
    f2 = open(args.ansr_file, 'r')
    rmse = []

    map_true_score = {}
    for line in f2:
        tokens = line.split()
        user_id = int(tokens[0])
        item_id = int(tokens[1])
        score = float(tokens[2])
        map_true_score[(user_id, item_id)] = score

    for line in f1:
        tokens = line.split()
        user_id = int(tokens[0])
        item_id = int(tokens[1])
        score = float(tokens[2])
        rmse.append(math.pow(score - map_true_score[(user_id, item_id)], 2))

    rmse = math.sqrt(sum(rmse) / len(rmse))
    print('rmse {0}'.format(rmse))

