import sys
import argparse

def get_args():

    parser = argparse.ArgumentParser(description="combine output of libFM to test.txt")
    parser.add_argument("test_file", help="testing file")
    parser.add_argument("score_file", help="output from libFM")
    parser.add_argument("pred_file", help="the name of output file")
    args = parser.parse_args()

    return args


if (__name__ == '__main__'):

    args = get_args()

    D = []
    with open(args.test_file, 'r') as f:
        for line in f:
            tokens = line.split()
            D.append(tokens)
    with open(args.score_file, 'r') as f:
        line_cnt = 0
        for line in f:
            tokens = line.split()
            D[line_cnt][2] = float(tokens[0])
            line_cnt += 1

    with open(args.pred_file, 'w') as f:
        for tokens in D:
            f.write('{0} {1} {2}\n'.format(tokens[0], tokens[1], tokens[2]))


