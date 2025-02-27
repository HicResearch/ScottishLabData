use example
--------------------------------------------------------------------
---------- TestCode to ReadCode ------------------------------------
--------------------------------------------------------------------

--DROP dbo.Lothian_ReadCode
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
--------------- Add Unit Information -------------------------------
--------------------------------------------------------------------
--DROP dbo.Lothian_ReadCode_Unit
SELECT *
Into dbo.Lothian_ReadCode_Unit
FROM 
(
  SELECT DISTINCT * FROM dbo.Lothian_ReadCode
)b
LEFT JOIN 
(
  SELECT DISTINCT CTTC_Code, CTTC_Units FROM dbo.Lothian_Unit
 )lkp
ON b.TestItemCode = lkp.CTTC_Code;


--------------------------------------------------------------------
---------- Create Table ------------------------------------
--------------------------------------------------------------------
DROP TABLE FHIR_Lothian
CREATE TABLE dbo.FHIR_Lothian (
subject         VARCHAR(50) NOT NULL,
category          VARCHAR(150) NULL,
code              VARCHAR(50) collate Latin1_General_BIN NOT NULL,
effectiveDate     DATETIME,
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

    ordersubcategory AS category,

    Read_Code AS code,

    specimencollectiondate AS effectiveDate,

    (case when ISNUMERIC(value)=1 
             then value 
          when substring(value, 1, 1)='>' or substring(value, 1, 1)='<'
             then substring(value, 2, LEN(value)-1)
          else NULL 
     end
       ) AS valueQuantity,

    CTTC_Units AS valueUnit,

    value AS valueString,

    (case when ISNUMERIC(rangemax)=1 
             then rangemax 
          else NULL 
     end
       ) AS referenceRangeHigh,

    (case when ISNUMERIC(rangemin)=1 
             then rangemin 
          else NULL 
     end
       ) AS referenceRangeLow,

    orderid AS encounter,

    specimentype AS specimen,

    'Lothian' AS healthboard,

    testitem AS readcodedescription

FROM dbo.Lothian_ReadCode_Unit
;