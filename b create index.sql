CREATE INDEX FHIRHICindex
on FHIR_HIC (personId);

CREATE INDEX FHIRGlasgowindex
on FHIR_Glasgow (personId);

CREATE INDEX LothianIndex
on FHIR_Lothian (personId);

CREATE INDEX DaSHIndex
on FHIR_DaSH (personId);

-- delete index if needed
-- DROP INDEX FHIRHICindex on FHIR_HIC;