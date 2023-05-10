---- The lab data table for HIC is 'FHIR_HIC'
---- The lab data table for Grampian/DaSH is 'FHIR_Grampian'
---- The lab data table for Lothian is 'FHIR_Lothian'
---- The lab data table for Glasgow is 'FHIR_Glasgow'



USE RDMP_3564_ExampleData  -- set which database to use.

delete FROM dbo.FHIR_HIC where code='';
delete FROM dbo.FHIR_Glasgow where code='';
delete FROM dbo.FHIR_Lothian where code='';
delete FROM dbo.FHIR_DaSH where code='';


-------------------------------------------------------------------------------------------
------ HIC  -------------------------------------------------------------------
-------------------------------------------------------------------------------------------
DROP TABLE HIC_ReadCodeAggregates
;WITH readCodeCount AS (
SELECT code, count(*) AS recordCount, count(*)*100/sum(count(*)) over()  AS recordCountPercent, count(DISTINCT personId) AS patientCount
FROM dbo.FHIR_HIC
GROUP BY code
) 
SELECT ROW_NUMBER() OVER (ORDER BY recordCount desc) orderNumber,* 
INTO HIC_ReadCodeAggregates
FROM readCodeCount
--876



-------------------------------------------------------------------------------------------
------ Glasgow  -------------------------------------------------------------------
-------------------------------------------------------------------------------------------
DROP TABLE Glasgow_ReadCodeAggregates
;WITH readCodeCount AS (
SELECT code, count(*) AS recordCount, count(*)*100/sum(count(*)) over()  AS recordCountPercent, count(DISTINCT personId) AS patientCount
FROM dbo.FHIR_Glasgow
GROUP BY code
) 
SELECT ROW_NUMBER() OVER (ORDER BY recordCount desc) orderNumber,* 
INTO Glasgow_ReadCodeAggregates
FROM readCodeCount
--1439

-------------------------------------------------------------------------------------------
------ Lothian  -------------------------------------------------------------------
-------------------------------------------------------------------------------------------
DROP TABLE Lothian_ReadCodeAggregates
;WITH readCodeCount AS (
SELECT code, count(*) AS recordCount, count(*)*100/sum(count(*)) over()  AS recordCountPercent, count(DISTINCT personId) AS patientCount
FROM dbo.FHIR_Lothian
GROUP BY code
) 
SELECT ROW_NUMBER() OVER (ORDER BY recordCount desc) orderNumber,* 
INTO Lothian_ReadCodeAggregates
FROM readCodeCount
--587

-------------------------------------------------------------------------------------------
---------- DaSH ---------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--- recordCountPercent is the % value * 10 for some reason, cannot have float on the results
DROP TABLE DaSH_ReadCodeAggregates
;with readCodeCount as (
SELECT code, count(*) AS recordCount, count(*)*100/sum(count(*)) over()  AS recordCountPercent, count(DISTINCT personId) AS patientCount
FROM dbo.FHIR_DaSH
GROUP BY code
)
SELECT ROW_NUMBER() OVER (ORDER BY recordCount desc) orderNumber,* 
INTO DaSH_ReadCodeAggregates
FROM readCodeCount
--407
