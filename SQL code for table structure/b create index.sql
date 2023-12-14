CREATE INDEX FHIRHICindex
on FHIR_HIC (subject);

CREATE INDEX FHIRGlasgowindex
on FHIR_Glasgow (subject);

CREATE INDEX LothianIndex
on FHIR_Lothian (subject);

CREATE INDEX DaSHIndex
on FHIR_DaSH (subject);

-- delete index if needed
-- DROP INDEX FHIRHICindex on FHIR_HIC;