Getting and Cleaning Data - Course Project
========================================================
by Javier Martínez Arribas


  With this project I have tried to collect, clean and process a data set coming 
from a .zip file. The data compressed in the .zip file contains 
several .txt files with data relative to a study about human activity 
recognition using smartphones. The experiments were carried out with a group of 
30 volunteers within an age bracket of 19-48 years performing six activities and
wearing a smartphone Samsung Galaxy S II on the waist. The data was collected
through the embedded accelerometer and gyroscope of the smartphone.
 
 
**Merges the training and the test sets to create one data set**
  
  The first step has been to merge the training and test set to create one data
set. Both training and test set were made up with 3 files, one for subject id,
one for activity id and the last one for 561 features.
  
  The data is here: [Human Activity Recognition data](https://d396qusza40orc.
              cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
  
  And we run the next R code to obtain it:
  

```r
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dest <- getwd()
dest <- paste(dest, sep = "", "/getdata-projectfiles-UCI HAR Dataset.zip")
download.file(url, destfile = dest, method = "curl")
unzip(dest)
orig <- getwd()
orig <- paste(orig, sep = "", "/UCI HAR Dataset/")
```

  
  When we have downloaded the data we are ready to merge all files in one dataset.
  We start with training files in this way:


```r
orig_train_subject <- paste(orig, sep = "", "/train/subject_train.txt")
train_subject <- read.table(orig_train_subject, header = F)

orig_train_x <- paste(orig, sep = "", "/train/X_train.txt")
train_x <- read.table(orig_train_x, header = F)

orig_train_y <- paste(orig, sep = "", "/train/y_train.txt")
train_y <- read.table(orig_train_y, header = F)

train <- cbind(train_subject, train_y, train_x)
```


  And continue with the test data files:
  

```r
orig_test_subject <- paste(orig, sep = "", "/test/subject_test.txt")
test_subject <- read.table(orig_test_subject, header = F)

orig_test_x <- paste(orig, sep = "", "/test/X_test.txt")
test_x <- read.table(orig_test_x, header = F)

orig_test_y <- paste(orig, sep = "", "/test/y_test.txt")
test_y <- read.table(orig_test_y, header = F)

test <- cbind(test_subject, test_y, test_x)

```


  After obtaining all data we create one unique dataset:
  

```r
dataset <- rbind(train, test)
```



**Extracts only the measurements on the mean and standard deviation for each 
measurement**

  In order to extract just some features about mean and standard deviation,
we make a column subsetting. First we need to read the features file:


```r
col_nam <- read.table("/Users/javimartinezarribas/Documents/Coursera/\nGettingCleaningData/UCI HAR Dataset/features.txt", 
    header = FALSE, sep = "")
```

and rename our unique dataset with the names that we have got it from the features 
file and include the subject id and the activity id as well:

```r
colnames(dataset) <- c("subject", "activity", as.character(col_nam[, 2]))
```

 We have got the complete dataset although we don't need all the columns, so
we substract just the columns that we want, that ones with the words 
"mean" or "std" in their names. After selecting these columns we create the 
desired dataset:

```r
col_mean_std <- grep("mean|std", col_nam$V2, value = TRUE)
mean_std_dataset <- dataset[, c("subject", "activity", col_mean_std)]
```


 I have decided to obtain mean and meanFreq columns because I have considered
that when we work with frequency variables we need to include the weighted 
average of the frequency components in order to compare the different frecuency 
means.


**Uses descriptive activity names to name the activities in the data set**

  To change the activity column ids with the suitable description we can run a
for loop:


```r
for (i in 1:nrow(dataset)) {
    if (dataset[i, 2] == 1) {
        dataset[i, 2] = "WALKING"
    } else if (dataset[i, 2] == 2) {
        dataset[i, 2] = "WALKING_UPSTAIRS"
    } else if (dataset[i, 2] == 3) {
        dataset[i, 2] = "WALKING_DOWNSTAIRS"
    } else if (dataset[i, 2] == 4) {
        dataset[i, 2] = "SITTING"
    } else if (dataset[i, 2] == 5) {
        dataset[i, 2] = "STANDING"
    } else if (dataset[i, 2] == 6) {
        dataset[i, 2] = "LAYING"
    }
}
```



**Appropriately labels the data set with descriptive variable names**

  We must rename column names in order to avoid some kind of future internal
R problems when we call some functions. To get this purpose we run the next code
trying to eliminate some characters like [() -]:

```r
cols_clean <- gsub("[()]", "", colnames(mean_std_dataset))
cols_clean <- gsub("[-]", "_", cols_clean)
colnames(mean_std_dataset) <- cols_clean
```



**Creates a second, independent tidy data set with the average of each variable 
for each activity and each subject**

  To create a second and tidy data set with the average of each variable for each 
activity and each subject I have used the aggregate function in this way:


```r
dataset <- aggregate(x = dataset[, 3:ncol(dataset)], by = list(subject = dataset$subject, 
    activity = dataset$activity), FUN = "mean", na.rm = T)
```



