#******SCRIPT TO TEST UPLOAD OF DATA FROM ONE DHIS 2 INSTANCE TO ANOTHER******

#This script was tested using R version 3.4.3


#**List of libraries that will be used**
#You will need to install these packages if you don't have them.
library(httr)
library(data.table)
library(jsonlite)

#**Aggregate data url using DHIS 2 web api. This is from source DHIS2 instance**
myurl<-"https://your dhis2 url/api/reportTables/pivot-table-id/data.csv"


#1. Get aggregate data from source DHIS 2 instance

#Password variable
his_user<-"dhis2 username"
his_pwd<-"dhis2 password"

#Simple method to get the data
response<-GET(url=myurl, authenticate(user =  his_user,password =  his_pwd))
#http_status(response)
mydata<-content(response,type = "text/csv")
mydata[is.na(mydata)]<-0
mydata<-data.table(mydata)

#2. Format data for destination DHIS 2 instance

#2.1 Add identifier variables for destination DHIS 2 using data.table. Currently doing for one organisation unit
mydata[,dest_orgunit:=ifelse(organisationunitname=="Some Organisation Unit","ZMyVNhkeNa7","")]

#2.2 Filter out the first batch data to upload.
#Filtered out the records I need
ds_1st<-mydata[,c(1,2,5,12,20)]
merge_ds1<-ds_1st[,.(dataElement="Khc3N0AZsS0",period=periodid,orgUnit=dest_orgunit,categoryOptionCombo="yPBVjv7T7SM",attributeOptionCombo="Es07ZfboVyC",value=`Some Column with Data`)]

forupload<-merge_ds1
forupload<-forupload[orgUnit=="ZMyVNhkeNa7"]

#2.2 Convert the data ready for upload to JSON using jsonlite. Format JSON to what DHIS2 will accept
x<-toJSON(forupload)
prettify(x)

#2.3 Save this data.
write(paste('{"dataValues":',x,'}'),paste("Upload_Data",Sys.Date(),".json"))

#3. Upload data to destination DHIS 2 instance using httr
httr::VERB(verb = "POST",
           url="https://destination DHIS2 instance/api/dataValueSets",
           httr::authenticate(user = "Destination Username",password = "Destination Password"),
           httr::verbose(),
           body=upload_file(paste("Upload_Data",Sys.Date(),".json"))
           )



