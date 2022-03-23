# gssgenderedchildcare

## Paper Overview
This repository contains data and code for the analysis of time spent on childcare and other care related activity by Canadian men and women. Specifically, data collected form the 2015 Canadian General Social Survey on Time Use is used to describe differences in daily time spent on care activities by Canadian males and females in two-parent/guardian households, within various categories of personal and household income. In this paper, I conclude that irrespective of income, Canadian females bear a large burden on childcare labour time than men. Notably, this difference persists even in households where the female is also the sole household income earner. This is consistent with recent literature on gender inequality in the North American context, which posits that even as female participation in the labour force increases, women are still expected to preform the majoirty of unpaid care work.

## File Structure
'outputs' includes the files neccisary to reproduce this paper, as well as a pdf copy of the paper itself, a copy of the questionnaire used to conduct the 2015 Canadian General Social Survey on Time Use, and a supplement to said survey. 'inputs' contains an empty folder 'data', into which raw data must be inserted before reproducing the paper. 'scripts' includes a single script, 00_data_clean.R, which takes raw data from 'inputs/data' as an input and outputs cleaned data into 'inputs/data'.

## Accessing Raw Data
Below is a list of instructions for accessing the raw data needed to reproduce this paper:
01. Go to http://www.chass.utoronto.ca/
02. Hover over Data Center button, click on U. of T. Users
03. Click SDA @ CHASS, you should be redirected to a U of T login page
04. Enter your U of T credentials, you should be sent to a landing page
05. Click Continue in English on the landing page
06. Use Crtl + F to find "GSS", click on General social surveys (GSS) link
07. Find "General social survey on Time Use (cycle 29), 2015:"
08. Click the Data link next to Main File
09. Hover over Download Button and click Customized Subset
10. Select CSV Data File, STATA Data definitions, and All Variables, except Sample Weights
 - see data_selection.pdf in directory for an image of the proper selection
11. Create the files, download, and save them
 - you may have to copy and paste the STATA defintions text from your browser to a .rtf text file
12. Rename the .csv file raw_2015_gss.csv and the .rtf file stata_defs.rtf
13. Place the files in the inputs/data folder of this directory

Check: 
1. Make sure that the STATA Data definitions file is a .rtf file
2. Confirm that the filenames are raw_2015_gss.csv and stata_defs.rtf
