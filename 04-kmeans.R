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

plot_kmeans <- function(points, labels, centers, name = NULL, ...) {
  png(paste0("plots/figure_", name, ".png"),
      width = 1280, height = 800, res = 100)
  plot(points, type = "p", pch = 19L, cex = 1.5, col = colors[labels],
       bty = "n", axes = FALSE, xlab = "", ylab = "", ...)
  points(centers, type = "p", col = "white",
         bg = centers_colors, pch = 21L, cex = 3.5, lwd = 1.5)
  dev.off()
}

kmeans <- function(points, n_clusters) {
  centers <- points[sample.int(n = nrow(points), size = n_clusters), ]
  step = 1L

  while (TRUE) {
    old_centers = centers
    labels = compute_labels(points, centers)
    centers = compute_centers(points, labels)

    if (all(centers == old_centers)) {
      break
    }

    if (isTRUE(args[["plot"]])) {
      plot_kmeans(points, labels, old_centers,
                  name = paste0(step, "_a"),
                  main = paste0("Itération ", step,
                                " : Affectation des points ",
                                "au centre le plus proche"))
      plot_kmeans(points, labels, centers,
                  name = paste0(step, "_b"),
                  main = paste0("Itération ", step,
                                " : Ajustement des centres"))
    }
    step = step + 1L
  }

  return(list(labels = labels, centers = centers))
}

points <- load_data(file = args[["file"]])

set.seed(1707)
centers <- points[sample.int(n = nrow(points), size = args[["n_clusters"]]), ]

if (isTRUE(args[["plot"]])) {
  png("plots/figure_0.png", width = 1280, height = 800, res = 100)
  plot(points, type = "p", pch = 19L, cex = 1.5,
       col = rgb(red = 0L, green = 0L, blue = 0L, alpha = 0.3),
       bty = "n", axes = FALSE, xlab = "", ylab = "",
       main = "Initialisation")
  points(centers, type = "p", col = "white",
         bg = centers_colors, pch = 21L, cex = 3.5, lwd = 1.5)
  invisible(dev.off())
}

set.seed(1707)
km <- kmeans(points = points, n_clusters = args[["n_clusters"]])
