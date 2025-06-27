--------- Lothian's lab data came in seperate flat files, each file for one year coverage 

--use example   --uncomment when testing pipeline using example data
--use RDMP_3564_ExampleData      

--import data from flat file using task ->import data 
--imported "Lab_Data_2015_Lothian_Corrected"
--imported "Lab_Data_2016_Lothian_Corrected"
--imported "Lab_Data_2017_Lothian_Corrected"
--imported "Lab_Data_2018_Lothian_Corrected"
--imported "Lab_Data_2019_Lothian_Corrected"
--imported "Lab_Data_2020_Lothian_Corrected"
--imported "Lab_Data_2021_Lothian_Corrected"

-- merge all table into DaSH
SELECT * INTO Lothian FROM (
  SELECT * 
  FROM CD_3564_Lab_Data_2015_corrected_V2
  UNION All
  SELECT * 
  FROM CD_3564_Lab_Data_2016_corrected_V2
  UNION All
  SELECT * 
  FROM CD_3564_Lab_Data_2017_corrected_V2
  UNION All
  SELECT * 
  FROM CD_3564_Lab_Data_2018_corrected_V2
  UNION All
  SELECT * 
  FROM CD_3564_Lab_Data_2019_corrected_V2
  UNION All
  SELECT * 
  FROM CD_3564_Lab_Data_2020_corrected_V2
  UNION All
  SELECT * 
  FROM CD_3564_Lab_Data_2021_corrected_V2
  ) as tmp

------------------------------------------------------------------------------------------------------------------
--example data should only run the following lines of code -------------------------------------------------------
------------------------------------------------------------------------------------------------------------------

-- TestCode to ReadCode 

SELECT *
Into Lothian_ReadCode
FROM 
(
  SELECT DISTINCT * FROM Lothian
)b
INNER JOIN 
(
  SELECT DISTINCT Test_Code, Read_Code FROM Lothian_TestCode2ReadCode
 )lkp
ON b.TestItemCode = lkp.Test_Code;



--------------------------------------------------------------------
---------- Create Table ------------------------------------
--------------------------------------------------------------------

CREATE TABLE dbo.FHIR_Lothian (
subject         VARCHAR(50) NOT NULL,
category          VARCHAR(150) NULL,
code              VARCHAR(50) collate Latin1_General_BIN NOT NULL,
effectiveDate     DATE NULL,
valueQuantity     VARCHAR(50) NULL,
valueUnit         VARCHAR(50) NULL,
valueString       VARCHAR(1000) NULL,
referenceRangeHigh    REAL NULL,
referenceRangeLow     REAL NULL,
encounter       VARCHAR(50) NULL,
specimen      VARCHAR(50) NULL,
healthBoard       VARCHAR(50) NULL,
readCodeDescription  VARCHAR(250) NULL
);


INSERT INTO FHIR_Lothian
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

    '' AS category,

    Read_Code AS code,

    SpecimenCollectionDate AS effectiveDate,

    (case when ISNUMERIC(Value)=1 
             then Value 
          when substring(Value, 1, 1)='>' or substring(value, 1, 1)='<'
             then substring(Value, 2, LEN(Value)-1)
          else NULL 
     end
       ) AS valueQuantity,

    Unit AS valueUnit,

    Value AS valueString,

    (case when ISNUMERIC(RangeMax)=1 
             then RangeMax 
          else NULL 
     end
       ) AS referenceRangeHigh,

    (case when ISNUMERIC(RangeMin)=1 
             then RangeMin 
          else NULL 
     end
       ) AS referenceRangeLow,

    0 AS encounter,

    '' AS specimen,

    'Lothian' AS healthboard,

    TestItem AS readcodedescription

FROM dbo.Lothian_ReadCode
;