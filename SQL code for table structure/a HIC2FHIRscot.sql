--------- HIC's pathology and microbiology data does not comes with readcode, they have been excluded from furture study
--------- Here we only focus on HIC's biochemistry, Haematology, Immunology and VirologyRestructured 

--use example   --uncomment when testing pipeline using example data
--use RDMP_3564_ExampleData      

--import data from flat file using task ->import data 
--imported "Labs_Biochem"
--imported "HaematologyRestructured"
--imported "ImmunologyRestructured"
--imported "VirologyRestructured"

--rename table
exec sp_rename 'Labs_Biochem', 'HIC'

------------------------------------------------------------------------------------------------------------------
--example data should only run from here -------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------


CREATE TABLE dbo.FHIR_HIC (
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

-- the example data is based on the HIC's biochemistry
--only run the biochemistry chunk of code for the example
--------------------------------------------------------------------
---------- biochemistry --------------------------------------------
--------------------------------------------------------------------
INSERT INTO FHIR_HIC
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

    testreportid AS encounter,

    samplename AS specimen,

    hb_extract AS healthBoard,

    readcodedescription AS readCodeDescription

FROM dbo.HIC
;

------------------------------------------------------------------------------------------------------------------
--example data should not run the following code -----------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------
---------- Haematology ---------------------------------------------
--------------------------------------------------------------------
INSERT INTO FHIR_HIC
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

    testidentifier AS encounter,

    samplename AS specimen,

    hb_extract AS healthBoard,

    readcodedescription AS readCodeDescription

FROM dbo.HaematologyRestructured
WHERE ReadCodeValue IS NOT NULL;

--------------------------------------------------------------------
---------- Immunology ----------------------------------------------
--------------------------------------------------------------------
INSERT INTO FHIR_HIC
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

    'Immunology' AS category,

    readcodevalue AS code,

    datetimesampled AS effectiveDate,

    QuantityValue as valueQuantity,

    quantityunit AS valueUnit,

    Interpretation as valueString,

    rangehighvalue AS referenceRangeHigh,

    rangelowvalue AS referenceRangeLow,

 -- [!WARNING!] no source column found. 
    NULL AS encounter,

 -- [!WARNING!] no source column found. 
    NULL AS specimen,

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

    testreportid AS encounter,

    samplename AS specimen,

    hb_extract AS healthBoard,

    readcodedescription AS readCodeDescription

FROM dbo.VirologyRestructured
WHERE ReadCodeValue IS NOT NULL;