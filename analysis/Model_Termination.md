---
title: "Defense Services Termination"
author: "Greg Sanders"
date: "Saturday, July 13, 2019"
output:
  html_document:
    keep_md: yes
--- 

Modeling Likelihood of Contract Termination, Ceiling Breach, or Exercised Option
============================================================================

#Setup

```
## Warning: replacing previous import 'Hmisc::summarize' by 'dplyr::summarize'
## when loading 'csis360'
```

```
## Warning: replacing previous import 'Hmisc::src' by 'dplyr::src' when
## loading 'csis360'
```

```
## Warning: replacing previous import 'dplyr::intersect' by
## 'lubridate::intersect' when loading 'csis360'
```

```
## Warning: replacing previous import 'dplyr::union' by 'lubridate::union'
## when loading 'csis360'
```

```
## Warning: replacing previous import 'dplyr::setdiff' by 'lubridate::setdiff'
## when loading 'csis360'
```

```
## Loading required package: MASS
```

```
## Loading required package: Matrix
```

```
## Loading required package: lme4
```

```
## 
## arm (Version 1.10-1, built: 2018-4-12)
```

```
## Working directory is C:/Users/gsand/Repositories/Services/analysis
```

```
## Loading required package: coda
```

```
## 
## Attaching package: 'coda'
```

```
## The following object is masked from 'package:arm':
## 
##     traceplot
```

```
## Loading required package: boot
```

```
## 
## Attaching package: 'boot'
```

```
## The following object is masked from 'package:arm':
## 
##     logit
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following object is masked from 'package:MASS':
## 
##     select
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```
## Loading required package: lattice
```

```
## 
## Attaching package: 'lattice'
```

```
## The following object is masked from 'package:boot':
## 
##     melanoma
```

```
## Loading required package: survival
```

```
## 
## Attaching package: 'survival'
```

```
## The following object is masked from 'package:boot':
## 
##     aml
```

```
## Loading required package: Formula
```

```
## 
## Attaching package: 'Hmisc'
```

```
## The following objects are masked from 'package:dplyr':
## 
##     src, summarize
```

```
## The following objects are masked from 'package:base':
## 
##     format.pval, units
```

```
## 
## Please cite as:
```

```
##  Hlavac, Marek (2018). stargazer: Well-Formatted Regression and Summary Statistics Tables.
```

```
##  R package version 5.2.2. https://CRAN.R-project.org/package=stargazer
```

```
## dummies-1.5.6 provided by Decision Patterns
```

```
## 
## Attaching package: 'dummies'
```

```
## The following object is masked from 'package:lme4':
## 
##     dummy
```

```
## 
## Attaching package: 'sjstats'
```

```
## The following object is masked from 'package:Hmisc':
## 
##     deff
```

```
## Loading required package: carData
```

```
## 
## Attaching package: 'car'
```

```
## The following object is masked from 'package:dplyr':
## 
##     recode
```

```
## The following object is masked from 'package:boot':
## 
##     logit
```

```
## The following object is masked from 'package:arm':
## 
##     logit
```

```
## 
## Attaching package: 'scales'
```

```
## The following object is masked from 'package:arm':
## 
##     rescale
```



##Load Data
First we load the data. The dataset used is a U.S. Defense Contracting dataset derived from FPDS.


```r
load(file="..//data//clean//def_sample.Rdata")
```


The sample is created by including the entirity of the ARRA and Disaster datasets, as well as 100,000 records each from the OCO datase and another 100,000 from all remaining records.

#Study Variables

##Services Complexity
Expectation: Higher service complexity would make work more demanding and thus raises the risks of negative contracting outcomes, namely the likelihood of cost ceiling breaches and terminations increases and the likelihood exercised options decraeses.

### 01A NAICS Salary
Expectation: Given the fact that one source for higher salaries is the difficulty of the work and the experience and education required, as average NAICS salary increases (decreases), the likelihood of terminations increases (decreases).


```r
 # !is.na(def_serv$cl_US6_avg_sal_lag1)&
 #  !is.na(def_serv$cl_CFTE)&
 #  !is.na(def_serv$c_pPBSC)&
 #  !is.na(def_serv$c_pOffPSC)&
 #  !is.na(def_serv$c_pairHist)&
 #  !is.na(def_serv$cl_pairCA)&

summary_continuous_plot(serv_smp,"cl_US6_avg_sal_lag1Const")
```

```
## Warning: summarise_() is deprecated. 
## Please use summarise() instead
## 
## The 'programming' vignette or the tidyeval book can help you
## to program with summarise() : https://tidyeval.tidyverse.org
## This warning is displayed once per session.
```

![](Model_Termination_files/figure-html/Model01A-1.png)<!-- -->

```r
#Model
Term_01A <- glm (data=serv_smp,
                 b_Term ~ cl_US6_avg_sal_lag1Const, family=binomial(link="logit"))


#Plot residuals versus fitted
stargazer::stargazer(Term_01A,type="text",
                       digits=2)
```

```
## 
## ====================================================
##                              Dependent variable:    
##                          ---------------------------
##                                    b_Term           
## ----------------------------------------------------
## cl_US6_avg_sal_lag1Const           0.10***          
##                                    (0.03)           
##                                                     
## Constant                          -3.95***          
##                                    (0.01)           
##                                                     
## ----------------------------------------------------
## Observations                       250,000          
## Log Likelihood                   -23,414.38         
## Akaike Inf. Crit.                 46,832.76         
## ====================================================
## Note:                    *p<0.1; **p<0.05; ***p<0.01
```

Expectations are matched  for terminations but the results are not significant.

### 01B Invoice Rate
Expectation: The invoice rate approximates how much the government is charged annually for each comparable full-time employees who are supporting the service contracts. A higher invoice rate indicates a more complex service. As invoice rate increases (decreases), the likelihood terminations increases (decreases).


```r
 # !is.na(def_serv$cl_US6_avg_sal_lag1)&
 #  !is.na(def_serv$cl_CFTE)&
 #  !is.na(def_serv$c_pPBSC)&
 #  !is.na(def_serv$c_pOffPSC)&
 #  !is.na(def_serv$c_pairHist)&
 #  !is.na(def_serv$cl_pairCA)&

summary_continuous_plot(serv_smp,"cl_CFTE")
```

![](Model_Termination_files/figure-html/Model01B-1.png)<!-- -->

```r
#Model

#Model
Term_01B <- glm (data=serv_smp,
                 b_Term ~ cl_CFTE, family=binomial(link="logit"))

display(Term_01B)
```

```
## glm(formula = b_Term ~ cl_CFTE, family = binomial(link = "logit"), 
##     data = serv_smp)
##             coef.est coef.se
## (Intercept) -3.95     0.01  
## cl_CFTE      0.04     0.03  
## ---
##   n = 250000, k = 2
##   residual deviance = 46838.1, null deviance = 46839.6 (difference = 1.5)
```

```r
#Plot residuals versus fitted
  stargazer::stargazer(
                       Term_01A,Term_01B,
                       
                       type="text",
                       digits=2)
```

```
## 
## =====================================================
##                              Dependent variable:     
##                          ----------------------------
##                                     b_Term           
##                               (1)            (2)     
## -----------------------------------------------------
## cl_US6_avg_sal_lag1Const    0.10***                  
##                              (0.03)                  
##                                                      
## cl_CFTE                                     0.04     
##                                            (0.03)    
##                                                      
## Constant                    -3.95***      -3.95***   
##                              (0.01)        (0.01)    
##                                                      
## -----------------------------------------------------
## Observations                250,000        250,000   
## Log Likelihood             -23,414.38    -23,419.06  
## Akaike Inf. Crit.          46,832.76      46,842.12  
## =====================================================
## Note:                     *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_01A,Term_01B, skip_vif = TRUE)
```

![](Model_Termination_files/figure-html/Model01B-2.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model01B-3.png)<!-- -->

```
## NULL
```

When considered alone, expectations are matched for ceiling breaches and exercised options, as higher invoice rate estimates a higher risk of ceiling breaches and lower possibility of exercised options. No significant relationship between invoice rate and terminations.



### 01C Service Complexity
Expectation: Collectively, the higher average salary and invoice rate (more complexity is indicated), the higher risk of ceiling breaches and terminations and the less exercised options there would be. Also we expect the result of combined model would be the same as individual models.

 

```r
 #  !is.na(def_serv$c_pPBSC)&
 #  !is.na(def_serv$c_pOffPSC)&
 #  !is.na(def_serv$c_pairHist)&
 #  !is.na(def_serv$cl_pairCA)&

#Model
Term_01C <- glm (data=serv_smp,
                 b_Term ~ cl_US6_avg_sal_lag1Const + cl_CFTE, family=binomial(link="logit"))

glmer_examine(Term_01C)
```

```
## cl_US6_avg_sal_lag1Const                  cl_CFTE 
##                 1.155086                 1.155086
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_01A,Term_01B,Term_01C,
                       
                       type="text",
                       digits=2)
```

```
## 
## =========================================================
##                                Dependent variable:       
##                          --------------------------------
##                                       b_Term             
##                             (1)        (2)        (3)    
## ---------------------------------------------------------
## cl_US6_avg_sal_lag1Const  0.10***               0.10***  
##                            (0.03)                (0.03)  
##                                                          
## cl_CFTE                                0.04      0.0002  
##                                       (0.03)     (0.03)  
##                                                          
## Constant                  -3.95***   -3.95***   -3.95*** 
##                            (0.01)     (0.01)     (0.01)  
##                                                          
## ---------------------------------------------------------
## Observations              250,000    250,000    250,000  
## Log Likelihood           -23,414.38 -23,419.06 -23,414.38
## Akaike Inf. Crit.        46,832.76  46,842.12  46,834.76 
## =========================================================
## Note:                         *p<0.1; **p<0.05; ***p<0.01
```

```r
  summary_residual_compare(Term_01A,Term_01C)
```

![](Model_Termination_files/figure-html/Model01C-1.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model01C-2.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance difference
## 1 model1_old 46828.76      46839.64   10.88078
## 2 model1_new 46828.76      46839.64   10.88081
## 
## [[2]]
## cl_US6_avg_sal_lag1Const                  cl_CFTE 
##                 1.155086                 1.155086
```

```r
  summary_residual_compare(Term_01B,Term_01C)
```

![](Model_Termination_files/figure-html/Model01C-3.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used

## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

![](Model_Termination_files/figure-html/Model01C-4.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance difference
## 1 model1_old 46838.12      46839.64   1.520306
## 2 model1_new 46828.76      46839.64  10.880812
## 
## [[2]]
## cl_US6_avg_sal_lag1Const                  cl_CFTE 
##                 1.155086                 1.155086
```

Both average salary and invoiced rate have a not inconsiderable VIF but one well within bounds, suggesting that the variance of the estimated coefficients is not evidently inflated and none of them are highly correlated with each other. 

Both individually and pair-wise, higher average salary and invoiced rate estimate higher possibility of cost ceiling breaches and lower likelihood of exercised options as expected. But the termination expectation is not supported or not significant for two measures of service complexity resepctively.



## Office Capacity

### 02A: Performance Based Services
Expectation: Performance-based services contracting ties a portion of a contractor's payment, contract extensions, or contract renewals to the achievement of specific, measurable performance standards and requirements, which encourages better contracting results. PBSC has the potential to reduce terminations and ceiling breaches and bring more possibility of exercised options.


```r
summary_continuous_plot(serv_smp,"pPBSC")
```

![](Model_Termination_files/figure-html/Model02A-1.png)<!-- -->

```r
#Model
Term_02A <- glm (data=serv_smp,
                 b_Term ~ c_pPBSC, family=binomial(link="logit"))

display(Term_02A)
```

```
## glm(formula = b_Term ~ c_pPBSC, family = binomial(link = "logit"), 
##     data = serv_smp)
##             coef.est coef.se
## (Intercept) -3.96     0.01  
## c_pPBSC      0.27     0.03  
## ---
##   n = 250000, k = 2
##   residual deviance = 46751.3, null deviance = 46839.6 (difference = 88.3)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_01C,Term_02A,
                       
                       type="text",
                       digits=2)
```

```
## 
## =====================================================
##                              Dependent variable:     
##                          ----------------------------
##                                     b_Term           
##                               (1)            (2)     
## -----------------------------------------------------
## cl_US6_avg_sal_lag1Const    0.10***                  
##                              (0.03)                  
##                                                      
## cl_CFTE                      0.0002                  
##                              (0.03)                  
##                                                      
## c_pPBSC                                    0.27***   
##                                            (0.03)    
##                                                      
## Constant                    -3.95***      -3.96***   
##                              (0.01)        (0.01)    
##                                                      
## -----------------------------------------------------
## Observations                250,000        250,000   
## Log Likelihood             -23,414.38    -23,375.66  
## Akaike Inf. Crit.          46,834.76      46,755.33  
## =====================================================
## Note:                     *p<0.1; **p<0.05; ***p<0.01
```

When considering PBSC alone, none of the expected sign was found in ceiling breaches, terminations or exercised options.


### 02B: No.Office PSC History
Expectation: The increasing share of contracting office obligations for a given service indicates high capcaity in that area, lower likelihood of cost ceiling breaches and termination and higher likelihood of exercised options are expected to be observed.


```r
 # !is.na(def_serv$cl_US6_avg_sal_lag1)&
 #  !is.na(def_serv$cl_CFTE)&
 #  !is.na(def_serv$c_pPBSC)&
 #  !is.na(def_serv$c_pOffPSC)&
 #  !is.na(def_serv$c_pairHist)&
 #  !is.na(def_serv$cl_pairCA)&

summary_continuous_plot(serv_smp,"c_pOffPSC")
```

![](Model_Termination_files/figure-html/Model02B-1.png)<!-- -->

```r
#Model
Term_02B <- glm (data=serv_smp,
                 b_Term ~ c_pOffPSC, family=binomial(link="logit"))

display(Term_02B)
```

```
## glm(formula = b_Term ~ c_pOffPSC, family = binomial(link = "logit"), 
##     data = serv_smp)
##             coef.est coef.se
## (Intercept) -3.98     0.02  
## c_pOffPSC    0.50     0.02  
## ---
##   n = 250000, k = 2
##   residual deviance = 46459.6, null deviance = 46839.6 (difference = 380.0)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_01C,Term_02A,Term_02B,
                       
                       type="text",
                       digits=2)
```

```
## 
## =========================================================
##                                Dependent variable:       
##                          --------------------------------
##                                       b_Term             
##                             (1)        (2)        (3)    
## ---------------------------------------------------------
## cl_US6_avg_sal_lag1Const  0.10***                        
##                            (0.03)                        
##                                                          
## cl_CFTE                    0.0002                        
##                            (0.03)                        
##                                                          
## c_pPBSC                              0.27***             
##                                       (0.03)             
##                                                          
## c_pOffPSC                                       0.50***  
##                                                  (0.02)  
##                                                          
## Constant                  -3.95***   -3.96***   -3.98*** 
##                            (0.01)     (0.01)     (0.02)  
##                                                          
## ---------------------------------------------------------
## Observations              250,000    250,000    250,000  
## Log Likelihood           -23,414.38 -23,375.66 -23,229.80
## Akaike Inf. Crit.        46,834.76  46,755.33  46,463.61 
## =========================================================
## Note:                         *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_02A,Term_02B, skip_vif = TRUE)
```

![](Model_Termination_files/figure-html/Model02B-2.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model02B-3.png)<!-- -->

```
## NULL
```

When considering number of contracting office obligations for a given service alone, expectation was only fulfilled for options growth.


### 02C: Office Capacity
Expectation: Collaberactively, the larger share of PBSC and contracting office obligations for a given service, the less risk of ceiling breaches and terminations and the more exercised options there would be. Also we expect the results of combined model would be the same as two individual models above. 


```r
#Model
Term_02C <- glm (data=serv_smp,
                 b_Term ~ c_pPBSC+c_pOffPSC, family=binomial(link="logit"))

glmer_examine(Term_02C)
```

```
##   c_pPBSC c_pOffPSC 
##  1.249797  1.249797
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_01C,Term_02A,Term_02B,Term_02C,
                       
                       type="text",
                       digits=2)
```

```
## 
## ====================================================================
##                                      Dependent variable:            
##                          -------------------------------------------
##                                            b_Term                   
##                             (1)        (2)        (3)        (4)    
## --------------------------------------------------------------------
## cl_US6_avg_sal_lag1Const  0.10***                                   
##                            (0.03)                                   
##                                                                     
## cl_CFTE                    0.0002                                   
##                            (0.03)                                   
##                                                                     
## c_pPBSC                              0.27***                 0.05   
##                                       (0.03)                (0.03)  
##                                                                     
## c_pOffPSC                                       0.50***    0.48***  
##                                                  (0.02)     (0.03)  
##                                                                     
## Constant                  -3.95***   -3.96***   -3.98***   -3.98*** 
##                            (0.01)     (0.01)     (0.02)     (0.02)  
##                                                                     
## --------------------------------------------------------------------
## Observations              250,000    250,000    250,000    250,000  
## Log Likelihood           -23,414.38 -23,375.66 -23,229.80 -23,228.52
## Akaike Inf. Crit.        46,834.76  46,755.33  46,463.61  46,463.04 
## ====================================================================
## Note:                                    *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_02A,Term_02C)
```

![](Model_Termination_files/figure-html/Model02C-1.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model02C-2.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance difference
## 1 model1_old 46751.33      46839.64   88.31184
## 2 model1_new 46457.04      46839.64  382.59617
## 
## [[2]]
##   c_pPBSC c_pOffPSC 
##  1.249797  1.249797
```

```r
summary_residual_compare(Term_02B,Term_02C)
```

