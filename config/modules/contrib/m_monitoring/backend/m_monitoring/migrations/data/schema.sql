-- process schema : m_monitoring.site
--
-- and dependencies : m_monitoring.site_category, m_monitoring.visit, m_monitoring.site_group, m_monitoring.observation, m_monitoring.actor, m_monitoring.sc_grotte, m_monitoring.sc_arbre_loge


---- sql schema pr_monitoring

CREATE SCHEMA IF NOT EXISTS pr_monitoring;

---- table pr_monitoring.t_sites

CREATE TABLE pr_monitoring.t_sites (
    id_site SERIAL NOT NULL,
    code VARCHAR NOT NULL,
    name VARCHAR NOT NULL,
    description VARCHAR,
    uuid UUID,
    geom GEOMETRY(GEOMETRY, 4326) NOT NULL,
    geom_local GEOMETRY(GEOMETRY, 2154),
    id_site_category INTEGER,
    id_digitiser INTEGER,
    id_inventor INTEGER,
    id_nomenclature_type_site INTEGER NOT NULL,
    data JSONB
);

COMMENT ON COLUMN pr_monitoring.t_sites.geom IS 'Géométrie du site (SRID=4326)';
COMMENT ON COLUMN pr_monitoring.t_sites.geom_local IS 'Géométrie locale site (SRID=2154)';
COMMENT ON COLUMN pr_monitoring.t_sites.id_site_category IS 'Catégorie de site (pour pouvoir associé des champs spécifiques)';
COMMENT ON COLUMN pr_monitoring.t_sites.id_digitiser IS 'Personne qui a saisi la donnée';
COMMENT ON COLUMN pr_monitoring.t_sites.id_inventor IS 'Descripteur du site';
COMMENT ON COLUMN pr_monitoring.t_sites.id_nomenclature_type_site IS 'Nomenclature de type de site';
COMMENT ON COLUMN pr_monitoring.t_sites.data IS 'Données additionnelles du site';

---- table pr_monitoring.bib_sites_category

CREATE TABLE pr_monitoring.bib_sites_category (
    id_category SERIAL NOT NULL,
    name VARCHAR NOT NULL,
    code VARCHAR NOT NULL,
    description VARCHAR NOT NULL
);


---- table pr_monitoring.t_visits

CREATE TABLE pr_monitoring.t_visits (
    id_visit SERIAL NOT NULL,
    uuid UUID,
    date_min DATE NOT NULL,
    date_max DATE,
    id_site INTEGER,
    id_digitiser INTEGER,
    id_dataset INTEGER NOT NULL,
    id_module INTEGER NOT NULL,
    data JSONB
);

COMMENT ON COLUMN pr_monitoring.t_visits.id_visit IS 'Clé primaire de la visite';
COMMENT ON COLUMN pr_monitoring.t_visits.date_min IS 'Date (minimale) associée à la visite';
COMMENT ON COLUMN pr_monitoring.t_visits.date_max IS 'Date (maximale) associée à la visite';
COMMENT ON COLUMN pr_monitoring.t_visits.id_site IS 'Site associé à la visite';
COMMENT ON COLUMN pr_monitoring.t_visits.id_digitiser IS 'Personne qui a saisi la donnée';
COMMENT ON COLUMN pr_monitoring.t_visits.id_dataset IS 'Jeu de données associé à la visite';
COMMENT ON COLUMN pr_monitoring.t_visits.id_module IS 'Protocole associé à la visite';
COMMENT ON COLUMN pr_monitoring.t_visits.data IS 'Données additionnelles du site';

---- table pr_monitoring.t_site_group

CREATE TABLE pr_monitoring.t_site_group (
    id_site_group SERIAL NOT NULL,
    code VARCHAR NOT NULL,
    name VARCHAR NOT NULL,
    description VARCHAR,
    id_digitiser INTEGER,
    site_group_uuid UUID,
    geom GEOMETRY(GEOMETRY, 4326),
    geom_local GEOMETRY(GEOMETRY, 2154),
    data JSONB
);

COMMENT ON COLUMN pr_monitoring.t_site_group.id_site_group IS 'Clé primaire du group de site';
COMMENT ON COLUMN pr_monitoring.t_site_group.id_digitiser IS 'Personne qui a saisi la donnée';
COMMENT ON COLUMN pr_monitoring.t_site_group.geom_local IS 'Géométrie locale site (SRID=2154)';
COMMENT ON COLUMN pr_monitoring.t_site_group.data IS 'Données additionnelles du  groupe de site';

---- table pr_monitoring.t_observations

CREATE TABLE pr_monitoring.t_observations (
    id_observation SERIAL NOT NULL,
    cd_nom INTEGER,
    id_digitiser INTEGER,
    id_visit INTEGER,
    observation_uuid UUID,
    data JSONB
);

COMMENT ON COLUMN pr_monitoring.t_observations.id_observation IS 'Clé primaire de l''observaiton';
COMMENT ON COLUMN pr_monitoring.t_observations.cd_nom IS 'Taxon lié à l''observation';
COMMENT ON COLUMN pr_monitoring.t_observations.id_digitiser IS 'Personne qui a saisi la donnée';
COMMENT ON COLUMN pr_monitoring.t_observations.id_visit IS 'Visite associée à l''observation';
COMMENT ON COLUMN pr_monitoring.t_observations.data IS 'Données additionnelles de l''observation';

