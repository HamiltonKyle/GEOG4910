##### Important information about the text below ######

# Any line that begins with a "#" is not read by RStudio. We will use this feature to provide 
# explanations and instructions, and you can use it to annotate (i.e., make notes about) your 
# R code.  Any lines of black text (i.e., not preceded by a "#") will be read by RStudio as a 
# command.  To make RStudio execute the command, highlight the entire line, including the black 
# text and either click on "Run" in the upper right corner of this window or press "Ctrl + Enter"
# on your keyboard. The results of your command will then appear in the "Console" window below.



##### Step #1:  Convert .xlsx files to .csv

# In Excel (not RStudio) open your .xlsx file.  Click on the appropriate worksheet. Inspect this datafile. 
# You should be familiar with the layout of the datasheet.

# Use the "Save as" command to save it as a .csv file. 
# using "CSV Comma delimited (*.csv)" option. When Excel gives you a warning and asks if you 
# want to keep the workbook in that format, click "yes". Make sure to note the location and file 
# path of your new .csv file. When you are finished you should have a .csv file for your data.



##### Step # 2:  Read your hare data file into RStudio #####

# In the file path code, you will need to convert backslashes (\) to a forwardslash (/)
# or use a double backslash (\\).  The code below will need to reflect the location of YOUR .csv 
# datafile on YOUR computer!! Below is the location on MY computer, not necessarily yours!

# Note, you can also setup your working directory instead...

# Now run the R code in the line below by placing the cursor on the line and clicking on "Run" or 
# pressing "Ctrl+Enter"

bunny.data <- read.csv("Paths\\....\\PelletData.csv")

#if you set your working directory, you can just use the code below to load your data

bunny.data <- read.csv("PelletData.csv", header=T, sep=",")

# In this command "read.csv" is telling RStudio to read in your .csv file. The text in 
# the parentheses specifies the location of your .csv file on your computer (note that 
# you will have to change the code we provided to reflect the location of the file on your 
# particular computer).  The "bunny.data <-" portion of the code is telling R to name the imported file 
# "bunny.data".  You could name it something else if you want.  For example, if you wanted to name it 
# "mydata", you would replace "bunny.data" with "mydata". The code below assumes you named it "bunny.data".



##### Step # 3:  View the structure of your bunny pellet and cover data file  #####

# Run the code below to view the structure of your bunny data

str(bunny.data)     # display the structure of the data

#Be sure to look at how many "levels" of data you have for each variable. Most importantly
# "Treatment" should only have two levels. If it has more than two, first make sure that your Excel 
# data only includes two treatment types (R cares about upper- vs. lower-case lettering), and make
# sure that any rows below your data (even if they seem blank), have been deleted.

# Notice the column names for your data (preceded with "$"). R is not well suited for handling special characters
# and typing long names in your code becomes tedious. To make the data easier to work with, run the following
# code to rename these columns.

names(bunny.data)[7]   <- "pellets"       # rename column 7  "pellets"
names(bunny.data)[5]   <- "cover.0m"      # rename column 8  "cover.0m", cover at ground level
names(bunny.data)[6]  <- "cover.2m"      # rename column 9  "cover.2m", cover at 2 meters

# Take a another look at your data

str(bunny.data)

# Notice that in your data, "pellets", "cover.0m" and cover.2m" are not "num" (numeric data).  To correct this for your analysis 
# you need to convert the data to numeric format.  Use the code provided below to make this conversion.


bunny.data$pellets  <- as.numeric(bunny.data$pellets)      # convert "pellets" data type to numeric
bunny.data$cover.0m <- as.numeric(bunny.data$cover.0m)     # convert "cover.0m" data type to numeric
bunny.data$cover.2m <- as.numeric(bunny.data$cover.2m)     # convert "cover.2m" data type to numeric

# Take one more look at the data structure to make sure all of your changes have been applied and that the data looks good.

str(bunny.data)



#### Step # 4: Create R objects for each dataset that you will test

