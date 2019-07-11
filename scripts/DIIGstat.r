#DIIGstat.r
library(arm)
library(dplyr)
library(ggplot2)
library(sjstats)
library(car)
library(scales)
library(grid)
#This will likely be folded into CSIS360
#But for now, using it to create and refine functions for regression analysis.


fit_curve<-function(x, a, b){invlogit(b *  x +a)}


bin_df<-function(data,rank_col,group_col=NULL,bins=20,ties.method="random"){
  #https://stats.stackexchange.com/questions/34008/how-does-ties-method-argument-of-rs-rank-function-work
  if(!is.null(group_col)){
    # Convert character vector to list of symbols
    dots <- lapply(group_col, as.symbol)
    
    # Group by
    data %>%
      group_by_(.dots=dots) 
  }
  #Calculate rank, this allows cut_number to work even when some answers have to be broken up into multiple bins
  bin<-rank(as.data.frame(data[,which(colnames(data)==rank_col)]),ties.method=ties.method)
  cut_number(bin,bins)
}

# bin_plot<-function(data,x_col,y_col,group_col=NULL,n=20,ties.method="random")
# 
# 
# data$bin_plot<-bin_df(data,rank_col=x_col,group_col=group_col)
# data<-data[,!is.na(data[,colnames(data)==x_col]) &
#              !is.na(data[,colnames(data)==y_col])
#            !is.na(data[,colnames(data)==group_col])
#            ]
# dots <- lapply(c(x_col,y_col,group_col), as.symbol)
# 
# # Group by
# data %>%
#   group_by_(.dots=dots) 
# 
# 
# 
# 
# 
# Term_01D_line_FxCb<-ggplot(data=subset(Term_smp,!is.na(l_Offr) & !is.na(FxCb)) %>% 
#                              group_by(bin_Offer_FxCb,FxCb) %>% 
#                              summarise (mean_Term = mean(b_Term),
#                                         mean_l_Offr =mean(l_Offr)),
#                            aes(y=mean_Term,x=mean_l_Offr))+geom_point()+facet_wrap(~FxCb)
# 
# }

#From Gelman and Hill
#http://www.stat.columbia.edu/~gelman/arm/software/
binned.resids <- function (x, y, nclass=sqrt(length(x))){
  breaks.index <- floor(length(x)*(1:(nclass-1))/nclass)
  breaks <- c (-Inf, sort(x)[breaks.index], Inf)
  output <- data.frame(xbar=double(),
                       ybar=double(),
                       n=integer(), 
                       x.lo=double(),
                       x.hi=double(),
                       se2=double())
  xbreaks <- NULL
  x.binned <- as.numeric (cut (x, breaks))
  for (i in 1:nclass){
    items <- (1:length(x))[x.binned==i]
    x.range <- range(x[items])
    xbar <- mean(x[items])
    ybar <- mean(y[items])
    n <- length(items)
    sdev <- sd(y[items])
    output <- rbind (output, data.frame(xbar=xbar,
                                        ybar=ybar,
                                        n=n, 
                                        x.lo=x.range[1],
                                        x.hi=x.range[2],
                                        se2=2*sdev/sqrt(n)))
  }
  # colnames (output) <- c ("xbar", "ybar", "n", "x.lo", "x.hi", "se2")
  return (list (binned=output, xbreaks=xbreaks))
}

binned_fitted_versus_term_residuals<-function(model,bins=20){
  
  #Save this for a future GLM
  # Term_data_01A<-data.frame(fitted=fitted(Term_01A),
  #                        residuals=residuals(Term_01A),
  #                        nTerm=Term_01A@frame$nTerm,
  #                        cb_Comp=Term_01A@frame$cb_Comp
  #                        )
  
  if(class(model)[1]=="glmerMod")
  {
    data <-data.frame(
      fitted=fitted(model),
      residuals=residuals(model),
      b_Term=model@frame$b_Term
    )
    
  }
  else
  {
    data <-data.frame(
      fitted=fitted(model),
      residuals=residuals(model),
      b_Term=model$model$b_Term
    )
  }
  
  data$bin_fitted<-bin_df(data,rank_col="fitted",bins=bins)
  
  data<-subset(data,!is.na(fitted) & !is.na(residuals) )
  
  ggplot(data= data %>% 
           group_by(bin_fitted) %>% 
           summarise (mean_Term = mean(b_Term),
                      mean_fitted =mean(fitted)),
         aes(y=mean_Term,x=mean_fitted))+geom_point() +
    labs(title="Binned Fitted Linear Model",           caption="Source: FPDS, CSIS Analysis")
}

resid_plot<-function(model,sample=NA){
  #Source https://rpubs.com/therimalaya/43190
  # Raju Rimal
  results<-data.frame(
    fitted=fitted(model),
    resid=residuals(model)
  )
  #For reasons of speed, I give the option to only partially show the results. 250k or 1m takes a while to plot.
  if(!is.na(sample)){
    results<-results[sample(nrow(results),sample),]
    
  }
  
  p1<-ggplot(results, aes(x=fitted, y=resid))+geom_point()
  p1<-p1+stat_smooth(method="loess")+geom_hline(yintercept=0, col="red", linetype="dashed")
  p1<-p1+xlab("Fitted values")+ylab("Residuals")
  p1<-p1+ggtitle("Residual vs Fitted Plot")+theme_bw()
  p1
}

binned_fitted_versus_residuals<-function(model,bins=20){
  if(class(model)[1]=="glmerMod")
  {
    if(!is.null(model@frame$b_CBre)){
      graph<-binned_fitted_versus_cbre_residuals(model,bins)
    } else if(!is.null(model@frame$l_CBre)){
      graph<-binned_fitted_versus_l_cbre_residuals(model,bins)
    } else if(!is.null(model@frame$b_Term)){
      graph<-binned_fitted_versus_term_residuals(model,bins)
    } else if(!is.null(model@frame$cl_Offr)){
      graph<-resid_plot(model,sample=25000)
    }
    else{stop("Outcome variable not recognized.")}
  }
  else
  {
    if(!is.null(model$model$b_CBre)){
      graph<-binned_fitted_versus_cbre_residuals(model,bins)
    } else if(!is.null(model$model$l_CBre)){
      graph<-binned_fitted_versus_l_cbre_residuals(model,bins)
    } else if(!is.null(model$model$b_Term)){
      graph<-binned_fitted_versus_term_residuals(model,bins)
    } else if(!is.null(model$model$cl_Offr)){
      graph<-resid_plot(model,sample=25000)
    }
    else{stop("Outcome variable not recognized.")}
  }
  graph
}


binned_fitted_versus_cbre_residuals<-function(model,bins=20){
  
  #Save this for a future GLM
  # CBre_data_01A<-data.frame(fitted=fitted(CBre_01A),
  #                        residuals=residuals(CBre_01A),
  #                        nCBre=CBre_01A@frame$nCBre,
  #                        cb_Comp=CBre_01A@frame$cb_Comp
  #                        )
  
  if(class(model)[1]=="glmerMod")
  {
    data <-data.frame(
      fitted=fitted(model),
      residuals=residuals(model),
      b_CBre=model@frame$b_CBre
    )
    
  }
  else
  {
    data <-data.frame(
      fitted=fitted(model),
      residuals=residuals(model),
      b_CBre=model$model$b_CBre
    )
  }
  
  data$bin_fitted<-bin_df(data,rank_col="fitted",bins=bins)
  
  data<-subset(data,!is.na(fitted) & !is.na(residuals) )
  
  ggplot(data= data %>% 
           group_by(bin_fitted) %>% 
           summarise (mean_CBre = mean(b_CBre),
                      mean_fitted =mean(fitted)),
         aes(y=mean_CBre,x=mean_fitted))+geom_point() +
    labs(title="Binned Fitted Linear Model",           caption="Source: FPDS, CSIS Analysis")
}

binned_fitted_versus_l_cbre_residuals<-function(model,bins=20){
  
  #Save this for a future GLM
  # CBre_data_01A<-data.frame(fitted=fitted(CBre_01A),
  #                        residuals=residuals(CBre_01A),
  #                        nCBre=CBre_01A@frame$nCBre,
  #                        cb_Comp=CBre_01A@frame$cb_Comp
  #                        )
  
  if(class(model)[1]=="glmerMod")
  {
    data <-data.frame(
      fitted=fitted(model),
      residuals=residuals(model),
      l_CBre=model@frame$l_CBre
    )
    
  }
  else
  {
    data <-data.frame(
      fitted=fitted(model),
      residuals=residuals(model),
      l_CBre=model$model$l_CBre
    )
  }
  
  data$bin_fitted<-bin_df(data,rank_col="fitted",bins=bins)
  
  data<-subset(data,!is.na(fitted) & !is.na(residuals) )
  
  ggplot(data= data %>% 
           group_by(bin_fitted) %>% 
           summarise (mean_CBre = mean(l_CBre),
                      mean_fitted =mean(fitted)),
         aes(y=mean_CBre,x=mean_fitted))+geom_point() +
    labs(title="Binned Fitted Linear Model",           caption="Source: FPDS, CSIS Analysis")
}


