DROP TABLE FHIR_Glasgow
CREATE TABLE dbo.FHIR_Glasgow (
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


INSERT INTO FHIR_Glasgow
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

    discipline AS category,

    clinicalcodevalue AS code,

    sampledate AS effectiveDate,

    quantityvalue AS valueQuantity,

    quantityunit AS valueUnit,

    (case when ARITHMETICCOMPARATOR is not null then CONCAT(ARITHMETICCOMPARATOR, QUANTITYVALUE) else null end) as valueString,

    rangehighvalue AS referenceRangeHigh,

    rangelowvalue AS referenceRangeLow,

    testid AS encounterId,

    samplename AS specimentType,

    'Glasgow' AS healthBoard,

    clinicalcodedescription AS readCodeDescription

FROM dbo.SCI_Store_20220802
;