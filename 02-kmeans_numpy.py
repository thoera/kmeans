# -*- coding: utf-8 -*-

"""
K-means :
1. Choisir n centres initiaux
2. Répéter :
    a. Affecter chacun des points au centre le plus proche
    b. Mettre à jour chaque centre à la moyenne des points
    qui lui ont été affectés
    c. Vérifier si l'algorithme a convergé
"""

import argparse
import numpy as np
import random

parser = argparse.ArgumentParser(description='K-means')
parser.add_argument('file', type=str,
                    help='the file to use for the clustering')
parser.add_argument('--n_clusters', nargs='?', const=3, default=3, type=int,
                    help='the number of clusters (default: 3)')
parser.add_argument('--max_iter', nargs='?', const=20, default=20, type=int,
                    help='the maximum number of iterations (default: 20)')
args = parser.parse_args()


def load_data(file):
    with open(file, 'r') as f:
        return [tuple(map(float, line.split(','))) for line in f]


def compute_labels(points, centers):
    dist = np.sum((points[:, None, :] - centers) ** 2, axis=-1)
    return np.argmin(dist, axis=1)


def compute_centers(points, labels):
    n_centers = len(set(labels))
    return np.array([points[labels == center].mean(axis=0)
                     for center in range(n_centers)])


def kmeans(points, n_clusters, max_iter=20):
    centers = points[random.sample(range(len(points)), k=n_clusters), :]
    step = 1

    while step <= max_iter:
        old_centers = centers
        labels = compute_labels(points, centers)
        centers = compute_centers(points, labels)

        if np.all(centers == old_centers):
            break
        step += 1

    return labels, centers


points = np.array(load_data(file=args.file))

random.seed(1707)
km, centers = kmeans(points=points, n_clusters=args.n_clusters,
                     max_iter=args.max_iter)