---- table pr_monitoring.cor_site_actor

CREATE TABLE pr_monitoring.cor_site_actor (
    id_actor SERIAL NOT NULL,
    id_site INTEGER NOT NULL,
    id_organism INTEGER,
    id_role INTEGER,
    id_nomenclature_type_actor INTEGER NOT NULL
);


---- table pr_monitoring.sc_grotte

CREATE TABLE pr_monitoring.sc_grotte (
    id_site SERIAL NOT NULL,
    profondeur FLOAT
);


---- table pr_monitoring.sc_arbre_loge

CREATE TABLE pr_monitoring.sc_arbre_loge (
    id_site SERIAL NOT NULL,
    hauteur FLOAT
);


---- pr_monitoring.t_sites primary key constraint

ALTER TABLE pr_monitoring.t_sites
    ADD CONSTRAINT pk_pr_monitoring_t_sites_id_site PRIMARY KEY (id_site);


---- pr_monitoring.bib_sites_category primary key constraint

ALTER TABLE pr_monitoring.bib_sites_category
    ADD CONSTRAINT pk_pr_monitoring_bib_sites_category_id_category PRIMARY KEY (id_category);


---- pr_monitoring.t_visits primary key constraint

ALTER TABLE pr_monitoring.t_visits
    ADD CONSTRAINT pk_pr_monitoring_t_visits_id_visit PRIMARY KEY (id_visit);


---- pr_monitoring.t_site_group primary key constraint

ALTER TABLE pr_monitoring.t_site_group
    ADD CONSTRAINT pk_pr_monitoring_t_site_group_id_site_group PRIMARY KEY (id_site_group);


---- pr_monitoring.t_observations primary key constraint

ALTER TABLE pr_monitoring.t_observations
    ADD CONSTRAINT pk_pr_monitoring_t_observations_id_observation PRIMARY KEY (id_observation);


---- pr_monitoring.cor_site_actor primary key constraint

ALTER TABLE pr_monitoring.cor_site_actor
    ADD CONSTRAINT pk_pr_monitoring_cor_site_actor_id_actor PRIMARY KEY (id_actor);


---- pr_monitoring.sc_grotte primary key constraint

ALTER TABLE pr_monitoring.sc_grotte
    ADD CONSTRAINT pk_pr_monitoring_sc_grotte_id_site PRIMARY KEY (id_site);


---- pr_monitoring.sc_arbre_loge primary key constraint

ALTER TABLE pr_monitoring.sc_arbre_loge
    ADD CONSTRAINT pk_pr_monitoring_sc_arbre_loge_id_site PRIMARY KEY (id_site);


---- pr_monitoring.t_sites foreign key constraint id_site_category

ALTER TABLE pr_monitoring.t_sites
    ADD CONSTRAINT fk_pr_monitoring_t_sit_bib_s_id_site_category FOREIGN KEY (id_site_category)
    REFERENCES pr_monitoring.bib_sites_category(id_category)
    ON UPDATE CASCADE ON DELETE SET NULL;

---- pr_monitoring.t_sites foreign key constraint id_digitiser

ALTER TABLE pr_monitoring.t_sites
    ADD CONSTRAINT fk_pr_monitoring_t_sit_t_rol_id_digitiser FOREIGN KEY (id_digitiser)
    REFERENCES utilisateurs.t_roles(id_role)
    ON UPDATE CASCADE ON DELETE SET NULL;

---- pr_monitoring.t_sites foreign key constraint id_inventor

ALTER TABLE pr_monitoring.t_sites
    ADD CONSTRAINT fk_pr_monitoring_t_sit_t_rol_id_inventor FOREIGN KEY (id_inventor)
    REFERENCES utilisateurs.t_roles(id_role)
    ON UPDATE CASCADE ON DELETE SET NULL;

---- pr_monitoring.t_sites foreign key constraint id_nomenclature_type_site

ALTER TABLE pr_monitoring.t_sites
    ADD CONSTRAINT fk_pr_monitoring_t_sit_t_nom_id_nomenclature_type_site FOREIGN KEY (id_nomenclature_type_site)
    REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature)
    ON UPDATE CASCADE ON DELETE CASCADE;


---- pr_monitoring.t_visits foreign key constraint id_site

ALTER TABLE pr_monitoring.t_visits
    ADD CONSTRAINT fk_pr_monitoring_t_vis_t_sit_id_site FOREIGN KEY (id_site)
    REFERENCES pr_monitoring.t_sites(id_site)
    ON UPDATE CASCADE ON DELETE SET NULL;

---- pr_monitoring.t_visits foreign key constraint id_digitiser

ALTER TABLE pr_monitoring.t_visits
    ADD CONSTRAINT fk_pr_monitoring_t_vis_t_rol_id_digitiser FOREIGN KEY (id_digitiser)
    REFERENCES utilisateurs.t_roles(id_role)
    ON UPDATE CASCADE ON DELETE SET NULL;

---- pr_monitoring.t_visits foreign key constraint id_dataset

ALTER TABLE pr_monitoring.t_visits
    ADD CONSTRAINT fk_pr_monitoring_t_vis_t_dat_id_dataset FOREIGN KEY (id_dataset)
    REFERENCES gn_meta.t_datasets(id_dataset)
    ON UPDATE CASCADE ON DELETE CASCADE;