residuals_plot<-function(model,col="fitted",bins=40){
  if(class(model)[1]=="glmerMod")
  {
    data <-data.frame(
      fitted=fitted(model),
      residuals=residuals(model)
    )
    if (col!="fitted"){
      data$x_col<-model@frame[,col]
      colnames(data)[colnames(data)=="x_col"]<-col
    }
    
  }
  else
  {
    data <-data.frame(
      fitted=fitted(model),
      residuals=residuals(model)
    )
    
    if (col!="fitted"){
      data$x_col<-model$model[,col]
      colnames(data)[colnames(data)=="x_col"]<-col
    }
  }
  
  #Safety measure for missing output variables.
  graph<-NULL
  if(class(model)[1]=="glmerMod")
  {
    if(!is.null(model@frame$b_CBre)){
      data$outcome<-model@frame$b_CBre
      data<-binned.resids (data[,col],
                           data$fitted-data$b_CBre, nclass=bins)$binned
    } else if(!is.null(model@frame$b_Term)){
      data$outcome<-model@frame$b_Term
      data<-binned.resids (data[,col],
                           data$fitted-data$b_Term, nclass=bins)$binned
    } else if(!is.null(model@frame$l_CBre)){
      data$outcome<-model@frame$l_CBre
      data<-binned.resids (data[,col],
                           data$residuals, nclass=bins)$binned
    } else if(!is.null(model@frame$l_OptGrowth)){
      data$outcome<-model@frame$l_OptGrowth
      data<-binned.resids (data[,col],
                           data$residuals, nclass=bins)$binned
    } else if(!is.null(model@frame$l_Offr)){
      data$outcome<-model@frame$l_Offr
      data<-binned.resids(data[,col],
                           data$residuals, nclass=bins)$binned
    } 
    else{stop("Outcome variable not recognized.")}
  }
  else
  {
    if(!is.null(model$model$b_CBre)){
      data$outcome<-model$model$b_CBre
      data<-binned.resids (data[,col],
                           data$fitted-data$b_CBre, nclass=bins)$binned
    } else if(!is.null(model$model$b_Term)){
      data$outcome<-model$model$b_Term
      data<-binned.resids (data[,col],
                           data$fitted-data$b_Term, nclass=bins)$binned
    } else if(!is.null(model$model$l_CBre)){
      data$outcome<-model$model$l_CBre
      data<-binned.resids (data[,col],
                           data$residuals, nclass=bins)$binned
    } else if(!is.null(model$model$l_OptGrowth)){
      data$outcome<-model$model$l_OptGrowth
      data<-binned.resids (data[,col],
                           data$residuals, nclass=bins)$binned
    } else if(!is.null(model$model$l_Offr)){
      # graph<-resid_plot(model,sample=25000)
      data$outcome<-model$model$l_Offr
      data<-binned.resids (data[,col],
                           data$residuals, nclass=bins)$binned
    } 
    else{stop("Outcome variable not recognized.")}
  }
  
  
  
  br<-ggplot(data=data,
             aes(x=xbar,y-ybar))+
    geom_point(aes(y=ybar))+ #Residuals
    geom_line(aes(y=se2),col="grey")+
    geom_line(aes(y=-se2),col="grey")+
    labs(title="Binned residual plot",
         y="Average residual")
  
  if (col=="fitted"){
    br<-br+labs(x="Estimated Pr(Termination)")
  }
  br
}




residuals_term_plot<-function(model,x_col="fitted",bins=40){
  #Plot the fitted values vs actual results
  
  
  # if(class(model)[1]=="glmerMod")
  # {
  #   data <-data.frame(
  #     fitted=fitted(model),
  #     residuals=residuals(model),
  #     b_Term=model@frame$b_Term
  #   )
  #   if (x_col!="fitted"){
  #     data$x_col<-model@frame[,x_col]
  #     colnames(data)[colnames(data)=="x_col"]<-x_col
  #   }
  #   
  # }
  # else
  # {
  #   data <-data.frame(
  #     fitted=fitted(model),
  #     residuals=residuals(model),
  #     b_Term=model$model$b_Term
  #   )
  #   
  #   if (x_col!="fitted"){
  #     data$x_col<-model$model[,x_col]
  #     colnames(data)[colnames(data)=="x_col"]<-x_col
  #   }
  # }
  
  # data<-binned.resids (data[,x_col],
  #                      data$fitted-data$b_Term, nclass=bins)$binned
  # 
  # br<-ggplot(data=data,
  #            aes(x=xbar,y-ybar))+
  #   geom_point(aes(y=ybar))+ #Residuals
  #   geom_line(aes(y=se2),col="grey")+
  #   geom_line(aes(y=-se2),col="grey")+
  #   labs(title="Binned residual plot",
  #        y="Average residual")
  # 
  # if (x_col=="fitted"){
  #   br<-br+labs(x="Estimated Pr(Termination)")
  # }
  # br
}

residuals_cbre_plot<-function(model,x_col="fitted",bins=40){
  #Plot the fitted values vs actual results
  
  
  if(class(model)[1]=="glmerMod")
  {
    data <-data.frame(
      fitted=fitted(model),
      residuals=residuals(model),
      b_CBre=model@frame$b_CBre
    )
    if (x_col!="fitted"){
      data$x_col<-
        test<-model@frame[,x_col]
      colnames(data)[colnames(data)=="x_col"]<-x_col
    }
    
  }
  else
  {
    data <-data.frame(
      fitted=fitted(model),
      residuals=residuals(model),
      b_CBre=model$model$b_CBre
    )
    if (x_col!="fitted"){
      data$x_col<-
        test<-model$model[,x_col]
      colnames(data)[colnames(data)=="x_col"]<-x_col
    }
  }
  
  
  data<-binned.resids (data[,x_col],
                       data$fitted-data$b_CBre, nclass=bins)$binned
  
  br<-ggplot(data=data,
             aes(x=xbar,y-ybar))+
    geom_point(aes(y=ybar))+ #Residuals
    geom_line(aes(y=se2),col="grey")+
    geom_line(aes(y=-se2),col="grey")+
    labs(title="Binned residual plot",
         y="Average residual")
  
  if (x_col=="fitted"){
    br<-br+labs(x="Estimated Pr(Ceiling Breach)")
  }
  br
}


freq_discrete_term_plot<-function(data,x_col,
                                  group_col=NA,
                                  na_remove=FALSE,
                                  caption=TRUE,rotate_text=FALSE){
  
  if(na_remove==TRUE){
    data<-data[!is.na(data[,group_col]),]
    data<-data[!is.na(data[,x_col]),]
  }
  
  if(is.na(group_col)){
    plot<-ggplot(data=data,
                 aes_string(x=x_col))+
      facet_wrap(~Term,ncol=1,scales="free_y")
  }
  else{
    plot<-ggplot(data=data,
                 aes_string(x=x_col))+
      facet_grid(as.formula(paste("Term~",group_col)),scales="free_y")
  }
  if(caption==TRUE){
    plot<-plot+labs(caption="Source: FPDS, CSIS Analysis")
  }
  
  if(rotate_text==TRUE){
    plot<-plot+theme(axis.text.x=element_text(angle=90,hjust=1))
  }
  
  plot+labs(title="Frequency by Termination")+
    geom_histogram(stat="count") +
    scale_y_continuous(labels = scales::comma)
}


freq_discrete_cbre_plot<-function(data,x_col,
                                  group_col=NA,
                                  na_remove=FALSE,
                                  caption=TRUE,
                                  rotate_text=FALSE){
  
  if(na_remove==TRUE){
    data<-data[!is.na(data[,group_col]),]
    data<-data[!is.na(data[,x_col]),]
  }
  
  if(is.na(group_col)){
    plot<-ggplot(data=data,
                 aes_string(x=x_col))
    # +
    # facet_wrap(~b_CBre,ncol=1,scales="free_y")
  }
  else{
    plot<-ggplot(data=data,
                 aes_string(x=x_col))
    # +
    # facet_grid(as.formula(paste("b_CBre~",group_col)),scales="free_y")
  }
  if(caption==TRUE){
    plot<-plot+labs(caption="Source: FPDS, CSIS Analysis")
  }
  if(rotate_text==TRUE){
    plot<-plot+theme(axis.text.x=element_text(angle=90,hjust=1))
  }
  
  plot+labs(title="Frequency by Ceiling Breach")+
    geom_histogram(stat="count") +
    scale_y_continuous(labels = scales::comma) 
  
}


