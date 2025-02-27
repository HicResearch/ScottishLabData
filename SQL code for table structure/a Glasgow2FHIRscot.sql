use example

--DROP TABLE FHIR_Glasgow

CREATE TABLE dbo.FHIR_Glasgow (
subject         VARCHAR(50) NOT NULL,
category          VARCHAR(150) NULL,
code              VARCHAR(50) collate Latin1_General_BIN NOT NULL,
effectiveDate     VARCHAR(50) NULL,
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


INSERT INTO FHIR_Glasgow
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

    discipline AS category,

    clinicalcodevalue AS code,

    sampledate AS effectiveDate,

    quantityvalue AS valueQuantity,

    quantityunit AS valueUnit,

    (case when ARITHMETICCOMPARATOR != '' 
	     then CONCAT(ARITHMETICCOMPARATOR, QUANTITYVALUE) 
		 else null 
		 end
	) as valueString,

    rangehighvalue AS referenceRangeHigh,

    rangelowvalue AS referenceRangeLow,

    testid AS encounter,

    samplename AS specimen,

    'Glasgow' AS healthBoard,

    clinicalcodedescription AS readCodeDescription

FROM dbo.Glasgow
;