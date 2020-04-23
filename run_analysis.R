## Getting and cleaning data course project
## The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set.
## 
library(dplyr)
library(stringr)
library(tidyr)

## set up default folders
dataFolder = "Dataset"
testFolder = file.path(dataFolder, "test")
trainFolder = file.path(dataFolder, 'train')

rootFolder = getwd()
setwd(file.path(rootFolder, dataFolder))
## read features
features <- read.table('./features.txt', header = FALSE, col.names = c('fid', 'fname')) %>%
  tbl_df() %>%
  mutate(fname = gsub('\\(|\\)|,|-|\\.', '_', fname)) %>%
  mutate(fname = gsub('_+', '_', fname))
getwd()
## read activity labels
activityLabels <- read.table('./activity_labels.txt', header = FALSE, col.names = c('aid', 'aname')) %>%
  tbl_df()


## read test data, combine subject, x test, y test together
setwd(file.path(rootFolder, testFolder))
subjectTest <- read.table('./subject_test.txt', header = FALSE, col.names = c('subject'), colClasses = 'factor')
yTest <- read.table('./y_test.txt', header = FALSE, col.names = c('activity'), colClasses = 'factor') %>%
  tbl_df() %>% 
  merge(activityLabels, by.x = 'activity', by.y = 'aid') %>%
  select(aname)%>%
  rename(activity = aname)
xTest <- read.table('./X_test.txt', header = FALSE, col.names = features$fname) %>%
  tbl_df() %>% 
  select(contains(c('mean', 'std')))
subjectTest <- cbind(subjectTest, yTest, xTest) %>% tbl_df()

## read train data, combine subject, xtest, y test together
setwd(file.path(rootFolder, trainFolder))
subjectTrain <- read.table('./subject_train.txt', header = FALSE, col.names = c('subject'), colClasses = 'factor')
yTrain <- read.table('./y_train.txt', header = FALSE, col.names = c('activity')) %>%
  tbl_df() %>% 
  merge(activityLabels, by.x = 'activity', by.y = 'aid') %>% 
  select(aname) %>%
  rename(activity = aname)
xTrain <- read.table('./X_train.txt', header = FALSE, col.names = features$fname) %>%
  tbl_df() %>% select(contains(c('mean', 'std')))
subjectTrain <- cbind(subjectTrain, yTrain, xTrain) %>% tbl_df()

## combine test and train data together
subjectMerge <- rbind(subjectTest, subjectTrain)

## create data set with the average of each variable for each activity and each subject
secondSubjectMerge <- subjectMerge %>%
  group_by(subject, activity) %>%
  summarize_each(list(mean = mean))

## return to the root folder
setwd(rootFolder)

## write merge data to merge_data.txt
write.table(subjectMerge, 'merge_data.txt', row.names = FALSE)

## write tidy data to tidy file
write.table(secondSubjectMerge, 'tidy.txt', row.names = FALSE)