freq_discrete_plot<-function(data,x_col,
                             group_col=NA,
                             na_remove=FALSE,
                             caption=TRUE,rotate_text=FALSE){
  
  if(na_remove==TRUE){
    data<-data[!is.na(data[,group_col]),]
    data<-data[!is.na(data[,x_col]),]
  }
  
  if(is.na(group_col)){
    plot<-ggplot(data=data,
                 aes_string(x=x_col))
  }
  else{
    plot<-ggplot(data=data,
                 aes_string(x=x_col))+
      facet_wrap(as.formula(paste("~",group_col)),scales="free_y")
  }
  if(caption==TRUE){
    plot<-plot+labs(caption="Source: FPDS, CSIS Analysis")
  }
  if(rotate_text==TRUE){
    plot<-plot+theme(axis.text.x=element_text(angle=90,hjust=1))
  }
  plot+labs(title="Frequency")+
    geom_histogram(stat="count") +
    scale_y_continuous(labels = scales::comma)
  
}


summary_continuous_plot<-function(data,x_col,group_col=NA,bins=20,metric="perform", log=FALSE){
  if (log==TRUE) data[,x_col]<-na_non_positive_log(data[,x_col])
  gridExtra::grid.arrange(freq_continuous_plot(data,x_col,group_col,bins=bins,caption=FALSE),
                          binned_percent_plot(data,x_col,group_col,caption=TRUE,metric=metric))
  
}


summary_double_continuous<-function(data,x_col,y_col,bins=20){
  data<-data[!is.na(data[,y_col]),]
  data<-data[!is.na(data[,x_col]),]
  data<-as.data.frame(data)
  data$interaction<-data[,x_col]*data[,y_col]
  
  
  #First a quick scatter plot for terminations by duration and ceiling
  gridExtra::grid.arrange(
    ggplot(data=data,
           aes_string(x=x_col,y=y_col))+geom_point(alpha=0.1)+
      labs(title="Distribution",
           caption="Source: FPDS, CSIS Analysis"),
    freq_continuous_plot(data,"interaction",bins=bins,caption=FALSE))
  
  
  
  #First a quick scatter plot for terminations by duration and ceiling
  gridExtra::grid.arrange(ggplot(data=data,
                                 aes_string(x=x_col,y=y_col))+geom_point(alpha=0.1)+facet_grid(CBre~.)+
                            labs(title="Distribution by Breach",
                                 caption="Source: FPDS, CSIS Analysis"),
                          
                          
                          #First a quick scatter plot for terminations by duration and ceiling
                          ggplot(data=data,
                                 aes_string(x=x_col,y=y_col))+geom_point(alpha=0.1)+facet_grid(Term~.)+
                            labs(title="Distribution by Termination"),
                          
                          ncol=2
  )
  
  binned_double_percent_plot(data,x_col,y_col,bins)
  # min_i<-min(data[,"interaction"])
  # max_i<-max(data[,"interaction"])
  # 
  # gridExtra::grid.arrange(binned_percent_plot(data,x_col,caption=FALSE)+xlim(min_i,max_i),
  #                         binned_percent_plot(data,y_col,caption=FALSE)+xlim(min_i,max_i),
  #                         binned_percent_plot(data,"interaction",caption=TRUE)+xlim(min_i,max_i))
  
}

summary_discrete_plot<-function(data,x_col,group_col=NA,rotate_text=FALSE,metric="perform"){
  if(is.na(group_col)){
    output<-list(table(unlist(data[,x_col])),
                 table(unlist(data[,x_col]),data$CBre),
                 table(unlist(data[,x_col]),data$Term))
    
  }
  else{
    if(is.numeric(data[,x_col])) stop(paste(xcol," is numeric."))
    output<-list(table(unlist(data[,x_col]),unlist(data[,group_col])),
                 table(unlist(data[,x_col]),unlist(data[,group_col]),data$CBre),
                 table(unlist(data[,x_col]),unlist(data[,group_col]),data$Term))
    
  }
  
  gridExtra::grid.arrange(freq_discrete_plot(data,x_col,group_col,caption=FALSE,rotate_text=rotate_text),
                          discrete_percent_plot(data,x_col,group_col,caption=TRUE,rotate_text=rotate_text,metric=metric))
  
  output
}


freq_continuous_term_plot<-function(data,x_col,group_col=NA,bins=20,
                                    caption=TRUE){
  if(is.na(group_col)){
    plot<-ggplot(data=data,
                 aes_string(x=x_col))+
      facet_wrap(~Term,ncol=1,scales="free_y")
  }
  else{
    plot<-ggplot(data=data,
                 aes_string(x=x_col))+geom_histogram(bins=bins) +
      facet_grid(as.formula(paste("Term~",group_col)),scales="free_y")
    
  }
  
  if(caption==TRUE){
    plot<-plot+labs(caption="Source: FPDS, CSIS Analysis")
  }
  plot+labs(title="Frequency by Termination")+
    scale_y_continuous(labels = scales::comma) + 
    geom_histogram(bins=bins) 
}

freq_continuous_plot<-function(data,x_col,group_col=NA,bins=20,
                               caption=TRUE){
  if(is.na(group_col)){
    plot<-ggplot(data=data,
                 aes_string(x=x_col))
  }
  else{
    plot<-ggplot(data=data,
                 aes_string(x=x_col))+geom_histogram(bins=bins)+
      facet_wrap(as.formula(paste("~",group_col)),scales="free_y")
    
  }
  
  if(caption==TRUE){
    plot<-plot+labs(caption="Source: FPDS, CSIS Analysis")
  }
  
  plot+labs(title="Frequency")+
    scale_y_continuous(labels = scales::comma) + 
    geom_histogram(bins=bins) 
}


freq_continuous_cbre_plot<-function(data,x_col,group_col=NA,bins=20,
                                    caption=TRUE){
  if(is.na(group_col)){
    plot<-ggplot(data=data,
                 aes_string(x=x_col))+
      facet_wrap(~CBre,ncol=1,scales="free_y")
  }
  else{
    plot<-ggplot(data=data,
                 aes_string(x=x_col))+geom_histogram(bins=bins) +
      facet_grid(as.formula(paste("CBre~",group_col)),scales="free_y")
    
  }
  
  if(caption==TRUE){
    plot<-plot+labs(caption="Source: FPDS, CSIS Analysis")
  }
  plot+labs(title="Frequency by Ceiling Breach")+
    scale_y_continuous(labels = scales::comma) + 
    geom_histogram(bins=bins) 
}


binned_percent_plot<-function(data,x_col,group_col=NA,bins=20,caption=TRUE,metric="perform"){
  data<-data[!is.na(data[,x_col]),]
  if(is.na(group_col)){
    data$bin_x<-bin_df(data,x_col,bins=bins)
    data<-data %>% group_by(bin_x)
    
    
    if(metric=="perform"){
      cbre<-data %>% summarise_ (   mean_y = "mean(b_CBre)"   
                                    , mean_x =  paste( "mean(" ,  x_col  ,")"  ))  
      term<-data %>% summarise_ (   mean_y = "mean(b_Term)"   
                                    , mean_x =  paste( "mean(" ,  x_col  ,")"  ))  
      term$output<-"Terminations"
      cbre$output<-"Ceiling Breaches"
      data<-rbind(cbre,term)
      data$output<-factor(data$output,c("Ceiling Breaches","Terminations"))  
    }
    else if (metric=="comp"){
      comp<-data %>% summarise_ (   mean_y = "mean(b_Comp)"   
                                    , mean_x =  paste( "mean(" ,  x_col  ,")"  ))  
      offer<-data %>% summarise_ (   mean_y = "mean(l_Offr)"   
                                     , mean_x =  paste( "mean(" ,  x_col  ,")"  ))  
      comp$output<-"Competed"
      offer$output<-"Offers (logged)"
      data<-rbind(comp,offer)
      data$output<-factor(data$output,c("Competed","Offers (logged)"))  
    }
    
    plot<-ggplot(data=data,
                 aes(y=mean_y,x=mean_x))+facet_wrap(~output,scales="free_y")
  }
  else{
    data<-data[!is.na(data[,group_col]),]
    data$bin_x<-bin_df(data,rank_col=x_col,group_col=group_col,bins=bins)
    data<-data %>%
      group_by_("bin_x",group_col)
    
    
    if(metric=="perform"){
      cbre<-data %>% summarise_ (   mean_y = "mean(b_CBre)"   
                                    , mean_x =  paste( "mean(" ,  x_col  ,")"  ))  
      term<-data %>% summarise_ (   mean_y = "mean(b_Term)"   
                                    , mean_x =  paste( "mean(" ,  x_col  ,")"  ))  
      term$output<-"Term."
      cbre$output<-"C. Bre."
      data<-rbind(cbre,term)
      data$output<-factor(data$output,c("C. Bre.","Term."))  
    }
    else if (metric=="comp"){
      comp<-data %>% summarise_ (   mean_y = "mean(b_Comp)"   
                                    , mean_x =  paste( "mean(" ,  x_col  ,")"  ))  
      offer<-data %>% summarise_ (   mean_y = "mean(l_Offr)"   
                                     , mean_x =  paste( "mean(" ,  x_col  ,")"  ))  
      comp$output<-"Comp."
      offer$output<-"Offers (logged)"
      data<-rbind(comp,offer)
      data$output<-factor(data$output,c("Comp.","Offers (logged)"))  
    }
    
    plot<-ggplot(data=data,
                 aes(y=mean_y,x=mean_x))+
      facet_grid(as.formula(paste("output~",group_col)),scales="free_y")
  }
  if(caption==TRUE){
    plot<-plot+labs(caption="Source: FPDS, CSIS Analysis")
  }
  plot+geom_point()
}