---- pr_monitoring.t_visits foreign key constraint id_module

ALTER TABLE pr_monitoring.t_visits
    ADD CONSTRAINT fk_pr_monitoring_t_vis_t_mod_id_module FOREIGN KEY (id_module)
    REFERENCES gn_commons.t_modules(id_module)
    ON UPDATE CASCADE ON DELETE CASCADE;


---- pr_monitoring.t_site_group foreign key constraint id_digitiser

ALTER TABLE pr_monitoring.t_site_group
    ADD CONSTRAINT fk_pr_monitoring_t_sit_t_rol_id_digitiser FOREIGN KEY (id_digitiser)
    REFERENCES utilisateurs.t_roles(id_role)
    ON UPDATE CASCADE ON DELETE SET NULL;


---- pr_monitoring.t_observations foreign key constraint cd_nom

ALTER TABLE pr_monitoring.t_observations
    ADD CONSTRAINT fk_pr_monitoring_t_obs_taxre_cd_nom FOREIGN KEY (cd_nom)
    REFERENCES taxonomie.taxref(cd_nom)
    ON UPDATE CASCADE ON DELETE SET NULL;

---- pr_monitoring.t_observations foreign key constraint id_digitiser

ALTER TABLE pr_monitoring.t_observations
    ADD CONSTRAINT fk_pr_monitoring_t_obs_t_rol_id_digitiser FOREIGN KEY (id_digitiser)
    REFERENCES utilisateurs.t_roles(id_role)
    ON UPDATE CASCADE ON DELETE SET NULL;

---- pr_monitoring.t_observations foreign key constraint id_visit

ALTER TABLE pr_monitoring.t_observations
    ADD CONSTRAINT fk_pr_monitoring_t_obs_t_vis_id_visit FOREIGN KEY (id_visit)
    REFERENCES pr_monitoring.t_visits(id_visit)
    ON UPDATE CASCADE ON DELETE SET NULL;


---- pr_monitoring.cor_site_actor foreign key constraint id_site

ALTER TABLE pr_monitoring.cor_site_actor
    ADD CONSTRAINT fk_pr_monitoring_cor_s_t_sit_id_site FOREIGN KEY (id_site)
    REFERENCES pr_monitoring.t_sites(id_site)
    ON UPDATE CASCADE ON DELETE CASCADE;

---- pr_monitoring.cor_site_actor foreign key constraint id_organism

ALTER TABLE pr_monitoring.cor_site_actor
    ADD CONSTRAINT fk_pr_monitoring_cor_s_bib_o_id_organism FOREIGN KEY (id_organism)
    REFERENCES utilisateurs.bib_organismes(id_organisme)
    ON UPDATE CASCADE ON DELETE SET NULL;

---- pr_monitoring.cor_site_actor foreign key constraint id_role

ALTER TABLE pr_monitoring.cor_site_actor
    ADD CONSTRAINT fk_pr_monitoring_cor_s_t_rol_id_role FOREIGN KEY (id_role)
    REFERENCES utilisateurs.t_roles(id_role)
    ON UPDATE CASCADE ON DELETE SET NULL;

---- pr_monitoring.cor_site_actor foreign key constraint id_nomenclature_type_actor

ALTER TABLE pr_monitoring.cor_site_actor
    ADD CONSTRAINT fk_pr_monitoring_cor_s_t_nom_id_nomenclature_type_actor FOREIGN KEY (id_nomenclature_type_actor)
    REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature)
    ON UPDATE CASCADE ON DELETE CASCADE;


---- pr_monitoring.sc_grotte foreign key constraint id_site

ALTER TABLE pr_monitoring.sc_grotte
    ADD CONSTRAINT fk_pr_monitoring_sc_gr_t_sit_id_site FOREIGN KEY (id_site)
    REFERENCES pr_monitoring.t_sites(id_site)
    ON UPDATE CASCADE ON DELETE CASCADE;


---- pr_monitoring.sc_arbre_loge foreign key constraint id_site

ALTER TABLE pr_monitoring.sc_arbre_loge
    ADD CONSTRAINT fk_pr_monitoring_sc_ar_t_sit_id_site FOREIGN KEY (id_site)
    REFERENCES pr_monitoring.t_sites(id_site)
    ON UPDATE CASCADE ON DELETE CASCADE;


---- nomenclature check type constraints

ALTER TABLE pr_monitoring.t_sites
        ADD CONSTRAINT check_nom_type_pr_monitoring_t_sites_id_ite_typite
        CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_type_site,'TYPE_SITE'))
        NOT VALID;



---- nomenclature check type constraints

ALTER TABLE pr_monitoring.cor_site_actor
        ADD CONSTRAINT check_nom_type_pr_monitoring_cor_site_actor_id_tor_pf_tor
        CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_type_actor,'PF_TYPE_ACTOR'))
        NOT VALID;



-- cor pr_monitoring.cor_site_group

CREATE TABLE IF NOT EXISTS pr_monitoring.cor_site_group (
    id_site INTEGER NOT NULL NOT NULL,
    id_site_group INTEGER NOT NULL NOT NULL
);


---- pr_monitoring.cor_site_group primary keys contraints

