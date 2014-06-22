#Downloading and unzipping files
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dest <- getwd()
dest <- paste(dest,sep="","/getdata-projectfiles-UCI HAR Dataset.zip")
download.file(url,destfile=dest,method="curl")
unzip(dest)
orig <- getwd()
orig <- paste(orig,sep="","/UCI HAR Dataset/")

#Training dataset
orig_train_subject <- paste(orig,sep="","/train/subject_train.txt")
train_subject <- read.table(orig_train_subject,header=F)
orig_train_x <- paste(orig,sep="","/train/X_train.txt")
train_x <- read.table(orig_train_x,header=F)
orig_train_y <- paste(orig,sep="","/train/y_train.txt")
train_y <- read.table(orig_train_y,header=F)
train <- cbind(train_subject,train_y,train_x)

#Testing dataset
orig_test_subject <- paste(orig,sep="","/test/subject_test.txt")
test_subject <- read.table(orig_test_subject,header=F)
orig_test_x <- paste(orig,sep="","/test/X_test.txt")
test_x <- read.table(orig_test_x,header=F)
orig_test_y <- paste(orig,sep="","/test/y_test.txt")
test_y <- read.table(orig_test_y,header=F)
test <- cbind(test_subject,test_y,test_x)

#Merging both datasets
dataset <- rbind(train,test)

#Name columns
col_nam <- read.table("/Users/javimartinezarribas/Documents/Coursera/GettingCleaningData/UCI HAR Dataset/features.txt",header=FALSE,sep="")
colnames(dataset) <- c("subject","activity",as.character(col_nam[,2]))

#Extract mean and std columns 
col_mean_std <- grep("mean|std",col_nam$V2,value=TRUE)
mean_std_dataset <- dataset[,c("subject","activity",col_mean_std)]


#Loop to change to a descriptive label activity
for(i in 1:nrow(dataset)){
  if (dataset[i,2]==1){
    dataset[i,2]="WALKING"
  }
  else if (dataset[i,2]==2) {
    dataset[i,2]="WALKING_UPSTAIRS"
  }
  else if (dataset[i,2]==3) {
    dataset[i,2]="WALKING_DOWNSTAIRS"
  }
  else if (dataset[i,2]==4) {
    dataset[i,2]="SITTING"
  }
  else if (dataset[i,2]==5) {
    dataset[i,2]="STANDING"
  }
  else if (dataset[i,2]==6) {
    dataset[i,2]="LAYING"
  }
}

#Change properly column names
cols_clean <- gsub("[()]","",colnames(mean_std_dataset))
cols_clean <- gsub("[-]","_",cols_clean)
colnames(mean_std_dataset) <- cols_clean

#New dataset of means by subject and activity
dataset <- aggregate(x=dataset[,3:ncol(dataset)],by=list(subject=dataset$subject,activity=dataset$activity), FUN = "mean", na.rm=T)

#Change properly column names in 2nd dataset
cols_clean <- gsub("[()]","",colnames(dataset))
cols_clean <- gsub("[-]","_",cols_clean)
colnames(dataset) <- cols_clean