bin_group<-function(data,bin_col,bins=20){
  data$bin<-bin_df(data,rank_col=bin_col,bins=bins)
  data<-data %>%
    group_by(bin)
  term<-data %>% summarise_ (   mean_y = "mean(b_Term)"   
                                , mean_x =  paste( "mean(" ,  bin_col  ,")"  ))  
  cbre<-data %>% summarise_ (   mean_y = "mean(b_CBre)"   
                                , mean_x =  paste( "mean(" ,  bin_col  ,")"  ))  
  term$output<-"Term."
  cbre$output<-"C. Bre."
  data<-rbind(term,cbre)
  data$bin_col<-bin_col
  data
}

binned_double_percent_plot<-function(data,x_col,y_col,bins=20,caption=TRUE){
  data<-data[!is.na(data[,x_col]),]
  data<-data[!is.na(data[,y_col]),]
  data<-as.data.frame(data)
  data$interaction<-data[,x_col]*data[,y_col]
  data<-rbind(bin_group(data,x_col,bins),
              bin_group(data,y_col,bins),
              bin_group(data,"interaction",bins))
  
  data$bin_col<-factor(data$bin_col,c(x_col,y_col,"interaction"))
  plot<-ggplot(data=data,
               aes(y=mean_y,x=mean_x))+
    facet_grid(output~bin_col,scales="free_y")
  
  if(caption==TRUE){
    plot<-plot+labs(caption="Source: FPDS, CSIS Analysis")
  }
  plot+geom_point()
}


binned_percent_term_plot<-function(data,x_col,group_col=NA,bins=20,caption=TRUE){
  data<-data[!is.na(data[,x_col]),]
  if(is.na(group_col)){
    data$bin_x<-bin_df(data,x_col,bins=bins)
    plot<-ggplot(data=data %>%
                   group_by(bin_x) %>%
                   summarise_ (   mean_Term = "mean(b_Term)"   
                                  , mean_x =  paste( "mean(" ,  x_col  ,")"  ))     ,
                 aes(y=mean_Term,x=mean_x))
  }
  else{
    data<-data[!is.na(data[,group_col]),]
    data$bin_x<-bin_df(data,rank_col=x_col,group_col=group_col,bins=bins)
    plot<-ggplot(data=data %>%
                   group_by_("bin_x",group_col) %>%
                   summarise_ (   mean_Term = "mean(b_Term)"   
                                  , mean_x =  paste( "mean(" ,  x_col  ,")"  ))     ,
                 aes(y=mean_Term,x=mean_x))+
      facet_wrap(as.formula(paste("~",group_col)))
  }
  if(caption==TRUE){
    plot<-plot+labs(caption="Source: FPDS, CSIS Analysis")
  }
  plot+geom_point()+
    labs(title="Percent Terminated")
}



binned_percent_cbre_plot<-function(data,x_col,group_col=NA,bins=20,caption=TRUE){
  data<-data[!is.na(data[,x_col]),]
  if(is.na(group_col)){
    data$bin_x<-bin_df(data,x_col,bins=bins)
    plot<-ggplot(data=data %>%
                   group_by(bin_x) %>%
                   summarise_ (   mean_CBre = "mean(b_CBre)"   
                                  , mean_x =  paste( "mean(" ,  x_col  ,")"  ))     ,
                 aes(y=mean_CBre,x=mean_x))
  }
  else{
    data<-data[!is.na(data[,group_col]),]
    data$bin_x<-bin_df(data,rank_col=x_col,group_col=group_col,bins=bins)
    plot<-ggplot(data=data %>%
                   group_by_("bin_x",group_col) %>%
                   summarise_ (   mean_CBre = "mean(b_CBre)"   
                                  , mean_x =  paste( "mean(" ,  x_col  ,")"  ))     ,
                 aes(y=mean_CBre,x=mean_x))+
      facet_wrap(as.formula(paste("~",group_col)))
  }
  if(caption==TRUE){
    plot<-plot+labs(caption="Source: FPDS, CSIS Analysis")
  }
  plot+geom_point()+
    labs(title="Percent Ceiling Breaches")
}

discrete_percent_term_plot<-function(data,x_col,group_col=NA,caption=TRUE){
  data<-data[!is.na(data[,x_col]),]
  if(is.na(group_col)){
    plot<-ggplot(data=data %>%
                   group_by_(x_col) %>%
                   summarise (   mean_Term = mean(b_Term)),
                 aes_string(y="mean_Term",x=x_col))
    
  }
  else{
    data<-data[!is.na(data[,group_col]),]
    plot<-ggplot(data=data %>%
                   group_by_(x_col,group_col) %>%
                   summarise (   mean_Term = mean(b_Term)),
                 aes_string(y="mean_Term",x=x_col))+
      facet_wrap(as.formula(paste("~",group_col)))
  }    
  if(caption==TRUE){
    plot<-plot+labs(caption="Source: FPDS, CSIS Analysis")
  }
  plot+geom_point()+
    labs(title="Percent Terminated")
  
}

discrete_percent_cbre_plot<-function(data,x_col,group_col=NA,caption=TRUE){
  data<-data[!is.na(data[,x_col]) & !is.na(data[,"b_CBre"]),]
  if(is.na(group_col)){
    plot<-ggplot(data=data %>%
                   group_by_(x_col) %>%
                   summarise (   mean_CBre = mean(b_CBre)),
                 aes_string(y="mean_CBre",x=x_col))
    
  }
  else{
    data<-data[!is.na(data[,group_col]),]
    plot<-ggplot(data=data %>%
                   group_by_(x_col,group_col) %>%
                   summarise (   mean_CBre = mean(b_CBre)),
                 aes_string(y="mean_CBre",x=x_col))+
      facet_wrap(as.formula(paste("~",group_col)))
    
  }
  
  if(caption==TRUE){
    plot<-plot+labs(caption="Source: FPDS, CSIS Analysis")
  }
  plot+geom_point()+
    labs(title="Percent Ceiling Breaches")
  
}

