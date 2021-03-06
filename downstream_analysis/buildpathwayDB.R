#!/usr/bin/env Rscript

library(KEGGREST)
library("getopt")

opt = getopt(matrix( c('help', 'h', 0, "logical", 
                       'verbose', 'v', 0, "integer",
                       'organism', 'o', 1, "character",
                       'database', 'd', 1, "character"
), ncol=4, byrow=TRUE ) );

if(! is.null(opt$help) || is.null(opt$organism )  || is.null(opt$database ) )
{
  cat(paste("Usage: buildpathwayDB.R [-h] [-v] -o KEGG_organism_code -d database.txt\n"));
  q(status=1);
}

org <- opt$organism

getPathwayInfo <- function(pathlist){
	pathnames <- c()
	for( j in 1:length(pathlist)){
		query <- keggGet(pathlist[[j]])
		pathnames <- c(pathnames, query[[1]]$NAME)
	}
	return(cbind(pathlist, pathnames))
}

paths <- keggLink("pathway", org)

id2name <- getPathwayInfo(unique(paths))
pathtable <- cbind(sub(paste(org,":",sep=""), "", names(paths)), sub("path:","",paths), sapply(paths, function(x) id2name[id2name[,1] == x,2]))

write.table(pathtable, file=opt$database, append=FALSE, quote=TRUE, sep="\t", row.names=FALSE, col.names=c("gene_id","path_id","path_name"))
