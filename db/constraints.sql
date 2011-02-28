create table condition_mapping (original_id integer, mapped_id integer);
create table group_mapping (original_id integer, mapped_id integer);
create table knockout_mapping (original_id integer, mapped_id integer);
create table paper_mapping (original_id integer, mapped_id integer);
create table observation_mapping (original_id integer, mapped_id integer);
create table perturbation_mapping (original_id integer, mapped_id integer);
create table species_mapping (original_id integer, mapped_id integer);

alter table composites_properties add constraint uc_comp_prop unique (composite_id, property_id);

alter table groupings add constraint uc_groupings unique (parent_id, child_id);
alter table species_vocabularies add constraint uc_spec_vocab unique (species_id, vocabulary_entry_id);
alter table vocabulary_entries add constraint uc_vocab unique (`key`, type);
alter table measurement_vocabs add constraint uc_meas_vocab unique (measurement_id, vocabulary_entries_id);
alter table measurement_datas add constraint uc_meas_data_uri unique (uri(500));