discrete_percent_plot<-function(data,x_col,group_col=NA,bins=20,caption=TRUE,rotate_text=FALSE,metric="perform"){
  data<-data[!is.na(data[,x_col]),]
  if(is.na(group_col)){
    data<-data %>% group_by_(x_col)
    
    
    
    
    if(metric=="perform"){
      cbre<-data %>% summarise_ (   mean_y = "mean(b_CBre)"   )
      term<-data %>% summarise_ (   mean_y = "mean(b_Term)"   )
      term$output<-"Terminations"
      cbre$output<-"Ceiling Breaches"
      data<-rbind(cbre,term)
      data$output<-factor(data$output,c("Ceiling Breaches","Terminations"))  
    }
    else if (metric=="comp"){
      comp<-data %>% summarise_ (   mean_y = "mean(b_Comp)"   )  
      offer<-data %>% summarise_ (   mean_y = "mean(l_Offr)"   )  
      comp$output<-"Competed"
      offer$output<-"Offers (logged)"
      data<-rbind(comp,offer)
      data$output<-factor(data$output,c("Competed","Offers (logged)"))  
    }
    
    
    plot<-ggplot(data=data,
                 aes_string(y="mean_y",x=x_col))+facet_wrap(~output)
  }
  else{
    data<-data[!is.na(data[,group_col]),]
    data<-data %>%
      group_by_(x_col,group_col)
    
    if(metric=="perform"){
      cbre<-data %>% summarise_ (   mean_y = "mean(b_CBre)"   )  
      term<-data %>% summarise_ (   mean_y = "mean(b_Term)"   )  
      term$output<-"Term."
      cbre$output<-"C. Bre."
      data<-rbind(cbre,term)
      data$output<-factor(data$output,c("C. Bre.","Term."))  
    }
    else if (metric=="comp"){
      comp<-data %>% summarise_ (   mean_y = "mean(b_Comp)"   )  
      offer<-data %>% summarise_ (   mean_y = "mean(l_Offr)"  )  
      comp$output<-"Comp."
      offer$output<-"Offers (logged)"
      data<-rbind(comp,offer)
      data$output<-factor(data$output,c("Comp.","Offers (logged)"))  
    }
    
    plot<-ggplot(data=data,
                 aes_string(y="mean_y",x=x_col))+
      facet_grid(as.formula(paste("output~",group_col)),scales="free_y")+
      theme(axis.text.x=element_text(angle=90,hjust=1))
  }
  if(caption==TRUE){
    plot<-plot+labs(caption="Source: FPDS, CSIS Analysis")
  }
  if(rotate_text==TRUE){
    plot<-plot+theme(axis.text.x=element_text(angle=90,hjust=1))
  }
  
  plot+geom_point()
}

fitted_term_model<-function(data,x_col){
  ggplot(data=data,
         aes_string(y="j_Term",x=x_col))+geom_point(alpha=0.01)+scale_y_sqrt() +
    labs(title="Fitted Linear Model", caption="Source: FPDS, CSIS Analysis")
}

fitted_cbre_model<-function(data,x_col){
  ggplot(data=data,
         aes_string(y="j_CBre",x=x_col))+geom_point(alpha=0.01)+scale_y_sqrt() +
    labs(title="Fitted Linear Model", caption="Source: FPDS, CSIS Analysis")
}


discrete_fitted_term_model<-function(data,x_col){
  ggplot(data=data,
         aes_string(y="j_Term",x=x_col))+geom_jitter(alpha=0.01,height=0)+scale_y_sqrt() +
    labs(title="Fitted Linear Model", caption="Source: FPDS, CSIS Analysis")
}


test<-c(1,2,3,4,5)
sd(test)
mean(test)
arm::rescale(test)

na_non_positive_log<-function(x){
  x[x<=0]<-NA
  log(x)
}

centered_log_description<-function(x,units=NA){
  x<-na_non_positive_log(x)
  xbar<-mean(x,na.rm=TRUE)
  xsd<-sd(x,na.rm=TRUE)
  paste("The variable is rescaled, by subtracting its mean (",
        format(xbar,digits=3,big.mark=","),
        ") and dividing by its standard deviation doubled (",
        format(2*xsd,digits=3,big.mark=","),
        "). Values of -1, -0.5, 0, 0.5, and 1 correspond to ",
        format(exp(xbar-2*xsd),digits=2,big.mark=","), ", ",
        format(exp(xbar-xsd),digits=2,big.mark=","), ", ",
        format(exp(xbar),digits=2,big.mark=","),", ",
        format(exp(xbar+xsd),digits=2,big.mark=","),", and ",
        format(exp(xbar+2*xsd),digits=2,big.mark=","),
        ifelse(is.na(units),"",paste("",units)),
        " respectively.",sep="")
}
# Old eversion
# centered_log_description<-function(x,units=NA){
#   xbar<-mean(x,na.rm=TRUE)
#   xsd<-sd(x,na.rm=TRUE)
#   paste("The variable is centered, by subtracting its mean (",
#         format(xbar,digits=3,big.mark=","),
#         ") and dividing by its standard deviation (",
#         format(xsd,digits=3,big.mark=","),
#         "). Values of -1, 0, 1, and 2 correspond to ",
#         format(exp(xbar-xsd),digits=2,big.mark=","), ", ",
#         format(exp(xbar),digits=2,big.mark=","),", ",
#         format(exp(xbar+xsd),digits=2,big.mark=","),", and ",
#         format(exp(xbar+2*xsd),digits=2,big.mark=","),
#         ifelse(is.na(units),"",paste("",units)),
#         " respectively.",sep="")
# }


centered_description<-function(x,units=NA){
  xbar<-mean(x,na.rm=TRUE)
  xsd<-sd(x,na.rm=TRUE)
  paste("The variable is rescaled, by subtracting its mean (",
        format(xbar,digits=3,big.mark=","),
        ") and dividing by its standard deviation doubled(",
        format(2*xsd,digits=3,big.mark=","),
        "). Values of -1, -0.5, 0, 0.5, and 1 correspond to ",
        format(xbar-2*xsd,digits=2,big.mark=","), ", ",
        format(xbar-xsd,digits=2,big.mark=","), ", ",
        format(xbar,digits=2,big.mark=","),", ",
        format(xbar+xsd,digits=2,big.mark=","),", and ",
        format(xbar+2*xsd,digits=2,big.mark=","),
        ifelse(is.na(units),"",paste("",units)),
        " respectively.",sep="")
}


NA_stats<-function(data,col,exclude_before_2008=TRUE){
  if(exclude_before_2008==TRUE) before2008<-data$StartCY<2008
  paste("Data is missing for ",
        format(sum(is.na(data[!before2008,col]))/nrow(data[!before2008,col]),digits=3),
        " of records and ",
        format(sum(data$Action_Obligation[is.na(data[!before2008,col])],na.rm=TRUE)/
                 sum(data$Action_Obligation[!before2008],na.rm=TRUE),digits=3),
        " of obligated dollars."
        ,sep="")
  
}


residual_compare<-function(model1_old,model1_new,model2_old,model2_new,col,x_axis_name,bins=20){
  if(col %in% model_colnames(model1_old) & col %in% model_colnames(model2_old)){
    gridExtra::grid.arrange(residuals_plot(model1_old,col,bins=bins)+
                              labs(x=x_axis_name),
                            residuals_plot(model1_new,col,bins=bins)+
                              labs(x=x_axis_name),
                            residuals_plot(model2_old,col,bins=bins)+
                              labs(x=x_axis_name),
                            residuals_plot(model2_new,col,bins=bins)+
                              labs(x=x_axis_name),
                            ncol=2)
  }
  else{#If the variable is just in the new model
    gridExtra::grid.arrange(residuals_plot(model1_new,col,bins=bins)+
                              labs(x=x_axis_name),
                            residuals_plot(model2_new,col,bins=bins)+
                              labs(x=x_axis_name),
                            ncol=1)
    
  }
}


deviance_stats<-function(model,model_name){
  # if(class(model)[1]=="glmerMod")
  # { 
  #   getME(model,"devcom")$dev
  #   output<-data.frame(model=model_name,
  #                      deviance=model$deviance,
  #                      null.deviance=model$null.deviance,
  #                      difference=model$null.deviance-model$deviance)
  #   
  # }
  # else
  # {
  output<-data.frame(model=model_name,
                     deviance=model$deviance,
                     null.deviance=model$null.deviance,
                     difference=model$null.deviance-model$deviance)
  # }
  output
  
}

model_colnames<-function(model){
  if(class(model)[1]=="glmerMod")
  { 
    output<-colnames(model@frame)
    
  }
  else
  {
    output<-colnames(model$model)
  }
  output
}



