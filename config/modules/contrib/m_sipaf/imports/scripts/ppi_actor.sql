DROP VIEW IF EXISTS :pre_processed_import_view;
CREATE VIEW :pre_processed_import_view AS
SELECT
	uuid_pf AS id_passage_faune,
	CASE
		WHEN type_role_org = 'Concessionaire' THEN 'CON'
		WHEN type_role_org = 'ETAT' THEN 'ETA'
		WHEN type_role_org = 'Département' THEN 'DEP'
		WHEN type_role_org = 'Gestionnaire' THEN 'GES'
		ELSE '???'
	END AS id_nomenclature_type_actor,
	nom_organism AS id_organism,
    NULL AS id_role
	FROM :raw_import_table t
	WHERE nom_organism IS NOT NULL AND nom_organism != ''
;