ALTER TABLE pr_monitoring.cor_site_group
    ADD CONSTRAINT pk_pr_monitoring_cor_site_group_id_site_id_site_group PRIMARY KEY (id_site, id_site_group);

---- pr_monitoring.cor_site_group foreign keys contraints

ALTER TABLE pr_monitoring.cor_site_group
    ADD CONSTRAINT fk_pr_monitoring_cor_site_group_id_site FOREIGN KEY (id_site)
    REFERENCES pr_monitoring.t_sites (id_site)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE pr_monitoring.cor_site_group
    ADD CONSTRAINT fk_pr_monitoring_cor_site_group_id_site_group FOREIGN KEY (id_site_group)
    REFERENCES pr_monitoring.t_site_group (id_site_group)
    ON UPDATE CASCADE ON DELETE CASCADE;
-- cor pr_monitoring.cor_site_module

CREATE TABLE IF NOT EXISTS pr_monitoring.cor_site_module (
    id_site INTEGER NOT NULL NOT NULL,
    id_module INTEGER NOT NULL NOT NULL
);


---- pr_monitoring.cor_site_module primary keys contraints

ALTER TABLE pr_monitoring.cor_site_module
    ADD CONSTRAINT pk_pr_monitoring_cor_site_module_id_site_id_module PRIMARY KEY (id_site, id_module);

---- pr_monitoring.cor_site_module foreign keys contraints

ALTER TABLE pr_monitoring.cor_site_module
    ADD CONSTRAINT fk_pr_monitoring_cor_site_module_id_site FOREIGN KEY (id_site)
    REFERENCES pr_monitoring.t_sites (id_site)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE pr_monitoring.cor_site_module
    ADD CONSTRAINT fk_pr_monitoring_cor_site_module_id_module FOREIGN KEY (id_module)
    REFERENCES gn_commons.t_modules (id_module)
    ON UPDATE CASCADE ON DELETE CASCADE;
-- cor pr_monitoring.cor_area_site

CREATE TABLE IF NOT EXISTS pr_monitoring.cor_area_site (
    id_site INTEGER NOT NULL NOT NULL,
    id_area INTEGER NOT NULL NOT NULL
);


---- pr_monitoring.cor_area_site primary keys contraints

ALTER TABLE pr_monitoring.cor_area_site
    ADD CONSTRAINT pk_pr_monitoring_cor_area_site_id_site_id_area PRIMARY KEY (id_site, id_area);

---- pr_monitoring.cor_area_site foreign keys contraints

ALTER TABLE pr_monitoring.cor_area_site
    ADD CONSTRAINT fk_pr_monitoring_cor_area_site_id_site FOREIGN KEY (id_site)
    REFERENCES pr_monitoring.t_sites (id_site)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE pr_monitoring.cor_area_site
    ADD CONSTRAINT fk_pr_monitoring_cor_area_site_id_area FOREIGN KEY (id_area)
    REFERENCES ref_geo.l_areas (id_area)
    ON UPDATE CASCADE ON DELETE CASCADE;
-- cor pr_monitoring.cor_linear_site

CREATE TABLE IF NOT EXISTS pr_monitoring.cor_linear_site (
    id_site INTEGER NOT NULL NOT NULL,
    id_linear INTEGER NOT NULL NOT NULL
);


---- pr_monitoring.cor_linear_site primary keys contraints

ALTER TABLE pr_monitoring.cor_linear_site
    ADD CONSTRAINT pk_pr_monitoring_cor_linear_site_id_site_id_linear PRIMARY KEY (id_site, id_linear);

---- pr_monitoring.cor_linear_site foreign keys contraints

ALTER TABLE pr_monitoring.cor_linear_site
    ADD CONSTRAINT fk_pr_monitoring_cor_linear_site_id_site FOREIGN KEY (id_site)
    REFERENCES pr_monitoring.t_sites (id_site)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE pr_monitoring.cor_linear_site
    ADD CONSTRAINT fk_pr_monitoring_cor_linear_site_id_linear FOREIGN KEY (id_linear)
    REFERENCES ref_geo.l_linears (id_linear)
    ON UPDATE CASCADE ON DELETE CASCADE;

-- cor pr_monitoring.cor_visit_observer

CREATE TABLE IF NOT EXISTS pr_monitoring.cor_visit_observer (
    id_visit INTEGER NOT NULL NOT NULL,
    id_role INTEGER NOT NULL NOT NULL
);


---- pr_monitoring.cor_visit_observer primary keys contraints

ALTER TABLE pr_monitoring.cor_visit_observer
    ADD CONSTRAINT pk_pr_monitoring_cor_visit_observer_id_visit_id_role PRIMARY KEY (id_visit, id_role);

---- pr_monitoring.cor_visit_observer foreign keys contraints

ALTER TABLE pr_monitoring.cor_visit_observer
    ADD CONSTRAINT fk_pr_monitoring_cor_visit_observer_id_visit FOREIGN KEY (id_visit)
    REFERENCES pr_monitoring.t_visits (id_visit)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE pr_monitoring.cor_visit_observer
    ADD CONSTRAINT fk_pr_monitoring_cor_visit_observer_id_role FOREIGN KEY (id_role)
    REFERENCES utilisateurs.t_roles (id_role)
    ON UPDATE CASCADE ON DELETE CASCADE;

