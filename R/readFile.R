#' Reads single plate data
#'
#' Reads individual sorter data files into R. Built exlusively for use with worms.
#' 
#' @param file The file to be read.
#' @param tofmin The minimum time of flight value allowed. Defaults to 60.
#' @param tofmin The minimum time of flight value allowed. Defaults to 2000.
#' @param extmin The minimum extinction value allowed. Defaults to 0.
#' @param extmin The maximum extinction value allowed. Defaults to 10000.
#' @param SVM Boolean specifying whether or not to use the support vector machine to separate worms and bubbles.
#' @return Returns a single data frame for a single plate file.
#' @import kernlab
#' @import COPASutils
#' @import dplyr
#' @export

readFile <- function(file, tofmin=60, tofmax=2000, extmin=0, extmax=10000, SVM=TRUE, levels=2, oldNames=FALSE){
    plate <- COPASutils::readSorter(file, tofmin, tofmax, extmin, extmax)
    modplate <- with(plate,
                     data.frame(row=Row,
                                col=as.factor(Column),
                                sort=Status.sort,
                                TOF=TOF,
                                EXT=EXT,
                                time=Time.Stamp,
                                green=Green,
                                yellow=Yellow,
                                red=Red))
    modplate <- modplate %>%
        dplyr::group_by(row, col) %>%
        dplyr::do(COPASutils::extractTime(.))
    modplate <- data.frame(modplate)
    modplate[,10:13] <- apply(modplate[,c(5, 7:9)], 2, function(x){x/modplate$TOF})
    colnames(modplate)[10:13] <- c("norm.EXT", "norm.green", "norm.yellow", "norm.red")
    if(SVM){
        plateprediction <- kernlab::predict(COPASutils::bubbleSVMmodel_noProfiler, modplate[,3:length(modplate)], type="probabilities")
        modplate$object <- plateprediction[,"1"]
        modplate$call50 <- factor(as.numeric(modplate$object>0.5), levels=c(1,0), labels=c("object", "bubble"))
    }
    modplate$stage <- ifelse(modplate$TOF>=60 & modplate$TOF<90, "L1", 
                             ifelse(modplate$TOF>=90 & modplate$TOF<200, "L2/L3",
                                    ifelse(modplate$TOF>=200 & modplate$TOF<300, "L4",
                                           ifelse(modplate$TOF>=300, "adult", NA))))
    modplate[,as.vector(which(lapply(modplate, class) == "integer"))] <- lapply(modplate[,as.vector(which(lapply(modplate, class) == "integer"))], as.numeric)
    
    if(oldNames){
        modplate <- cbind(info(file, levels), modplate)
    } else {
        plateInfo <- newInfo(file, levels)
        
        #### Put in new file path to templates once known
        strainsFile <- paste0("~/Templates/", plateInfo$strainTemplate[1], ".csv")
        conditionsFile <- paste0("~/Templates/", plateInfo$conditionTemplate[1], ".csv")
        controlsFile <- paste0("~/Templates/", plateInfo$controlTemplate[1], ".csv")
        
        strains <- readTemplate(strainsFile, type="strains")
        conditions  <- readTemplate(conditionsFile, type="conditions")
        controls  <- readTemplate(controlsFile, type="controls")
        
        modplate <- cbind(plateInfo[,1:5], modplate)
        modplate <- dplyr::left_join(modplate, strains, by=c("row", "col"))
        modplate <- dplyr::left_join(modplate, conditions, by=c("row", "col"))
        modplate <- dplyr::left_join(modplate, controls, by=c("row", "col"))
    }
    
    return(modplate)
}