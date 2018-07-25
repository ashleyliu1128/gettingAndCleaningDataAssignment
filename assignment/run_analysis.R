# Read data in
test <- read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE)
train <- read.table("./UCI HAR Dataset/train/X_train.txt", header = FALSE)

# Merges the training and the test sets to create one data set
dataSet <- rbind(test, train)

# Extracts only the measurements on the mean and standard deviation for each measurement
features <- read.table("./UCI HAR Dataset/features.txt", header = FALSE, stringsAsFactors = FALSE)
column_names <- features[,2]
names(dataSet) <- column_names
subset_columns <- grep("mean\\(\\)|std\\(\\)", column_names)
subSet <- dataSet[,subset_columns]

# Uses descriptive activity names to name the activities in the data set
# Loading activity label and and test/training label files
activityLables <- read.table("./UCI HAR Dataset/activity_labels.txt", header = FALSE, stringsAsFactors = FALSE)
activityTest <- read.table("./UCI HAR Dataset/test/y_test.txt", header = FALSE, stringsAsFactors = FALSE)
activityTrain <- read.table("./UCI HAR Dataset/train/y_train.txt", header = FALSE, stringsAsFactors = FALSE)
# Bind activity data from test and train, and match the activity labels with names
activity <- rbind(activityTest, activityTrain)
library(dplyr)
activityMerged <- join(activity, activityLables)
# Bind activity names with the data set, and rename the column names
subset_column_names <- names(subSet)
subSet <- cbind(subSet, activityMerged$V2)
names(subSet) <- c(subset_column_names, "activityName")

# Appropriately labels the data set with descriptive variable names
names(subSet) <- gsub("^t", "time", names(subSet))
names(subSet) <- gsub("^f", "frequency", names(subSet))
names(subSet) <- gsub("Acc", "Accelerometer", names(subSet))
names(subSet) <- gsub("Gyro", "Gyroscope", names(subSet))
names(subSet) <- gsub("Mag", "Magnitude", names(subSet))
names(subSet) <- gsub("BodyBody", "Body", names(subSet))

# Creates a second, independent tidy data set with the average of each variable for each activity and each subject
# Bind subject in the data set
subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = FALSE)
subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = FALSE)
subject <- rbind(subjectTest, subjectTrain)
names(subject) <- c("subject")
subSet <- cbind(subSet, subject)
# Group by activity and subject, and get the average
library(plyr)
average <- aggregate(. ~subject + activityName, subSet, mean)
average <- average[order(average$subject, average$activityName),]