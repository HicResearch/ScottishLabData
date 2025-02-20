--------- DaSH's lab data only contains biochemistry and haematology data 
--------- Tests does not comes with readcode haveuse RDMP_3564_ExampleData
--DROP TABLE DaSH_v2;

-- add category based on the flat file name
ALTER TABLE DaSH
ADD category VARCHAR(150) NOT NULL
DEFAULT 'biochemsitry'; -- edit default value based on the flat file name which indicate the category of the data
-- if multiple flat files, import each file for one table, conduct the above step  seperatly and merge all table into DaSH


select *, 
substring(Reference_Range, 1, case when  CHARINDEX('{', Reference_Range) = 0 then LEN(Reference_Range) 
else CHARINDEX('{', Reference_Range)-1 end) as "low",
substring(Reference_Range, case when  CHARINDEX('{', Reference_Range) = 0 then LEN(Reference_Range) 
else CHARINDEX('{', Reference_Range)+1 end, LEN(Reference_Range) ) as "high"
into DaSH_v2
from dbo.DaSH;



--DROP TABLE FHIR_DaSH
CREATE TABLE dbo.FHIR_DaSH (
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

INSERT INTO FHIR_DaSH
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

    category AS category,

    read_code AS code,

    date_of_sample AS effectiveDate,

    (case when ISNUMERIC(result)=1 
             then result 
          when substring(result, 1, 1)='>' or substring(result, 1, 1)='<'
             then substring(result, 2, LEN(result)-1)
          else NULL 
     end
       ) AS valueQuantity,

    test_units AS valueUnit,

    (case when ISNUMERIC(result_extension)=0 
             then result_extension 
		  when ISNUMERIC(result)=0
             then result 
		  else NULL
     end
       ) AS valueString,

    high AS referenceRangeHigh,

    low AS referenceRangeLow,

    NULL AS encounter,

    NULL AS specimen,

    'Grampian' AS healthboard,

    test_description AS readCodeDescription

FROM DaSH_v2
WHERE read_code IS NOT NULL;