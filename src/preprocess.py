import sys
import argparse

def get_args():

    parser = argparse.ArgumentParser(description="swap '?' to '0' in test.txt")
    parser.add_argument("orig_file", help="file that need to be prepocessed")
    parser.add_argument("output_file", help="the name of output file")
    args = parser.parse_args()

    return args


if (__name__ == '__main__'):

    args = get_args()

    D = []
    with open(args.orig_file, 'r') as f:
        for line in f:
            tokens = line.split()
            D.append(tokens)

    with open(args.output_file, 'w') as f:
        for tokens in D:
            f.write('{0} {1} {2}\n'.format(tokens[0], tokens[1], 0))


