library(DBI)
source('ExemplarTestData/dummyData.R')

# create to SQLite DB
con <- dbConnect(RSQLite::SQLite(), ":memory:")

# 'FHIR' table definition
df.fhir <- data.frame(subject = 'VARCHAR',
                  category = 'VARCHAR',
                  code= 'VARCHAR',
                  effectiveDate = 'VARCHAR',
                  valueQuantity = 'VARCHAR',
                  valueUnit = 'VARCHAR',
                  valueString = 'VARCHAR',
                  referenceRangeHigh = 'FLOAT',
                  referenceRangeLow = 'FLOAT',
                  encounter = 'VARCHAR',
                  specimen = 'VARCHAR',
                  healthBoard = 'VARCHAR',
                  readCodeDescription = 'VARCHAR'
)

initDb <- function() {
  dbCreateTable(con, 'FHIR_HIC', df.fhir)
  
  # create source 'HIC' data
  df.tnf <- initData()
  dbCreateTable(con, 'HICbiochem', df.tnf)
  dbAppendTable(con, 'HICbiochem', df.tnf)
  
  # map 'HIC' data to 'FHIR' table
  rs <- dbExecute(con, "INSERT INTO FHIR_HIC
  (
      subject,
      category,
      code,
      effectiveDate,
      valueQuantity,
      valueUnit,
      valueString,
      referenceRangeHigh,
      referenceRangeLow,
      encounter,
      specimen,
      healthBoard,
      readCodeDescription
  )
  SELECT
      prochi AS subject,
  
      'Biochemistry' AS category,
  
      readcodevalue AS code,
  
      datetimesampled AS effectiveDate,
  
      (case when (QuantityValue is null and substr(Interpretation, 1, 1)='>') or (QuantityValue is null and substr(Interpretation, 1, 1)='<') 
               then substr(Interpretation, 2, LENGTH(Interpretation)-1)
            else QuantityValue 
       end
         )AS valueQuantity,
  
      quantityunit AS valueUnit,
  
      (case when ArithmeticComparator is not null and ArithmeticComparator!='' 
               then CONCAT_WS(' ', ArithmeticComparator, QuantityValue, Interpretation) 
               else Interpretation end
         ) as valueString,
  
      rangehighvalue AS referenceRangeHigh,
  
      rangelowvalue AS referenceRangeLow,
  
      testreportid AS encounter,
  
      samplename AS specimen,
  
      hb_extract AS healthBoard,
  
      readcodedescription AS readCodeDescription
  
  FROM HICbiochem")
  
}