-- cor pr_monitoring.cor_site_group_module

CREATE TABLE IF NOT EXISTS pr_monitoring.cor_site_group_module (
    id_site_group INTEGER NOT NULL NOT NULL,
    id_module INTEGER NOT NULL NOT NULL
);


---- pr_monitoring.cor_site_group_module primary keys contraints

ALTER TABLE pr_monitoring.cor_site_group_module
    ADD CONSTRAINT pk_pr_monitoring_cor_site_group_module_id_site_group_id_module PRIMARY KEY (id_site_group, id_module);

---- pr_monitoring.cor_site_group_module foreign keys contraints

ALTER TABLE pr_monitoring.cor_site_group_module
    ADD CONSTRAINT fk_pr_monitoring_cor_site_group_module_id_site_group FOREIGN KEY (id_site_group)
    REFERENCES pr_monitoring.t_site_group (id_site_group)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE pr_monitoring.cor_site_group_module
    ADD CONSTRAINT fk_pr_monitoring_cor_site_group_module_id_module FOREIGN KEY (id_module)
    REFERENCES gn_commons.t_modules (id_module)
    ON UPDATE CASCADE ON DELETE CASCADE;
-- cor pr_monitoring.cor_area_site_group

CREATE TABLE IF NOT EXISTS pr_monitoring.cor_area_site_group (
    id_site_group INTEGER NOT NULL NOT NULL,
    id_area INTEGER NOT NULL NOT NULL
);


---- pr_monitoring.cor_area_site_group primary keys contraints

ALTER TABLE pr_monitoring.cor_area_site_group
    ADD CONSTRAINT pk_pr_monitoring_cor_area_site_group_id_site_group_id_area PRIMARY KEY (id_site_group, id_area);

---- pr_monitoring.cor_area_site_group foreign keys contraints

ALTER TABLE pr_monitoring.cor_area_site_group
    ADD CONSTRAINT fk_pr_monitoring_cor_area_site_group_id_site_group FOREIGN KEY (id_site_group)
    REFERENCES pr_monitoring.t_site_group (id_site_group)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE pr_monitoring.cor_area_site_group
    ADD CONSTRAINT fk_pr_monitoring_cor_area_site_group_id_area FOREIGN KEY (id_area)
    REFERENCES ref_geo.l_areas (id_area)
    ON UPDATE CASCADE ON DELETE CASCADE;
-- cor pr_monitoring.cor_linear_site_group

CREATE TABLE IF NOT EXISTS pr_monitoring.cor_linear_site_group (
    id_site_group INTEGER NOT NULL NOT NULL,
    id_linear INTEGER NOT NULL NOT NULL
);


---- pr_monitoring.cor_linear_site_group primary keys contraints

ALTER TABLE pr_monitoring.cor_linear_site_group
    ADD CONSTRAINT pk_pr_monitoring_cor_linear_site_group_id_site_group_id_linear PRIMARY KEY (id_site_group, id_linear);

---- pr_monitoring.cor_linear_site_group foreign keys contraints

ALTER TABLE pr_monitoring.cor_linear_site_group
    ADD CONSTRAINT fk_pr_monitoring_cor_linear_site_group_id_site_group FOREIGN KEY (id_site_group)
    REFERENCES pr_monitoring.t_site_group (id_site_group)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE pr_monitoring.cor_linear_site_group
    ADD CONSTRAINT fk_pr_monitoring_cor_linear_site_group_id_linear FOREIGN KEY (id_linear)
    REFERENCES ref_geo.l_linears (id_linear)
    ON UPDATE CASCADE ON DELETE CASCADE;


-- Triggers


CREATE OR REPLACE FUNCTION pr_monitoring.fn_tri_insert_t_sites_copy_geom_to_geom_local()
    RETURNS trigger AS
        $BODY$
            DECLARE
            BEGIN
                NEW.geom_local := ST_TRANSFORM(NEW.geom, 2154);
                RETURN NEW;
            END;
        $BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;

CREATE TRIGGER pr_monitoring_tri_insert_t_sites_copy_geom_to_geom_local
    BEFORE INSERT ON pr_monitoring.t_sites
    FOR EACH ROW
        EXECUTE PROCEDURE pr_monitoring.fn_tri_insert_t_sites_copy_geom_to_geom_local();

CREATE TRIGGER pr_monitoring_tri_update_t_sites_copy_geom_to_geom_local
    BEFORE UPDATE OF geom ON pr_monitoring.t_sites
    FOR EACH ROW
        EXECUTE PROCEDURE pr_monitoring.fn_tri_insert_t_sites_copy_geom_to_geom_local();

---- Trigger intersection pr_monitoring.t_sites.geom_local avec le ref_geo


CREATE OR REPLACE FUNCTION pr_monitoring.fct_trig_insert_cor_area_site_on_each_statement()
    RETURNS trigger AS
        $BODY$
            DECLARE
            BEGIN
                WITH geom_test AS (
                    SELECT ST_TRANSFORM(t.geom_local, 2154) as geom_local,
                    t.id_site
                    FROM NEW as t
                )
                INSERT INTO pr_monitoring.cor_area_site (
                    id_area,
                    id_site
                )
                SELECT
                    a.id_area,
                    t.id_site
                    FROM geom_test t
                    JOIN ref_geo.l_areas a
                        ON public.ST_INTERSECTS(t.geom_local, a.geom)
                        WHERE
                            a.enable IS TRUE
                            AND (
                                ST_GeometryType(t.geom_local) = 'ST_Point'
                                OR
                                NOT public.ST_TOUCHES(t.geom_local,a.geom)
                            );
                RETURN NULL;
            END;
        $BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;

