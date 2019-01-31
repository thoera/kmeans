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
from sklearn.cluster import KMeans

parser = argparse.ArgumentParser(description='K-means')
parser.add_argument('file', type=str,
                    help='the file to use for the clustering')
parser.add_argument('--n_clusters', nargs='?', const=3, default=3, type=int,
                    help='the number of clusters (default: 3)')
args = parser.parse_args()


def load_data(file):
    with open(file, 'r') as f:
        return [tuple(map(float, line.split(','))) for line in f]


points = load_data(file=args.file)

km = KMeans(n_clusters=args.n_clusters, random_state=1707).fit(points)
