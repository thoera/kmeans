# ------------------------------------------------------------------------------
# K-means :
# 1. Choisir n centres initiaux
# 2. Répéter :
#     a. Affecter chacun des points au centre le plus proche
#     b. Mettre à jour chaque centre à la moyenne des points
#     qui lui ont été affectés
#     c. Vérifier si l'algorithme a convergé
# ------------------------------------------------------------------------------

library("argparser")
library("ggplot2")

parser <- arg_parser("K-means")
parser <- add_argument(parser, "file", type = "character",
                       help = "the file to use for the clustering")
parser <- add_argument(parser, "--n_clusters", default = 3L, type = "integer",
                       help = "the number of clusters (default: 3)")
parser <- add_argument(parser, "--plot", short = "-p", flag = TRUE,
                       help = "create a plot for each step of the algorithm")
args <- parse_args(parser)

# generate n colors from the viridis palette
colors <- viridisLite::viridis(args[["n_clusters"]], alpha = 0.3)
centers_colors <- viridisLite::viridis(args[["n_clusters"]])

load_data <- function(file) {
  points <- scan(file, sep = ",", quiet = TRUE)
  points <- matrix(points, ncol = 2L, byrow = TRUE)
}

compute_labels <- function(points, centers) {
  labels <- apply(points, MARGIN = 1L, FUN = function(point) {
    which.min(
      rowSums(
        sweep(centers, MARGIN = 2L, STATS = point, FUN = "-") ** 2L
      )
    )
  })
}

compute_centers <- function(points, labels) {
  n_centers <- length(unique(labels))
  t(
    vapply(
      seq_len(n_centers),
      FUN = function(center) {
        apply(points[labels == center, ], MARGIN = 2L, FUN = mean)
      },
      FUN.VALUE = double(2L)
    ) 
  )
}

plot_kmeans <- function(points, labels, centers, name, title = NULL) {
  ggplot(data = data.frame(centers), aes(x = X1, y = X2)) +
    geom_point(data = data.frame(points), aes(x = X1, y = X2),
               size = 3L, alpha = 0.3, color = colors[labels]) +
    geom_point(size = 8L, color = "#FFFFFF") +
    geom_point(size = 7L, color = centers_colors) +
    labs(title = title) +
    theme_void() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))
  ggsave(filename = paste0("plots/figure_", name, ".png"),
         width = 8L, height = 5L)
}

kmeans <- function(points, n_clusters) {
  centers <- points[sample.int(n = nrow(points), size = n_clusters), ]
  step <- 1L
  
  while (TRUE) {
    old_centers <- centers
    labels <- compute_labels(points, centers)
    centers <- compute_centers(points, labels)
    
    if (all(centers == old_centers)) {
      break
    }
    
    if (isTRUE(args[["plot"]])) {
      plot_kmeans(points, labels, old_centers,
                  name = paste0(step, "_a"),
                  title = paste0("Itération ", step,
                                 " : Affectation des points ",
                                 "au centre le plus proche"))
      plot_kmeans(points, labels, centers,
                  name = paste0(step, "_a"),
                  title = paste0("Itération ", step,
                                 " : Ajustement des centres"))
    }
    step <- step + 1L
  }
  
  return(list(labels = labels, centers = centers))
}

points <- load_data(file = args[["file"]])

set.seed(1707)
centers <- points[sample.int(n = nrow(points), size = args[["n_clusters"]]), ]

if (isTRUE(args[["plot"]])) {
  ggplot(data = data.frame(centers), aes(x = X1, y = X2)) +
    geom_point(data = data.frame(points), aes(x = X1, y = X2),
               size = 3L, alpha = 0.3) +
    geom_point(size = 8L, color = "#FFFFFF") +
    geom_point(size = 7L, color = centers_colors) +
    labs(title = "Initialisation") +
    theme_void() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))
  ggsave(filename = "plots/figure_0.png", width = 8L, height = 5L)
}

set.seed(1707)
km <- kmeans(points = points, n_clusters = args[["n_clusters"]])
