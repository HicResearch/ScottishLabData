--------- DaSH's lab data only contains biochemistry and haematology data 
--------- Tests does not comes with readcode have been excluded from furture study

select *, 
substring(Reference_Range, 1, CHARINDEX('{', Reference_Range)-1) as "low",
substring(Reference_Range, CHARINDEX('{', Reference_Range)+1, LEN(Reference_Range) ) as "high"
into DaSH_v2
from dbo.DaSH;

DROP TABLE FHIR_DaSH
CREATE TABLE dbo.FHIR_DaSH (
personId         VARCHAR(50) NOT NULL,
category          VARCHAR(150) NULL,
code              VARCHAR(50) collate Latin1_General_BIN NOT NULL,
effectiveDate     DATETIME,
valueQuantity     VARCHAR(50) NULL,
valueUnit         VARCHAR(50) NULL,
valueString       VARCHAR(1000) NULL,
referenceRangeHigh    REAL NULL,
referenceRangeLow     REAL NULL,
encounterId       VARCHAR(50) NULL,
specimentType      VARCHAR(50) NULL,
healthBoard       VARCHAR(50) NULL,
readCodeDescription  VARCHAR(250) NULL
);

INSERT INTO FHIR_DaSH
(
    personId,
    category,
    code,
    effectiveDate,
    valueQuantity,
    valueUnit,
    valueString,
    referenceRangeHigh,
    referenceRangeLow,
    encounterId,
    specimentType,
    healthBoard,
    readCodeDescription
)

SELECT
    prochi AS personId,

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
          else NULL 
     end
       ) AS valueString,

    high AS referenceRangeHigh,

    low AS referenceRangeLow,

    NULL AS encounterid,

    NULL AS specimenttype,

    'Grampian' AS healthboard,

    test_description AS readCodeDescription

FROM DaSH_v2
WHERE read_code IS NOT NULL;
;