CREATE OR REPLACE FUNCTION pr_monitoring.fct_trig_update_cor_area_site_on_row()
    RETURNS trigger AS
        $BODY$
            BEGIN
                DELETE FROM pr_monitoring.cor_area_site WHERE id_site = NEW.id_site;
                INSERT INTO pr_monitoring.cor_area_site (
                    id_area,
                    id_site
                )
                SELECT
                    a.id_area,
                    t.id_site
                FROM ref_geo.l_areas a
                JOIN pr_monitoring.t_sites t
                    ON public.ST_INTERSECTS(ST_TRANSFORM(t.geom_local, 2154), a.geom)
                WHERE
                    a.enable IS TRUE
                    AND t.id_site = NEW.id_site
                    AND (
                        ST_GeometryType(t.geom_local) = 'ST_Point'
                        OR NOT public.ST_TOUCHES(ST_TRANSFORM(t.geom_local, 2154), a.geom)
                    )
                ;
                RETURN NULL;
            END;
        $BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;

CREATE OR REPLACE FUNCTION pr_monitoring.process_all_cor_area_site()
    RETURNS INTEGER AS
        $BODY$
            BEGIN
                DELETE FROM pr_monitoring.cor_area_site;
                INSERT INTO pr_monitoring.cor_area_site (
                    id_area,
                    id_site
                )
                SELECT
                    a.id_area,
                    t.id_site
                FROM ref_geo.l_areas a
                JOIN pr_monitoring.t_sites t
                    ON public.ST_INTERSECTS(ST_TRANSFORM(t.geom_local, 2154), a.geom)
                WHERE
                    a.enable IS TRUE
                    AND (
                        ST_GeometryType(t.geom_local) = 'ST_Point'
                        OR NOT public.ST_TOUCHES(ST_TRANSFORM(t.geom_local, 2154), a.geom)
                    )
                ;
                RETURN NULL;
            END;
        $BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;

CREATE TRIGGER trg_insert_pr_monitoring_cor_area_site
    AFTER INSERT ON pr_monitoring.t_sites
    REFERENCING NEW TABLE AS NEW
    FOR EACH STATEMENT
        EXECUTE PROCEDURE pr_monitoring.fct_trig_insert_cor_area_site_on_each_statement();

CREATE TRIGGER trg_update_pr_monitoring_cor_area_site
    AFTER UPDATE OF geom ON pr_monitoring.t_sites
    FOR EACH ROW
        EXECUTE PROCEDURE pr_monitoring.fct_trig_update_cor_area_site_on_row();

---- Trigger pr_monitoring.t_sites.geom_local avec une distance de 100 avec ref_geo.l_linears.id_linear


CREATE OR REPLACE FUNCTION pr_monitoring.fct_trig_insert_cor_linear_site_on_each_statement()
    RETURNS trigger AS
        $BODY$
            DECLARE
            BEGIN
                INSERT INTO pr_monitoring.cor_linear_site (
                    id_linear,
                    id_site
                )
                WITH t_match AS (
                    SELECT
                        l.id_linear,
                        t.id_site,
                        ROW_NUMBER() OVER (PARTITION BY t.id_site, id_type) As rank
                        FROM NEW AS t
                        JOIN ref_geo.l_linears l
                            ON ST_DWITHIN(t.geom_local, l.geom, 100)
                        WHERE l.enable = TRUE
                        ORDER BY t.geom_local <-> l.geom
                )
                SELECT
                    id_linear,
                    id_site
                    FROM t_match
                    WHERE rank = 1
                ;
                RETURN NULL;
            END;
        $BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;

CREATE OR REPLACE FUNCTION pr_monitoring.fct_trig_update_cor_linear_site_on_row()
    RETURNS trigger AS
        $BODY$
            BEGIN
                DELETE FROM pr_monitoring.cor_linear_site WHERE id_site = NEW.id_site;
                INSERT INTO pr_monitoring.cor_linear_site (
                    id_linear,
                    id_site
                )
                WITH t_match AS (
                    SELECT
                        l.id_linear,
                        t.id_site,
                        ROW_NUMBER() OVER (PARTITION BY t.id_site, id_type) As rank
                        FROM pr_monitoring.t_sites AS t
                        JOIN ref_geo.l_linears l
                            ON ST_DWITHIN(t.geom_local, l.geom, 100)
                        WHERE
                            t.id_site = NEW.id_site
                            AND l.enable = TRUE
                        ORDER BY t.geom_local <-> l.geom
                )
                SELECT
                    id_linear,
                    id_site
                    FROM t_match
                    WHERE rank = 1
                ;
                RETURN NULL;
            END;
        $BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;

