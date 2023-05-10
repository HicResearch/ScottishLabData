--------- HIC's pathology and microbiology data does not comes with readcode, they have been excluded from furture study


DROP TABLE FHIR_HIC
CREATE TABLE dbo.FHIR_HIC (
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

--------------------------------------------------------------------
---------- biochemistry --------------------------------------------
--------------------------------------------------------------------
INSERT INTO FHIR_HIC
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
    prochi AS personid,

    'Biochemistry' AS category,

    readcodevalue AS code,

    datetimesampled AS effectiveDate,

    (case when (QuantityValue is null and substring(Interpretation, 1, 1)='>') or (QuantityValue is null and substring(Interpretation, 1, 1)='<') 
             then substring(Interpretation, 2, LEN(Interpretation)-1)
          else QuantityValue 
     end
       )AS valueQuantity,

    quantityunit AS valueUnit,

    (case when ArithmeticComparator is not null and ArithmeticComparator!='' 
             then CONCAT(ArithmeticComparator, QuantityValue, ' ', Interpretation) 
             else Interpretation end
       ) as valueString,

    rangehighvalue AS referenceRangeHigh,

    rangelowvalue AS referenceRangeLow,

    testreportid AS encounterId,

    samplename AS specimentType,

    hb_extract AS healthBoard,

    readcodedescription AS readCodeDescription

FROM dbo.Labs_Biochem
;

--------------------------------------------------------------------
---------- Haematology ---------------------------------------------
--------------------------------------------------------------------
INSERT INTO FHIR_HIC
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

    'Haematology' AS category,

    readcodevalue AS code,

    datetimesampled AS effectiveDate,
    
    (case when (QuantityValue is null and substring(Interpretation, 1, 1)='>') or (QuantityValue is null and substring(Interpretation, 1, 1)='<') 
             then substring(Interpretation, 2, LEN(Interpretation)-1)
          else QuantityValue 
     end
       )AS valueQuantity,
    
    quantityunit AS valueUnit,

    (case when ArithmeticComparator is not null and ArithmeticComparator!='' 
             then CONCAT(ArithmeticComparator, QuantityValue, ' ', Interpretation) 
             else Interpretation end
       ) as valueString,

    rangehighvalue AS referenceRangeHigh,

    rangelowvalue AS referenceRangeLow,

    testidentifier AS encounterId,

    samplename AS specimentType,

    hb_extract AS healthBoard,

    readcodedescription AS readCodeDescription

FROM dbo.HaematologyRestructured
WHERE ReadCodeValue IS NOT NULL;

--------------------------------------------------------------------
---------- Immunology ----------------------------------------------
--------------------------------------------------------------------
INSERT INTO FHIR_HIC
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

    'Immunology' AS category,

    readcodevalue AS code,

    datetimesampled AS effectiveDate,

    QuantityValue as valueQuantity,

    quantityunit AS valueUnit,

    Interpretation as valueString,

    rangehighvalue AS referenceRangeHigh,

    rangelowvalue AS referenceRangeLow,

 -- [!WARNING!] no source column found. 
    NULL AS encounterId,

 -- [!WARNING!] no source column found. 
    NULL AS specimentType,

    hb_extract AS healthBoard,

    readcodedescription AS readCodeDescription

FROM dbo.ImmunologyRestructured
WHERE ReadCodeValue IS NOT NULL;



--------------------------------------------------------------------
------------ Virology ----------------------------------------------
--------------------------------------------------------------------

SET dateformat dmy;
ALTER table dbo.VirologyRestructured
ALTER COLUMN datetimesampled datetime NULL;


INSERT INTO FHIR_HIC
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

    'Virology' AS category,

    readcodevalue AS code,

    datetimesampled AS effectiveDate,
    
    (case when (QuantityValue is null and substring(Interpretation, 1, 1)='>') or (QuantityValue is null and substring(Interpretation, 1, 1)='<') 
             then substring(Interpretation, 2, LEN(Interpretation)-1)
          else QuantityValue 
     end
       )AS valueQuantity,

    quantityunit AS valueUnit,

    (case when ArithmeticComparator is not null and ArithmeticComparator!='' 
             then CONCAT(ArithmeticComparator, QuantityValue, ' ', Interpretation) 
             else Interpretation end
     ) AS valuestring,

    rangehighvalue AS referenceRangeHigh,

    rangelowvalue AS referenceRangeLow,

    testreportid AS encounterId,

    samplename AS specimentType,

    hb_extract AS healthBoard,

    readcodedescription AS readCodeDescription

FROM dbo.VirologyRestructured
WHERE ReadCodeValue IS NOT NULL;
