#load usefull packages
library(data.table)
library(dplyr)

#set working directory
setwd("/Users/toto/Documents/coursera/data scientist/data-cleaning/week4/project")

#download compressed dset file
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dfil <- "getdata_projectfiles_UCI HAR Dataset.zip"
if (!file.exists(destFile)){
download.file(fileurl, destfile = dfil)
}

#save the download date
datedwl <- date()

#uncompress dset file
unzip(dfil)

#change working directory to UCI dset
setwd("./UCI HAR Dataset")

#read activity datafiles
ates <- read.table("./test/y_test.txt", header=FALSE)
atra <- read.table("./train/y_train.txt", header=FALSE)

#read features datafiles
ftes <- read.table("./test/X_test.txt", header=FALSE)
ftra <- read.table("./train/X_train.txt", header=FALSE)

#read subject datafiles
stes <- read.table("./test/subject_test.txt", header=FALSE)
stra <- read.table("./train/subject_train.txt", header=FALSE)

#read activity Labels datafile
alab <- read.table("./activity_labels.txt", header=FALSE)

#read feature names datafile
fnam <- read.table("./features.txt", header=FALSE)

#merge test and train above dataframes group by features, activity and subject
fdat <- rbind(ftes, ftra)
adat <- rbind(ates, atra)
sdat <- rbind(stes, stra)

#rename colums in adat and alab dataframes
names(adat) <- "ActivityName"
names(alab) <- c("ActivityName", "Activity")

#activity names concatenation
activity <- left_join(adat, alab, "ActivityName")[, 2]

#rename sdat columns
names(sdat) <- "Subject"

#rename fdat columns using fnam columns
names(fdat) <- fnam$V2

#merge in one big dset sdat, acti and fdat datas
dset <- cbind(sdat, activity)
dset <- cbind(dset, fdat)

#create one new dset with only mean and standard deviation metrics
subsmetrics <- fnam$V2[grep("mean\\(\\)|std\\(\\)", fnam$V2)]
dnam <- c("Subject", "activity", as.character(subsmetrics))
dset <- subset(dset, select=dnam)

#rename dset columns with more descriptive activity name
names(dset)<-gsub("^t", "Time", names(dset))
names(dset)<-gsub("^f", "Frequency", names(dset))
names(dset)<-gsub("Acc", "Accelerometer", names(dset))
names(dset)<-gsub("Gyro", "Gyroscope", names(dset))
names(dset)<-gsub("Mag", "Magnitude", names(dset))
names(dset)<-gsub("BodyBody", "Body", names(dset))

#final tidy dataset (average on each variables)
tdset<-aggregate(. ~Subject + activity, dset, mean)
tdset<-tdset[order(tdset$Subject,tdset$activity),]

#save tdset locally
write.table(tdset, file = "tidydata.txt",row.name=FALSE)