CREATE OR REPLACE FUNCTION pr_monitoring.process_all_cor_linear_site()
    RETURNS INTEGER AS
        $BODY$
            BEGIN
                DELETE FROM pr_monitoring.cor_linear_site;
                INSERT INTO pr_monitoring.cor_linear_site (
                    id_linear,
                    id_site
                )
                WITH t_match AS (
                    SELECT
                        l.id_linear,
                        t.id_site,
                        ROW_NUMBER() OVER (PARTITION BY t.id_site, id_type) As rank
                        FROM pr_monitoring.t_sites AS t
                        JOIN ref_geo.l_linears l
                            ON ST_DWITHIN(t.geom_local, l.geom, 100)
                        WHERE l.enable = TRUE
                        ORDER BY t.geom_local <-> l.geom
                )
                SELECT
                    id_linear,
                    id_site
                    FROM t_match
                    WHERE rank = 1
                ;
                RETURN NULL;
            END;
        $BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;

CREATE TRIGGER trg_insert_pr_monitoring_cor_linear_site
    AFTER INSERT ON pr_monitoring.t_sites
    REFERENCING NEW TABLE AS NEW
    FOR EACH STATEMENT
        EXECUTE PROCEDURE pr_monitoring.fct_trig_insert_cor_linear_site_on_each_statement();

CREATE TRIGGER trg_update_pr_monitoring_cor_linear_site
    AFTER UPDATE OF geom ON pr_monitoring.t_sites
    FOR EACH ROW
        EXECUTE PROCEDURE pr_monitoring.fct_trig_update_cor_linear_site_on_row();



-- Triggers


CREATE OR REPLACE FUNCTION pr_monitoring.fn_tri_insert_t_site_group_copy_geom_to_geom_local()
    RETURNS trigger AS
        $BODY$
            DECLARE
            BEGIN
                NEW.geom_local := ST_TRANSFORM(NEW.geom, 2154);
                RETURN NEW;
            END;
        $BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;

CREATE TRIGGER pr_monitoring_tri_insert_t_site_group_copy_geom_to_geom_local
    BEFORE INSERT ON pr_monitoring.t_site_group
    FOR EACH ROW
        EXECUTE PROCEDURE pr_monitoring.fn_tri_insert_t_site_group_copy_geom_to_geom_local();

CREATE TRIGGER pr_monitoring_tri_update_t_site_group_copy_geom_to_geom_local
    BEFORE UPDATE OF geom ON pr_monitoring.t_site_group
    FOR EACH ROW
        EXECUTE PROCEDURE pr_monitoring.fn_tri_insert_t_site_group_copy_geom_to_geom_local();

---- Trigger intersection pr_monitoring.t_site_group.geom_local avec le ref_geo


CREATE OR REPLACE FUNCTION pr_monitoring.fct_trig_insert_cor_area_site_group_on_each_statement()
    RETURNS trigger AS
        $BODY$
            DECLARE
            BEGIN
                WITH geom_test AS (
                    SELECT ST_TRANSFORM(t.geom_local, 2154) as geom_local,
                    t.id_site_group
                    FROM NEW as t
                )
                INSERT INTO pr_monitoring.cor_area_site_group (
                    id_area,
                    id_site_group
                )
                SELECT
                    a.id_area,
                    t.id_site_group
                    FROM geom_test t
                    JOIN ref_geo.l_areas a
                        ON public.ST_INTERSECTS(t.geom_local, a.geom)
                        WHERE
                            a.enable IS TRUE
                            AND (
                                ST_GeometryType(t.geom_local) = 'ST_Point'
                                OR
                                NOT public.ST_TOUCHES(t.geom_local,a.geom)
                            );
                RETURN NULL;
            END;
        $BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;

CREATE OR REPLACE FUNCTION pr_monitoring.fct_trig_update_cor_area_site_group_on_row()
    RETURNS trigger AS
        $BODY$
            BEGIN
                DELETE FROM pr_monitoring.cor_area_site_group WHERE id_site_group = NEW.id_site_group;
                INSERT INTO pr_monitoring.cor_area_site_group (
                    id_area,
                    id_site_group
                )
                SELECT
                    a.id_area,
                    t.id_site_group
                FROM ref_geo.l_areas a
                JOIN pr_monitoring.t_site_group t
                    ON public.ST_INTERSECTS(ST_TRANSFORM(t.geom_local, 2154), a.geom)
                WHERE
                    a.enable IS TRUE
                    AND t.id_site_group = NEW.id_site_group
                    AND (
                        ST_GeometryType(t.geom_local) = 'ST_Point'
                        OR NOT public.ST_TOUCHES(ST_TRANSFORM(t.geom_local, 2154), a.geom)
                    )
                ;
                RETURN NULL;
            END;
        $BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;

CREATE OR REPLACE FUNCTION pr_monitoring.process_all_cor_area_site_group()
    RETURNS INTEGER AS
        $BODY$
            BEGIN
                DELETE FROM pr_monitoring.cor_area_site_group;
                INSERT INTO pr_monitoring.cor_area_site_group (
                    id_area,
                    id_site_group
                )
                SELECT
                    a.id_area,
                    t.id_site_group
                FROM ref_geo.l_areas a
                JOIN pr_monitoring.t_site_group t
                    ON public.ST_INTERSECTS(ST_TRANSFORM(t.geom_local, 2154), a.geom)
                WHERE
                    a.enable IS TRUE
                    AND (
                        ST_GeometryType(t.geom_local) = 'ST_Point'
                        OR NOT public.ST_TOUCHES(ST_TRANSFORM(t.geom_local, 2154), a.geom)
                    )
                ;
                RETURN NULL;
            END;
        $BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;

