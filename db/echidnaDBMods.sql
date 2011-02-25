/* The following adds the species property to composites that didn't have a species */
INSERT INTO composites_properties (composite_id, property_id, created_at, updated_at, is_observation, is_perturbation)
VALUES (1814,1,NOW(),NOW(),0,0),(1815,1,NOW(),NOW(),0,0),(1816,1,NOW(),NOW(),0,0),(1817,1,NOW(),NOW(),0,0),(1818,1,NOW(),NOW(),0,0),(1819,1,NOW(),NOW(),0,0),(1820,1,NOW(),NOW(),0,0),(1821,1,NOW(),NOW(),0,0),(1822,1,NOW(),NOW(),0,0),(1823,1,NOW(),NOW(),0,0),(1824,1,NOW(),NOW(),0,0),(1825,1,NOW(),NOW(),0,0),(1826,1,NOW(),NOW(),0,0),(1827,1,NOW(),NOW(),0,0),(1828,1,NOW(),NOW(),0,0),(1829,1,NOW(),NOW(),0,0),(1830,1,NOW(),NOW(),0,0),(1831,1,NOW(),NOW(),0,0),(1832,1,NOW(),NOW(),0,0),(1833,1,NOW(),NOW(),0,0),(1834,1,NOW(),NOW(),0,0),(1835,1,NOW(),NOW(),0,0),(1836,1,NOW(),NOW(),0,0),(1837,1,NOW(),NOW(),0,0),(1838,1,NOW(),NOW(),0,0),(1839,1,NOW(),NOW(),0,0),(1840,1,NOW(),NOW(),0,0),(1841,1,NOW(),NOW(),0,0),(1842,1,NOW(),NOW(),0,0),(1843,1,NOW(),NOW(),0,0),(1844,1,NOW(),NOW(),0,0),(1845,1,NOW(),NOW(),0,0);

/* Update the type for the following keys */
UPDATE vocabulary_entries SET type='clinical'
WHERE `key` IN ('Gender','Reviewed Histological diagnosis','Histology', 'WHO Grade','Age at Diagnosis','KPS','Type of Surgery','Radiotherapy','Chemotherapy','Alive','Survival Years','Included in Study','Survival');

UPDATE vocabulary_entries SET type='environmental'
WHERE `key` IN ('illumination','time','Optical density (600nm)', 'irradiation history','doubling time','CuSO4.5H2O','pH','clockTime','pump rate','NiSO4.H2O','MnSO4.H2O','DIP', 'CoSO4.7H2O','uv','batch','gamma','EMS','H2O2','NaCl','glucose','frozen_age','ATP concentration','pump','temperature', 'oxygen','ZnSO4.7H2O','FeSO4.7H2O','paraquat','EDTA') AND type='controlled vocabulary';

UPDATE vocabulary_entries SET type='genetic'
WHERE `key` IN ('1p (LOH)','19q (LOH)','IDH (R132) mutation', 'EGFR (Amplification)','knockout','overexpressed gene') and type='controlled vocabulary';

/* add the following to the vocabulary_entries table */
INSERT INTO vocabulary_entries (`key`,type,created_at,updated_at) 
VALUES ('data type','measurement',NOW(),NOW());

INSERT INTO vocabulary_entries (`key`,type,created_at,updated_at) 
VALUES ('platform','microarray',NOW(),NOW());

INSERT INTO vocabulary_entries (`key`,type,created_at,updated_at) 
VALUES ('slide type','microarray',NOW(),NOW());

INSERT INTO vocabulary_entries (`key`,type,created_at,updated_at) 
VALUES ('slide format','microarray',NOW(),NOW());

INSERT INTO vocabulary_entries (`key`,type,created_at,updated_at) 
VALUES ('Protein-Dna type','microarray',NOW(),NOW());

/* add the following to the measurements table */
INSERT INTO measurements (name,created_at,updated_at)
VALUES ('Gene Expression',NOW(),NOW());

INSERT INTO measurements (name,created_at,updated_at)
VALUES ('Protein-Dna',NOW(),NOW());

INSERT INTO measurements (name,created_at,updated_at)
VALUES ('Transcriptome Structure',NOW(),NOW());

INSERT INTO measurements (name,created_at,updated_at)
VALUES ('Growth Curve',NOW(),NOW());

/* add the following the the properties table */
INSERT INTO properties (`key`,value,created_at,updated_at)
VALUES ('data type','Gene Expression',NOW(),NOW());

insert into properties (`key`, value, created_at, updated_at) values ('slide type', 'tiling', now(), now());

insert into properties (`key`, value, created_at, updated_at) values ('slide type', 'spotted', now(), now());

insert into properties (`key`, value, created_at, updated_at) values ('slide type', 'tiling (pcr span)', now(), now());

insert into properties (`key`, value, created_at, updated_at) values ('platform', 'ISB (in-house)', now(), now());

insert into properties (`key`, value, created_at, updated_at) values ('platform', 'agilent', now(), now());

insert into properties (`key`, value, created_at, updated_at) values ('slide format', '1x10k', now(), now());

insert into properties (`key`, value, created_at, updated_at) values ('slide format', '8x64k', now(), now());

insert into properties (`key`, value, created_at, updated_at) values ('slide format', '4x180k', now(), now());

update species set name = 'Halobacterium sp. NRC-1' where name = 'halo';
update species set name = 'Homo sapiens' where name = 'human';
