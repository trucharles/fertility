library(googlesheets4)
library(netmeta)
library(writexl)

# function to pdf figures

fig_to_pdf <- function(outcome, figname, fig, w, h){
  pdf(paste(outcome, figname, "DRUGS.pdf"),
      width = w, height = h)
  fig
  dev.off()
}

conduct_nma_cont <- function(url, sheets){
  wd <- getwd()
  # create and send to pdf observations, contrast-based formatted data,
  #   network graphs, forest plots, SUCRA rankings, SUCRA rankograms, SUCRA
  #   curves, design-based decomposition, network estimate splits, heat
  #   plots, and funnel plots
  for (i in seq_along(sheets)){
    dir.create(file.path(getwd(), sheets[i]), showWarnings = FALSE)
    setwd(file.path(getwd(), sheets[i]))
    # get pairwise data
    obs <- read_sheet(url, sheet = sheets[i])
    # sanitize headers
    names(obs) <- tolower(sub(" ", "_", names(obs)))
    # convert to contrast-based formatted data
    pw <- pairwise(list(grouped_intervention,control),
                             n = list(intervention_n, control_n),
                             mean = list(intervention_mean, control_mean),
                             sd = list(intervention_sd, control_sd),
                             data = obs, studlab = study_id)
    # conduct network meta-analysis
    nma <- netmeta(TE, seTE, treat1, treat2, studlab,
                   data=pw, sm="MD", reference="plac",
                   common=FALSE)


    # create network graph
    fig_to_pdf(sheets[i], "network graph",
               netgraph(nma, scale=1.5, cex=.5,
                        thickness="number.of.studies"), 8,8)
    # get index of placebo
    plcidx <- which("Placebo/no treatment" == nma$trts)
    # get vs placebo indices
    plcindices <- seq(from=(plcidx-1)*length(nma$trts)+1,
                  to=(plcidx-1)*length(nma$trts)+length(nma$trts))
    # get limits for forest plot
    plotLL <- floor(min(nma$lower.random[plcindices]))
    plotUL <- ceiling(max(nma$upper.random[plcindices]))
    # create forest plot
    fig_to_pdf(sheets[i], "forest plot",
               forest(nma, xlim=c(plotLL, plotUL), sortvar="SUCRA",
                     xlab = sheets[i]), 8, 11)
    # SUCRA rankings
    print(netrank(nma, method="SUCRA", small.values="bad",
                  random = TRUE, common = TRUE))
    # SUCRA rankogram
    rog <- rankogram(nma,
                     small.values="bad",
                     random=TRUE)$cumrank.matrix.random
    # Combine SUCRA curves into one figure
    fig_to_pdf(sheets[i], "SUCRA plot",
               matplot(t(rog), xlab="Rank", ylab="Probability of Rank",
                   type="l",lty=ceiling(seq_len(length(nma$trts)) / 8),
                   col=seq_len(length(nma$trts))), 10, 10)
    # Manually create SUCRA plot legend
    pdf(paste(sheets[i], "SUCRA legend DRUGS.pdf"), width = 5, height = 9)
    plot(c(0,1),type="n", axes=F, xlab="", ylab="")
    legend("center", nma$trts,cex=0.8,
           lty=ceiling(seq_len(length(nma$trts)) / 8),
           col=seq_len(length(nma$trts)))
    dev.off()
    # Create funnel plots
    fig_to_pdf(sheets[i], "funnel plot",
               funnel(nma, pch = 1,
                      method.bias = "Egger",
                      legend = FALSE,
                      order=names(sort(nma$k.trts[nma$k.trts>1]))),6,8)
    # Check global inconsistency
    print(decomp.design(nma))
    # Check local inconsistency
    print(netsplit(nma))
    # Create heat plots
    fig_to_pdf(sheets[i], "heat plot", netheat(nma, random=F),12,8)
    # Create league tables
    netleague(nma, common = TRUE, digits = 2, bracket = "(",
              separator = " to ", writexl = TRUE,
              path=paste(sheets[i],"league table FE DRUGS.xlsx"))
    netleague(nma, common = FALSE, digits = 2, bracket = "(",
              separator = " to ", writexl = TRUE,
              path=paste(sheets[i],"league table RE DRUGS.xlsx"))
    # go back to original directory
    setwd(wd)
  }
}

conduct_nma_disc <- function(url, sheets){
  wd <- getwd()
  # create and send to pdf observations, contrast-based formatted data,
  #   network graphs, forest plots, SUCRA rankings, SUCRA rankograms, SUCRA
  #   curves, design-based decomposition, network estimate splits, heat
  #   plots, and funnel plots
  for (i in seq_along(sheets)){
    dir.create(file.path(getwd(), sheets[i]), showWarnings = FALSE)
    setwd(file.path(getwd(), sheets[i]))
    # get pairwise data
    obs <- read_sheet(url, sheet = sheets[i])
    # sanitize headers
    names(obs) <- tolower(sub(" ", "_", names(obs)))
    # convert to contrast-based formatted data
    pw <- pairwise(grouped_intervention,
                   event = event,
                   n = n_total,
                   data = obs, studlab = study_id)
    # conduct network meta-analysis
    nma <- netmetabin(pw, reference="plac", method="Inverse",
                      cc.pooled=TRUE, common=FALSE)

    # create network graph
    fig_to_pdf(sheets[i], "network graph",
               netgraph(nma, scale=1.5, cex=.5,
                        thickness="number.of.studies"), 8,8)
    # create forest plot
    fig_to_pdf(sheets[i], "forest plot",
               forest(nma, sortvar="SUCRA",
                      xlab = sheets[i],
                      rightcols = c("effect", "ci")), 11, 8)

    # SUCRA rankings
    print(netrank(nma, method="SUCRA", small.values="bad",
                  random = TRUE, common = TRUE))

    # SUCRA rankogram
    rog <- rankogram(nma,
                     small.values="bad",
                     random=TRUE)$cumrank.matrix.random
    # Combine SUCRA curves into one figure
    fig_to_pdf(sheets[i], "SUCRA plot",
               matplot(t(rog), xlab="Rank", ylab="Probability of Rank",
                       type="l",lty=ceiling(seq_len(length(nma$trts)) / 8),
                       col=seq_len(length(nma$trts))), 10, 10)
    # Manually create SUCRA plot legend
    pdf(paste(sheets[i], "SUCRA legend DRUGS.pdf"), width = 5, height = 9)
    plot(c(0,1),type="n", axes=F, xlab="", ylab="")
    legend("center", nma$trts,cex=0.8,
           lty=ceiling(seq_len(length(nma$trts)) / 8),
           col=seq_len(length(nma$trts)))
    dev.off()
    # Create funnel plots
    fig_to_pdf(sheets[i], "funnel plot",
               funnel(nma, pch = 1,
                      method.bias = "Egger",
                      legend = FALSE,
                      order=names(sort(nma$k.trts[nma$k.trts>1]))),6,8)
    # Check global inconsistency
    print(decomp.design(nma))
    # Check local inconsistency
    print(netsplit(nma))
    # Create heat plots
    fig_to_pdf(sheets[i], "heat plot", netheat(nma, random=F),12,8)


    # Create league tables
    netleague(nma, common = TRUE, digits = 2, bracket = "(",
              separator = " to ", writexl = TRUE,
              path=paste(sheets[i],"league table FE DRUGS.xlsx"))
    netleague(nma, common = FALSE, digits = 2, bracket = "(",
              separator = " to ", writexl = TRUE,
              path=paste(sheets[i],"league table RE DRUGS.xlsx"))

    # go back to original directory
    setwd(wd)
  }
}