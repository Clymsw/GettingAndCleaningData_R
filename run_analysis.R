#1. Get Data
#sDataFile = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

#download.file(url=sDataFile, destfile = "data.zip", method = "curl")
#unzip("data.zip")

dfTrainingX_total <- read.delim("UCI HAR Dataset/train/X_train.txt", header = FALSE, sep = "")
dfTrainingY <- read.delim("UCI HAR Dataset/train/y_train.txt", header = FALSE)
dfTrainingSubject <- read.delim("UCI HAR Dataset/train/subject_train.txt", header = FALSE)

dfTestX_total <- read.delim("UCI HAR Dataset/test/X_test.txt", header = FALSE, sep = "")
dfTestY <- read.delim("UCI HAR Dataset/test/y_test.txt", header = FALSE)
dfTestSubject <- read.delim("UCI HAR Dataset/test/subject_test.txt", header = FALSE)


#2. Appropriately label the data set with descriptive variable names. 
colNames <- read.delim("UCI HAR Dataset/features.txt", header = FALSE)
colNames <- lapply(colNames, as.character)

colnames(dfTrainingX_total) <- colNames[[1]]
colnames(dfTestX_total) <- colNames[[1]]
colnames(dfTrainingY) <- "Activity.Type"
colnames(dfTestY) <- "Activity.Type"
colnames(dfTrainingSubject) <- "Subject"
colnames(dfTestSubject) <- "Subject"


#3. Extract only the measurements on the mean and standard deviation for each measurement. 
dfTrainingX_mean <- dfTrainingX_total[grep("mean()",colNames[[1]])]
dfTestX_mean <- dfTestX_total[grep("mean()",colNames[[1]])]
dfTrainingX_std <- dfTrainingX_total[grep("std()",colNames[[1]])]
dfTestX_std <- dfTestX_total[grep("std()",colNames[[1]])]

dfTrainingX <- cbind.data.frame(dfTrainingX_mean, dfTrainingX_std)
dfTestX <- cbind.data.frame(dfTestX_mean, dfTestX_std)


#4. Merge the training and the test sets to create one data set.
TotalDataSetY <- rbind.data.frame(dfTrainingY, dfTestY)
TotalDataSetX <- rbind.data.frame(dfTrainingX, dfTestX)
TotalDataSetSubject <- rbind.data.frame(dfTrainingSubject, dfTestSubject)
TotalDataSet <- cbind.data.frame(TotalDataSetY, TotalDataSetSubject, TotalDataSetX)


#5. Use descriptive activity names to name the activities in the data set
activityNames <- read.delim("UCI HAR Dataset/activity_labels.txt", header = FALSE, sep="")

TotalDataSet$Activity.Type <- activityNames$V2[match(TotalDataSet$Activity.Type,activityNames$V1)]


#6. From the data set in step 4, create a second, independent tidy data set 
#   with the average of each variable for each activity and each subject.

library(reshape2)

mltTotalDataSet <- melt(TotalDataSet, id=c("Activity.Type","Subject") )

dfAvgDataByActivity <- dcast(mltTotalDataSet, Activity.Type ~ variable, mean)
colnames(dfAvgDataByActivity)[1] <- "Activity Type or Subject"

dfAvgDataBySubject <- dcast(mltTotalDataSet, Subject ~ variable, mean)
colnames(dfAvgDataBySubject)[1] <- "Activity Type or Subject"
dfAvgDataBySubject$`Activity Type or Subject` <- as.factor(dfAvgDataBySubject$`Activity Type or Subject`)

dfAvgData <- rbind.data.frame(dfAvgDataByActivity, dfAvgDataBySubject)

#write.table(dfAvgDataByActivity, "tidyresults.txt")
#write.table(dfAvgDataBySubject, "tidyresults.txt", append=TRUE)

write.table(dfAvgData, "tidyresults.txt", row.names = FALSE)


#7. Read in using the following:
#dfAvgData <- read.table("tidyresults.txt")
