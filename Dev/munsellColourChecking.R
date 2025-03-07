in_gamut(c("5R 5/8","2.5R 9/28"))


mnsl <-"7.5YR 2/2"
mnsl <-"7.5YR 8/1"
mnsl <-"7.5YR 5/8"
mnsl <-"7.5YR 2/2"
mnsl <-"7.5YR 7/3"

col <- munsell::mnsl2hex(in_gamut(mnsl, fix = T))

col <- munsell::mnsl2hex(mnsl)
plot(NULL, axes = FALSE, xlab = "", ylab = "", xlim = c(0, 2.5), ylim = c(0, 1), main=mnsl)
rect(xleft = 0, xright = 2.5, ybottom = 0, ytop = 1, col=col)


plot_mnsl("7.5YR 7/3")


library(aqp)
col <- munsell2rgb('7.5YR', 7, 3)
plot(NULL, axes = FALSE, xlab = "", ylab = "", xlim = c(0, 2.5), ylim = c(0, 1), main=mnsl)
rect(xleft = 0, xright = 2.5, ybottom = 0, ytop = 1, col=col)
