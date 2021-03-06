#' Read plate data
#'
#' This is the primary fuction for reading data into R with this package. It is built exlusively for use with worm data. This function can read in individual plates, plates from a single directory (e.g. setup or score directory), or plates from an experimental directory (with both score and setup sub-directories). The files/directories to be read in (individual file/directory/experiment directory) are detected and handled automatically by the function. This function also utilizes an SVM to determine whether objects are more likely to be bubbles or worms and labels them accordingly. It also estimates the lifestage of each worm.
#' 
#' @param fileDir The file or directory to be read. This can be an individual file, a directory containing .txt files to be read, or the directory containing the score and setup directories.
#' @param tofmin The minimum time of flight value allowed. Defaults to 60.
#' @param tofmin The minimum time of flight value allowed. Defaults to 2000.
#' @param extmin The minimum extinction value allowed. Defaults to 0.
#' @param extmin The maximum extinction value allowed. Defaults to 10000.
#' @param SVM Boolean specifying whether or not to use the support vector machine to separate worms and bubbles.
#' @return If a single file is given, a single data frame for only the provided plate is returned. If an experiment directory is given, a list of two data frames will be returned. The first element in the list will be a single data frame for all of the score plates. The second element will be all of the setup plates. If there are no setup plates, NA will fill the second list element. If a setup or score directory is given, a single data frame of all of the plates in the directory will be returned.
#' @export

readData <- function(fileDir, tofmin=60, tofmax=2000, extmin=0, extmax=10000, SVM=TRUE) {
    if (length(dir(fileDir)) == 0){
        data <- readFile(fileDir, tofmin, tofmax, extmin, extmax, SVM)
    } else if ("score" %in% dir(fileDir) && "setup" %in% dir(fileDir)) {
        if (grep("/$", fileDir) == 1){
            fileDir <- substr(fileDir, 1, nchar(fileDir)-1)
        }
        scorePath <- file.path(fileDir, "score")
        setupPath <- file.path(fileDir, "setup")
        score <- readDirectory(scorePath, tofmin, tofmax, extmin, extmax, SVM)
        setup <- readDirectory(setupPath, tofmin, tofmax, extmin, extmax, SVM)
        data <- list(score, setup)
    } else {
        if (grep("/$", fileDir) == 1){
            fileDir <- substr(fileDir, 1, nchar(fileDir)-1)
        }
        data <- readDirectory(fileDir, tofmin, tofmax, extmin, extmax, SVM)
    }
    return(data)
}