summary_residual_compare<-function(model1_old,model1_new,
                                   model2_old=NULL,model2_new=NULL,
                                   skip_vif=FALSE,bins=5){
  #Plot the fitted values vs actual results
  
  if(!is.null(model2_new)){
    
    if(!is.na(bins)){
      #Plot residuals versus fitted
      if("c_OffCri" %in% model_colnames(model1_old)) bins<-bins+5
      if("cl_Ceil" %in% model_colnames(model1_old)) bins<-bins+10
      if("cl_Days" %in% model_colnames(model1_old)) bins<-bins+5
      
    }      
    
    gridExtra::grid.arrange(binned_fitted_versus_residuals(model1_old,bins=bins),
                            binned_fitted_versus_residuals(model1_new,bins=bins),
                            binned_fitted_versus_residuals(model2_old,bins=bins),
                            binned_fitted_versus_residuals(model2_new,bins=bins),
                            ncol=2)
    #This only works once you have some continuous variables or set a small bin count
    
    gridExtra::grid.arrange(residuals_plot(model1_old,bins=bins),
                            residuals_plot(model1_new,bins=bins),
                            residuals_plot(model2_old,bins=bins),
                            residuals_plot(model2_new,bins=bins),
                            ncol=2)
    
    
    
    # if("c_OffCri" %in% model_colnames(model1_new) & "c_OffCri" %in% model_colnames(model2_new)){
    # residual_compare(model1_old,model1_new,model2_old,model2_new,"c_OffCri","Office Crisis %",10)
    # }
    
    if("cl_Ceil" %in% model_colnames(model1_new)){
      residual_compare(model1_old,model1_new,model2_old,model2_new,"cl_Ceil","Centered Log(Ceiling)",20)
    }
    
    if("cl_Days" %in% model_colnames(model1_new)){
      residual_compare(model1_old,model1_new,model2_old,model2_new,"cl_Days","Centered Log(Days)",10)
    }
    output<-NULL
    if(class(model1_new)=="glmerMod" & class(model2_new)=="glmerMod" & skip_vif==FALSE) 
    { 
      # If the fit is singular or near-singular, there might be a higher chance of a false positive (we’re not necessarily screening out gradient and Hessian checking on singular directions properly); a higher chance that the model has actually misconverged (because the optimization problem is difficult on the boundary); and a reasonable argument that the random effects model should be simplified.
      # https://rstudio-pubs-static.s3.amazonaws.com/33653_57fc7b8e5d484c909b615d8633c01d51.html
      # The definition of singularity is that some of the constrained parameters of the random effects theta parameters are on the boundary (equal to zero, or very very close to zero, say <10−6):
      m1t<-getME(model1_new,"theta")
      m1l<-getME(model1_new,"lower")
      m2t<-getME(model2_new,"theta")
      m2l<-getME(model2_new,"lower")
      # min(m2t[ll==0])
      
      # min(m2t[ll==0])
      output<-list(car::vif(model1_new),car::vif(model2_new),
                   m1t[m1l==0],
                   m2t[m2l==0],
                   model1_new@optinfo$conv$lme4$messages,
                   model2_new@optinfo$conv$lme4$messages
      )
    } 
    else if ((class(model1_new)!="glmerMod" & class(model2_new)!="glmerMod") &
             (class(model1_old)!="glmerMod" & class(model2_old)!="glmerMod") & 
             skip_vif==FALSE){
      output<-list(rbind(deviance_stats(model1_old,"model1_old"),
                         deviance_stats(model1_new,"model1_new"),
                         deviance_stats(model2_old,"model2_old"),
                         deviance_stats(model2_new,"model2_new")),
                   car::vif(model1_new),car::vif(model2_new)
      )
    }
    
  } else{
    gridExtra::grid.arrange(binned_fitted_versus_residuals(model1_old,bins=bins),
                            binned_fitted_versus_residuals(model1_new,bins=bins),
                            ncol=2)
    
    
    
    #This only works once you have some continuous variables o
    
    if(!is.na(bins)){
      #Plot residuals versus fitted
      if("c_OffCri" %in% model_colnames(model1_old)) bins<-bins+5
      if("cl_Ceil" %in% model_colnames(model1_old)) bins<-bins+10
      if("cl_Days" %in% model_colnames(model1_old)) bins<-bins+5
      
      
    } 
    gridExtra::grid.arrange(residuals_plot(model1_old,bins=bins),
                            residuals_plot(model1_new,bins=bins),
                            ncol=2)
    
    
    # if("c_OffCri" %in% model_colnames(model1_new) & "c_OffCri" %in% model_colnames(model2_new)){
    # residual_compare(model1_old,model1_new,model2_old,model2_new,"c_OffCri","Office Crisis %",10)
    # }
    
    # if("cl_Ceil" %in% model_colnames(model1_new)){
    #   residual_compare(model1_old,model1_new,model2_old,model2_new,"cl_Ceil","Centered Log(Ceiling)",20)
    # }
    # 
    # if("cl_Days" %in% model_colnames(model1_new)){
    #   residual_compare(model1_old,model1_new,model2_old,model2_new,"cl_Days","Centered Log(Days)",10)
    # }
    output<-NULL
    if(class(model1_new)=="glmerMod") 
    { 
      # If the fit is singular or near-singular, there might be a higher chance of a false positive (we’re not necessarily screening out gradient and Hessian checking on singular directions properly); a higher chance that the model has actually misconverged (because the optimization problem is difficult on the boundary); and a reasonable argument that the random effects model should be simplified.
      # https://rstudio-pubs-static.s3.amazonaws.com/33653_57fc7b8e5d484c909b615d8633c01d51.html
      # The definition of singularity is that some of the constrained parameters of the random effects theta parameters are on the boundary (equal to zero, or very very close to zero, say <10−6):
      m1t<-getME(model1_new,"theta")
      m1l<-getME(model1_new,"lower")
      # min(m2t[ll==0])
      
      # min(m2t[ll==0])
      output<-list(car::vif(model1_new),
                   m1t[m1l==0],
                   model1_new@optinfo$conv$lme4$messages
      )
    } 
    else if (class(model1_new)!="glmerMod" & class(model1_old)!="glmerMod" &
             skip_vif==FALSE){
      output<-list(rbind(deviance_stats(model1_old,"model1_old"),
                         deviance_stats(model1_new,"model1_new")),
                   car::vif(model1_new)
      )
    }
  }
  
  
  
  output
  
}


glmer_examine<-function(model,display=FALSE){
  if(display==TRUE) display(model)
  output<-car::vif(model)
  if(class(model)[1]=="glmerMod") 
  { 
    
    # If the fit is singular or near-singular, there might be a higher chance of a false positive (we’re not necessarily screening out gradient and Hessian checking on singular directions properly); a higher chance that the model has actually misconverged (because the optimization problem is difficult on the boundary); and a reasonable argument that the random effects model should be simplified.
    # https://rstudio-pubs-static.s3.amazonaws.com/33653_57fc7b8e5d484c909b615d8633c01d51.html
    # The definition of singularity is that some of the constrained parameters of the random effects theta parameters are on the boundary (equal to zero, or very very close to zero, say <10−6):
    t<-getME(model,"theta")
    l<-getME(model,"lower")
    
    # min(m2t[ll==0])
    
    # min(m2t[ll==0])
    if(!is.null(model@optinfo$conv$lme4$messages)){
      output<-list(car::vif(model),
                   icc(model),
                   model@optinfo$conv$lme4$messages,
                   t[l==0])
    }
    else{
      output<-list(car::vif(model),
                   icc(model),
                   t[l==0]
      )
    }
  } 
  output
}

get_icc<-function(model,display=FALSE){
  ############################################################################################################################
  #Keep Calm and Learn Multilevel Logistic Modeling: A Simplified Three-Step Procedure for Beginners Using SPSS, Stata, and R#
  ############################################################################################################################
  # icc <- model@theta^2/ (model@theta^2 + (3.14159^2/3))
  # icc
  if(display==TRUE) display(model)
  if(!is.null(model@optinfo$conv$lme4$messages)){
    output<-list(icc(model),
                 model@optinfo$conv$lme4$messages)
  }
  else{
    output<-icc(model)
  }
  output
}


summary_regression_compare<-function(model_old,model_new){
  
  arm::residual.plot(fitted(model_old),
                     resid(model_old),
                     sigma(model_old)
  )
  arm::residual.plot(fitted(model_new),
                     resid(model_new),
                     sigma(model_new)
  )
  
}


get_pars<-function(model){
  if (isLMM(model)) {
    pars <- getME(model,"theta")
  } else {
    ## GLMM: requires both random and fixed parameters
    pars <- getME(model, c("theta","fixef"))
  }
  pars
}


# #Extract statistic information of the 15 discrete variables and generate dataframe    
# name_categorical <- c("CompOffr","Veh","PricingFee","UCA","Intl","Term",
#                      "Dur","Ceil","CBre","PSR","Urg","FxCb","Fee","CRai",
#                      "NoComp")   #list of all categorial and binary variables
# 

# memory.limit(56000)

