source('ExemplarTestData/createTables.R')
source('./R code for data harmonisation/0_functions.R')


# initialise 'HIC' database - creates 'con' variable
initDb()

# get dummy data from db
dat <- dbGetQuery(con, "SELECT * FROM FHIR_HIC")

# create example data harmonisation object
changeCmd <- data.frame(ReadCode = '44I4.', 
                        readCodeDescription = 'Potassium', 
                        HIC_unit = 'mmol/L; nmol/L',
                        Unit = 'mmol/L',
                        Rule = 'if nmol/L value 1e-06')
# harmonise data by transfering units
rc = '44I4.'
unitTransferFunction(dat, changeCmd)
dbDisconnect(con)
