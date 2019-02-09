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
import matplotlib
from matplotlib import pyplot as plt
import random

parser = argparse.ArgumentParser(description='K-means')
parser.add_argument('file', type=str,
                    help='the file to use for the clustering')
parser.add_argument('--n_clusters', nargs='?', const=3, default=3, type=int,
                    help='the number of clusters (default: 3)')
parser.add_argument('-p', '--plot', action='store_true',
                    help='create a plot for each step of the algorithm')
args = parser.parse_args()

# generate n colors from the viridis palette
viridis = matplotlib.cm.get_cmap('viridis', args.n_clusters)
colors = viridis.colors


def load_data(file):
    with open(file, 'r') as f:
        return [tuple(map(float, line.split(','))) for line in f]


def dist(x, y):
    return sum((xi - yi) ** 2 for xi, yi in zip(x, y))


def compute_labels(points, centers):
    labels = []
    for point in points:
        distances = [dist(point, center) for center in centers]
        labels.append(distances.index(min(distances)))
    return labels


def compute_centers(points, labels):
    centers = {k: [] for k in set(labels)}
    for label, point in zip(labels, points):
        centers[label].append(point)

    return [tuple(sum(x) / len(x) for x in zip(*centers[label]))
            for label in centers]


def plot_kmeans(points, labels, centers, name, title=None):
    plt.figure(figsize=(16, 10))
    plt.scatter(*zip(*points), alpha=0.3,
                c=labels, cmap=matplotlib.colors.ListedColormap(colors))
    plt.scatter(*zip(*centers), s=250, c=colors, edgecolors='white')
    plt.title(title)
    plt.axis('off')
    plt.savefig(f'plots/figure_{name}.png', bbox_inches='tight', dpi=100)
    plt.close()


def kmeans(points, n_clusters):
    centers = random.sample(points, k=n_clusters)
    step = 1

    while True:
        old_centers = centers
        labels = compute_labels(points, centers)
        centers = compute_centers(points, labels)

        if centers == old_centers:
            break

        if args.plot:
            plot_kmeans(points, labels, old_centers,
                        title=f'Itération {step} : Affectation des points ' +
                              'au centre le plus proche',
                        name=str(step) + '_a')
            plot_kmeans(points, labels, centers,
                        title=f'Itération {step} : Ajustement des centres',
                        name=str(step) + '_b')
        step += 1

    return labels, centers


points = load_data(file=args.file)

random.seed(1707)
centers = random.sample(points, k=args.n_clusters)

if args.plot:
    plt.figure(figsize=(16, 10))
    plt.scatter(*zip(*points), alpha=0.3, c='black')
    plt.scatter(*zip(*centers), s=250, c=colors, edgecolors='white')
    plt.title('Initialisation')
    plt.axis('off')
    plt.savefig(f'plots/figure_0.png', bbox_inches='tight', dpi=100)
    plt.close()

random.seed(1707)
km, centers = kmeans(points=points, n_clusters=args.n_clusters)
