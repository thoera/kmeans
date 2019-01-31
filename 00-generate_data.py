# -*- coding: utf-8 -*-

import argparse
import numpy as np
from sklearn.datasets import make_blobs

parser = argparse.ArgumentParser(description='Generate data')
parser.add_argument('--n_points', nargs='?', const=150, default=150, type=int,
                    help='the number of points to generate (default: 150)')
parser.add_argument('--n_clusters', nargs='?', const=3, default=3, type=int,
                    help='the number of clusters (default: 3)')
args = parser.parse_args()

coord, labels = make_blobs(n_samples=args.n_points, centers=args.n_clusters,
                           random_state=1707)

np.savetxt(f'data/data_{str(args.n_points)}.csv', coord,
           fmt='%1.6f', delimiter=",")
