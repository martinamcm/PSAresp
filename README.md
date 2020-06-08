## PSAresp
Analysis of single arm Prostate-Specific Antigen scores using augmented and binary methods

## [![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues)

## Description
PSAresp is a Shiny app which can be used to implement efficient analysis of PSA response. The PSA data is analysed using:
* Binary Method: Uses patients' binary response indicator 
* Augmented Method: Uses patients' continuous PSA data 

The tutorial below uses an example dataset to provide step-by-step guidance for using the PSAresp Shiny app. 

In the case that further queries arise about the functionality of the app for specific applications, contact Martina McMenamin at <martina.mcmenamin@mrc-bsu.cam.ac.uk>.

## Getting started

To access the PSAresp GUI, go to https://martinamcm.shinyapps.io/psaresp/. 

An example dataset is available in the repository.

## Tutorial

The user begins by uploading a csv file containing a single column with the % change from baseline in PSA scores. A waterfall plot displays the data as shown below. 

<p align="center">
<img src="/Images/WaterfallPlot.png" title="WaterfallPlot" width="80%" align="center"/>
</p>

In the 'Analysis' panel, the user sets the response threshold for % change in PSA and a point at which to truncate PSA scores. For instance if the truncation point is 100%, all PSA scores above this value will be replaced by 100. 

<p align="center">
<img src="/Images/Analysis1.png" title="PSAanalysis" width="80%" align="center"/>
</p>

Note that changing the truncation point changes the results for the augmented approach but not the binary approach. 

<p align="center">
<img src="/Images/Analysis2.png" title="PSAanalysisTrunc" width="80%" align="center"/>
</p>

Clicking the 'Download Report' button will generate a pdf file containing the results, as shown below. 

<p align="center">
<img src="/Images/PSAreport.pdf" title="PSAreport" width="80%" align="center"/>
</p>