statsummary_discrete <- function(x, 
                                 contract,accuracy=0.01,
                                 value_col=NULL){      #input(x: name of the discrete variable, contract：name of the dataframe)
  if(is.null(value_col)){
    if("Action_Obligation.OMB20_GDP18" %in% colnames(contract)){
      value_col<-"Action_Obligation.OMB20_GDP18"
    }
    else if("Action_Obligation" %in% colnames(contract)){
      value_col<-"Action_Obligation"
    }
    else if("Action_Obligation.Then.Year" %in% colnames(contract)){
      value_col<-"Action_Obligation.Then.Year"
    }
    else if("Action.Obligation" %in% colnames(contract)){
      value_col<-"Action.Obligation"
    }
    else stop("No standard value column in dataset, pass the desired column to oolumn_name.")
  }
  else if(!value_col %in% colnames(contract) ){
    stop(paste(value_col,"not present in contract."))
  }
  if(!is.factor(contract[[x]])) contract[[x]]<-factor(contract[[x]])
  unique_value_list <- levels(contract[[x]])
  categories <- c(unique_value_list)
  Percent_Actions <- c()
  Percent_Records <- c()
  for (i in 1:length(unique_value_list)){
    Percent_Records <- c(Percent_Records, percent(round(sum(contract[[x]] == unique_value_list[i],na.rm = TRUE)/nrow(contract),5),accuracy = accuracy))
    Percent_Actions <- c(Percent_Actions, percent(round(sum(contract[contract[[x]] == unique_value_list[i],value_col],na.rm = TRUE)/sum(contract[,value_col],na.rm = TRUE),5),accuracy = accuracy))    
  }
  if(sum(is.na(contract[[x]]))>1){#If any NA}
    categories <- c(unique_value_list,"NA")
    Percent_Records <- c(Percent_Records, percent(round(sum(is.na(contract[[x]]))/nrow(contract),5),accuracy = .01))
    Percent_Actions <- c(Percent_Actions, percent(round(sum(contract[[value_col]][is.na(contract[[x]])],na.rm = TRUE)/sum(contract[,value_col],na.rm = TRUE),5),accuracy = accuracy))
  }
  name_categorical <- c(x,"%of records","% of $s")
  categories <- as.data.frame(cbind(categories,Percent_Records,Percent_Actions))
  colnames(categories) <- name_categorical
  return(categories)
}

#Extract statistic information of the 26 continuous variables and generate dataframe      
name_Continuous <- c("Action_Obligation","UnmodifiedContractBaseAndAllOptionsValue",
                     "ChangeOrderBaseAndAllOptionsValue","UnmodifiedDays",
                     "UnmodifiedNumberOfOffersReceived",
                     "capped_def6_ratio_lag1","capped_def5_ratio_lag1","capped_def4_ratio_lag1","capped_def3_ratio_lag1","capped_def2_ratio_lag1",
                     "def6_HHI_lag1","def5_HHI_lag1","def4_HHI_lag1","def3_HHI_lag1","def2_HHI_lag1",
                     "def6_obl_lag1","def5_obl_lag1","def4_obl_lag1","def3_obl_lag1","def2_obl_lag1",
                     "US6_avg_sal_lag1","US5_avg_sal_lag1","US4_avg_sal_lag1","US3_avg_sal_lag1","US2_avg_sal_lag1"
)

statsummary_continuous <- function(x, contract,log=TRUE,digits=3){       #input(x: namelist of all continuous variables contract: name of the data frame)
  continuous_Info <- data.frame(matrix(ncol = 9,nrow = 0))
  colnames(continuous_Info) <- c("Variable_Name","Min","Max","Median","Logarithmic Mean",
                                 "1 unit below","1 unit above","% of records NA", 
                                 "% of Obligations to NA records")
  contract<-as.data.frame(contract)
  if(log==FALSE)
    colnames(continuous_Info)[colnames(continuous_Info)=="Logarithmic Mean"]<-"Arithmatic Mean"  
  for (i in x){
    Percent_NA <- round(sum(is.na(contract[[i]]))/nrow(contract),5)
    Percent_Ob <- round(sum(contract$Action_Obligation[is.na(contract[[i]])],na.rm = TRUE)/sum(contract$Action_Obligation,na.rm = TRUE),5)
    transformed_i<-contract[[i]]
    transformed_i[transformed_i==0] <- NA
    transformed_i <- log(contract[[i]])
    maxval <- round(max(contract[[i]],na.rm = TRUE), digits)
    medianval <- round(median(contract[[i]],na.rm = TRUE), digits)
    minval <- round(min(contract[[i]],na.rm = TRUE), digits)
    meanval <- round(mean(contract[[i]],na.rm = TRUE), digits)
    meanlog <- round(exp(mean(transformed_i,na.rm = TRUE)), digits)
    sdval <- sd(contract[[i]],na.rm = TRUE)
    sdlog <- sd(transformed_i,na.rm = TRUE)
    unitaboveval <- round(mean(contract[[i]],na.rm = TRUE)+2*sdval,digits)
    unitbelowval <- round(mean(contract[[i]],na.rm = TRUE)-2*sdval,digits)
    unitabovelog <- round(exp(mean(transformed_i,na.rm = TRUE)+2*sdlog),digits)
    unitbelowlog <- round(exp(mean(transformed_i,na.rm = TRUE)-2*sdlog),digits)
    Percent_NA <- round(sum(is.na(contract[[i]]))/nrow(contract),5)
    Percent_Ob <- round(sum(contract$Action_Obligation[is.na(contract[[i]])],na.rm = TRUE)/sum(contract$Action_Obligation,na.rm = TRUE),5)
    if(log==TRUE)
      newrow <- c(i, minval, maxval, medianval, meanlog, unitbelowlog, unitabovelog,
                  Percent_NA, Percent_Ob)
    else 
      newrow <- c(i, minval, maxval, medianval, meanval, unitbelowval, unitaboveval,
                  Percent_NA, Percent_Ob)
    continuous_Info[nrow(continuous_Info)+1,] <- newrow
  }
  # formating
  continuous_Info[,-1] <- lapply(continuous_Info[,-1], function(x) as.numeric(x))
  continuous_Info$aboveMax[continuous_Info$Max < continuous_Info$`1 unit above`] <- " * "
  continuous_Info$belowMin[continuous_Info$Min > continuous_Info$`1 unit below`] <- " * "
  # editing percentage values
  continuous_Info[,8:9] <- lapply(continuous_Info[,8:9], function(x) percent(x))#, accuracy = .01))
  continuous_Info[,2:7] <- lapply(continuous_Info[,2:7], function(x) comma_format(accuracy = .001)(x))#big.mark = ',',
  continuous_Info$`% of Obligations to NA records`[continuous_Info$`% of Obligations to NA records`=="NA%"] <- NA
  
  continuous_Info$`1 unit below` <- paste(continuous_Info$`1 unit below`,continuous_Info$belowMin)
  continuous_Info$`1 unit below` <- gsub("NA","",continuous_Info$`1 unit below`)
  continuous_Info$`1 unit above` <- paste(continuous_Info$`1 unit above`,continuous_Info$aboveMax)
  continuous_Info$`1 unit above` <- gsub("NA","",continuous_Info$`1 unit above`)
  continuous_Info[,c("belowMin","aboveMax")] <- NULL
  return(continuous_Info)
}














#function for making grouped bar plot for each categorical variable, data set used in function "Data/transformed_def.Rdata"
name_categorical <- c("CompOffr","Veh","PricingFee","UCA","Intl","Term",
                      "Dur","Ceil","CBre","PSR","Urg","FxCb","Fee","CRai",
                      "NoComp")

#Input(x: name of the categorical variable needs plot; contract: name of the dataframe)
#Output: grouped bar plot for the selected variable;
grouped_barplot <- function(x, contract,
                            value_col=NULL) {
  
  if(is.null(value_col)){
    if("Action_Obligation.OMB20_GDP18" %in% colnames(contract)){
      value_col<-"Action_Obligation.OMB20_GDP18"
    }
    else if("Action_Obligation" %in% colnames(contract)){
      value_col<-"Action_Obligation"
    }
    else if("Action_Obligation.Then.Year" %in% colnames(contract)){
      value_col<-"Action_Obligation.Then.Year"
    }
    else if("Action.Obligation" %in% colnames(contract)){
      value_col<-"Action.Obligation"
    }
    else stop("No standard value column in dataset, pass the desired column to oolumn_name.")
  }
  else if(!value_col %in% colnames(contract) ){
    stop(paste(value_col,"not present in contract."))
  }
  memory.limit(56000)
  #perparing data for ploting
  name_Info <- statsummary_discrete(x, contract,value_col=value_col)
  name_Info_noNAN <- subset(name_Info, name_Info[, 1] != "NA")
  name_Info_noNAN[, 1] <- factor(name_Info_noNAN[, 1], droplevels(name_Info_noNAN[, 1]))
  
  name_Info[, -1] <- lapply(name_Info[, -1], function(x) as.numeric(gsub("%","",x)))
  name_Info <- reshape2::melt(name_Info, id = x)
  levels(name_Info$variable)[levels(name_Info$variable)=="%of records"] = "% of records"
  levels(name_Info$variable)[levels(name_Info$variable)=="% of $s"] = "% of obligations"
  name_Info$variable <- factor(name_Info$variable, rev(levels(name_Info$variable)))
  if(any(name_Info[, 1]=="NA"))
    limits<-rev(c(levels(name_Info_noNAN[ ,1]),"NA"))
  else
    limits<-rev(levels(name_Info_noNAN[ ,1]))
  basicplot <- ggplot(data = name_Info, 
                      aes(x = name_Info[, 1], 
                          y = name_Info[, 3], 
                          fill = factor(variable))) +
    geom_bar(stat = "identity", position = "dodge", width = 0.8) + 
    xlab("Category") + 
    ylab("") + 
    coord_flip() + 
    guides(fill = guide_legend(reverse = TRUE)) +   #reverse the order of legend
    theme_grey() + 
    scale_fill_grey() + 
    theme(legend.title = element_blank(), 
          legend.position = "bottom", 
          legend.margin = margin(t=-0.8, r=0, b=0.5, l=0, unit="cm"),
          legend.text = element_text(margin = margin(r = 0.5, unit = "cm")),    #increase the distances between two legends
          plot.margin = margin(t=0.3, r=0.5, b=0, l=0.5, unit = "cm")) + 
    ggtitle(paste("Statistic summary of categorical variable: ", x)) +
    scale_x_discrete(limits = limits)    #keep the order of category the same
  return(basicplot)
}