![](Model_Termination_files/figure-html/Model02C-3.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used

## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

![](Model_Termination_files/figure-html/Model02C-4.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance difference
## 1 model1_old 46459.61      46839.64   380.0307
## 2 model1_new 46457.04      46839.64   382.5962
## 
## [[2]]
##   c_pPBSC c_pOffPSC 
##  1.249797  1.249797
```

No high correlation is observed between PBSC and Contract Office Obligations for PSC based on the vif score.

After combining PBSC and Contract office obligations for PSC, PBSC had a flipped relationship with ceiling breaches that matches with expectation (A look at summary statistics for Performance-Based experience did find that as the percent of performance-based service went from 0 percent to 75 percent, the ceiling breach rate declined. Above 75 percent, it rose dramatically, suggesting an additional variable may influence that relationship.) but lost significance with terminations. Contract office obligations for PSC is associate with more exercised options. The rest of results remained unmatching with expectations.


### 02D: Cumulative  Model
Expectation: When all the four variables are combined into one model, same expectations are applied as individual ones. Per service complexity indicator increases, higher risk of ceiling breaches and terminations and less exercised options expected. Per office capacity indicator increases, lower risk of ceiling breaches and terminations and more exercised options expected.


```r
#Model
Term_02D <- glm (data=serv_smp,
                 b_Term ~ cl_US6_avg_sal_lag1Const + cl_CFTE+c_pPBSC+c_pOffPSC, family=binomial(link="logit"))

glmer_examine(Term_02D)
```

```
## cl_US6_avg_sal_lag1Const                  cl_CFTE                  c_pPBSC 
##                 1.206850                 1.165515                 1.263851 
##                c_pOffPSC 
##                 1.266682
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_01C,Term_02C,Term_02D,
                       
                       type="text",
                       digits=2)
```

```
## 
## =========================================================
##                                Dependent variable:       
##                          --------------------------------
##                                       b_Term             
##                             (1)        (2)        (3)    
## ---------------------------------------------------------
## cl_US6_avg_sal_lag1Const  0.10***                -0.002  
##                            (0.03)                (0.03)  
##                                                          
## cl_CFTE                    0.0002                 0.02   
##                            (0.03)                (0.03)  
##                                                          
## c_pPBSC                                0.05       0.05   
##                                       (0.03)     (0.03)  
##                                                          
## c_pOffPSC                            0.48***    0.48***  
##                                       (0.03)     (0.03)  
##                                                          
## Constant                  -3.95***   -3.98***   -3.98*** 
##                            (0.01)     (0.02)     (0.02)  
##                                                          
## ---------------------------------------------------------
## Observations              250,000    250,000    250,000  
## Log Likelihood           -23,414.38 -23,228.52 -23,228.39
## Akaike Inf. Crit.        46,834.76  46,463.04  46,466.79 
## =========================================================
## Note:                         *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_02C,Term_02D)
```

![](Model_Termination_files/figure-html/Model02D-1.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model02D-2.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance difference
## 1 model1_old 46457.04      46839.64   382.5962
## 2 model1_new 46456.79      46839.64   382.8504
## 
## [[2]]
## cl_US6_avg_sal_lag1Const                  cl_CFTE                  c_pPBSC 
##                 1.206850                 1.165515                 1.263851 
##                c_pOffPSC 
##                 1.266682
```

```r
summary_residual_compare(Term_01C,Term_02D)
```

![](Model_Termination_files/figure-html/Model02D-3.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used

## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

![](Model_Termination_files/figure-html/Model02D-4.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance difference
## 1 model1_old 46828.76      46839.64   10.88081
## 2 model1_new 46456.79      46839.64  382.85036
## 
## [[2]]
## cl_US6_avg_sal_lag1Const                  cl_CFTE                  c_pPBSC 
##                 1.206850                 1.165515                 1.263851 
##                c_pOffPSC 
##                 1.266682
```

No high correlation is observed among all of the 4 predictors (average salary, invoiced rate, PBSC and Contract Office Obligations for PSC) so far based on the vif score. When all measures for sevice complexity and office capacity are combined, per dependent variable:

1. Ceiling Breaches: All variables remain the same within each subgroup (Services Complexity and Office Capacity). Except for Contract office obligations for PSC, the results of other varibles matched with the expectation for ceiling breaches so far. 

2. Terminations: Except for Contract office obligations for PSC, the rest of variables didn't show significant relationships with Termination. The only significant relationship between Contract office obligations for PSC and Temrination didn't match the expectation.

3. Exercised Options: Except for PBSC, all other three variables are associated with exercised options as expected.



## Office-Vendor Relationship

### 03A: Pair History
Expactation: The number of past years of the relationship between the contracting office or the contractors with a single transaction in a given fiscal year enough to qualify, namely, pair history increases (decreases), the likelihood of cost ceiling breaches and terminations decreases (increases) and the exercised options increase (decrease) for that partnership.


```r
 # !is.na(def_serv$cl_US6_avg_sal_lag1)&
 #  !is.na(def_serv$cl_CFTE)&
 #  !is.na(def_serv$c_pPBSC)&
 #  !is.na(def_serv$c_pOffPSC)&
 #  !is.na(def_serv$c_pairHist)&
 #  !is.na(def_serv$cl_pairCA)&

summary_discrete_plot(serv_smp,"c_pairHist")
```

```
## Warning: Ignoring unknown parameters: binwidth, bins, pad
```

```
## Warning: group_by_() is deprecated. 
## Please use group_by() instead
## 
## The 'programming' vignette or the tidyeval book can help you
## to program with group_by() : https://tidyeval.tidyverse.org
## This warning is displayed once per session.
```

![](Model_Termination_files/figure-html/Model03A-1.png)<!-- -->

```
## [[1]]
## 
## -0.727331277356926 -0.519773791968938  -0.31221630658095 
##              38833              30773              28265 
## -0.104658821192962  0.102898664195026  0.310456149583014 
##              29388              33017              27617 
##  0.518013634971002   0.72557112035899 
##              21668              40439 
## 
## [[2]]
##                     
##                       None Ceiling Breach
##   -0.727331277356926 36517           2316
##   -0.519773791968938 29088           1685
##   -0.31221630658095  26645           1620
##   -0.104658821192962 27663           1725
##   0.102898664195026  30978           2039
##   0.310456149583014  25988           1629
##   0.518013634971002  20479           1189
##   0.72557112035899   38545           1894
## 
## [[3]]
##                     
##                          0     1
##   -0.727331277356926 37825  1008
##   -0.519773791968938 30288   485
##   -0.31221630658095  27898   367
##   -0.104658821192962 29044   344
##   0.102898664195026  32439   578
##   0.310456149583014  26913   704
##   0.518013634971002  21158   510
##   0.72557112035899   39713   726
```

```r
#Model
Term_03A <- glm (data=serv_smp,
                 b_Term ~ c_pairHist, family=binomial(link="logit"))

display(Term_03A)
```

```
## glm(formula = b_Term ~ c_pairHist, family = binomial(link = "logit"), 
##     data = serv_smp)
##             coef.est coef.se
## (Intercept) -3.95     0.01  
## c_pairHist   0.00     0.03  
## ---
##   n = 250000, k = 2
##   residual deviance = 46839.6, null deviance = 46839.6 (difference = 0.0)
```

```r
#Plot residuals versus fitted
  stargazer::stargazer(
                       Term_02D,Term_03A,
                       
                       type="text",
                       digits=2)
```

```
## 
## =====================================================
##                              Dependent variable:     
##                          ----------------------------
##                                     b_Term           
##                               (1)            (2)     
## -----------------------------------------------------
## cl_US6_avg_sal_lag1Const     -0.002                  
##                              (0.03)                  
##                                                      
## cl_CFTE                       0.02                   
##                              (0.03)                  
##                                                      
## c_pPBSC                       0.05                   
##                              (0.03)                  
##                                                      
## c_pOffPSC                   0.48***                  
##                              (0.03)                  
##                                                      
## c_pairHist                                  0.001    
##                                            (0.03)    
##                                                      
## Constant                    -3.98***      -3.95***   
##                              (0.02)        (0.01)    
##                                                      
## -----------------------------------------------------
## Observations                250,000        250,000   
## Log Likelihood             -23,228.39    -23,419.82  
## Akaike Inf. Crit.          46,466.79      46,843.64  
## =====================================================
## Note:                     *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_02D,Term_03A, skip_vif = TRUE)
```

![](Model_Termination_files/figure-html/Model03A-2.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model03A-3.png)<!-- -->

```
## NULL
```

When considering pair history alone, expectations were met for ceiling breaches and terminations, but not for exercised options. 


### 03B: Interaction
Expectation: As the number of contract actions a vendor has performed for an office in the past year increases (decreases), the likelihood of cost ceiling breaches and terminations decreases (increases) and that of exercised options increases (decreases) for that partnership.


```r
 # !is.na(def_serv$cl_US6_avg_sal_lag1)&
 #  !is.na(def_serv$cl_CFTE)&
 #  !is.na(def_serv$c_pPBSC)&
 #  !is.na(def_serv$c_pOffPSC)&
 #  !is.na(def_serv$c_pairHist)&
 #  !is.na(def_serv$cl_pairCA)&

summary_continuous_plot(serv_smp,"cl_pairCA")
```

![](Model_Termination_files/figure-html/Model03B-1.png)<!-- -->

```r
#Model
Term_03B <- glm (data=serv_smp,
                 b_Term ~ cl_pairCA, family=binomial(link="logit"))

display(Term_03B)
```

```
## glm(formula = b_Term ~ cl_pairCA, family = binomial(link = "logit"), 
##     data = serv_smp)
##             coef.est coef.se
## (Intercept) -3.97     0.02  
## cl_pairCA    0.47     0.03  
## ---
##   n = 250000, k = 2
##   residual deviance = 46552.9, null deviance = 46839.6 (difference = 286.8)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_02D,Term_03A,Term_03B,
                       
                       type="text",
                       digits=2)
```

```
## 
## =========================================================
##                                Dependent variable:       
##                          --------------------------------
##                                       b_Term             
##                             (1)        (2)        (3)    
## ---------------------------------------------------------
## cl_US6_avg_sal_lag1Const   -0.002                        
##                            (0.03)                        
##                                                          
## cl_CFTE                     0.02                         
##                            (0.03)                        
##                                                          
## c_pPBSC                     0.05                         
##                            (0.03)                        
##                                                          
## c_pOffPSC                 0.48***                        
##                            (0.03)                        
##                                                          
## c_pairHist                            0.001              
##                                       (0.03)             
##                                                          
## cl_pairCA                                       0.47***  
##                                                  (0.03)  
##                                                          
## Constant                  -3.98***   -3.95***   -3.97*** 
##                            (0.02)     (0.01)     (0.02)  
##                                                          
## ---------------------------------------------------------
## Observations              250,000    250,000    250,000  
## Log Likelihood           -23,228.39 -23,419.82 -23,276.44
## Akaike Inf. Crit.        46,466.79  46,843.64  46,556.88 
## =========================================================
## Note:                         *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_03A,Term_03B, skip_vif = TRUE)
```

![](Model_Termination_files/figure-html/Model03B-2.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model03B-3.png)<!-- -->

```
## NULL
```

```r
summary_residual_compare(Term_02D,Term_03B, skip_vif = TRUE)
```

![](Model_Termination_files/figure-html/Model03B-4.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used

## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

![](Model_Termination_files/figure-html/Model03B-5.png)<!-- -->

```
## NULL
```

When considering contract actions alone, no expectation were met. The patterns in the plots are complex, ceiling breaches has a sinusoidal or perhaps exponential relationship while terminations has an neative relationship, until the number of ations grows extreme at which point the risk jumps up.

### 03C: Office-Vendor Relationship
Expectation: 
The importance of partnership, trust, and handling difficult problems and uncertainty together naturally lead into the last characteristic: the relationship between the contractor and buyer. The higher level of interaction provides the more opportunity to build a deeper relationship, the likelihood of cost ceiling breaches and terminations decreases and the exercised options increase for that partnership. Also we expect the result of combined model would be the same as individual models above.


```r
 # !is.na(def_serv$cl_US6_avg_sal_lag1)&
 #  !is.na(def_serv$cl_CFTE)&
 #  !is.na(def_serv$c_pPBSC)&
 #  !is.na(def_serv$c_pOffPSC)&
 #  !is.na(def_serv$c_pairHist)&
 #  !is.na(def_serv$cl_pairCA)&

#Model
Term_03C <- glm (data=serv_smp,
                 b_Term ~ c_pairHist+cl_pairCA, family=binomial(link="logit"))

glmer_examine(Term_03C)
```

```
## c_pairHist  cl_pairCA 
##   1.191974   1.191974
```

```r
#Plot residuals versus fitted
  stargazer::stargazer(
                       Term_02D,Term_03A,Term_03B,Term_03C,
                       
                       type="text",
                       digits=2)
```

```
## 
## ====================================================================
##                                      Dependent variable:            
##                          -------------------------------------------
##                                            b_Term                   
##                             (1)        (2)        (3)        (4)    
## --------------------------------------------------------------------
## cl_US6_avg_sal_lag1Const   -0.002                                   
##                            (0.03)                                   
##                                                                     
## cl_CFTE                     0.02                                    
##                            (0.03)                                   
##                                                                     
## c_pPBSC                     0.05                                    
##                            (0.03)                                   
##                                                                     
## c_pOffPSC                 0.48***                                   
##                            (0.03)                                   
##                                                                     
## c_pairHist                            0.001                -0.24*** 
##                                       (0.03)                (0.03)  
##                                                                     
## cl_pairCA                                       0.47***    0.55***  
##                                                  (0.03)     (0.03)  
##                                                                     
## Constant                  -3.98***   -3.95***   -3.97***   -3.98*** 
##                            (0.02)     (0.01)     (0.02)     (0.02)  
##                                                                     
## --------------------------------------------------------------------
## Observations              250,000    250,000    250,000    250,000  
## Log Likelihood           -23,228.39 -23,419.82 -23,276.44 -23,250.18
## Akaike Inf. Crit.        46,466.79  46,843.64  46,556.88  46,506.37 
## ====================================================================
## Note:                                    *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_03A,Term_03C)
```

![](Model_Termination_files/figure-html/Model03C-1.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model03C-2.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance   difference
## 1 model1_old 46839.64      46839.64 1.285661e-03
## 2 model1_new 46500.37      46839.64 3.392697e+02
## 
## [[2]]
## c_pairHist  cl_pairCA 
##   1.191974   1.191974
```

```r
summary_residual_compare(Term_03B,Term_03C)
```

![](Model_Termination_files/figure-html/Model03C-3.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used

## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

![](Model_Termination_files/figure-html/Model03C-4.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance difference
## 1 model1_old 46552.88      46839.64   286.7590
## 2 model1_new 46500.37      46839.64   339.2697
## 
## [[2]]
## c_pairHist  cl_pairCA 
##   1.191974   1.191974
```

```r
summary_residual_compare(Term_02D,Term_03C)
```

![](Model_Termination_files/figure-html/Model03C-5.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used

## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

![](Model_Termination_files/figure-html/Model03C-6.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance difference
## 1 model1_old 46456.79      46839.64   382.8504
## 2 model1_new 46500.37      46839.64   339.2697
## 
## [[2]]
## c_pairHist  cl_pairCA 
##   1.191974   1.191974
```

When combining pair history and contract actions, magnitude of relationships with dependent variables incraesed, but the agreement with expectations splited in the same way as individually.  


### 03D: Cumulative  Model

Expectation: Under each subgroup, the predictors are expected to have similar impacts on dependent variables individually and cumulatively:
1. Higher Services Complexity: Higher likelihood of cost ceiling breaches and terminations; Less exercised options
2. Larger Office Capacity: Lower likelihood of cost ceiling breaches and terminations; More exercised options
3. Deeper Office-Vendor Relationship: Lower likelihood of cost ceiling breaches and terminations; More exercised options


```r
#Model
Term_03D <- glm (data=serv_smp,
                 b_Term ~ cl_US6_avg_sal_lag1Const + 
                   cl_CFTE+ c_pPBSC+c_pOffPSC+
                   c_pairHist+cl_pairCA, family=binomial(link="logit"))

glmer_examine(Term_03D)
```

```
## cl_US6_avg_sal_lag1Const                  cl_CFTE                  c_pPBSC 
##                 1.255453                 1.185440                 1.315968 
##                c_pOffPSC               c_pairHist                cl_pairCA 
##                 1.422282                 1.221264                 1.486627
```

```r
#Plot residuals versus fitted   

stargazer::stargazer(
                       Term_02D,Term_03C,Term_03D,
                       
                       type="text",
                       digits=2)
```

```
## 
## =========================================================
##                                Dependent variable:       
##                          --------------------------------
##                                       b_Term             
##                             (1)        (2)        (3)    
## ---------------------------------------------------------
## cl_US6_avg_sal_lag1Const   -0.002                -0.06*  
##                            (0.03)                (0.03)  
##                                                          
## cl_CFTE                     0.02                 0.07**  
##                            (0.03)                (0.03)  
##                                                          
## c_pPBSC                     0.05                  0.03   
##                            (0.03)                (0.03)  
##                                                          
## c_pOffPSC                 0.48***               0.37***  
##                            (0.03)                (0.03)  
##                                                          
## c_pairHist                           -0.24***   -0.23*** 
##                                       (0.03)     (0.03)  
##                                                          
## cl_pairCA                            0.55***    0.41***  
##                                       (0.03)     (0.03)  
##                                                          
## Constant                  -3.98***   -3.98***   -3.99*** 
##                            (0.02)     (0.02)     (0.02)  
##                                                          
## ---------------------------------------------------------
## Observations              250,000    250,000    250,000  
## Log Likelihood           -23,228.39 -23,250.18 -23,149.37
## Akaike Inf. Crit.        46,466.79  46,506.37  46,312.75 
## =========================================================
## Note:                         *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_03C,Term_03D)
```

![](Model_Termination_files/figure-html/Model03D-1.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model03D-2.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance difference
## 1 model1_old 46500.37      46839.64   339.2697
## 2 model1_new 46298.75      46839.64   540.8894
## 
## [[2]]
## cl_US6_avg_sal_lag1Const                  cl_CFTE                  c_pPBSC 
##                 1.255453                 1.185440                 1.315968 
##                c_pOffPSC               c_pairHist                cl_pairCA 
##                 1.422282                 1.221264                 1.486627
```

```r
summary_residual_compare(Term_02D,Term_03D)
```

![](Model_Termination_files/figure-html/Model03D-3.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used

## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

![](Model_Termination_files/figure-html/Model03D-4.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance difference
## 1 model1_old 46456.79      46839.64   382.8504
## 2 model1_new 46298.75      46839.64   540.8894
## 
## [[2]]
## cl_US6_avg_sal_lag1Const                  cl_CFTE                  c_pPBSC 
##                 1.255453                 1.185440                 1.315968 
##                c_pOffPSC               c_pairHist                cl_pairCA 
##                 1.422282                 1.221264                 1.486627
```

None of the predictors has high level of correlation (vif over 1.7) with each other. 
In the cumulative model, per dependent variable and independent variable:

2. Terminations:
   A. Service Complexity:
      The reult for average salary did not match with expectation.
      The result for invoice rate did matach with expectation, only significant (for p-value <0.5), which is still sufficient.
      
   B. Office Capacity: 
      The relationship with PBSC was not significant.
      The result for office obligations did not match with expectation.
     
   C. Office-Vendor Relationship:
      The result for pair history matched with expectation once all variables included.
      The result for contract actions did not match with expectation.


## Study Variables Alone


```r
 # !is.na(def_serv$cl_US6_avg_sal_lag1)&
 #  !is.na(def_serv$cl_CFTE)&
 #  !is.na(def_serv$c_pPBSC)&
 #  !is.na(def_serv$c_pOffPSC)&
 #  !is.na(def_serv$c_pairHist)&
 #  !is.na(def_serv$cl_pairCA)&

study_coef_list<-list("(Intercept)"="(Intercept)",
                      "cl_US6_avg_sal_lag1Const"="Log(Det. Ind. Salary)",
                      "cl_CFTE"="Log(Service Invoice Rate)",
                      "c_pPBSC"="Office Perf.-Based %",
                      "c_pOffPSC"="Office Service Exp. %",
                      "c_pairHist"="Paired Years",
                      "cl_pairCA"="Log(Paired Actions)"
)


all_coef_list<-list("(Intercept)"="(Intercept)",
                    "cl_US6_avg_sal_lag1Const"="Log(Det. Ind. Salary)",
                    "cl_CFTE"="Log(Service Invoice Rate)",
                    "c_pPBSC"="Office Perf.-Based %",
                    "c_pOffPSC"="Office Service Exp. %",
                    "c_pairHist"="Paired Years",
                    "cl_pairCA"="Log(Paired Actions)",
                    
                    #Contract Controls
                    
                    "Comp1or51 offer"="Comp=1 offer",
                    "Comp1or52-4 offers"="Comp=2-4 offers",
                    "Comp1or55+ offers"="Comp=5+ offers",
                    
                    "CompOffr1 offer"="Comp=1 offer",
                    "CompOffr2 offers"="Comp=2 offers",
                    "CompOffr3-4 offers"="Comp=3-4 offers",
                    "CompOffr5+ offers"="Comp=5+ offers",
                    
                    "cl_Ceil"="Log(Init. Ceiling)",
                    "capped_cl_Days"="Log(Init. Days)",
                    "VehS-IDC"="Vehicle=S-IDC",
                    "VehM-IDC"="Vehicle=M-IDC",
                    "VehFSS/GWAC"="Vehicle=FSS/GWAC",
                    "VehBPA/BOA"="Vehicle=BPA/BOA",
                    "PricingUCAFFP"="Pricing=FFP",
                    "PricingUCAOther FP"="Pricing=Other FP",
                    "PricingUCAIncentive"="Pricing=Incentive Fee",
                    "PricingUCACombination or Other"="Pricing=Combination or Other",
                    "PricingUCAOther CB"="Pricing=Other CB",
                    "PricingUCAT&M/LH/FPLOE"="Pricing=T&M/LH/FP:LoE",
                    "PricingUCAUCA"="Pricing=UCA",
                    
                    "PricingFeeOther FP"="Pricing=Other FP",
                    "PricingFeeIncentive"="Pricing=Incentive Fee",
                    "PricingFeeCombination or Other"="Pricing=Combination or Other",
                    "PricingFeeOther CB"="Pricing=Other CB",
                    "PricingFeeT&M/LH/FPLOE"="Pricing=T&M/LH/FP:LoE",
                    "b_UCA"="UCA",
                    "CrisisARRA"="Crisis=ARRA",
                    "CrisisDis"="Crisis=Disaster",
                    "CrisisOCO"="Crisis=OCO",
                    "b_Intl"="Performed Abroad",

                    #NAICS
                    "cl_def3_HHI_lag1"="Log(Subsector HHI)",
                    "cl_def6_HHI_lag1"="Log(Det. Ind. HHI)",
                    "cl_def3_ratio_lag1"="Log(Subsector Ratio)",
                    "cl_def6_obl_lag1"="Log(Det. Ind. DoD Obl.)",
                    "cl_def6_ratio_lag1"="Log(Det. Ind. Ratio)",
                    #Office
                    "c_pMarket"="Percent Market",
                    "cl_OffVol"="Office Volume",
                    "cl_office_naics_hhi_k"="Office Concentration",
                    
                    
                    #interations
                    # # "cl_def6_HHI_lag1:capped_cl_Days"="Log(Det. Ind. HHI):Log(Init. Days)",
                    # "cl_def6_HHI_lag1:cl_def6_obl_lag1"="Log(Det. Ind. HHI):Log(Det. Ind. DoD Obl.)",
                    # # "cl_def3_HHI_lag1:cl_def3_ratio_lag1"="Log(Subsector HHI):Log(Subsector Ratio)"),
                    "cl_def6_HHI_lag1:b_UCA"="Log(Det. Ind. HHI):UCA",
                    # "cl_Ceil:b_UCA"="Log(Init. Ceiling):UCA",
                    # "CompOffr1 offer:b_UCA"="Comp=1 offer:UCA",
                    # "CompOffr2 offers:b_UCA"="Comp=2 offers:UCA",
                    # "CompOffr3-4 offers:b_UCA"="Comp=3-4 offers:UCA",
                    # "CompOffr5+ offers:b_UCA"="Comp=5+ offers:UCA"
                    "VehS-IDC:b_Intl"="Vehicle=S-IDC:Performed Abroad",
                    "VehM-IDC:b_Intl"="Vehicle=M-IDC:Performed Abroad",
                    "VehFSS/GWAC:b_Intl"="Vehicle=FSS/GWAC:Performed Abroad",
                    "VehBPA/BOA:b_Intl"="Vehicle=BPA/BOA:Performed Abroad",
                    "cl_US6_avg_sal_lag1:PricingFeeOther FP"="Pricing=Other FP:Log(Det. Ind. U.S. Avg. Salary)",
                    "cl_US6_avg_sal_lag1:PricingFeeIncentive"="Pricing=Incentive Fee:Log(Det. Ind. U.S. Avg. Salary)",
                    "cl_US6_avg_sal_lag1:PricingFeeCombination or Other"="Pricing=Comb./or Other:Log(Det. Ind. U.S. Avg. Salary)",
                    "cl_US6_avg_sal_lag1:PricingFeeOther CB"="Pricing=Other CB:Log(Det. Ind. U.S. Avg. Salary)",
                    "cl_US6_avg_sal_lag1:PricingFeeT&M/LH/FPLOE"="Pricing=T&M/LH/FP:LoE:Log(Det. Ind. U.S. Avg. Salary)"
)


#Terminations
stargazer::stargazer(Term_01A,Term_01B,Term_02A,Term_02B,Term_03A,Term_03B,Term_03D,
                       type="text",
                       digits=2)
```

```
## 
## =====================================================================================================
##                                                      Dependent variable:                             
##                          ----------------------------------------------------------------------------
##                                                             b_Term                                   
##                             (1)        (2)        (3)        (4)        (5)        (6)        (7)    
## -----------------------------------------------------------------------------------------------------
## cl_US6_avg_sal_lag1Const  0.10***                                                            -0.06*  
##                            (0.03)                                                            (0.03)  
##                                                                                                      
## cl_CFTE                                0.04                                                  0.07**  
##                                       (0.03)                                                 (0.03)  
##                                                                                                      
## c_pPBSC                                         0.27***                                       0.03   
##                                                  (0.03)                                      (0.03)  
##                                                                                                      
## c_pOffPSC                                                  0.50***                          0.37***  
##                                                             (0.02)                           (0.03)  
##                                                                                                      
## c_pairHist                                                             0.001                -0.23*** 
##                                                                        (0.03)                (0.03)  
##                                                                                                      
## cl_pairCA                                                                        0.47***    0.41***  
##                                                                                   (0.03)     (0.03)  
##                                                                                                      
## Constant                  -3.95***   -3.95***   -3.96***   -3.98***   -3.95***   -3.97***   -3.99*** 
##                            (0.01)     (0.01)     (0.01)     (0.02)     (0.01)     (0.02)     (0.02)  
##                                                                                                      
## -----------------------------------------------------------------------------------------------------
## Observations              250,000    250,000    250,000    250,000    250,000    250,000    250,000  
## Log Likelihood           -23,414.38 -23,419.06 -23,375.66 -23,229.80 -23,419.82 -23,276.44 -23,149.37
## Akaike Inf. Crit.        46,832.76  46,842.12  46,755.33  46,463.61  46,843.64  46,556.88  46,312.75 
## =====================================================================================================
## Note:                                                                     *p<0.1; **p<0.05; ***p<0.01
```

```r
texreg::htmlreg(list(Term_01A,Term_01B,Term_02A,Term_02B,Term_03A,Term_03B,Term_03D),file="..//Output//Term_Model.html",
                single.row = TRUE,
                # custom.model.name=c("Ceiling Breaches"),
                stars=c(0.1,0.05,0.01,0.001),
                groups = list(
                              "Services Complexity" = 2:3,
                              "Office Capacity" =4:5,
                              "Past Relationship"=6:7
                              ),
                custom.coef.map=all_coef_list,
                bold=0.05,
                custom.note="%stars. Numerical inputs are rescaled.",
                caption="Table 7: Logit Bivariate Look at Study Variables and Terminations",
                caption.above=TRUE)
```

```
## The table was written to the file '..//Output//Term_Model.html'.
```

# Controls

##Contract-Level Controls
###Scope Variables
#### 04A: Cost Ceiling

Expectation: Initial Ceiling size positively estimates increasing probability of ceiling breaches and terminations and negatively estimates the option growth. Terminations and ceiling breaches simply comes down to large being associated with higher risk, while for option growth size imply makes it harder to grow proportionally.



```r
#Frequency Plot for unlogged ceiling
freq_continuous_term_plot(serv_smp,"UnmodifiedContractBaseAndAllOptionsValue.OMB20_GDP18",
               bins=1000)
```

![](Model_Termination_files/figure-html/Model04A-1.png)<!-- -->

```r
freq_continuous_term_plot(subset(serv_smp,UnmodifiedContractBaseAndAllOptionsValue.OMB20_GDP18<100000000),
               "UnmodifiedContractBaseAndAllOptionsValue.OMB20_GDP18",
               bins=1000)
```

![](Model_Termination_files/figure-html/Model04A-2.png)<!-- -->

```r
summary_continuous_plot(serv_smp,"cl_Ceil",bins=50)
```

![](Model_Termination_files/figure-html/Model04A-3.png)<!-- -->

```r
summary(serv_smp$cl_Ceil)
```

```
##     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
## -3.39507 -0.33607 -0.01080  0.01125  0.31925  3.24200
```

```r
str(serv_smp)
```

```
## Classes 'grouped_df', 'tbl_df', 'tbl' and 'data.frame':	250000 obs. of  249 variables:
##  $ CSIScontractID                                      : num  19015001 19101209 24640201 26380332 27836378 ...
##  $ Action_Obligation.Then.Year                         : num  34772 32784 1172796 290276 51362 ...
##  $ IsClosed                                            : num  0 0 0 0 0 0 0 0 1 0 ...
##  $ Term                                                : num  0 0 0 0 0 0 0 0 1 0 ...
##  $ LastCurrentCompletionDate                           : Date, format: "2012-11-02" "2008-08-22" ...
##  $ MinOfSignedDate                                     : Date, format: "2012-05-24" "2008-05-23" ...
##  $ MaxBoostDate                                        : Date, format: "2012-05-24" "2008-05-23" ...
##  $ StartFY                                             : num  2012 2008 2010 2013 2014 ...
##  $ Agency                                              : Factor w/ 38 levels "*ODD","1450",..: 3 3 4 4 3 4 25 3 4 4 ...
##  $ Office                                              : chr  "N40080" "N69450" "W911S2" "W912BU" ...
##  $ ProdServ                                            : Factor w/ 3088 levels "","1000","1005",..: 3066 2913 2769 2414 2513 2872 1429 1979 3088 2549 ...
##  $ NAICS                                               : num  237310 237310 236220 541620 488310 ...
##  $ UnmodifiedDays                                      : num  163 92 366 431 4 ...
##  $ qDuration                                           : Ord.factor w/ 5 levels "[0 months,~2 months)"<..: 2 2 4 4 1 1 2 1 4 1 ...
##  $ Ceil                                                : Ord.factor w/ 6 levels "[0,15k)"<"[15k,100k)"<..: 2 2 4 3 2 4 1 2 3 3 ...
##  $ UnmodifiedContractBaseAndAllOptionsValue.Then.Year  : num  34772 32784 1174805 290276 27900 ...
##  $ UnmodifiedCurrentCompletionDate                     : Date, format: "2012-11-02" "2008-08-22" ...
##  $ SumOfisChangeOrder                                  : int  0 0 1 0 0 0 0 0 0 0 ...
##  $ ChangeOrderBaseAndAllOptionsValue                   : num  0 0 -2009 0 0 ...
##  $ qNChg                                               : Factor w/ 4 levels "   0","   1",..: 1 1 2 1 1 1 1 1 1 1 ...
##  $ CBre                                                : Ord.factor w/ 2 levels "None"<"Ceiling Breach": 1 1 1 1 1 1 1 1 1 1 ...
##  $ qCRais                                              : Factor w/ 4 levels "[  -Inf,-0.001)",..: 2 2 1 2 2 2 2 2 2 2 ...
##  $ Where                                               : Factor w/ 204 levels "AFG","AGO","ALB",..: 192 192 192 78 192 192 192 19 121 1 ...
##  $ Intl                                                : Factor w/ 2 levels "Just U.S.","Any Intl.": 1 1 1 2 1 1 1 2 2 2 ...
##  $ PSR                                                 : Factor w/ 3 levels "Products","R&D",..: 3 3 3 3 3 3 3 3 3 3 ...
##  $ UnmodifiedNumberOfOffersReceived                    : num  7 3 2 1 9 15 8 1 4 1 ...
##  $ Offr                                                : Ord.factor w/ 4 levels "1"<"2"<"3-4"<..: 4 3 2 1 4 4 4 1 3 1 ...
##  $ Comp                                                : Factor w/ 2 levels "No Comp.","Comp.": 2 2 1 1 2 2 2 1 2 2 ...
##  $ EffComp                                             : Factor w/ 3 levels "No Comp.","1 Offer",..: 3 3 1 1 3 3 3 1 3 2 ...
##  $ Urg                                                 : Factor w/ 2 levels "Not Urgency",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ Veh                                                 : Factor w/ 5 levels "Def/Pur","S-IDC",..: 2 2 2 4 2 2 5 2 1 1 ...
##  $ FxCb                                                : Factor w/ 3 levels "Fixed","Combo/Other",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ Fee                                                 : Ord.factor w/ 6 levels "Incentive"<"Fixed Fee"<..: 4 4 4 4 4 4 4 4 4 4 ...
##  $ UCA                                                 : Factor w/ 2 levels "Not UCA","UCA": 1 1 1 1 1 1 1 1 1 1 ...
##  $ EntityID                                            : num  31937 427894 60938 683522 316618 ...
##  $ UnmodifiedEntityID                                  : num  31937 427894 60938 683522 316618 ...
##  $ PlaceCountryISO3                                    : Factor w/ 225 levels "*MF","*MU","AFG",..: 211 211 211 88 211 211 211 22 134 3 ...
##  $ Crisis                                              : Factor w/ 4 levels "Other","ARRA",..: 1 1 1 1 1 1 1 4 1 4 ...
##  $ b_Term                                              : num  0 0 0 0 0 0 0 0 1 0 ...
##  $ j_Term                                              : num  0.0436 0.02902 0.01707 0.01272 0.00879 ...
##  $ b_CBre                                              : num  0 0 0 0 0 0 0 0 0 0 ...
##  $ j_CBre                                              : num  0.0136 0.0198 0.0348 0.026 0.0233 ...
##  $ pChangeOrderBaseAndAllOptionsValue                  : num  0 0 -0.00171 0 0 ...
##  $ pChange3Sig                                         : num  0 0 -0.002 0 0 0 0 0 0 0 ...
##  $ qCrai                                               : Factor w/ 4 levels "[  -Inf,-0.001)",..: 2 2 1 2 2 2 2 2 2 2 ...
##  $ Action_Obligation.OMB20_GDP18                       : num  34772 34762 1218869 285031 49477 ...
##  $ UnmodifiedContractBaseAndAllOptionsValue.OMB20_GDP18: num  34772 34762 1220957 285031 26876 ...
##  $ qHighCeiling                                        : Factor w/ 6 levels "[0.00e+00,1.50e+04)",..: 2 2 4 3 2 4 1 2 3 3 ...
##  $ ceil.median.wt                                      : num  38655 38655 2120594 246578 38655 ...
##  $ capped_UnmodifiedDays                               : num  163 92 366 431 4 ...
##  $ cl_Days                                             : num  0.2192 0.0475 0.4621 0.5112 -0.8939 ...
##  $ capped_cl_Days                                      : num  0.2193 0.0476 0.4622 0.5114 -0.8941 ...
##  $ UnmodifiedYearsFloat                                : num  0.446 0.252 1.002 1.18 0.011 ...
##  $ UnmodifiedYearsCat                                  : num  0 0 1 1 0 0 0 0 1 0 ...
##  $ Dur.Simple                                          : Ord.factor w/ 3 levels "<~1 year"<"(~1 year,~2 years]"<..: 1 1 2 2 1 1 1 1 2 1 ...
##  $ n_Fixed                                             : num  1 1 1 1 1 1 1 1 1 1 ...
##  $ n_Incent                                            : num  0 0 0 0 0 0 0 0 0 0 ...
##  $ n_NoFee                                             : num  1 1 1 1 1 1 1 1 1 1 ...
##  $ Pricing                                             : Factor w/ 5 levels "FFP","Other FP",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ PricingFee                                          : Factor w/ 6 levels "FFP","Other FP",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ PricingUCA                                          : Factor w/ 7 levels "Combination or Other",..: 2 2 2 2 2 2 2 2 2 2 ...
##  $ b_Comp                                              : int  1 1 0 0 1 1 1 0 1 1 ...
##  $ n_Comp                                              : Factor w/ 3 levels "0","0.5","1": 3 3 1 1 3 3 3 1 3 2 ...
##  $ q_Offr                                              : Factor w/ 4 levels "1","2","3-4",..: 4 3 2 1 4 4 4 1 3 1 ...
##  $ nq_Offr                                             : num  4 3 0 0 4 4 4 0 3 1 ...
##  $ CompOffr                                            : Factor w/ 5 levels "No Competition",..: 5 4 1 1 5 5 5 1 4 2 ...
##  $ cb_Comp                                             : num  0.271 0.271 -0.729 -0.729 0.271 ...
##  $ cn_Comp                                             : num  0.416 0.416 -0.739 -0.739 0.416 ...
##  $ cn_Offr                                             : num  0.678 0.351 -0.628 -0.628 0.678 ...
##  $ cl_Offr                                             : num  0.5955 0.142 -0.0751 -0.4461 0.73 ...
##  $ b_Urg                                               : num  0 0 0 0 0 0 0 0 0 0 ...
##  $ NoComp                                              : Factor w/ 3 levels "Any Comp.","Other No",..: 1 1 2 2 1 1 1 2 1 1 ...
##  $ NoCompOffr                                          : Factor w/ 5 levels "Other No","Urgency",..: 5 4 1 1 5 5 5 1 4 3 ...
##  $ Comp1or5                                            : Factor w/ 4 levels "No Competition",..: 4 3 1 1 4 4 4 1 3 2 ...
##  $ b_Intl                                              : int  0 0 0 1 0 0 0 1 1 1 ...
##  $ b_UCA                                               : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ SIDV                                                : int  1 1 1 0 1 1 0 1 0 0 ...
##  $ MIDV                                                : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ FSSGWAC                                             : int  0 0 0 1 0 0 0 0 0 0 ...
##  $ BPABOA                                              : int  0 0 0 0 0 0 1 0 0 0 ...
##  $ StartCY                                             : num  2012 2008 2010 2013 2014 ...
##  $ NAICS5                                              : int  23731 23731 23622 54162 48831 23622 51741 33661 23899 53211 ...
##  $ NAICS4                                              : int  2373 2373 2362 5416 4883 2362 5174 3366 2389 5321 ...
##  $ NAICS3                                              : int  237 237 236 541 488 236 517 336 238 532 ...
##  $ NAICS2                                              : chr  "23" "23" "23" "54" ...
##  $ def6_HHI_lag1                                       : num  188.3 528.9 87.5 209.7 2372.4 ...
##  $ def6_obl_lag1                                       : num  1.24e+09 1.53e+09 9.07e+09 3.67e+08 4.00e+07 ...
##  $ def6_ratio_lag1                                     : num  0.0144 0.0144 0.0329 0.0273 0.0175 ...
##  $ US6_avg_sal_lag1                                    : num  50785 50785 56201 61043 53326 ...
##  $ def5_HHI_lag1                                       : num  188.3 528.9 87.5 209.7 2372.4 ...
##  $ def5_obl_lag1                                       : num  1.24e+09 1.53e+09 9.07e+09 3.67e+08 4.00e+07 ...
##  $ def5_ratio_lag1                                     : num  0.0144 0.0144 0.0329 0.0273 0.0175 ...
##  $ US5_avg_sal_lag1                                    : num  50785 50785 56201 61043 53326 ...
##  $ def4_HHI_lag1                                       : num  188.3 528.9 76.4 435.9 544 ...
##  $ def4_obl_lag1                                       : num  1.24e+09 1.53e+09 1.08e+10 8.98e+09 2.69e+08 ...
##  $ def4_ratio_lag1                                     : num  0.0144 0.0144 0.0361 0.0433 0.0147 ...
##  $ US4_avg_sal_lag1                                    : num  50785 50785 56024 76717 59582 ...
##  $ def3_HHI_lag1                                       : num  149.9 90.3 73.2 74.5 979.6 ...
##  $ def3_obl_lag1                                       : num  6.94e+09 5.99e+09 1.19e+10 8.77e+10 4.80e+09 ...
##   [list output truncated]
##  - attr(*, "groups")=Classes 'tbl_df', 'tbl' and 'data.frame':	6 obs. of  2 variables:
##   ..$ qHighCeiling: Factor w/ 6 levels "[0.00e+00,1.50e+04)",..: 1 2 3 4 5 6
##   ..$ .rows       :List of 6
##   .. ..$ : int  7 14 16 18 21 26 28 32 35 36 ...
##   .. ..$ : int  1 2 5 8 12 23 24 27 29 30 ...
##   .. ..$ : int  4 9 10 11 15 17 19 22 25 41 ...
##   .. ..$ : int  3 6 13 20 40 51 86 94 98 109 ...
##   .. ..$ : int  74 114 119 133 1234 1307 1448 1518 1539 1551 ...
##   .. ..$ : int  353 934 1884 2005 2022 2661 3036 5840 7103 7109 ...
##   ..- attr(*, ".drop")= logi TRUE
```

```r
#Model
Term_04A <- glm (data=serv_smp,
                 b_Term ~ cl_Ceil, family=binomial(link="logit"))
display(Term_04A)
```

```
## glm(formula = b_Term ~ cl_Ceil, family = binomial(link = "logit"), 
##     data = serv_smp)
##             coef.est coef.se
## (Intercept) -4.03     0.02  
## cl_Ceil      0.76     0.03  
## ---
##   n = 250000, k = 2
##   residual deviance = 46173.0, null deviance = 46839.6 (difference = 666.6)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_03D,Term_04A,
                       
                       type="text",
                       digits=2)
```

```
## 
## =====================================================
##                              Dependent variable:     
##                          ----------------------------
##                                     b_Term           
##                               (1)            (2)     
## -----------------------------------------------------
## cl_US6_avg_sal_lag1Const     -0.06*                  
##                              (0.03)                  
##                                                      
## cl_CFTE                      0.07**                  
##                              (0.03)                  
##                                                      
## c_pPBSC                       0.03                   
##                              (0.03)                  
##                                                      
## c_pOffPSC                   0.37***                  
##                              (0.03)                  
##                                                      
## c_pairHist                  -0.23***                 
##                              (0.03)                  
##                                                      
## cl_pairCA                   0.41***                  
##                              (0.03)                  
##                                                      
## cl_Ceil                                    0.76***   
##                                            (0.03)    
##                                                      
## Constant                    -3.99***      -4.03***   
##                              (0.02)        (0.02)    
##                                                      
## -----------------------------------------------------
## Observations                250,000        250,000   
## Log Likelihood             -23,149.37    -23,086.52  
## Akaike Inf. Crit.          46,312.75      46,177.04  
## =====================================================
## Note:                     *p<0.1; **p<0.05; ***p<0.01
```

```r
#summary_residual_compare(Term_03D,Term_04A, skip_vif = TRUE)
```

Contract ceiling has a significant relationship, though the residuals show a possible non-linear patterns. This is most remarkable in the positive centered values between 0 and 1. This may be driven  by a missing value and is worth watching.
Expectations upheld for ceiling breaches and terminations. Weak expectations for options growth were countered.

#### 04B: Maximum Duration

Expectation: Greater maximum duration will positively estimate the probability ceiling of  breaches and terminations. Greater growth for options is also expected, because year-on-year options may be more of a default, though the scatter plot seems to go the other way.


```r
#Frequency Plot for max duration
freq_continuous_term_plot(serv_smp,"UnmodifiedDays",
               bins=1000)
```

![](Model_Termination_files/figure-html/Model04B-1.png)<!-- -->

```r
summary_continuous_plot(serv_smp,"capped_cl_Days")
```

![](Model_Termination_files/figure-html/Model04B-2.png)<!-- -->

```r
#Model
Term_04B <- glm (data=serv_smp,
                 b_Term ~ capped_cl_Days, family=binomial(link="logit"))

display(Term_04B)
```

```
## glm(formula = b_Term ~ capped_cl_Days, family = binomial(link = "logit"), 
##     data = serv_smp)
##                coef.est coef.se
## (Intercept)    -4.14     0.02  
## capped_cl_Days  1.40     0.04  
## ---
##   n = 250000, k = 2
##   residual deviance = 45342.4, null deviance = 46839.6 (difference = 1497.2)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_03D,Term_04A,Term_04B,
                       
                       type="text",
                       digits=2)
```

```
## 
## =========================================================
##                                Dependent variable:       
##                          --------------------------------
##                                       b_Term             
##                             (1)        (2)        (3)    
## ---------------------------------------------------------
## cl_US6_avg_sal_lag1Const   -0.06*                        
##                            (0.03)                        
##                                                          
## cl_CFTE                    0.07**                        
##                            (0.03)                        
##                                                          
## c_pPBSC                     0.03                         
##                            (0.03)                        
##                                                          
## c_pOffPSC                 0.37***                        
##                            (0.03)                        
##                                                          
## c_pairHist                -0.23***                       
##                            (0.03)                        
##                                                          
## cl_pairCA                 0.41***                        
##                            (0.03)                        
##                                                          
## cl_Ceil                              0.76***             
##                                       (0.03)             
##                                                          
## capped_cl_Days                                  1.40***  
##                                                  (0.04)  
##                                                          
## Constant                  -3.99***   -4.03***   -4.14*** 
##                            (0.02)     (0.02)     (0.02)  
##                                                          
## ---------------------------------------------------------
## Observations              250,000    250,000    250,000  
## Log Likelihood           -23,149.37 -23,086.52 -22,671.21
## Akaike Inf. Crit.        46,312.75  46,177.04  45,346.41 
## =========================================================
## Note:                         *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_03D,Term_04B, skip_vif = TRUE)
```

![](Model_Termination_files/figure-html/Model04B-3.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model04B-4.png)<!-- -->

```
## NULL
```

```r
summary_residual_compare(Term_04A,Term_04B, skip_vif = TRUE)
```

![](Model_Termination_files/figure-html/Model04B-5.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used

## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

![](Model_Termination_files/figure-html/Model04B-6.png)<!-- -->

```
## NULL
```

All expections were upheld.

#### 04C: Both Scope variables


```r
#Model
Term_04C <- glm (data=serv_smp,
                 b_Term ~ cl_Ceil +capped_cl_Days, family=binomial(link="logit"))
display(Term_04C)
```

```
## glm(formula = b_Term ~ cl_Ceil + capped_cl_Days, family = binomial(link = "logit"), 
##     data = serv_smp)
##                coef.est coef.se
## (Intercept)    -4.15     0.02  
## cl_Ceil         0.33     0.03  
## capped_cl_Days  1.24     0.04  
## ---
##   n = 250000, k = 3
##   residual deviance = 45241.5, null deviance = 46839.6 (difference = 1598.1)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_03D,Term_04A,Term_04B,Term_04C,
                       
                       type="text",
                       digits=2)
```

```
## 
## ====================================================================
##                                      Dependent variable:            
##                          -------------------------------------------
##                                            b_Term                   
##                             (1)        (2)        (3)        (4)    
## --------------------------------------------------------------------
## cl_US6_avg_sal_lag1Const   -0.06*                                   
##                            (0.03)                                   
##                                                                     
## cl_CFTE                    0.07**                                   
##                            (0.03)                                   
##                                                                     
## c_pPBSC                     0.03                                    
##                            (0.03)                                   
##                                                                     
## c_pOffPSC                 0.37***                                   
##                            (0.03)                                   
##                                                                     
## c_pairHist                -0.23***                                  
##                            (0.03)                                   
##                                                                     
## cl_pairCA                 0.41***                                   
##                            (0.03)                                   
##                                                                     
## cl_Ceil                              0.76***               0.33***  
##                                       (0.03)                (0.03)  
##                                                                     
## capped_cl_Days                                  1.40***    1.24***  
##                                                  (0.04)     (0.04)  
##                                                                     
## Constant                  -3.99***   -4.03***   -4.14***   -4.15*** 
##                            (0.02)     (0.02)     (0.02)     (0.02)  
##                                                                     
## --------------------------------------------------------------------
## Observations              250,000    250,000    250,000    250,000  
## Log Likelihood           -23,149.37 -23,086.52 -22,671.21 -22,620.77
## Akaike Inf. Crit.        46,312.75  46,177.04  45,346.41  45,247.54 
## ====================================================================
## Note:                                    *p<0.1; **p<0.05; ***p<0.01
```

```r
#summary_residual_compare(Term_03D,Term_04C)
#summary_residual_compare(Term_04A,Term_04C)
#summary_residual_compare(Term_04B,Term_04C)
```
Days loses significance for ceiling breaches. Ceiling has a smaller coefficient for terminations. Otherwise largely unchanged.

#### 04D: Cumulative  Model


```r
#Model
Term_04D <- glm (data=serv_smp,
                 b_Term ~ cl_US6_avg_sal_lag1Const + 
                   cl_CFTE+ c_pPBSC+c_pOffPSC+
                   c_pairHist+cl_pairCA+
                   cl_Ceil + capped_cl_Days, family=binomial(link="logit"))
glmer_examine(Term_04D)
```

```
## cl_US6_avg_sal_lag1Const                  cl_CFTE                  c_pPBSC 
##                 1.377677                 1.248554                 1.281831 
##                c_pOffPSC               c_pairHist                cl_pairCA 
##                 1.416182                 1.217292                 1.492250 
##                  cl_Ceil           capped_cl_Days 
##                 1.213180                 1.197587
```

```r
#Plot residuals versus fitted   

stargazer::stargazer(
                       Term_03D,Term_04C,Term_04D,
                       
                       type="text",
                       digits=2)
```

```
## 
## =========================================================
##                                Dependent variable:       
##                          --------------------------------
##                                       b_Term             
##                             (1)        (2)        (3)    
## ---------------------------------------------------------
## cl_US6_avg_sal_lag1Const   -0.06*               -0.41*** 
##                            (0.03)                (0.04)  
##                                                          
## cl_CFTE                    0.07**                0.001   
##                            (0.03)                (0.03)  
##                                                          
## c_pPBSC                     0.03                0.08***  
##                            (0.03)                (0.03)  
##                                                          
## c_pOffPSC                 0.37***               0.56***  
##                            (0.03)                (0.03)  
##                                                          
## c_pairHist                -0.23***              -0.28*** 
##                            (0.03)                (0.03)  
##                                                          
## cl_pairCA                 0.41***               0.41***  
##                            (0.03)                (0.03)  
##                                                          
## cl_Ceil                              0.33***    0.38***  
##                                       (0.03)     (0.03)  
##                                                          
## capped_cl_Days                       1.24***    1.39***  
##                                       (0.04)     (0.04)  
##                                                          
## Constant                  -3.99***   -4.15***   -4.23*** 
##                            (0.02)     (0.02)     (0.02)  
##                                                          
## ---------------------------------------------------------
## Observations              250,000    250,000    250,000  
## Log Likelihood           -23,149.37 -22,620.77 -22,192.22
## Akaike Inf. Crit.        46,312.75  45,247.54  44,402.44 
## =========================================================
## Note:                         *p<0.1; **p<0.05; ***p<0.01
```

```r
#summary_residual_compare(Term_03D,Term_04D)
#summary_residual_compare(Term_04C,Term_04D)
```
Salary no longer matches expectations for ceiling breaches. Invoice rate is no longer significant for terminations. 


### Competition
#### 05A: No Competition / 1 / 2-4 / 5+ Offers
Expectations
No Competition (Baseline)			+	-	-
1 Offer			+	-	-
2-4 Offers			-	+	+
5+ Offers			-	+	-


```r
summary_discrete_plot(serv_smp,"Comp1or5")
```

```
## Warning: Ignoring unknown parameters: binwidth, bins, pad
```

![](Model_Termination_files/figure-html/Model05A-1.png)<!-- -->

```
## [[1]]
## 
## No Competition        1 offer     2-4 offers      5+ offers 
##          69119          42631          83977          54273 
## 
## [[2]]
##                 
##                   None Ceiling Breach
##   No Competition 66020           3099
##   1 offer        41141           1490
##   2-4 offers     78621           5356
##   5+ offers      50121           4152
## 
## [[3]]
##                 
##                      0     1
##   No Competition 68283   836
##   1 offer        41970   661
##   2-4 offers     82682  1295
##   5+ offers      52343  1930
```

```r
#Model
Term_05A <- glm (data=serv_smp,
                 b_Term ~ Comp1or5, family=binomial(link="logit"))

display(Term_05A)
```

```
## glm(formula = b_Term ~ Comp1or5, family = binomial(link = "logit"), 
##     data = serv_smp)
##                    coef.est coef.se
## (Intercept)        -4.40     0.03  
## Comp1or51 offer     0.25     0.05  
## Comp1or52-4 offers  0.25     0.04  
## Comp1or55+ offers   1.10     0.04  
## ---
##   n = 250000, k = 4
##   residual deviance = 45908.5, null deviance = 46839.6 (difference = 931.1)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_04D,Term_05A,
                       
                       type="text",
                       digits=2)
```

```
## 
## =====================================================
##                              Dependent variable:     
##                          ----------------------------
##                                     b_Term           
##                               (1)            (2)     
## -----------------------------------------------------
## cl_US6_avg_sal_lag1Const    -0.41***                 
##                              (0.04)                  
##                                                      
## cl_CFTE                      0.001                   
##                              (0.03)                  
##                                                      
## c_pPBSC                     0.08***                  
##                              (0.03)                  
##                                                      
## c_pOffPSC                   0.56***                  
##                              (0.03)                  
##                                                      
## c_pairHist                  -0.28***                 
##                              (0.03)                  
##                                                      
## cl_pairCA                   0.41***                  
##                              (0.03)                  
##                                                      
## cl_Ceil                     0.38***                  
##                              (0.03)                  
##                                                      
## capped_cl_Days              1.39***                  
##                              (0.04)                  
##                                                      
## Comp1or51 offer                            0.25***   
##                                            (0.05)    
##                                                      
## Comp1or52-4 offers                         0.25***   
##                                            (0.04)    
##                                                      
## Comp1or55+ offers                          1.10***   
##                                            (0.04)    
##                                                      
## Constant                    -4.23***      -4.40***   
##                              (0.02)        (0.03)    
##                                                      
## -----------------------------------------------------
## Observations                250,000        250,000   
## Log Likelihood             -22,192.22    -22,954.26  
## Akaike Inf. Crit.          44,402.44      45,916.52  
## =====================================================
## Note:                     *p<0.1; **p<0.05; ***p<0.01
```
Expectations were completely unmet for ceiling breaches. For terminations, expectations were met for 2-4 offers and 5+ offers, but not for 1 offer. For ceiling breaches expectations were met for 1 offer, but not for 2-4 or 5+.

#### 05B: Cumulative  Model


```r
#Model
Term_05B <- glm (data=serv_smp,
                 b_Term ~ cl_US6_avg_sal_lag1Const + 
                   cl_CFTE+ c_pPBSC+c_pOffPSC+
                   c_pairHist+cl_pairCA+
                   cl_Ceil + capped_cl_Days+
                   Comp1or5, family=binomial(link="logit"))

glmer_examine(Term_05B)
```

```
##                              GVIF Df GVIF^(1/(2*Df))
## cl_US6_avg_sal_lag1Const 1.404354  1        1.185054
## cl_CFTE                  1.269042  1        1.126518
## c_pPBSC                  1.326296  1        1.151649
## c_pOffPSC                1.474135  1        1.214139
## c_pairHist               1.229930  1        1.109022
## cl_pairCA                1.541963  1        1.241758
## cl_Ceil                  1.229339  1        1.108755
## capped_cl_Days           1.201378  1        1.096074
## Comp1or5                 1.069184  3        1.011212
```

```r
#Plot residuals versus fitted   

stargazer::stargazer(
                       Term_04D,Term_05A,Term_05B,
                       
                       type="text",
                       digits=2)
```

```
## 
## =========================================================
##                                Dependent variable:       
##                          --------------------------------
##                                       b_Term             
##                             (1)        (2)        (3)    
## ---------------------------------------------------------
## cl_US6_avg_sal_lag1Const  -0.41***              -0.38*** 
##                            (0.04)                (0.04)  
##                                                          
## cl_CFTE                    0.001                 -0.05   
##                            (0.03)                (0.03)  
##                                                          
## c_pPBSC                   0.08***                0.06*   
##                            (0.03)                (0.03)  
##                                                          
## c_pOffPSC                 0.56***               0.56***  
##                            (0.03)                (0.03)  
##                                                          
## c_pairHist                -0.28***              -0.23*** 
##                            (0.03)                (0.03)  
##                                                          
## cl_pairCA                 0.41***               0.31***  
##                            (0.03)                (0.03)  
##                                                          
## cl_Ceil                   0.38***               0.32***  
##                            (0.03)                (0.03)  
##                                                          
## capped_cl_Days            1.39***               1.40***  
##                            (0.04)                (0.04)  
##                                                          
## Comp1or51 offer                      0.25***    0.31***  
##                                       (0.05)     (0.05)  
##                                                          
## Comp1or52-4 offers                   0.25***    0.15***  
##                                       (0.04)     (0.05)  
##                                                          
## Comp1or55+ offers                    1.10***    0.90***  
##                                       (0.04)     (0.04)  
##                                                          
## Constant                  -4.23***   -4.40***   -4.59*** 
##                            (0.02)     (0.03)     (0.04)  
##                                                          
## ---------------------------------------------------------
## Observations              250,000    250,000    250,000  
## Log Likelihood           -22,192.22 -22,954.26 -21,882.87
## Akaike Inf. Crit.        44,402.44  45,916.52  43,789.73 
## =========================================================
## Note:                         *p<0.1; **p<0.05; ***p<0.01
```

```r
#summary_residual_compare(Term_04D,Term_05B)
```
Minimal effect on study variables. 2-4 offers for terminations is not  longer significant, it's really 5+ that boosts the risks. But for exercised options, 5+ leads to more options while fewer having negative relationship with 2-4 offers, but only significant with p-value < 0.1 

### Contract Vehicle

#### 06A: Def/Pur; S-IDC; M-IDC; FSS-GWAC; BPA-BOA.

Old text:
Expectation: Indefinite delivery vehicles, means that the government has an existing relationship with the vendor and administration is easier. The downside is that the government may be locked into the vendor, although exit does not necessarily require outright termination, instead the government may simply cease to use a vehicle. Taken together, across the board the four categories of vehicles are expected to  negatively estimate the probability of termination. Ceiling breaches are a more complex topic and the study team does not have immediate expecations aside from likely significance.
Definitive Contract (base)			+	+	+
Single-Award IDC			-	-	-
Multi-Award IDC			-	-	-
FSS/GWAC			-	-	-
BPA/BOA			-	-	-



```r
summary_discrete_plot(serv_smp,"Veh")
```

```
## Warning: Ignoring unknown parameters: binwidth, bins, pad
```

![](Model_Termination_files/figure-html/Model06A-1.png)<!-- -->

```
## [[1]]
## 
##  Def/Pur    S-IDC    M-IDC FSS/GWAC  BPA/BOA 
##    75929   122437    29968    11005    10661 
## 
## [[2]]
##           
##              None Ceiling Breach
##   Def/Pur   71858           4071
##   S-IDC    115315           7122
##   M-IDC     27841           2127
##   FSS/GWAC  10587            418
##   BPA/BOA   10302            359
## 
## [[3]]
##           
##                 0      1
##   Def/Pur   74076   1853
##   S-IDC    120648   1789
##   M-IDC     29225    743
##   FSS/GWAC  10772    233
##   BPA/BOA   10557    104
```

```r
#Model
Term_06A <- glm (data=serv_smp,
                 b_Term ~ Veh, family=binomial(link="logit"))

display(Term_06A)
```

```
## glm(formula = b_Term ~ Veh, family = binomial(link = "logit"), 
##     data = serv_smp)
##             coef.est coef.se
## (Intercept) -3.69     0.02  
## VehS-IDC    -0.52     0.03  
## VehM-IDC     0.02     0.04  
## VehFSS/GWAC -0.15     0.07  
## VehBPA/BOA  -0.93     0.10  
## ---
##   n = 250000, k = 5
##   residual deviance = 46481.9, null deviance = 46839.6 (difference = 357.8)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_05B,Term_06A,
                       
                       type="text",
                       digits=2)
```

```
## 
## =====================================================
##                              Dependent variable:     
##                          ----------------------------
##                                     b_Term           
##                               (1)            (2)     
## -----------------------------------------------------
## cl_US6_avg_sal_lag1Const    -0.38***                 
##                              (0.04)                  
##                                                      
## cl_CFTE                      -0.05                   
##                              (0.03)                  
##                                                      
## c_pPBSC                      0.06*                   
##                              (0.03)                  
##                                                      
## c_pOffPSC                   0.56***                  
##                              (0.03)                  
##                                                      
## c_pairHist                  -0.23***                 
##                              (0.03)                  
##                                                      
## cl_pairCA                   0.31***                  
##                              (0.03)                  
##                                                      
## cl_Ceil                     0.32***                  
##                              (0.03)                  
##                                                      
## capped_cl_Days              1.40***                  
##                              (0.04)                  
##                                                      
## Comp1or51 offer             0.31***                  
##                              (0.05)                  
##                                                      
## Comp1or52-4 offers          0.15***                  
##                              (0.05)                  
##                                                      
## Comp1or55+ offers           0.90***                  
##                              (0.04)                  
##                                                      
## VehS-IDC                                  -0.52***   
##                                            (0.03)    
##                                                      
## VehM-IDC                                    0.02     
##                                            (0.04)    
##                                                      
## VehFSS/GWAC                                -0.15**   
##                                            (0.07)    
##                                                      
## VehBPA/BOA                                -0.93***   
##                                            (0.10)    
##                                                      
## Constant                    -4.59***      -3.69***   
##                              (0.04)        (0.02)    
##                                                      
## -----------------------------------------------------
## Observations                250,000        250,000   
## Log Likelihood             -21,882.87    -23,240.93  
## Akaike Inf. Crit.          43,789.73      46,491.86  
## =====================================================
## Note:                     *p<0.1; **p<0.05; ***p<0.01
```

```r
#summary_residual_compare(Term_05D,Term_06A)
```
For ceiling breaches, IDCs, particularly multiaward IDCs, were more likely to have breaches contrary to expecatitions.

For terminations expectation were upheld or S-IDCs and BPA/BOA. They were not upheld for multi-award, which is significantly more likely to be terminated.

Expectations were largely upheld for options exercised, with the exception of FSS/GWAC.


#### 06B: Cumulative  Model


```r
#Model
Term_06B <- glm (data=serv_smp,
                 b_Term ~ cl_US6_avg_sal_lag1Const + 
                   cl_CFTE+ c_pPBSC+c_pOffPSC+
                   c_pairHist+cl_pairCA+
                   cl_Ceil + capped_cl_Days+
                   Comp1or5+
                   Veh, family=binomial(link="logit"))

glmer_examine(Term_06B)
```

```
##                              GVIF Df GVIF^(1/(2*Df))
## cl_US6_avg_sal_lag1Const 1.413849  1        1.189054
## cl_CFTE                  1.230828  1        1.109427
## c_pPBSC                  1.367288  1        1.169311
## c_pOffPSC                1.503765  1        1.226281
## c_pairHist               1.303575  1        1.141742
## cl_pairCA                1.782565  1        1.335127
## cl_Ceil                  1.284827  1        1.133502
## capped_cl_Days           1.184822  1        1.088495
## Comp1or5                 1.201495  3        1.031067
## Veh                      1.627168  4        1.062745
```

```r
#Plot residuals versus fitted   

stargazer::stargazer(
                       Term_05B,Term_06A,Term_06B,
                       
                       type="text",
                       digits=2)
```

```
## 
## =========================================================
##                                Dependent variable:       
##                          --------------------------------
##                                       b_Term             
##                             (1)        (2)        (3)    
## ---------------------------------------------------------
## cl_US6_avg_sal_lag1Const  -0.38***              -0.28*** 
##                            (0.04)                (0.04)  
##                                                          
## cl_CFTE                    -0.05                 -0.02   
##                            (0.03)                (0.03)  
##                                                          
## c_pPBSC                    0.06*                 -0.03   
##                            (0.03)                (0.03)  
##                                                          
## c_pOffPSC                 0.56***               0.69***  
##                            (0.03)                (0.03)  
##                                                          
## c_pairHist                -0.23***              -0.09*** 
##                            (0.03)                (0.03)  
##                                                          
## cl_pairCA                 0.31***               0.58***  
##                            (0.03)                (0.03)  
##                                                          
## cl_Ceil                   0.32***               0.28***  
##                            (0.03)                (0.03)  
##                                                          
## capped_cl_Days            1.40***               1.39***  
##                            (0.04)                (0.04)  
##                                                          
## Comp1or51 offer           0.31***               0.30***  
##                            (0.05)                (0.05)  
##                                                          
## Comp1or52-4 offers        0.15***               0.29***  
##                            (0.05)                (0.05)  
##                                                          
## Comp1or55+ offers         0.90***               1.19***  
##                            (0.04)                (0.04)  
##                                                          
## VehS-IDC                             -0.52***   -1.29*** 
##                                       (0.03)     (0.04)  
##                                                          
## VehM-IDC                               0.02     -0.94*** 
##                                       (0.04)     (0.05)  
##                                                          
## VehFSS/GWAC                          -0.15**    -0.32*** 
##                                       (0.07)     (0.07)  
##                                                          
## VehBPA/BOA                           -0.93***   -1.22*** 
##                                       (0.10)     (0.10)  
##                                                          
## Constant                  -4.59***   -3.69***   -3.97*** 
##                            (0.04)     (0.02)     (0.04)  
##                                                          
## ---------------------------------------------------------
## Observations              250,000    250,000    250,000  
## Log Likelihood           -21,882.87 -23,240.93 -21,324.25
## Akaike Inf. Crit.        43,789.73  46,491.86  42,680.49 
## =========================================================
## Note:                         *p<0.1; **p<0.05; ***p<0.01
```

```r
#summary_residual_compare(Term_05B,Term_06B)
```
Expectations for vehicle are now upheld for both ceiling breaches and terminations. For other variables the addition of vehicle proved less pivotal, though coefficients were often decreased.

### Type of Contract

The next step adds a measure for whether the contract was cost-based or fixed-price. 

Expectation Prior CSIS research has found that fixed-price contracts estimate a higher probability of terminations but did not find a notable relationship for ceiling breaches.

#### 07A: FFP / Other FP / Incentive / T&M/FP:LOE;LH / Other CB / Combination

Firm-Fixed Price (base)			+	++	+
Other Fixed Price			-	-	-
Time & Materials / Labor Hours / FP: LoE			+	-	-
Incentive Fee (both FPIF or CBIF)			-	-	+
Other Cost Based			-	-	-
Undefinitized Contract Award			++	++	--
Combination			+	+	-



```r
serv_smp$PricingUCA<-factor(serv_smp$PricingUCA,
                            levels=c( "FFP","Other FP","T&M/LH/FPLOE","Incentive","Other CB","UCA" ,"Combination or Other" ))
serv_opt$PricingUCA<-factor(serv_opt$PricingUCA,
                            levels=c( "FFP","Other FP","T&M/LH/FPLOE","Incentive","Other CB","UCA" ,"Combination or Other" ))
  summary_discrete_plot(serv_smp,"PricingUCA")
```

```
## Warning: Ignoring unknown parameters: binwidth, bins, pad
```

![](Model_Termination_files/figure-html/Model07A-1.png)<!-- -->

```
## [[1]]
## 
##                  FFP             Other FP         T&M/LH/FPLOE 
##               222793                 1580                 4704 
##            Incentive             Other CB                  UCA 
##                 1000                14531                 2867 
## Combination or Other 
##                 2525 
## 
## [[2]]
##                       
##                          None Ceiling Breach
##   FFP                  209856          12937
##   Other FP               1537             43
##   T&M/LH/FPLOE           4491            213
##   Incentive               885            115
##   Other CB              14106            425
##   UCA                    2662            205
##   Combination or Other   2366            159
## 
## [[3]]
##                       
##                             0      1
##   FFP                  218279   4514
##   Other FP               1531     49
##   T&M/LH/FPLOE           4657     47
##   Incentive               999      1
##   Other CB              14461     70
##   UCA                    2848     19
##   Combination or Other   2503     22
```

```r
#Model
Term_07A <- glm (data=serv_smp,
                 b_Term ~ PricingUCA, family=binomial(link="logit"))

display(Term_07A)
```

```
## glm(formula = b_Term ~ PricingUCA, family = binomial(link = "logit"), 
##     data = serv_smp)
##                                coef.est coef.se
## (Intercept)                    -3.88     0.02  
## PricingUCAOther FP              0.44     0.15  
## PricingUCAT&M/LH/FPLOE         -0.72     0.15  
## PricingUCAIncentive            -3.03     0.99  
## PricingUCAOther CB             -1.45     0.12  
## PricingUCAUCA                  -1.13     0.23  
## PricingUCACombination or Other -0.86     0.21  
## ---
##   n = 250000, k = 7
##   residual deviance = 46483.4, null deviance = 46839.6 (difference = 356.2)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_06B,Term_07A,
                       
                       type="text",
                       digits=2)
```

```
## 
## ===========================================================
##                                    Dependent variable:     
##                                ----------------------------
##                                           b_Term           
##                                     (1)            (2)     
## -----------------------------------------------------------
## cl_US6_avg_sal_lag1Const          -0.28***                 
##                                    (0.04)                  
##                                                            
## cl_CFTE                            -0.02                   
##                                    (0.03)                  
##                                                            
## c_pPBSC                            -0.03                   
##                                    (0.03)                  
##                                                            
## c_pOffPSC                         0.69***                  
##                                    (0.03)                  
##                                                            
## c_pairHist                        -0.09***                 
##                                    (0.03)                  
##                                                            
## cl_pairCA                         0.58***                  
##                                    (0.03)                  
##                                                            
## cl_Ceil                           0.28***                  
##                                    (0.03)                  
##                                                            
## capped_cl_Days                    1.39***                  
##                                    (0.04)                  
##                                                            
## Comp1or51 offer                   0.30***                  
##                                    (0.05)                  
##                                                            
## Comp1or52-4 offers                0.29***                  
##                                    (0.05)                  
##                                                            
## Comp1or55+ offers                 1.19***                  
##                                    (0.04)                  
##                                                            
## VehS-IDC                          -1.29***                 
##                                    (0.04)                  
##                                                            
## VehM-IDC                          -0.94***                 
##                                    (0.05)                  
##                                                            
## VehFSS/GWAC                       -0.32***                 
##                                    (0.07)                  
##                                                            
## VehBPA/BOA                        -1.22***                 
##                                    (0.10)                  
##                                                            
## PricingUCAOther FP                               0.44***   
##                                                  (0.15)    
##                                                            
## PricingUCAT&M/LH/FPLOE                          -0.72***   
##                                                  (0.15)    
##                                                            
## PricingUCAIncentive                             -3.03***   
##                                                  (0.99)    
##                                                            
## PricingUCAOther CB                              -1.45***   
##                                                  (0.12)    
##                                                            
## PricingUCAUCA                                   -1.13***   
##                                                  (0.23)    
##                                                            
## PricingUCACombination or Other                  -0.86***   
##                                                  (0.21)    
##                                                            
## Constant                          -3.97***      -3.88***   
##                                    (0.04)        (0.02)    
##                                                            
## -----------------------------------------------------------
## Observations                      250,000        250,000   
## Log Likelihood                   -21,324.25    -23,241.71  
## Akaike Inf. Crit.                42,680.49      46,497.43  
## ===========================================================
## Note:                           *p<0.1; **p<0.05; ***p<0.01
```

```r
#summary_residual_compare(Term_06B,Term_07A,30)
```

Other fixed price and other cost based aligned with expecations for ceiling breaches.
For terminations, other fixed price, incentive, cost-based, were line with expectations. 
For options exercied Other fixed-price, incentive, and UCA were in line with expectations

#### 07B: Cumulative  Model


```r
#Model
Term_07B <- glm (data=serv_smp,
                 b_Term ~ cl_US6_avg_sal_lag1Const + 
                   cl_CFTE+ c_pPBSC+c_pOffPSC+
                   c_pairHist+cl_pairCA+
                   cl_Ceil + capped_cl_Days+
                   Comp1or5+
                   Veh+
                   PricingUCA, family=binomial(link="logit"))

glmer_examine(Term_07B)
```

```
##                              GVIF Df GVIF^(1/(2*Df))
## cl_US6_avg_sal_lag1Const 1.368167  1        1.169687
## cl_CFTE                  1.223535  1        1.106135
## c_pPBSC                  1.392201  1        1.179916
## c_pOffPSC                1.518989  1        1.232473
## c_pairHist               1.281360  1        1.131972
## cl_pairCA                1.797937  1        1.340872
## cl_Ceil                  1.303672  1        1.141785
## capped_cl_Days           1.195502  1        1.093390
## Comp1or5                 1.258646  3        1.039084
## Veh                      1.685768  4        1.067455
## PricingUCA               1.111130  6        1.008820
```

```r
#Plot residuals versus fitted   

stargazer::stargazer(
                       Term_06B,Term_07A,Term_07B,
                       
                       type="text",
                       digits=2)
```

```
## 
## ===============================================================
##                                      Dependent variable:       
##                                --------------------------------
##                                             b_Term             
##                                   (1)        (2)        (3)    
## ---------------------------------------------------------------
## cl_US6_avg_sal_lag1Const        -0.28***              -0.23*** 
##                                  (0.04)                (0.04)  
##                                                                
## cl_CFTE                          -0.02                  0.03   
##                                  (0.03)                (0.03)  
##                                                                
## c_pPBSC                          -0.03                 -0.01   
##                                  (0.03)                (0.03)  
##                                                                
## c_pOffPSC                       0.69***               0.71***  
##                                  (0.03)                (0.03)  
##                                                                
## c_pairHist                      -0.09***               -0.06*  
##                                  (0.03)                (0.03)  
##                                                                
## cl_pairCA                       0.58***               0.58***  
##                                  (0.03)                (0.03)  
##                                                                
## cl_Ceil                         0.28***               0.40***  
##                                  (0.03)                (0.03)  
##                                                                
## capped_cl_Days                  1.39***               1.45***  
##                                  (0.04)                (0.04)  
##                                                                
## Comp1or51 offer                 0.30***               0.34***  
##                                  (0.05)                (0.05)  
##                                                                
## Comp1or52-4 offers              0.29***               0.27***  
##                                  (0.05)                (0.05)  
##                                                                
## Comp1or55+ offers               1.19***               1.08***  
##                                  (0.04)                (0.04)  
##                                                                
## VehS-IDC                        -1.29***              -1.15*** 
##                                  (0.04)                (0.04)  
##                                                                
## VehM-IDC                        -0.94***              -0.90*** 
##                                  (0.05)                (0.05)  
##                                                                
## VehFSS/GWAC                     -0.32***              -0.36*** 
##                                  (0.07)                (0.07)  
##                                                                
## VehBPA/BOA                      -1.22***              -1.20*** 
##                                  (0.10)                (0.10)  
##                                                                
## PricingUCAOther FP                         0.44***    -0.42*** 
##                                             (0.15)     (0.15)  
##                                                                
## PricingUCAT&M/LH/FPLOE                     -0.72***   -0.82*** 
##                                             (0.15)     (0.15)  
##                                                                
## PricingUCAIncentive                        -3.03***   -3.64*** 
##                                             (0.99)     (1.00)  
##                                                                
## PricingUCAOther CB                         -1.45***   -1.77*** 
##                                             (0.12)     (0.12)  
##                                                                
## PricingUCAUCA                              -1.13***   -1.14*** 
##                                             (0.23)     (0.23)  
##                                                                
## PricingUCACombination or Other             -0.86***   -1.16*** 
##                                             (0.21)     (0.22)  
##                                                                
## Constant                        -3.97***   -3.88***   -3.93*** 
##                                  (0.04)     (0.02)     (0.04)  
##                                                                
## ---------------------------------------------------------------
## Observations                    250,000    250,000    250,000  
## Log Likelihood                 -21,324.25 -23,241.71 -21,077.26
## Akaike Inf. Crit.              42,680.49  46,497.43  42,198.52 
## ===============================================================
## Note:                               *p<0.1; **p<0.05; ***p<0.01
```

```r
#summary_residual_compare(Term_06B,Term_07B)
#summary_residual_compare(Term_07A,Term_07B,bins=3)
```

Incentive contracts are no longer significantly associated with a greater risk of ceiling breaches, though they have also lost significance in options. Suprirsingly, UCA and Combination or Other have both become significant in for lower risk of ceiling breaches.


### Crisis Dataset
Expectation: Service Contract replying on crisis funds would have more likelihood of cost-ceiling breaches and exercised options but less terminations.  

#### 08A: Crisis Funding

```r
summary_discrete_plot(serv_smp,"Crisis")
```

```
## Warning: Ignoring unknown parameters: binwidth, bins, pad
```

![](Model_Termination_files/figure-html/Model08A-1.png)<!-- -->

```
## [[1]]
## 
##  Other   ARRA    Dis    OCO 
## 233079   1503    405  15013 
## 
## [[2]]
##        
##           None Ceiling Breach
##   Other 219921          13158
##   ARRA    1272            231
##   Dis      367             38
##   OCO    14343            670
## 
## [[3]]
##        
##              0      1
##   Other 228695   4384
##   ARRA    1480     23
##   Dis      398      7
##   OCO    14705    308
```

```r
#Model
Term_08A <- glm (data=serv_smp,
                 b_Term ~ Crisis, family=binomial(link="logit"))
display(Term_08A)
```

```
## glm(formula = b_Term ~ Crisis, family = binomial(link = "logit"), 
##     data = serv_smp)
##             coef.est coef.se
## (Intercept) -3.95     0.02  
## CrisisARRA  -0.21     0.21  
## CrisisDis   -0.09     0.38  
## CrisisOCO    0.09     0.06  
## ---
##   n = 250000, k = 4
##   residual deviance = 46836.3, null deviance = 46839.6 (difference = 3.3)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_07B,Term_08A,
                       
                       type="text",
                       digits=2)
```

```
## 
## ===========================================================
##                                    Dependent variable:     
##                                ----------------------------
##                                           b_Term           
##                                     (1)            (2)     
## -----------------------------------------------------------
## cl_US6_avg_sal_lag1Const          -0.23***                 
##                                    (0.04)                  
##                                                            
## cl_CFTE                             0.03                   
##                                    (0.03)                  
##                                                            
## c_pPBSC                            -0.01                   
##                                    (0.03)                  
##                                                            
## c_pOffPSC                         0.71***                  
##                                    (0.03)                  
##                                                            
## c_pairHist                         -0.06*                  
##                                    (0.03)                  
##                                                            
## cl_pairCA                         0.58***                  
##                                    (0.03)                  
##                                                            
## cl_Ceil                           0.40***                  
##                                    (0.03)                  
##                                                            
## capped_cl_Days                    1.45***                  
##                                    (0.04)                  
##                                                            
## Comp1or51 offer                   0.34***                  
##                                    (0.05)                  
##                                                            
## Comp1or52-4 offers                0.27***                  
##                                    (0.05)                  
##                                                            
## Comp1or55+ offers                 1.08***                  
##                                    (0.04)                  
##                                                            
## VehS-IDC                          -1.15***                 
##                                    (0.04)                  
##                                                            
## VehM-IDC                          -0.90***                 
##                                    (0.05)                  
##                                                            
## VehFSS/GWAC                       -0.36***                 
##                                    (0.07)                  
##                                                            
## VehBPA/BOA                        -1.20***                 
##                                    (0.10)                  
##                                                            
## PricingUCAOther FP                -0.42***                 
##                                    (0.15)                  
##                                                            
## PricingUCAT&M/LH/FPLOE            -0.82***                 
##                                    (0.15)                  
##                                                            
## PricingUCAIncentive               -3.64***                 
##                                    (1.00)                  
##                                                            
## PricingUCAOther CB                -1.77***                 
##                                    (0.12)                  
##                                                            
## PricingUCAUCA                     -1.14***                 
##                                    (0.23)                  
##                                                            
## PricingUCACombination or Other    -1.16***                 
##                                    (0.22)                  
##                                                            
## CrisisARRA                                        -0.21    
##                                                  (0.21)    
##                                                            
## CrisisDis                                         -0.09    
##                                                  (0.38)    
##                                                            
## CrisisOCO                                         0.09     
##                                                  (0.06)    
##                                                            
## Constant                          -3.93***      -3.95***   
##                                    (0.04)        (0.02)    
##                                                            
## -----------------------------------------------------------
## Observations                      250,000        250,000   
## Log Likelihood                   -21,077.26    -23,418.15  
## Akaike Inf. Crit.                42,198.52      46,844.30  
## ===========================================================
## Note:                           *p<0.1; **p<0.05; ***p<0.01
```

```r
# summary_residual_compare(Term_07B,Term_08A,30)
```

For ceiling breaches ARRA and Disaster results were in keeping with expcetations but OCO results were not. There were no significant results for terminations. For options, contrary to exepectation, all forms of crisis funding have a lower rate of usage.



#### 08B: Cumulative  Model


```r
#Model
Term_08B <- glm (data=serv_smp,
                 b_Term ~ cl_US6_avg_sal_lag1Const + 
                   cl_CFTE+ c_pPBSC+c_pOffPSC+
                   c_pairHist+cl_pairCA+
                   cl_Ceil + capped_cl_Days+
                   Comp1or5+
                   Veh+
                   PricingUCA+
                   Crisis, family=binomial(link="logit"))

glmer_examine(Term_08B)
```

```
##                              GVIF Df GVIF^(1/(2*Df))
## cl_US6_avg_sal_lag1Const 1.407621  1        1.186432
## cl_CFTE                  1.377619  1        1.173720
## c_pPBSC                  1.389438  1        1.178744
## c_pOffPSC                1.555327  1        1.247128
## c_pairHist               1.289037  1        1.135358
## cl_pairCA                2.261331  1        1.503772
## cl_Ceil                  1.344482  1        1.159518
## capped_cl_Days           1.236352  1        1.111914
## Comp1or5                 1.274763  3        1.041290
## Veh                      1.856948  4        1.080438
## PricingUCA               1.119717  6        1.009468
## Crisis                   1.625038  3        1.084286
```

```r
#Plot residuals versus fitted   
stargazer::stargazer(
                       Term_07B,Term_08A,Term_08B,
                       
                       type="text",
                       digits=2)
```

```
## 
## ===============================================================
##                                      Dependent variable:       
##                                --------------------------------
##                                             b_Term             
##                                   (1)        (2)        (3)    
## ---------------------------------------------------------------
## cl_US6_avg_sal_lag1Const        -0.23***              -0.19*** 
##                                  (0.04)                (0.04)  
##                                                                
## cl_CFTE                           0.03                 -0.06*  
##                                  (0.03)                (0.03)  
##                                                                
## c_pPBSC                          -0.01                 -0.01   
##                                  (0.03)                (0.03)  
##                                                                
## c_pOffPSC                       0.71***               0.68***  
##                                  (0.03)                (0.03)  
##                                                                
## c_pairHist                       -0.06*               -0.08**  
##                                  (0.03)                (0.03)  
##                                                                
## cl_pairCA                       0.58***               0.70***  
##                                  (0.03)                (0.04)  
##                                                                
## cl_Ceil                         0.40***               0.45***  
##                                  (0.03)                (0.03)  
##                                                                
## capped_cl_Days                  1.45***               1.39***  
##                                  (0.04)                (0.04)  
##                                                                
## Comp1or51 offer                 0.34***               0.39***  
##                                  (0.05)                (0.05)  
##                                                                
## Comp1or52-4 offers              0.27***               0.28***  
##                                  (0.05)                (0.05)  
##                                                                
## Comp1or55+ offers               1.08***               1.11***  
##                                  (0.04)                (0.05)  
##                                                                
## VehS-IDC                        -1.15***              -1.24*** 
##                                  (0.04)                (0.04)  
##                                                                
## VehM-IDC                        -0.90***              -0.94*** 
##                                  (0.05)                (0.05)  
##                                                                
## VehFSS/GWAC                     -0.36***              -0.41*** 
##                                  (0.07)                (0.07)  
##                                                                
## VehBPA/BOA                      -1.20***              -1.21*** 
##                                  (0.10)                (0.10)  
##                                                                
## PricingUCAOther FP              -0.42***              -0.49*** 
##                                  (0.15)                (0.15)  
##                                                                
## PricingUCAT&M/LH/FPLOE          -0.82***              -0.86*** 
##                                  (0.15)                (0.15)  
##                                                                
## PricingUCAIncentive             -3.64***              -3.67*** 
##                                  (1.00)                (1.00)  
##                                                                
## PricingUCAOther CB              -1.77***              -1.80*** 
##                                  (0.12)                (0.12)  
##                                                                
## PricingUCAUCA                   -1.14***              -1.16*** 
##                                  (0.23)                (0.23)  
##                                                                
## PricingUCACombination or Other  -1.16***              -1.19*** 
##                                  (0.22)                (0.22)  
##                                                                
## CrisisARRA                                  -0.21     -0.57*** 
##                                             (0.21)     (0.21)  
##                                                                
## CrisisDis                                   -0.09      -0.09   
##                                             (0.38)     (0.39)  
##                                                                
## CrisisOCO                                    0.09     -0.56*** 
##                                             (0.06)     (0.08)  
##                                                                
## Constant                        -3.93***   -3.95***   -3.86*** 
##                                  (0.04)     (0.02)     (0.04)  
##                                                                
## ---------------------------------------------------------------
## Observations                    250,000    250,000    250,000  
## Log Likelihood                 -21,077.26 -23,418.15 -21,045.20
## Akaike Inf. Crit.              42,198.52  46,844.30  42,140.40 
## ===============================================================
## Note:                               *p<0.1; **p<0.05; ***p<0.01
```

```r
#summary_residual_compare(Term_07B,Term_08B)
```

Terminatins for OCO and ARRA are now significant in the expected direction.


## Industrial Sector

### Level 6

#### Model 09A: l_def6_HHI_lag1
HHI (logged, + means more consolidation)	cl_def6_HHI_lag1+		+	-	-

Expectations are  unchanged.

```r
#Frequency Plot for unlogged ceiling
summary_continuous_plot(serv_smp,"def6_HHI_lag1")
```

![](Model_Termination_files/figure-html/Model09A-1.png)<!-- -->

```r
summary_continuous_plot(serv_smp,"cl_def6_HHI_lag1")
```

![](Model_Termination_files/figure-html/Model09A-2.png)<!-- -->

```r
summary_continuous_plot(serv_smp,"cl_def3_HHI_lag1")
```

![](Model_Termination_files/figure-html/Model09A-3.png)<!-- -->

```r
#Model
Term_09A <- glm (data=serv_smp,
                 b_Term ~ cl_def6_HHI_lag1, family=binomial(link="logit"))

display(Term_09A)
```

```
## glm(formula = b_Term ~ cl_def6_HHI_lag1, family = binomial(link = "logit"), 
##     data = serv_smp)
##                  coef.est coef.se
## (Intercept)      -3.95     0.01  
## cl_def6_HHI_lag1 -0.04     0.03  
## ---
##   n = 250000, k = 2
##   residual deviance = 46838.0, null deviance = 46839.6 (difference = 1.7)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_08B,Term_09A,
                       
                       type="text",
                       digits=2)
```

```
## 
## ===========================================================
##                                    Dependent variable:     
##                                ----------------------------
##                                           b_Term           
##                                     (1)            (2)     
## -----------------------------------------------------------
## cl_US6_avg_sal_lag1Const          -0.19***                 
##                                    (0.04)                  
##                                                            
## cl_CFTE                            -0.06*                  
##                                    (0.03)                  
##                                                            
## c_pPBSC                            -0.01                   
##                                    (0.03)                  
##                                                            
## c_pOffPSC                         0.68***                  
##                                    (0.03)                  
##                                                            
## c_pairHist                        -0.08**                  
##                                    (0.03)                  
##                                                            
## cl_pairCA                         0.70***                  
##                                    (0.04)                  
##                                                            
## cl_Ceil                           0.45***                  
##                                    (0.03)                  
##                                                            
## capped_cl_Days                    1.39***                  
##                                    (0.04)                  
##                                                            
## Comp1or51 offer                   0.39***                  
##                                    (0.05)                  
##                                                            
## Comp1or52-4 offers                0.28***                  
##                                    (0.05)                  
##                                                            
## Comp1or55+ offers                 1.11***                  
##                                    (0.05)                  
##                                                            
## VehS-IDC                          -1.24***                 
##                                    (0.04)                  
##                                                            
## VehM-IDC                          -0.94***                 
##                                    (0.05)                  
##                                                            
## VehFSS/GWAC                       -0.41***                 
##                                    (0.07)                  
##                                                            
## VehBPA/BOA                        -1.21***                 
##                                    (0.10)                  
##                                                            
## PricingUCAOther FP                -0.49***                 
##                                    (0.15)                  
##                                                            
## PricingUCAT&M/LH/FPLOE            -0.86***                 
##                                    (0.15)                  
##                                                            
## PricingUCAIncentive               -3.67***                 
##                                    (1.00)                  
##                                                            
## PricingUCAOther CB                -1.80***                 
##                                    (0.12)                  
##                                                            
## PricingUCAUCA                     -1.16***                 
##                                    (0.23)                  
##                                                            
## PricingUCACombination or Other    -1.19***                 
##                                    (0.22)                  
##                                                            
## CrisisARRA                        -0.57***                 
##                                    (0.21)                  
##                                                            
## CrisisDis                          -0.09                   
##                                    (0.39)                  
##                                                            
## CrisisOCO                         -0.56***                 
##                                    (0.08)                  
##                                                            
## cl_def6_HHI_lag1                                  -0.04    
##                                                  (0.03)    
##                                                            
## Constant                          -3.86***      -3.95***   
##                                    (0.04)        (0.01)    
##                                                            
## -----------------------------------------------------------
## Observations                      250,000        250,000   
## Log Likelihood                   -21,045.20    -23,418.99  
## Akaike Inf. Crit.                42,140.40      46,841.99  
## ===========================================================
## Note:                           *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_08B,Term_09A, skip_vif = TRUE)
```

![](Model_Termination_files/figure-html/Model09A-4.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model09A-5.png)<!-- -->

```
## NULL
```

Expected direction for ceiling breach and termination, but no real results on options.

#### Model 09B: Defense to Overall ratio
The higher the ratio of defense obligations to reciepts in the overall economy, the DoD holds a monosopy over a sector. Given the challenges of monosopy, the a higher ratio estimates a greater  risk of ceiling breaches.

Ratio Def. obligatons : US revenue	cl_def6_obl_lag1+		+	-	-


```r
#Frequency Plot for unlogged ceiling
      summary_continuous_plot(serv_smp,"def6_ratio_lag1")
```

![](Model_Termination_files/figure-html/Model09B-1.png)<!-- -->

```r
      summary_continuous_plot(serv_smp,"cl_def6_ratio_lag1")
```

![](Model_Termination_files/figure-html/Model09B-2.png)<!-- -->

```r
#Model
Term_09B <- glm (data=serv_smp,
                 b_Term ~ cl_def6_ratio_lag1, family=binomial(link="logit"))

display(Term_09B)
```

```
## glm(formula = b_Term ~ cl_def6_ratio_lag1, family = binomial(link = "logit"), 
##     data = serv_smp)
##                    coef.est coef.se
## (Intercept)        -3.97     0.02  
## cl_def6_ratio_lag1 -0.50     0.05  
## ---
##   n = 250000, k = 2
##   residual deviance = 46708.5, null deviance = 46839.6 (difference = 131.2)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_08B,Term_09A,Term_09B,
                       
                       type="text",
                       digits=2)
```

```
## 
## ===============================================================
##                                      Dependent variable:       
##                                --------------------------------
##                                             b_Term             
##                                   (1)        (2)        (3)    
## ---------------------------------------------------------------
## cl_US6_avg_sal_lag1Const        -0.19***                       
##                                  (0.04)                        
##                                                                
## cl_CFTE                          -0.06*                        
##                                  (0.03)                        
##                                                                
## c_pPBSC                          -0.01                         
##                                  (0.03)                        
##                                                                
## c_pOffPSC                       0.68***                        
##                                  (0.03)                        
##                                                                
## c_pairHist                      -0.08**                        
##                                  (0.03)                        
##                                                                
## cl_pairCA                       0.70***                        
##                                  (0.04)                        
##                                                                
## cl_Ceil                         0.45***                        
##                                  (0.03)                        
##                                                                
## capped_cl_Days                  1.39***                        
##                                  (0.04)                        
##                                                                
## Comp1or51 offer                 0.39***                        
##                                  (0.05)                        
##                                                                
## Comp1or52-4 offers              0.28***                        
##                                  (0.05)                        
##                                                                
## Comp1or55+ offers               1.11***                        
##                                  (0.05)                        
##                                                                
## VehS-IDC                        -1.24***                       
##                                  (0.04)                        
##                                                                
## VehM-IDC                        -0.94***                       
##                                  (0.05)                        
##                                                                
## VehFSS/GWAC                     -0.41***                       
##                                  (0.07)                        
##                                                                
## VehBPA/BOA                      -1.21***                       
##                                  (0.10)                        
##                                                                
## PricingUCAOther FP              -0.49***                       
##                                  (0.15)                        
##                                                                
## PricingUCAT&M/LH/FPLOE          -0.86***                       
##                                  (0.15)                        
##                                                                
## PricingUCAIncentive             -3.67***                       
##                                  (1.00)                        
##                                                                
## PricingUCAOther CB              -1.80***                       
##                                  (0.12)                        
##                                                                
## PricingUCAUCA                   -1.16***                       
##                                  (0.23)                        
##                                                                
## PricingUCACombination or Other  -1.19***                       
##                                  (0.22)                        
##                                                                
## CrisisARRA                      -0.57***                       
##                                  (0.21)                        
##                                                                
## CrisisDis                        -0.09                         
##                                  (0.39)                        
##                                                                
## CrisisOCO                       -0.56***                       
##                                  (0.08)                        
##                                                                
## cl_def6_HHI_lag1                            -0.04              
##                                             (0.03)             
##                                                                
## cl_def6_ratio_lag1                                    -0.50*** 
##                                                        (0.05)  
##                                                                
## Constant                        -3.86***   -3.95***   -3.97*** 
##                                  (0.04)     (0.01)     (0.02)  
##                                                                
## ---------------------------------------------------------------
## Observations                    250,000    250,000    250,000  
## Log Likelihood                 -21,045.20 -23,418.99 -23,354.24
## Akaike Inf. Crit.              42,140.40  46,841.99  46,712.48 
## ===============================================================
## Note:                               *p<0.1; **p<0.05; ***p<0.01
```

```r
#summary_residual_compare(Term_08A,Term_09A)
#summary_residual_compare(Term_09A,Term_09B)
```


#### Model 09C: Defense Obligations
Defense obligations (logged)	cl_def6_ratio_lag1+		-	-	+


```r
#Frequency Plot for unlogged ceiling
      summary_continuous_plot(serv_smp,"def6_obl_lag1Const")
```

![](Model_Termination_files/figure-html/Model09C-1.png)<!-- -->

```r
      summary_continuous_plot(serv_smp,"cl_def6_obl_lag1Const")
```

![](Model_Termination_files/figure-html/Model09C-2.png)<!-- -->

```r
#Model
Term_09C <- glm (data=serv_smp,
                 b_Term ~ cl_def6_obl_lag1Const, family=binomial(link="logit"))

display(Term_09C)
```

```
## glm(formula = b_Term ~ cl_def6_obl_lag1Const, family = binomial(link = "logit"), 
##     data = serv_smp)
##                       coef.est coef.se
## (Intercept)           -3.95     0.01  
## cl_def6_obl_lag1Const -0.01     0.03  
## ---
##   n = 250000, k = 2
##   residual deviance = 46839.4, null deviance = 46839.6 (difference = 0.2)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(Term_09A,Term_09B,Term_09C,
                       
                       type="text",
                       digits=2)
```

```
## 
## ======================================================
##                             Dependent variable:       
##                       --------------------------------
##                                    b_Term             
##                          (1)        (2)        (3)    
## ------------------------------------------------------
## cl_def6_HHI_lag1        -0.04                         
##                         (0.03)                        
##                                                       
## cl_def6_ratio_lag1                -0.50***            
##                                    (0.05)             
##                                                       
## cl_def6_obl_lag1Const                         -0.01   
##                                               (0.03)  
##                                                       
## Constant               -3.95***   -3.97***   -3.95*** 
##                         (0.01)     (0.02)     (0.01)  
##                                                       
## ------------------------------------------------------
## Observations           250,000    250,000    250,000  
## Log Likelihood        -23,418.99 -23,354.24 -23,419.70
## Akaike Inf. Crit.     46,841.99  46,712.48  46,843.39 
## ======================================================
## Note:                      *p<0.1; **p<0.05; ***p<0.01
```

```r
#summary_residual_compare(Term_08A,Term_09C)
#summary_residual_compare(Term_09A,Term_09C)
#summary_residual_compare(Term_09B,Term_09C)
```

Contrary to expectation. for termination and options.

#### Model 09D: NAICS 6 Combined
Consolidation at lessa nd more granular levels may have different effects. Efficiencies are often used to describe sectors, like utilities, with high barriers to entry. Many of these aspects seem like they would already be captured at less granular NAICS levels, e.g. power plants, rather than more specific NAICS levels, like solar vs. coal. As a result, consolidation for more granular NAICS codes should estimate higher rates of ceiling breaches compared to less granular NAICS code.

We'll start by adding in everything from both models and seeing what violates VIF.

```r
#Frequency Plot for unlogged ceiling



#Model
Term_09D <- glm (data=serv_smp,
                 b_Term ~ cl_def6_HHI_lag1+cl_def6_ratio_lag1+cl_def6_obl_lag1Const
                 , family=binomial(link="logit"))

glmer_examine(Term_09D)
```

```
##      cl_def6_HHI_lag1    cl_def6_ratio_lag1 cl_def6_obl_lag1Const 
##              1.224432              1.525968              1.574301
```

```r
Term_09D2 <- glm (data=serv_smp,
                 b_Term ~ cl_def6_HHI_lag1+cl_def6_ratio_lag1
                 , family=binomial(link="logit"))

glmer_examine(Term_09D2)
```

```
##   cl_def6_HHI_lag1 cl_def6_ratio_lag1 
##           1.037074           1.037074
```

```r
#Plot residuals versus fitted
stargazer::stargazer(Term_09D,Term_09D2,
                     
                       type="text",
                       digits=2)
```

```
## 
## ==================================================
##                           Dependent variable:     
##                       ----------------------------
##                                  b_Term           
##                            (1)            (2)     
## --------------------------------------------------
## cl_def6_HHI_lag1         0.14***         0.04     
##                           (0.03)        (0.03)    
##                                                   
## cl_def6_ratio_lag1       -0.76***      -0.51***   
##                           (0.06)        (0.05)    
##                                                   
## cl_def6_obl_lag1Const    0.27***                  
##                           (0.04)                  
##                                                   
## Constant                 -3.98***      -3.97***   
##                           (0.02)        (0.02)    
##                                                   
## --------------------------------------------------
## Observations             250,000        250,000   
## Log Likelihood          -23,327.25    -23,353.29  
## Akaike Inf. Crit.       46,662.50      46,712.57  
## ==================================================
## Note:                  *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_09D,Term_09D2)
```

![](Model_Termination_files/figure-html/Model09D-1.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model09D-2.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance difference
## 1 model1_old 46654.50      46839.64   185.1358
## 2 model1_new 46706.57      46839.64   133.0631
## 
## [[2]]
##   cl_def6_HHI_lag1 cl_def6_ratio_lag1 
##           1.037074           1.037074
```
The hypothesis is upheld. Deviance is a little lower and residuals a little higher than the prior forms of consolidation for the level 3 model.  For the level 6 model, deviance is reduced some in both cases.

NAICS Subsector (Level 3)					
HHI (logged, + means more consolidation)	cl_def3_HHI_lag1+		+	++	-
Ratio Def. obligatons : US revenue	cl_def3_ratio_lag1+		+	+	-

Ratio at either level is no longer in line with expectations for ceiling breaches.


#### Model 09E: Cumulative Model
Consolidation at lessa nd more granular levels may have different effects. Efficiencies are often used to describe sectors, like utilities, with high barriers to entry. Many of these aspects seem like they would already be captured at less granular NAICS levels, e.g. power plants, rather than more specific NAICS levels, like solar vs. coal. As a result, consolidation for more granular NAICS codes should estimate higher rates of ceiling breaches compared to less granular NAICS code.

We'll start by adding in everything from both models and seeing what violates VIF.

```r
#Frequency Plot for unlogged ceiling

#Model
Term_09E <- glm (data=serv_smp,
                 b_Term ~ cl_US6_avg_sal_lag1Const + 
                   cl_CFTE+ c_pPBSC+c_pOffPSC+
                   c_pairHist+cl_pairCA+
                   cl_Ceil + capped_cl_Days+
                   Comp1or5+
                   Veh+
                   PricingUCA+
                   Crisis+
                   cl_def6_HHI_lag1+cl_def6_ratio_lag1, family=binomial(link="logit"))
glmer_examine(Term_09E)
```

```
##                              GVIF Df GVIF^(1/(2*Df))
## cl_US6_avg_sal_lag1Const 1.445756  1        1.202396
## cl_CFTE                  1.363141  1        1.167536
## c_pPBSC                  1.441240  1        1.200516
## c_pOffPSC                1.696858  1        1.302635
## c_pairHist               1.332179  1        1.154200
## cl_pairCA                2.219493  1        1.489796
## cl_Ceil                  1.380628  1        1.175001
## capped_cl_Days           1.253906  1        1.119780
## Comp1or5                 1.305371  3        1.045416
## Veh                      1.892397  4        1.082995
## PricingUCA               1.135345  6        1.010634
## Crisis                   1.567488  3        1.077790
## cl_def6_HHI_lag1         1.337516  1        1.156510
## cl_def6_ratio_lag1       1.218466  1        1.103841
```

```r
#Plot residuals versus fitted
stargazer::stargazer(Term_08B,Term_09D2,Term_09E,type="text",
                       digits=2)
```

```
## 
## ===============================================================
##                                      Dependent variable:       
##                                --------------------------------
##                                             b_Term             
##                                   (1)        (2)        (3)    
## ---------------------------------------------------------------
## cl_US6_avg_sal_lag1Const        -0.19***              -0.11*** 
##                                  (0.04)                (0.04)  
##                                                                
## cl_CFTE                          -0.06*               -0.07**  
##                                  (0.03)                (0.03)  
##                                                                
## c_pPBSC                          -0.01                  0.01   
##                                  (0.03)                (0.03)  
##                                                                
## c_pOffPSC                       0.68***               0.77***  
##                                  (0.03)                (0.03)  
##                                                                
## c_pairHist                      -0.08**               -0.11*** 
##                                  (0.03)                (0.03)  
##                                                                
## cl_pairCA                       0.70***               0.75***  
##                                  (0.04)                (0.04)  
##                                                                
## cl_Ceil                         0.45***               0.50***  
##                                  (0.03)                (0.04)  
##                                                                
## capped_cl_Days                  1.39***               1.32***  
##                                  (0.04)                (0.04)  
##                                                                
## Comp1or51 offer                 0.39***               0.40***  
##                                  (0.05)                (0.05)  
##                                                                
## Comp1or52-4 offers              0.28***               0.29***  
##                                  (0.05)                (0.05)  
##                                                                
## Comp1or55+ offers               1.11***               1.08***  
##                                  (0.05)                (0.05)  
##                                                                
## VehS-IDC                        -1.24***              -1.24*** 
##                                  (0.04)                (0.04)  
##                                                                
## VehM-IDC                        -0.94***              -0.84*** 
##                                  (0.05)                (0.05)  
##                                                                
## VehFSS/GWAC                     -0.41***              -0.37*** 
##                                  (0.07)                (0.07)  
##                                                                
## VehBPA/BOA                      -1.21***              -1.14*** 
##                                  (0.10)                (0.10)  
##                                                                
## PricingUCAOther FP              -0.49***              -0.61*** 
##                                  (0.15)                (0.15)  
##                                                                
## PricingUCAT&M/LH/FPLOE          -0.86***              -0.80*** 
##                                  (0.15)                (0.15)  
##                                                                
## PricingUCAIncentive             -3.67***              -3.66*** 
##                                  (1.00)                (1.00)  
##                                                                
## PricingUCAOther CB              -1.80***              -1.76*** 
##                                  (0.12)                (0.12)  
##                                                                
## PricingUCAUCA                   -1.16***              -1.18*** 
##                                  (0.23)                (0.23)  
##                                                                
## PricingUCACombination or Other  -1.19***              -1.13*** 
##                                  (0.22)                (0.22)  
##                                                                
## CrisisARRA                      -0.57***              -0.58*** 
##                                  (0.21)                (0.21)  
##                                                                
## CrisisDis                        -0.09                 0.005   
##                                  (0.39)                (0.39)  
##                                                                
## CrisisOCO                       -0.56***              -0.46*** 
##                                  (0.08)                (0.08)  
##                                                                
## cl_def6_HHI_lag1                             0.04      -0.05   
##                                             (0.03)     (0.03)  
##                                                                
## cl_def6_ratio_lag1                         -0.51***   -0.70*** 
##                                             (0.05)     (0.05)  
##                                                                
## Constant                        -3.86***   -3.97***   -3.91*** 
##                                  (0.04)     (0.02)     (0.04)  
##                                                                
## ---------------------------------------------------------------
## Observations                    250,000    250,000    250,000  
## Log Likelihood                 -21,045.20 -23,353.29 -20,914.82
## Akaike Inf. Crit.              42,140.40  46,712.57  41,883.64 
## ===============================================================
## Note:                               *p<0.1; **p<0.05; ***p<0.01
```

```r
#summary_residual_compare(Term_09D2,Term_09E)
#summary_residual_compare(Term_08B,Term_09E)
```

Expectations are not upheld.

### Level 3
#### Model 10A: cl_def3_HHI
HHI (logged, + means more consolidation)	cl_def3_HHI_lag1+		+	++	-


```r
#Frequency Plot for unlogged ceiling
summary_continuous_plot(serv_smp,"cl_def3_HHI_lag1")
```

![](Model_Termination_files/figure-html/Model10A-1.png)<!-- -->

```r
#Model
Term_10A <- glm (data=serv_smp,
                 b_Term ~ cl_def3_HHI_lag1, family=binomial(link="logit"))
display(Term_10A)
```

```
## glm(formula = b_Term ~ cl_def3_HHI_lag1, family = binomial(link = "logit"), 
##     data = serv_smp)
##                  coef.est coef.se
## (Intercept)      -3.97     0.01  
## cl_def3_HHI_lag1  0.47     0.03  
## ---
##   n = 250000, k = 2
##   residual deviance = 46578.4, null deviance = 46839.6 (difference = 261.3)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_09A,Term_10A,
                       
                       type="text",
                       digits=2)
```

```
## 
## ==============================================
##                       Dependent variable:     
##                   ----------------------------
##                              b_Term           
##                        (1)            (2)     
## ----------------------------------------------
## cl_def6_HHI_lag1      -0.04                   
##                       (0.03)                  
##                                               
## cl_def3_HHI_lag1                    0.47***   
##                                     (0.03)    
##                                               
## Constant             -3.95***      -3.97***   
##                       (0.01)        (0.01)    
##                                               
## ----------------------------------------------
## Observations         250,000        250,000   
## Log Likelihood      -23,418.99    -23,289.19  
## Akaike Inf. Crit.   46,841.99      46,582.38  
## ==============================================
## Note:              *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_09A,Term_10A, skip_vif =  TRUE)
```

![](Model_Termination_files/figure-html/Model10A-2.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model10A-3.png)<!-- -->

```
## NULL
```

Contrary to expectation on Ceiling breach and otions growth, in line with expectations on terminations.

Level 3 HHI seems to slightly out perform level 6.


#### Model 10B: Defense to Overall ratio
Ratio Def. obligatons : US revenue	cl_def3_ratio_lag1+		+	+	-


```r
#Frequency Plot for unlogged ceiling
summary_continuous_plot(serv_smp,"capped_def3_ratio_lag1")
```

![](Model_Termination_files/figure-html/Model10B-1.png)<!-- -->

```r
summary_continuous_plot(serv_smp,"cl_def3_ratio_lag1")
```

![](Model_Termination_files/figure-html/Model10B-2.png)<!-- -->

```r
#Model
Term_10B <- glm (data=serv_smp,
                 b_Term ~ cl_def3_ratio_lag1, family=binomial(link="logit"))
display(Term_10B)
```

```
## glm(formula = b_Term ~ cl_def3_ratio_lag1, family = binomial(link = "logit"), 
##     data = serv_smp)
##                    coef.est coef.se
## (Intercept)        -4.01     0.02  
## cl_def3_ratio_lag1 -0.79     0.04  
## ---
##   n = 250000, k = 2
##   residual deviance = 46293.6, null deviance = 46839.6 (difference = 546.0)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_09B,Term_10A,Term_10B,
                       
                       type="text",
                       digits=2)
```

```
## 
## ===================================================
##                          Dependent variable:       
##                    --------------------------------
##                                 b_Term             
##                       (1)        (2)        (3)    
## ---------------------------------------------------
## cl_def6_ratio_lag1  -0.50***                       
##                      (0.05)                        
##                                                    
## cl_def3_HHI_lag1               0.47***             
##                                 (0.03)             
##                                                    
## cl_def3_ratio_lag1                        -0.79*** 
##                                            (0.04)  
##                                                    
## Constant            -3.97***   -3.97***   -4.01*** 
##                      (0.02)     (0.01)     (0.02)  
##                                                    
## ---------------------------------------------------
## Observations        250,000    250,000    250,000  
## Log Likelihood     -23,354.24 -23,289.19 -23,146.82
## Akaike Inf. Crit.  46,712.48  46,582.38  46,297.64 
## ===================================================
## Note:                   *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_09B,Term_10B, skip_vif = TRUE)
```

![](Model_Termination_files/figure-html/Model10B-3.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model10B-4.png)<!-- -->

```
## NULL
```

Expectations were in lined with ceiling breaches and options, not with termination, and 


#### Model 10C: NAICS 6 and NAICS 3
Consolidation at lessa nd more granular levels may have different effects. Efficiencies are often used to describe sectors, like utilities, with high barriers to entry. Many of these aspects seem like they would already be captured at less granular NAICS levels, e.g. power plants, rather than more specific NAICS levels, like solar vs. coal. As a result, consolidation for more granular NAICS codes should estimate higher rates of ceiling breaches compared to less granular NAICS code.

We'll start by adding in everything from both models and seeing what violates VIF.

```r
#Frequency Plot for unlogged ceiling



#Model
Term_10C <- glm (data=serv_smp,
                 b_Term ~ cl_def3_HHI_lag1+cl_def3_ratio_lag1, family=binomial(link="logit"))
glmer_examine(Term_10C)
```

```
##   cl_def3_HHI_lag1 cl_def3_ratio_lag1 
##           1.043009           1.043009
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                     Term_09E,Term_10A,Term_10B,Term_10C,
                     
                       type="text",
                       digits=2)
```

```
## 
## ==========================================================================
##                                            Dependent variable:            
##                                -------------------------------------------
##                                                  b_Term                   
##                                   (1)        (2)        (3)        (4)    
## --------------------------------------------------------------------------
## cl_US6_avg_sal_lag1Const        -0.11***                                  
##                                  (0.04)                                   
##                                                                           
## cl_CFTE                         -0.07**                                   
##                                  (0.03)                                   
##                                                                           
## c_pPBSC                           0.01                                    
##                                  (0.03)                                   
##                                                                           
## c_pOffPSC                       0.77***                                   
##                                  (0.03)                                   
##                                                                           
## c_pairHist                      -0.11***                                  
##                                  (0.03)                                   
##                                                                           
## cl_pairCA                       0.75***                                   
##                                  (0.04)                                   
##                                                                           
## cl_Ceil                         0.50***                                   
##                                  (0.04)                                   
##                                                                           
## capped_cl_Days                  1.32***                                   
##                                  (0.04)                                   
##                                                                           
## Comp1or51 offer                 0.40***                                   
##                                  (0.05)                                   
##                                                                           
## Comp1or52-4 offers              0.29***                                   
##                                  (0.05)                                   
##                                                                           
## Comp1or55+ offers               1.08***                                   
##                                  (0.05)                                   
##                                                                           
## VehS-IDC                        -1.24***                                  
##                                  (0.04)                                   
##                                                                           
## VehM-IDC                        -0.84***                                  
##                                  (0.05)                                   
##                                                                           
## VehFSS/GWAC                     -0.37***                                  
##                                  (0.07)                                   
##                                                                           
## VehBPA/BOA                      -1.14***                                  
##                                  (0.10)                                   
##                                                                           
## PricingUCAOther FP              -0.61***                                  
##                                  (0.15)                                   
##                                                                           
## PricingUCAT&M/LH/FPLOE          -0.80***                                  
##                                  (0.15)                                   
##                                                                           
## PricingUCAIncentive             -3.66***                                  
##                                  (1.00)                                   
##                                                                           
## PricingUCAOther CB              -1.76***                                  
##                                  (0.12)                                   
##                                                                           
## PricingUCAUCA                   -1.18***                                  
##                                  (0.23)                                   
##                                                                           
## PricingUCACombination or Other  -1.13***                                  
##                                  (0.22)                                   
##                                                                           
## CrisisARRA                      -0.58***                                  
##                                  (0.21)                                   
##                                                                           
## CrisisDis                        0.005                                    
##                                  (0.39)                                   
##                                                                           
## CrisisOCO                       -0.46***                                  
##                                  (0.08)                                   
##                                                                           
## cl_def6_HHI_lag1                 -0.05                                    
##                                  (0.03)                                   
##                                                                           
## cl_def6_ratio_lag1              -0.70***                                  
##                                  (0.05)                                   
##                                                                           
## cl_def3_HHI_lag1                           0.47***               0.34***  
##                                             (0.03)                (0.03)  
##                                                                           
## cl_def3_ratio_lag1                                    -0.79***   -0.71*** 
##                                                        (0.04)     (0.04)  
##                                                                           
## Constant                        -3.91***   -3.97***   -4.01***   -4.02*** 
##                                  (0.04)     (0.01)     (0.02)     (0.02)  
##                                                                           
## --------------------------------------------------------------------------
## Observations                    250,000    250,000    250,000    250,000  
## Log Likelihood                 -20,914.82 -23,289.19 -23,146.82 -23,077.47
## Akaike Inf. Crit.              41,883.64  46,582.38  46,297.64  46,160.93 
## ==========================================================================
## Note:                                          *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_08B,Term_10C)
```

![](Model_Termination_files/figure-html/Model10C-1.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model10C-2.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance difference
## 1 model1_old 42090.40      46839.64  4749.2344
## 2 model1_new 46154.93      46839.64   684.7043
## 
## [[2]]
##   cl_def3_HHI_lag1 cl_def3_ratio_lag1 
##           1.043009           1.043009
```

NAICS Subsector (Level 3)					
HHI (logged, + means more consolidation)	cl_def3_HHI_lag1+		+	++	-
Ratio Def. obligatons : US revenue	cl_def3_ratio_lag1+		+	+	-

Expectations matched for def3_HHI, not matched for ceiling  breach or options
ratio expectations for ceiling breach and options but not terminations.


#### Model 10D: Cumulative Model
.

```r
#Frequency Plot for unlogged ceiling


#Model
Term_10D <- glm (data=serv_smp,
                 b_Term ~ cl_US6_avg_sal_lag1Const + 
                   cl_CFTE+ c_pPBSC+c_pOffPSC+
                   c_pairHist+cl_pairCA+
                   cl_Ceil + capped_cl_Days+
                   Comp1or5+
                   Veh+
                   PricingUCA+
                   Crisis+
                   cl_def6_HHI_lag1+cl_def6_ratio_lag1+
                   cl_def3_HHI_lag1+cl_def3_ratio_lag1, family=binomial(link="logit"))

glmer_examine(Term_10D)
```

```
##                              GVIF Df GVIF^(1/(2*Df))
## cl_US6_avg_sal_lag1Const 1.539279  1        1.240677
## cl_CFTE                  1.376006  1        1.173033
## c_pPBSC                  1.483644  1        1.218049
## c_pOffPSC                1.685000  1        1.298076
## c_pairHist               1.339104  1        1.157197
## cl_pairCA                2.437808  1        1.561348
## cl_Ceil                  1.381124  1        1.175212
## capped_cl_Days           1.247267  1        1.116811
## Comp1or5                 1.312185  3        1.046323
## Veh                      2.018386  4        1.091756
## PricingUCA               1.161386  6        1.012546
## Crisis                   1.574977  3        1.078646
## cl_def6_HHI_lag1         2.208069  1        1.485957
## cl_def6_ratio_lag1       1.587655  1        1.260022
## cl_def3_HHI_lag1         2.067675  1        1.437941
## cl_def3_ratio_lag1       1.657985  1        1.287628
```

```r
#Plot residuals versus fitted
stargazer::stargazer(Term_09E,Term_10C,Term_10D,
                     
                       type="text",
                       digits=2)
```

```
## 
## ===============================================================
##                                      Dependent variable:       
##                                --------------------------------
##                                             b_Term             
##                                   (1)        (2)        (3)    
## ---------------------------------------------------------------
## cl_US6_avg_sal_lag1Const        -0.11***              0.13***  
##                                  (0.04)                (0.04)  
##                                                                
## cl_CFTE                         -0.07**                -0.01   
##                                  (0.03)                (0.03)  
##                                                                
## c_pPBSC                           0.01                 -0.03   
##                                  (0.03)                (0.03)  
##                                                                
## c_pOffPSC                       0.77***               0.86***  
##                                  (0.03)                (0.03)  
##                                                                
## c_pairHist                      -0.11***               -0.04   
##                                  (0.03)                (0.03)  
##                                                                
## cl_pairCA                       0.75***               0.55***  
##                                  (0.04)                (0.04)  
##                                                                
## cl_Ceil                         0.50***               0.50***  
##                                  (0.04)                (0.04)  
##                                                                
## capped_cl_Days                  1.32***               1.27***  
##                                  (0.04)                (0.04)  
##                                                                
## Comp1or51 offer                 0.40***               0.37***  
##                                  (0.05)                (0.05)  
##                                                                
## Comp1or52-4 offers              0.29***               0.29***  
##                                  (0.05)                (0.05)  
##                                                                
## Comp1or55+ offers               1.08***               1.04***  
##                                  (0.05)                (0.05)  
##                                                                
## VehS-IDC                        -1.24***              -1.11*** 
##                                  (0.04)                (0.04)  
##                                                                
## VehM-IDC                        -0.84***              -0.84*** 
##                                  (0.05)                (0.05)  
##                                                                
## VehFSS/GWAC                     -0.37***              -0.19*** 
##                                  (0.07)                (0.07)  
##                                                                
## VehBPA/BOA                      -1.14***              -1.15*** 
##                                  (0.10)                (0.10)  
##                                                                
## PricingUCAOther FP              -0.61***              -0.73*** 
##                                  (0.15)                (0.15)  
##                                                                
## PricingUCAT&M/LH/FPLOE          -0.80***              -0.56*** 
##                                  (0.15)                (0.15)  
##                                                                
## PricingUCAIncentive             -3.66***              -3.37*** 
##                                  (1.00)                (1.00)  
##                                                                
## PricingUCAOther CB              -1.76***              -1.50*** 
##                                  (0.12)                (0.12)  
##                                                                
## PricingUCAUCA                   -1.18***              -1.16*** 
##                                  (0.23)                (0.23)  
##                                                                
## PricingUCACombination or Other  -1.13***              -0.89*** 
##                                  (0.22)                (0.22)  
##                                                                
## CrisisARRA                      -0.58***              -0.67*** 
##                                  (0.21)                (0.21)  
##                                                                
## CrisisDis                        0.005                 -0.08   
##                                  (0.39)                (0.39)  
##                                                                
## CrisisOCO                       -0.46***              -0.46*** 
##                                  (0.08)                (0.08)  
##                                                                
## cl_def6_HHI_lag1                 -0.05                -0.38*** 
##                                  (0.03)                (0.04)  
##                                                                
## cl_def6_ratio_lag1              -0.70***              -0.34*** 
##                                  (0.05)                (0.05)  
##                                                                
## cl_def3_HHI_lag1                           0.34***    0.51***  
##                                             (0.03)     (0.04)  
##                                                                
## cl_def3_ratio_lag1                         -0.71***   -0.63*** 
##                                             (0.04)     (0.05)  
##                                                                
## Constant                        -3.91***   -4.02***   -4.02*** 
##                                  (0.04)     (0.02)     (0.04)  
##                                                                
## ---------------------------------------------------------------
## Observations                    250,000    250,000    250,000  
## Log Likelihood                 -20,914.82 -23,077.47 -20,704.21
## Akaike Inf. Crit.              41,883.64  46,160.93  41,466.41 
## ===============================================================
## Note:                               *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_09D2,Term_10D)
```

![](Model_Termination_files/figure-html/Model10D-1.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model10D-2.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance difference
## 1 model1_old 46706.57      46839.64   133.0631
## 2 model1_new 41408.41      46839.64  5431.2263
## 
## [[2]]
##                              GVIF Df GVIF^(1/(2*Df))
## cl_US6_avg_sal_lag1Const 1.539279  1        1.240677
## cl_CFTE                  1.376006  1        1.173033
## c_pPBSC                  1.483644  1        1.218049
## c_pOffPSC                1.685000  1        1.298076
## c_pairHist               1.339104  1        1.157197
## cl_pairCA                2.437808  1        1.561348
## cl_Ceil                  1.381124  1        1.175212
## capped_cl_Days           1.247267  1        1.116811
## Comp1or5                 1.312185  3        1.046323
## Veh                      2.018386  4        1.091756
## PricingUCA               1.161386  6        1.012546
## Crisis                   1.574977  3        1.078646
## cl_def6_HHI_lag1         2.208069  1        1.485957
## cl_def6_ratio_lag1       1.587655  1        1.260022
## cl_def3_HHI_lag1         2.067675  1        1.437941
## cl_def3_ratio_lag1       1.657985  1        1.287628
```

```r
summary_residual_compare(Term_08B,Term_10D)
```

![](Model_Termination_files/figure-html/Model10D-3.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used

## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

![](Model_Termination_files/figure-html/Model10D-4.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance difference
## 1 model1_old 42090.40      46839.64   4749.234
## 2 model1_new 41408.41      46839.64   5431.226
## 
## [[2]]
##                              GVIF Df GVIF^(1/(2*Df))
## cl_US6_avg_sal_lag1Const 1.539279  1        1.240677
## cl_CFTE                  1.376006  1        1.173033
## c_pPBSC                  1.483644  1        1.218049
## c_pOffPSC                1.685000  1        1.298076
## c_pairHist               1.339104  1        1.157197
## cl_pairCA                2.437808  1        1.561348
## cl_Ceil                  1.381124  1        1.175212
## capped_cl_Days           1.247267  1        1.116811
## Comp1or5                 1.312185  3        1.046323
## Veh                      2.018386  4        1.091756
## PricingUCA               1.161386  6        1.012546
## Crisis                   1.574977  3        1.078646
## cl_def6_HHI_lag1         2.208069  1        1.485957
## cl_def6_ratio_lag1       1.587655  1        1.260022
## cl_def3_HHI_lag1         2.067675  1        1.437941
## cl_def3_ratio_lag1       1.657985  1        1.287628
```
HHI6 for ceiling breach now matches expectations but HHI6 for term went in the opposite direction. s

## Office 
### Office and Vendor-Office Pair

#### Model 11A: Vendor Market Share
Expectation: Contracts of offices partnered with vendors who have larger market shares would be more likely to experience cost ceiling breaches and exercised options, but less likely to have terminations.
Market Share Vendor for that Office	c_pMarket		++	-	+


```r
summary_continuous_plot(serv_smp,"c_pMarket")
```

![](Model_Termination_files/figure-html/Model11A-1.png)<!-- -->

```r
#Model
Term_11A <- glm (data=serv_smp,
                 b_Term ~ c_pMarket, family=binomial(link="logit"))

display(Term_11A)
```

```
## glm(formula = b_Term ~ c_pMarket, family = binomial(link = "logit"), 
##     data = serv_smp)
##             coef.est coef.se
## (Intercept) -3.96     0.01  
## c_pMarket   -0.27     0.04  
## ---
##   n = 250000, k = 2
##   residual deviance = 46782.9, null deviance = 46839.6 (difference = 56.7)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                      Term_11A,
                       
                       type="text",
                       digits=2)
```

```
## 
## =============================================
##                       Dependent variable:    
##                   ---------------------------
##                             b_Term           
## ---------------------------------------------
## c_pMarket                  -0.27***          
##                             (0.04)           
##                                              
## Constant                   -3.96***          
##                             (0.01)           
##                                              
## ---------------------------------------------
## Observations                250,000          
## Log Likelihood            -23,391.45         
## Akaike Inf. Crit.          46,786.90         
## =============================================
## Note:             *p<0.1; **p<0.05; ***p<0.01
```

Aligns with expectations on terminatio, but not for ceiling  breach or for options.


#### Model 11B: Cumulative Model


```r
#Frequency Plot for unlogged ceiling


#Model
Term_11B <- glm (data=serv_smp,
                 b_Term ~ cl_US6_avg_sal_lag1Const + 
                   cl_CFTE+ c_pPBSC+c_pOffPSC+
                   c_pairHist+cl_pairCA+
                   cl_Ceil + capped_cl_Days+
                   Comp1or5+
                   Veh+
                   PricingUCA+
                   Crisis+
                   cl_def6_HHI_lag1+cl_def6_ratio_lag1+
                   cl_def3_HHI_lag1+cl_def3_ratio_lag1+
                   c_pMarket, family=binomial(link="logit"))

glmer_examine(Term_11B)
```

```
##                              GVIF Df GVIF^(1/(2*Df))
## cl_US6_avg_sal_lag1Const 1.577004  1        1.255788
## cl_CFTE                  1.420531  1        1.191860
## c_pPBSC                  1.558436  1        1.248373
## c_pOffPSC                1.703099  1        1.305028
## c_pairHist               1.343553  1        1.159117
## cl_pairCA                2.598335  1        1.611935
## cl_Ceil                  1.394623  1        1.180941
## capped_cl_Days           1.259909  1        1.122457
## Comp1or5                 1.333992  3        1.049201
## Veh                      2.019333  4        1.091820
## PricingUCA               1.168453  6        1.013058
## Crisis                   1.638719  3        1.085802
## cl_def6_HHI_lag1         2.190180  1        1.479926
## cl_def6_ratio_lag1       1.639912  1        1.280591
## cl_def3_HHI_lag1         2.063285  1        1.436414
## cl_def3_ratio_lag1       1.691829  1        1.300703
## c_pMarket                1.364547  1        1.168138
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                     Term_10D,Term_11A,Term_11B,
                     
                       type="text",
                       digits=2)
```

```
## 
## ===============================================================
##                                      Dependent variable:       
##                                --------------------------------
##                                             b_Term             
##                                   (1)        (2)        (3)    
## ---------------------------------------------------------------
## cl_US6_avg_sal_lag1Const        0.13***                0.08**  
##                                  (0.04)                (0.04)  
##                                                                
## cl_CFTE                          -0.01                  0.05   
##                                  (0.03)                (0.03)  
##                                                                
## c_pPBSC                          -0.03                -0.12*** 
##                                  (0.03)                (0.03)  
##                                                                
## c_pOffPSC                       0.86***               0.92***  
##                                  (0.03)                (0.03)  
##                                                                
## c_pairHist                       -0.04                 -0.03   
##                                  (0.03)                (0.03)  
##                                                                
## cl_pairCA                       0.55***               0.69***  
##                                  (0.04)                (0.04)  
##                                                                
## cl_Ceil                         0.50***               0.53***  
##                                  (0.04)                (0.04)  
##                                                                
## capped_cl_Days                  1.27***               1.25***  
##                                  (0.04)                (0.04)  
##                                                                
## Comp1or51 offer                 0.37***               0.44***  
##                                  (0.05)                (0.05)  
##                                                                
## Comp1or52-4 offers              0.29***               0.29***  
##                                  (0.05)                (0.05)  
##                                                                
## Comp1or55+ offers               1.04***               1.00***  
##                                  (0.05)                (0.05)  
##                                                                
## VehS-IDC                        -1.11***              -1.14*** 
##                                  (0.04)                (0.04)  
##                                                                
## VehM-IDC                        -0.84***              -0.87*** 
##                                  (0.05)                (0.05)  
##                                                                
## VehFSS/GWAC                     -0.19***              -0.22*** 
##                                  (0.07)                (0.07)  
##                                                                
## VehBPA/BOA                      -1.15***              -1.05*** 
##                                  (0.10)                (0.10)  
##                                                                
## PricingUCAOther FP              -0.73***              -0.78*** 
##                                  (0.15)                (0.16)  
##                                                                
## PricingUCAT&M/LH/FPLOE          -0.56***              -0.55*** 
##                                  (0.15)                (0.15)  
##                                                                
## PricingUCAIncentive             -3.37***              -3.39*** 
##                                  (1.00)                (1.00)  
##                                                                
## PricingUCAOther CB              -1.50***              -1.40*** 
##                                  (0.12)                (0.12)  
##                                                                
## PricingUCAUCA                   -1.16***              -1.03*** 
##                                  (0.23)                (0.23)  
##                                                                
## PricingUCACombination or Other  -0.89***              -0.86*** 
##                                  (0.22)                (0.22)  
##                                                                
## CrisisARRA                      -0.67***              -0.68*** 
##                                  (0.21)                (0.21)  
##                                                                
## CrisisDis                        -0.08                 -0.04   
##                                  (0.39)                (0.39)  
##                                                                
## CrisisOCO                       -0.46***               -0.09   
##                                  (0.08)                (0.08)  
##                                                                
## cl_def6_HHI_lag1                -0.38***              -0.36*** 
##                                  (0.04)                (0.04)  
##                                                                
## cl_def6_ratio_lag1              -0.34***              -0.35*** 
##                                  (0.05)                (0.05)  
##                                                                
## cl_def3_HHI_lag1                0.51***               0.50***  
##                                  (0.04)                (0.04)  
##                                                                
## cl_def3_ratio_lag1              -0.63***              -0.61*** 
##                                  (0.05)                (0.05)  
##                                                                
## c_pMarket                                  -0.27***   -0.67*** 
##                                             (0.04)     (0.06)  
##                                                                
## Constant                        -4.02***   -3.96***   -4.05*** 
##                                  (0.04)     (0.01)     (0.04)  
##                                                                
## ---------------------------------------------------------------
## Observations                    250,000    250,000    250,000  
## Log Likelihood                 -20,704.21 -23,391.45 -20,607.76
## Akaike Inf. Crit.              41,466.41  46,786.90  41,275.52 
## ===============================================================
## Note:                               *p<0.1; **p<0.05; ***p<0.01
```

```r
#summary_residual_compare(Term_10D,Term_11B)
#summary_residual_compare(Term_11S,Term_11B)
```
Note that the VIF is getting high on pair_CA.

### Other Office Characteristics
#### 12A: Past Office Volume (dollars)

Expectation: Contracting offices previously had more contract volume in dollars would have more experience managing cost and preventing cost-ceiling breaches, therefore larger past office volume would lower the likelihood of cost-ceiling breaches but no substantial relationships with likelihood of terminations or exercised options.

Past Office Volume $s	cl_OffVol		-	+	+
From looking at data, terminations, easier for big, less dependent. - less dependenct


```r
summary_continuous_plot(serv_smp,"cl_OffVol")
```

![](Model_Termination_files/figure-html/Model12A-1.png)<!-- -->

```r
#Model
Term_12A <- glm (data=serv_smp,
                 b_Term ~ cl_OffVol, family=binomial(link="logit"))

display(Term_12A)
```

```
## glm(formula = b_Term ~ cl_OffVol, family = binomial(link = "logit"), 
##     data = serv_smp)
##             coef.est coef.se
## (Intercept) -3.99     0.02  
## cl_OffVol    0.66     0.05  
## ---
##   n = 250000, k = 2
##   residual deviance = 46586.3, null deviance = 46839.6 (difference = 253.4)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_12A,
                       
                       type="text",
                       digits=2)
```

```
## 
## =============================================
##                       Dependent variable:    
##                   ---------------------------
##                             b_Term           
## ---------------------------------------------
## cl_OffVol                   0.66***          
##                             (0.05)           
##                                              
## Constant                   -3.99***          
##                             (0.02)           
##                                              
## ---------------------------------------------
## Observations                250,000          
## Log Likelihood            -23,293.13         
## Akaike Inf. Crit.          46,590.27         
## =============================================
## Note:             *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_11A,Term_12A, skip_vif = TRUE)
```

![](Model_Termination_files/figure-html/Model12A-2.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model12A-3.png)<!-- -->

```
## NULL
```

```r
summary_residual_compare(Term_03D,Term_12A, skip_vif = TRUE)
```

![](Model_Termination_files/figure-html/Model12A-4.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used

## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

![](Model_Termination_files/figure-html/Model12A-5.png)<!-- -->

```
## NULL
```
Fully 
When considering past office volume alone, the relationship was as expected with cost-ceiling breaches. Out of our expectation, the results also showed increasing post office volume would reduce the possibility of exercised options but increase likelihood of having terminations.




#### 12B: Detailed Industry Diveristy

Expectation: More diverse industries of contracts contracting offices handle, the higher complexity they deal with, which would increase the likelihood of having cost ceiling breaches and terminations, and decreasing the likelihood of having options exercised.



```r
summary_continuous_plot(serv_smp,"cl_office_naics_hhi_k")
```

![](Model_Termination_files/figure-html/Model12B-1.png)<!-- -->

```r
#Model
Term_12B <- glm (data=serv_smp,
                 b_Term ~ cl_office_naics_hhi_k, family=binomial(link="logit"))

display(Term_12B)
```

```
## glm(formula = b_Term ~ cl_office_naics_hhi_k, family = binomial(link = "logit"), 
##     data = serv_smp)
##                       coef.est coef.se
## (Intercept)           -3.98     0.02  
## cl_office_naics_hhi_k  0.49     0.03  
## ---
##   n = 250000, k = 2
##   residual deviance = 46555.9, null deviance = 46839.6 (difference = 283.7)
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                       Term_12B,
                       
                       type="text",
                       digits=2)
```

```
## 
## =================================================
##                           Dependent variable:    
##                       ---------------------------
##                                 b_Term           
## -------------------------------------------------
## cl_office_naics_hhi_k           0.49***          
##                                 (0.03)           
##                                                  
## Constant                       -3.98***          
##                                 (0.02)           
##                                                  
## -------------------------------------------------
## Observations                    250,000          
## Log Likelihood                -23,277.95         
## Akaike Inf. Crit.              46,559.90         
## =================================================
## Note:                 *p<0.1; **p<0.05; ***p<0.01
```

```r
# summary_residual_compare(Term_11A,Term_12B, skip_vif = TRUE)
# summary_residual_compare(Term_03D,Term_12B, skip_vif = TRUE)
```

When using hhi calculated based on contracting office obligation: considering hhi alone, expectation for Temrination was not met.
When using hhi calculated based on contracting office number of contarcts: considering hhi alone, all expectation were met.

#### 12C: Cumulative Model


```r
#Frequency Plot for unlogged ceiling


#Model
Term_12C <- glm (data=serv_smp,
                 b_Term ~ cl_US6_avg_sal_lag1Const + 
                   cl_CFTE+ c_pPBSC+c_pOffPSC+
                   c_pairHist+cl_pairCA+
                   cl_Ceil + capped_cl_Days+
                   Comp1or5+
                   Veh+
                   PricingUCA+
                   Crisis+
                   cl_def6_HHI_lag1+cl_def6_ratio_lag1+
                   cl_def3_HHI_lag1+cl_def3_ratio_lag1+
                   c_pMarket+
                   cl_OffVol+cl_office_naics_hhi_k, family=binomial(link="logit"))

glmer_examine(Term_12C)
```

```
##                              GVIF Df GVIF^(1/(2*Df))
## cl_US6_avg_sal_lag1Const 1.612893  1        1.269997
## cl_CFTE                  1.438268  1        1.199278
## c_pPBSC                  1.588572  1        1.260385
## c_pOffPSC                2.277646  1        1.509187
## c_pairHist               1.389222  1        1.178653
## cl_pairCA                2.830895  1        1.682526
## cl_Ceil                  1.418564  1        1.191035
## capped_cl_Days           1.280011  1        1.131376
## Comp1or5                 1.344231  3        1.050539
## Veh                      2.046869  4        1.093670
## PricingUCA               1.177667  6        1.013721
## Crisis                   1.657403  3        1.087856
## cl_def6_HHI_lag1         2.204607  1        1.484792
## cl_def6_ratio_lag1       1.640474  1        1.280810
## cl_def3_HHI_lag1         2.089365  1        1.445464
## cl_def3_ratio_lag1       1.704985  1        1.305751
## c_pMarket                1.411540  1        1.188083
## cl_OffVol                1.296365  1        1.138580
## cl_office_naics_hhi_k    2.154490  1        1.467818
```

```r
#Plot residuals versus fitted
stargazer::stargazer(
                     Term_11B,Term_12A,Term_12C,
                     
                       type="text",
                       digits=2)
```

```
## 
## ===============================================================
##                                      Dependent variable:       
##                                --------------------------------
##                                             b_Term             
##                                   (1)        (2)        (3)    
## ---------------------------------------------------------------
## cl_US6_avg_sal_lag1Const         0.08**                 0.05   
##                                  (0.04)                (0.04)  
##                                                                
## cl_CFTE                           0.05                  0.04   
##                                  (0.03)                (0.03)  
##                                                                
## c_pPBSC                         -0.12***              -0.14*** 
##                                  (0.03)                (0.03)  
##                                                                
## c_pOffPSC                       0.92***               0.92***  
##                                  (0.03)                (0.04)  
##                                                                
## c_pairHist                       -0.03                 -0.06*  
##                                  (0.03)                (0.04)  
##                                                                
## cl_pairCA                       0.69***               0.65***  
##                                  (0.04)                (0.04)  
##                                                                
## cl_Ceil                         0.53***               0.50***  
##                                  (0.04)                (0.04)  
##                                                                
## capped_cl_Days                  1.25***               1.23***  
##                                  (0.04)                (0.04)  
##                                                                
## Comp1or51 offer                 0.44***               0.45***  
##                                  (0.05)                (0.05)  
##                                                                
## Comp1or52-4 offers              0.29***               0.30***  
##                                  (0.05)                (0.05)  
##                                                                
## Comp1or55+ offers               1.00***               0.99***  
##                                  (0.05)                (0.05)  
##                                                                
## VehS-IDC                        -1.14***              -1.14*** 
##                                  (0.04)                (0.04)  
##                                                                
## VehM-IDC                        -0.87***              -0.87*** 
##                                  (0.05)                (0.05)  
##                                                                
## VehFSS/GWAC                     -0.22***              -0.21*** 
##                                  (0.07)                (0.07)  
##                                                                
## VehBPA/BOA                      -1.05***              -1.03*** 
##                                  (0.10)                (0.10)  
##                                                                
## PricingUCAOther FP              -0.78***              -0.79*** 
##                                  (0.16)                (0.16)  
##                                                                
## PricingUCAT&M/LH/FPLOE          -0.55***              -0.55*** 
##                                  (0.15)                (0.15)  
##                                                                
## PricingUCAIncentive             -3.39***              -3.41*** 
##                                  (1.00)                (1.00)  
##                                                                
## PricingUCAOther CB              -1.40***              -1.42*** 
##                                  (0.12)                (0.12)  
##                                                                
## PricingUCAUCA                   -1.03***              -1.03*** 
##                                  (0.23)                (0.23)  
##                                                                
## PricingUCACombination or Other  -0.86***              -0.85*** 
##                                  (0.22)                (0.22)  
##                                                                
## CrisisARRA                      -0.68***              -0.68*** 
##                                  (0.21)                (0.21)  
##                                                                
## CrisisDis                        -0.04                 -0.04   
##                                  (0.39)                (0.39)  
##                                                                
## CrisisOCO                        -0.09                 -0.09   
##                                  (0.08)                (0.08)  
##                                                                
## cl_def6_HHI_lag1                -0.36***              -0.33*** 
##                                  (0.04)                (0.04)  
##                                                                
## cl_def6_ratio_lag1              -0.35***              -0.36*** 
##                                  (0.05)                (0.05)  
##                                                                
## cl_def3_HHI_lag1                0.50***               0.48***  
##                                  (0.04)                (0.04)  
##                                                                
## cl_def3_ratio_lag1              -0.61***              -0.60*** 
##                                  (0.05)                (0.05)  
##                                                                
## c_pMarket                       -0.67***              -0.63*** 
##                                  (0.06)                (0.06)  
##                                                                
## cl_OffVol                                  0.66***    0.23***  
##                                             (0.05)     (0.04)  
##                                                                
## cl_office_naics_hhi_k                                   0.06   
##                                                        (0.04)  
##                                                                
## Constant                        -4.05***   -3.99***   -4.06*** 
##                                  (0.04)     (0.02)     (0.04)  
##                                                                
## ---------------------------------------------------------------
## Observations                    250,000    250,000    250,000  
## Log Likelihood                 -20,607.76 -23,293.13 -20,591.31
## Akaike Inf. Crit.              41,275.52  46,590.27  41,246.62 
## ===============================================================
## Note:                               *p<0.1; **p<0.05; ***p<0.01
```

```r
summary_residual_compare(Term_10D,Term_12C)
```

![](Model_Termination_files/figure-html/Model12C-1.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

```
## Warning in if (class(model1_new) != "glmerMod" & class(model1_old) !=
## "glmerMod" & : the condition has length > 1 and only the first element will
## be used
```

![](Model_Termination_files/figure-html/Model12C-2.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance difference
## 1 model1_old 41408.41      46839.64   5431.226
## 2 model1_new 41182.62      46839.64   5657.023
## 
## [[2]]
##                              GVIF Df GVIF^(1/(2*Df))
## cl_US6_avg_sal_lag1Const 1.612893  1        1.269997
## cl_CFTE                  1.438268  1        1.199278
## c_pPBSC                  1.588572  1        1.260385
## c_pOffPSC                2.277646  1        1.509187
## c_pairHist               1.389222  1        1.178653
## cl_pairCA                2.830895  1        1.682526
## cl_Ceil                  1.418564  1        1.191035
## capped_cl_Days           1.280011  1        1.131376
## Comp1or5                 1.344231  3        1.050539
## Veh                      2.046869  4        1.093670
## PricingUCA               1.177667  6        1.013721
## Crisis                   1.657403  3        1.087856
## cl_def6_HHI_lag1         2.204607  1        1.484792
## cl_def6_ratio_lag1       1.640474  1        1.280810
## cl_def3_HHI_lag1         2.089365  1        1.445464
## cl_def3_ratio_lag1       1.704985  1        1.305751
## c_pMarket                1.411540  1        1.188083
## cl_OffVol                1.296365  1        1.138580
## cl_office_naics_hhi_k    2.154490  1        1.467818
```

```r
summary_residual_compare(Term_11B,Term_12C)
```

![](Model_Termination_files/figure-html/Model12C-3.png)<!-- -->

```
## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used

## Warning in if (class(model1_new) == "glmerMod") {: the condition has length
## > 1 and only the first element will be used
```

![](Model_Termination_files/figure-html/Model12C-4.png)<!-- -->

```
## [[1]]
##        model deviance null.deviance difference
## 1 model1_old 41215.52      46839.64   5624.118
## 2 model1_new 41182.62      46839.64   5657.023
## 
## [[2]]
##                              GVIF Df GVIF^(1/(2*Df))
## cl_US6_avg_sal_lag1Const 1.612893  1        1.269997
## cl_CFTE                  1.438268  1        1.199278
## c_pPBSC                  1.588572  1        1.260385
## c_pOffPSC                2.277646  1        1.509187
## c_pairHist               1.389222  1        1.178653
## cl_pairCA                2.830895  1        1.682526
## cl_Ceil                  1.418564  1        1.191035
## capped_cl_Days           1.280011  1        1.131376
## Comp1or5                 1.344231  3        1.050539
## Veh                      2.046869  4        1.093670
## PricingUCA               1.177667  6        1.013721
## Crisis                   1.657403  3        1.087856
## cl_def6_HHI_lag1         2.204607  1        1.484792
## cl_def6_ratio_lag1       1.640474  1        1.280810
## cl_def3_HHI_lag1         2.089365  1        1.445464
## cl_def3_ratio_lag1       1.704985  1        1.305751
## c_pMarket                1.411540  1        1.188083
## cl_OffVol                1.296365  1        1.138580
## cl_office_naics_hhi_k    2.154490  1        1.467818
```


## Pre-Multilevel Model Summary


```r
 # !is.na(def_serv$cl_US6_avg_sal_lag1)&
 #  !is.na(def_serv$cl_CFTE)&
 #  !is.na(def_serv$c_pPBSC)&
 #  !is.na(def_serv$c_pOffPSC)&
 #  !is.na(def_serv$c_pairHist)&
 #  !is.na(def_serv$cl_pairCA)&


#Terminations
stargazer::stargazer(Term_01A,Term_01B,Term_02A,Term_02B,Term_03A,Term_03B,Term_03D,Term_12C,
                       type="text",
                       digits=2)
```

```
## 
## ======================================================================================================================
##                                                                  Dependent variable:                                  
##                                ---------------------------------------------------------------------------------------
##                                                                        b_Term                                         
##                                   (1)        (2)        (3)        (4)        (5)        (6)        (7)        (8)    
## ----------------------------------------------------------------------------------------------------------------------
## cl_US6_avg_sal_lag1Const        0.10***                                                            -0.06*      0.05   
##                                  (0.03)                                                            (0.03)     (0.04)  
##                                                                                                                       
## cl_CFTE                                      0.04                                                  0.07**      0.04   
##                                             (0.03)                                                 (0.03)     (0.03)  
##                                                                                                                       
## c_pPBSC                                               0.27***                                       0.03     -0.14*** 
##                                                        (0.03)                                      (0.03)     (0.03)  
##                                                                                                                       
## c_pOffPSC                                                        0.50***                          0.37***    0.92***  
##                                                                   (0.02)                           (0.03)     (0.04)  
##                                                                                                                       
## c_pairHist                                                                   0.001                -0.23***    -0.06*  
##                                                                              (0.03)                (0.03)     (0.04)  
##                                                                                                                       
## cl_pairCA                                                                              0.47***    0.41***    0.65***  
##                                                                                         (0.03)     (0.03)     (0.04)  
##                                                                                                                       
## cl_Ceil                                                                                                      0.50***  
##                                                                                                               (0.04)  
##                                                                                                                       
## capped_cl_Days                                                                                               1.23***  
##                                                                                                               (0.04)  
##                                                                                                                       
## Comp1or51 offer                                                                                              0.45***  
##                                                                                                               (0.05)  
##                                                                                                                       
## Comp1or52-4 offers                                                                                           0.30***  
##                                                                                                               (0.05)  
##                                                                                                                       
## Comp1or55+ offers                                                                                            0.99***  
##                                                                                                               (0.05)  
##                                                                                                                       
## VehS-IDC                                                                                                     -1.14*** 
##                                                                                                               (0.04)  
##                                                                                                                       
## VehM-IDC                                                                                                     -0.87*** 
##                                                                                                               (0.05)  
##                                                                                                                       
## VehFSS/GWAC                                                                                                  -0.21*** 
##                                                                                                               (0.07)  
##                                                                                                                       
## VehBPA/BOA                                                                                                   -1.03*** 
##                                                                                                               (0.10)  
##                                                                                                                       
## PricingUCAOther FP                                                                                           -0.79*** 
##                                                                                                               (0.16)  
##                                                                                                                       
## PricingUCAT&M/LH/FPLOE                                                                                       -0.55*** 
##                                                                                                               (0.15)  
##                                                                                                                       
## PricingUCAIncentive                                                                                          -3.41*** 
##                                                                                                               (1.00)  
##                                                                                                                       
## PricingUCAOther CB                                                                                           -1.42*** 
##                                                                                                               (0.12)  
##                                                                                                                       
## PricingUCAUCA                                                                                                -1.03*** 
##                                                                                                               (0.23)  
##                                                                                                                       
## PricingUCACombination or Other                                                                               -0.85*** 
##                                                                                                               (0.22)  
##                                                                                                                       
## CrisisARRA                                                                                                   -0.68*** 
##                                                                                                               (0.21)  
##                                                                                                                       
## CrisisDis                                                                                                     -0.04   
##                                                                                                               (0.39)  
##                                                                                                                       
## CrisisOCO                                                                                                     -0.09   
##                                                                                                               (0.08)  
##                                                                                                                       
## cl_def6_HHI_lag1                                                                                             -0.33*** 
##                                                                                                               (0.04)  
##                                                                                                                       
## cl_def6_ratio_lag1                                                                                           -0.36*** 
##                                                                                                               (0.05)  
##                                                                                                                       
## cl_def3_HHI_lag1                                                                                             0.48***  
##                                                                                                               (0.04)  
##                                                                                                                       
## cl_def3_ratio_lag1                                                                                           -0.60*** 
##                                                                                                               (0.05)  
##                                                                                                                       
## c_pMarket                                                                                                    -0.63*** 
##                                                                                                               (0.06)  
##                                                                                                                       
## cl_OffVol                                                                                                    0.23***  
##                                                                                                               (0.04)  
##                                                                                                                       
## cl_office_naics_hhi_k                                                                                          0.06   
##                                                                                                               (0.04)  
##                                                                                                                       
## Constant                        -3.95***   -3.95***   -3.96***   -3.98***   -3.95***   -3.97***   -3.99***   -4.06*** 
##                                  (0.01)     (0.01)     (0.01)     (0.02)     (0.01)     (0.02)     (0.02)     (0.04)  
##                                                                                                                       
## ----------------------------------------------------------------------------------------------------------------------
## Observations                    250,000    250,000    250,000    250,000    250,000    250,000    250,000    250,000  
## Log Likelihood                 -23,414.38 -23,419.06 -23,375.66 -23,229.80 -23,419.82 -23,276.44 -23,149.37 -20,591.31
## Akaike Inf. Crit.              46,832.76  46,842.12  46,755.33  46,463.61  46,843.64  46,556.88  46,312.75  41,246.62 
## ======================================================================================================================
## Note:                                                                                      *p<0.1; **p<0.05; ***p<0.01
```

```r
texreg::htmlreg(list(Term_01A,Term_01B,Term_02A,Term_02B,Term_03A,Term_03B,Term_03D,Term_12C),file="..//Output//Term_model_lvl1.html",
                single.row = TRUE,
                # custom.model.name=c("Ceiling Breaches"),
                stars=c(0.1,0.05,0.01,0.001),
                groups = list(
                              "Services Complexity" = 2:3,
                              "Office Capacity" =4:5,
                              "Past Relationship"=6:7
                              ),
                custom.coef.map=study_coef_list,
                bold=0.05,
                custom.note="%stars. Numerical inputs are rescaled.",
                caption="Table 7: Logit Bivariate Look at Study Variables and Terminations",
                caption.above=TRUE)
```

```
## The table was written to the file '..//Output//Term_model_lvl1.html'.
```