# To make comparisons between treatment (thinned) and control (non-thinned), you will need to create an R object (i.e. dataset) 
# for each of these in R. The code below creates the object "thinned.data" for all observations that were in the thinned stand 
# and another R object for the observations in the non-thinned stand. If you renamed your plot type column in excel you will need to
# modify the R code to reflect your changes.

thinned.data <- bunny.data[bunny.data$Treatment == 'Thinned',]  # Here you are telling R to select only the rows of data where "Plot type" equals (==) "thinned"
mature.data <- bunny.data[bunny.data$Treatment == 'Mature',]

#Now check to make sure that the objects have retained all your observations.  There should have been a total of 20 plots in each.

nrow(thinned.data)       # Counts the number of observations in the thinned data set
nrow(mature.data)   # Counts the number of observations in the mature data set

# Did the returned values seem reasonable? If not, you need to think of what might be wrong and correct it before you formally analyze
# your data.

# You can view the specific values for your new objects using the this code. 
# Compare this with your original csv spreadsheet.

thinned.data$pellets         # Returns the values for all pellet count observations in the thinned stand

mature.data$pellets     # Returns the values for all pellet count observations in the mature stand

thinned.data$cover.0m        # Returns the values for all cover observations at 0m for the thinned stand

mature.data$cover.0m    # Returns the values for all cover observations at 0m for the mature stand

thinned.data$cover.2m        # Returns the values for all cover observations at 2m for the thinned stand

mature.data$cover.2m    # Returns the values for all cover observations at 2m for the mature stand



##### Question 7 (Finally!):  Test the assumptions of homogeneity of variance 

# Before proceeding with the t-test, it is necessary to evaluate the sample variances of the two groups,
# using a Fisher's F-test to verify the homoskedasticity (homogeneity of variances). In R you can do the following:

var.test(thinned.data$pellets,mature.data$pellets)  # Variance test comparing thinned and mature pellet counts

# Now run the same test on the cover data at both 0m and 2m.

var.test(thinned.data$cover.0m,mature.data$cover.0m)  # Variance test comparing thinned and mature cover at 0m

var.test(thinned.data$cover.2m,mature.data$cover.2m)  # Variance test comparing thinned and mature cover at 2m

# Now interpret these results using the resulting p-values. If the test returned a p-value < 0.05 you should reject the
# null hypothesis (i.e., meaning that the variances are different). Using this information you will be modifying the t-test code in the following step.



##### Question 8a:  Perform a two-tailed t-test to determine if there is a statistically significant difference in pellet densities between tree stands.

# Start by running the t-test on the pellet data using the following code. Make sure to modify the code based on your variance test in the previous step.
# You will be editing the portion of code where var.equal="TRUE". This is asking you if the variance is equal between your thinned and non-thinned
# data. If the p-value from your var.test is < 0.05 you need to change this value to "FALSE". If the p-value was > 0.05 then it should
# equal "TRUE".

pellet.ttest <- t.test(thinned.data$pellets,mature.data$pellets, var.equal=TRUE, paired=FALSE)  # Run t-test, name it "pellet.ttest"

pellet.ttest # view the results of your t-test and now answer Question 8a.


##### Question 12a:  Perform a two-tailed t-test to determine if there is a statistically significant difference between tree stands.

cover2m.ttest <- t.test(thinned.data$cover.2m, mature.data$cover.2m, var.equal=TRUE, paired=FALSE)  # Run t-test, name it "cover2m.ttest". 
# Be sure to modify the code according to equal or unequal variances.

# To fully interpret your data, you'll need to calculate your t-critical value based on your chosen 
# alpha level (0.05) and the degrees of freedom for your tests (n-2). Remember that because this test
# is two-sided so we divide alpha by 2 to distribute the value to both sides of our curve. 

# CRITICAL ## Before running the code below, you will need to determine your degrees of freedom and enter them into the code by replacing "X".
qt(.975, X)     # t-critical value (alpha = 0.05 and df = ??)

cover2m.ttest     # Return cover2m.ttest results(i.e., read results of your t-test)