#function for generating frequency information table for categorical variables                            
freq_table <- function(x, contract){
  Frequency <- as.data.frame(table(contract[[x]]))
  Frequency[["Percent_Freq"]] <- round(Frequency[["Freq"]]/sum(Frequency[["Freq"]]),4)*100
  colnames(Frequency) <- c(x, "Count_Freq", "Percent_Freq")
  Percent_Obli <- c()
  for (i in Frequency[[x]]) {
    Percent_Obligation <- round(sum(contract[["Action_Obligation"]][contract[[x]] == i], na.rm = TRUE)/sum(contract[["Action_Obligation"]], na.rm = TRUE),5)
    Percent_Obli <- c(Percent_Obli, Percent_Obligation)
  }
  Frequency[["Percent_Obli"]] <- Percent_Obli*100
  return(Frequency)
}

#generate barplot according to frequency information table for categorical variables                                 
part_grouped_barplot <- function(name, frequency_Info){
  part_barplot <- ggplot(data = frequency_Info, 
                         aes(x = frequency_Info[["Description"]], 
                             y = frequency_Info[["value"]], 
                             fill=factor(frequency_Info[["variable"]]))) + 
    geom_bar(stat = "identity", 
             position= "dodge", 
             width = 0.8) + 
    xlab("") + 
    ylab("") + 
    coord_flip() + 
    theme_grey() +
    scale_fill_grey(labels = c("% of records", "% of obligations"),
                    guide = guide_legend(reverse = TRUE)) +
    theme(legend.title = element_blank(),
          legend.position = "bottom",
          legend.margin = margin(t=-0.8, r=0, b=0.5, l=0, unit = "cm"),
          legend.text = element_text(margin = margin(r=0.5, unit = "cm")),
          plot.margin = margin(t=0.3, r=0.5, b=0, l=0.5, unit = "cm")) 
  return(part_barplot)
}





get_pars<-function(model){
  if (isLMM(model)) {
  } else {
    pars <- getME(model,"theta")
    ## GLMM: requires both random and fixed parameters
    pars <- getME(model, c("theta","fixef"))
  }
  pars
}

get_study_variables_odds_ratio<-function(or.df){
  or.df<-or.df[or.df$variable %in% c("cl_def3_HHI_lag1"    ,
                                     "cl_def6_HHI_lag1" ,
                                     "CompOffr1 offer" ,
                                     "CompOffr2 offers",
                                     "CompOffr3-4 offers",
                                     "CompOffr5+ offers"
                                     # "CompOffr1 offer:b_UCA",
                                     # "CompOffr2 offers:b_UCA"   ,         
                                     # "CompOffr3-4 offers:b_UCA",
                                     # "CompOffr5+ offers:b_UCA",
                                     # "cl_def6_HHI_lag1:b_UCA",
                                     # "cl_def6_HHI_lag1:cl_def6_obl_lag1"
  ),]
  or.df$variable<-factor(or.df$variable)
  
  or.df<-or.df[,c("output" ,  "input"  ,  "variable",   "OR"  ,"2.5 %"  ,  "97.5 %" )]
  or.df$OR<-round(or.df$OR,digits=2)
  or.df[["2.5 %"]]<-round(or.df[["2.5 %"]],digits=2)
  or.df[["97.5 %"]]<-round(or.df[["97.5 %"]],digits=2)
  colnames(or.df)[colnames(or.df)=="output"]<-"Output"
  colnames(or.df)[colnames(or.df)=="input"]<-"Model"
  colnames(or.df)[colnames(or.df)=="OR"]<-"Odds Ratio"
  colnames(or.df)[colnames(or.df)=="2.5 %"]<-"Lower Bound"
  colnames(or.df)[colnames(or.df)=="97.5 %"]<-"Upper Bound"
  colnames(or.df)[colnames(or.df)=="variable"]<-"Variable"
  
  levels(or.df$Variable)<- list("Log(Subsector HHI)"=c("cl_def3_HHI_lag1"),
                                "Log(Det. Ind. HHI)"=c("cl_def6_HHI_lag1"),
                                "Comp=1 offer"=c("CompOffr1 offer"),
                                "Comp=2 offers"=c("CompOffr2 offers"),
                                "Comp=3-4 offers"=c("CompOffr3-4 offers"),
                                "Comp=5+ offers"=c("CompOffr5+ offers")
  )
  or.df
}

odds_ratio<-function(FM,name,input=NA,output=NA,walds=FALSE){
  OR <- exp(fixef(FM))
  if(walds==TRUE){
    CI <- exp(confint(FM,parm="beta_",method="Wald"))
  }
  else{
    CI <- exp(confint(FM,parm="beta_")) # it can be slow (~ a few minutes). As alternative, the much faster but less precise Wald's method can be used: CI <- exp(confint(FM,parm="beta_",method="Wald"))
  }
  write.csv(cbind(OR,CI),file=paste("output//",name,"_odds_ratio.csv",sep=""))
  OR<-as.data.frame(cbind(OR,CI))
  if(!is.na(output)) OR$output<-output
  if(!is.na(input)) OR$input<-input
  OR$variable<-rownames(OR)
  OR
}


log_analysis<-function(model){
  exp(cbind(coef(model),confint(model)))-1
}




# Helper function for string wrapping. 
# Default 20 character target width.
swr <- function(string, nwrap=20) {
  # https://stackoverflow.com/questions/37174316/how-to-fit-long-text-into-ggplot2-facet-titles
  
  paste(strwrap(string, width=nwrap), collapse="\n")
}
swr <- Vectorize(swr)




allFit_save <- function(m,meth.tab=NULL ,
                        data=NULL,
                        verbose=TRUE,
                        maxfun=1e5,
                        filename="output//allFit.rdata")
{
  source(system.file("utils", "allFit.R", package="lme4"))
  if (is.null(meth.tab))
    meth.tab <- meth.tab.0
  stopifnot(length(dm <- dim(meth.tab)) == 2, dm[1] >= 1, dm[2] >= 2,
            is.character(optimizer <- meth.tab[,"optimizer"]),
            is.character(method    <- meth.tab[,"method"]))
  fit.names <- gsub("\\.$","",paste(optimizer, method, sep="."))
  if(file.exists(filename))
    load(filename)
  else
    res <- setNames(as.list(fit.names), fit.names)
  for (i in seq_along(fit.names)) {
    if(typeof(res[[i]])=="character"){
      if (verbose) cat(fit.names[i],": ")
      ctrl <- list(optimizer=optimizer[i])
      ctrl$optCtrl <- switch(optimizer[i],
                             optimx    = list(method   = method[i]),
                             nloptWrap = list(algorithm= method[i]),
                             verbose=TRUE,
                             list(maxfun=maxfun))
      ctrl <- do.call(if(isGLMM(m)) glmerControl else lmerControl, ctrl)
      tt <- system.time(rr <- tryCatch(update(m, control = ctrl),
                                       error = function(e) e))
      attr(rr, "optCtrl") <- ctrl$optCtrl # contains crucial info here
      attr(rr, "time") <- tt  # store timing info
      res[[i]] <- rr
      save(m,res,file=filename)
      if (verbose) cat("[OK]\n")
    }
  }
  
  structure(res, class = "allfit", fit = m, sessionInfo =  sessionInfo(),
            data = data # is dropped if NULL
  )
}




# Helper function for string wrapping. 
# Default 20 character target width.
swr <- function(string, nwrap=20) {
  paste(strwrap(string, width=nwrap), collapse="\n")
}
swr <- Vectorize(swr)