CREATE TRIGGER trg_insert_pr_monitoring_cor_area_site_group
    AFTER INSERT ON pr_monitoring.t_site_group
    REFERENCING NEW TABLE AS NEW
    FOR EACH STATEMENT
        EXECUTE PROCEDURE pr_monitoring.fct_trig_insert_cor_area_site_group_on_each_statement();

CREATE TRIGGER trg_update_pr_monitoring_cor_area_site_group
    AFTER UPDATE OF geom ON pr_monitoring.t_site_group
    FOR EACH ROW
        EXECUTE PROCEDURE pr_monitoring.fct_trig_update_cor_area_site_group_on_row();

---- Trigger pr_monitoring.t_site_group.geom_local avec une distance de 100 avec ref_geo.l_linears.id_linear


CREATE OR REPLACE FUNCTION pr_monitoring.fct_trig_insert_cor_linear_site_group_on_each_statement()
    RETURNS trigger AS
        $BODY$
            DECLARE
            BEGIN
                INSERT INTO pr_monitoring.cor_linear_site_group (
                    id_linear,
                    id_site_group
                )
                WITH t_match AS (
                    SELECT
                        l.id_linear,
                        t.id_site_group,
                        ROW_NUMBER() OVER (PARTITION BY t.id_site_group, id_type) As rank
                        FROM NEW AS t
                        JOIN ref_geo.l_linears l
                            ON ST_DWITHIN(t.geom_local, l.geom, 100)
                        WHERE l.enable = TRUE
                        ORDER BY t.geom_local <-> l.geom
                )
                SELECT
                    id_linear,
                    id_site_group
                    FROM t_match
                    WHERE rank = 1
                ;
                RETURN NULL;
            END;
        $BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;

CREATE OR REPLACE FUNCTION pr_monitoring.fct_trig_update_cor_linear_site_group_on_row()
    RETURNS trigger AS
        $BODY$
            BEGIN
                DELETE FROM pr_monitoring.cor_linear_site_group WHERE id_site_group = NEW.id_site_group;
                INSERT INTO pr_monitoring.cor_linear_site_group (
                    id_linear,
                    id_site_group
                )
                WITH t_match AS (
                    SELECT
                        l.id_linear,
                        t.id_site_group,
                        ROW_NUMBER() OVER (PARTITION BY t.id_site_group, id_type) As rank
                        FROM pr_monitoring.t_site_group AS t
                        JOIN ref_geo.l_linears l
                            ON ST_DWITHIN(t.geom_local, l.geom, 100)
                        WHERE
                            t.id_site_group = NEW.id_site_group
                            AND l.enable = TRUE
                        ORDER BY t.geom_local <-> l.geom
                )
                SELECT
                    id_linear,
                    id_site_group
                    FROM t_match
                    WHERE rank = 1
                ;
                RETURN NULL;
            END;
        $BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;

CREATE OR REPLACE FUNCTION pr_monitoring.process_all_cor_linear_site_group()
    RETURNS INTEGER AS
        $BODY$
            BEGIN
                DELETE FROM pr_monitoring.cor_linear_site_group;
                INSERT INTO pr_monitoring.cor_linear_site_group (
                    id_linear,
                    id_site_group
                )
                WITH t_match AS (
                    SELECT
                        l.id_linear,
                        t.id_site_group,
                        ROW_NUMBER() OVER (PARTITION BY t.id_site_group, id_type) As rank
                        FROM pr_monitoring.t_site_group AS t
                        JOIN ref_geo.l_linears l
                            ON ST_DWITHIN(t.geom_local, l.geom, 100)
                        WHERE l.enable = TRUE
                        ORDER BY t.geom_local <-> l.geom
                )
                SELECT
                    id_linear,
                    id_site_group
                    FROM t_match
                    WHERE rank = 1
                ;
                RETURN NULL;
            END;
        $BODY$
    LANGUAGE plpgsql VOLATILE
    COST 100;

CREATE TRIGGER trg_insert_pr_monitoring_cor_linear_site_group
    AFTER INSERT ON pr_monitoring.t_site_group
    REFERENCING NEW TABLE AS NEW
    FOR EACH STATEMENT
        EXECUTE PROCEDURE pr_monitoring.fct_trig_insert_cor_linear_site_group_on_each_statement();

CREATE TRIGGER trg_update_pr_monitoring_cor_linear_site_group
    AFTER UPDATE OF geom ON pr_monitoring.t_site_group
    FOR EACH ROW
        EXECUTE PROCEDURE pr_monitoring.fct_trig_update_cor_linear_site_group_on_row();



-- Indexes


CREATE INDEX pr_monitoring_t_sites_geom_idx
    ON pr_monitoring.t_sites
    USING GIST (geom);
CREATE INDEX pr_monitoring_t_sites_geom_local_idx
    ON pr_monitoring.t_sites
    USING GIST (geom_local);


-- Indexes


CREATE INDEX pr_monitoring_t_site_group_geom_local_idx
    ON pr_monitoring.t_site_group
    USING GIST (geom_local);

-- process schema : m_monitoring.visit


-- process schema : m_monitoring.site_group


-- process schema : m_monitoring.observation


-- process schema : m_monitoring.site_category

