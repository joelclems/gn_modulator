"""
    SchemaMethods : SQL

    SQL text production methods for schema
"""

from sqlalchemy import inspect
from gn_modulator.utils.cache import get_global_cache, set_global_cache

from geonature.utils.env import db

from ..errors import (
    SchemaProcessedPropertyError,
)

from gn_modulator.utils.cache import get_global_cache, clear_global_cache
from gn_modulator.utils.commons import get_class_from_path


class SchemaSqlBase:
    def get_sql_type(self, column_def, cor_table=False, required=False):
        field_type = column_def.get("type")

        sql_type = self.cls.c_get_type(field_type, "definition", "sql")["type"]

        if column_def.get("primary_key") and not cor_table:
            sql_type = "SERIAL NOT NULL"

        if field_type == "geometry":
            sql_type = "GEOMETRY({}, {})".format(
                column_def.get("geometry_type", "GEOMETRY").upper(), column_def["srid"]
            )

        if not sql_type:
            raise SchemaProcessedPropertyError(
                "Property type {} in processed_properties but not managed yet for SQL processing".format(
                    field_type
                )
            )

        if required and ("NOT NULL" not in sql_type):
            sql_type += " NOT NULL"

        return sql_type

    def sql_default(self, column_def):
        if column_def.get("default") is None:
            return None
        if column_def["type"] == "uuid":
            # PATCH DEBUG
            return "public.uuid_generate_v4()"
            return "uuid_generate_v4()"

    def sql_schema_name(self):
        """
        from meta.sql_schema_name or id
        """
        return self.sql_schema_dot_table().split(".")[0]

    def sql_table_name(self):
        """
        from meta.sql_table_name or id
        """
        return self.sql_schema_dot_table().split(".")[1]

    def sql_schema_dot_table(self):
        return self.cls.c_get_sql_schema_dot_table_from_definition(self.schema_code())

    @classmethod
    def c_get_sql_schema_dot_table_from_definition(cls, schema_code):
        definition = get_global_cache(["schema", schema_code, "definition"])
        sql_schema_dot_table = definition["meta"].get("sql_schema_dot_table")

        if sql_schema_dot_table is not None:
            return sql_schema_dot_table

        Model = get_class_from_path(definition["meta"].get("model"))
        return f"{Model.__table__.schema}.{Model.__tablename__}"

    @classmethod
    def c_get_schema_code_from_sql_schema_dot_table(cls, sql_schema_dot_table):
        for schema_code in cls.schema_codes():
            if cls.c_get_sql_schema_dot_table_from_definition(schema_code) == sql_schema_dot_table:
                return schema_code

    @classmethod
    def c_sql_schema_dot_table_exists(cls, sql_schema_dot_table):
        sql_schema_name = sql_schema_dot_table.split(".")[0]
        sql_table_name = sql_schema_dot_table.split(".")[1]
        return cls.c_sql_table_exists(sql_schema_name, sql_table_name)

    @classmethod
    def table_names(cls, sql_schema_name):
        table_names = get_global_cache(["table_names", sql_schema_name])
        if table_names is None:
            table_names = inspect(db.engine).get_table_names(sql_schema_name)
            set_global_cache(["table_names", sql_schema_name], table_names)
        return table_names

    @classmethod
    def c_sql_table_exists(cls, sql_schema_name, sql_table_name):
        return sql_table_name.lower() in cls.table_names(sql_schema_name)

    @classmethod
    def c_sql_schema_exists(cls, sql_schema_name):
        return sql_schema_name in inspect(db.engine).get_schema_names()

    def sql_schema_exists(self):
        """
        check if sql schema exists
        """
        return self.cls.c_sql_schema_exists(self.sql_schema_name())

    def sql_table_exists(self):
        """
        check if sql table exists
        """
        return self.cls.c_sql_table_exists(self.sql_schema_name(), self.sql_table_name())

    def sql_txt_create_schema(self):
        """
        Create schema sql schema
        """
        txt = "CREATE SCHEMA  IF NOT EXISTS {};".format(self.sql_schema_name())
        return txt

    def sql_txt_drop_schema(self):
        """
        Drop schema sql schema

        Jamais de drop cascade !!!!!!!
        """

        txt = "DROP SCHEMA {};".format(self.sql_schema_name())
        return txt

    def sql_processing(self):
        """
        Variable meta
            - pour authoriser l'execution de script sql pour le schema
            - par defaut à False
        """
        return self.attr("meta.sql_processing", False)

    @classmethod
    def c_sql_exec_txt(cls, txt):
        """
        - exec txt as sql
        - remove empty or comments or empty lines and exec sql
          - db.engine.execute doesn't process sql text with comments
        """

        # if not self.sql_processing():
        #     raise SchemaUnautorizedSqlError(
        #         "L'exécution de commandes sql n'est pas autorisé pour le schema {}"
        #         .format(self.schema_code())
        #     )

        txt_no_comment = "\n".join(
            filter(lambda l: (l and not l.strip().startswith("--")), txt.split("\n"))
        )
        return db.engine.execute(txt_no_comment)

    def sql_txt_drop_table(self):
        """
        code sql qui permet de supprimer la table du schema
        """
        txt = ""

        txt += "DROP TABLE {}.{};".format(self.sql_schema_name(), self.sql_table_name())

        return txt

    def sql_txt_process(self, processed_schema_codes=[]):
        """
        process all sql for a schema
        """

        clear_global_cache(["sql_table"])
        if not self.sql_processing():
            processed_schema_codes.append(self.schema_code())
            return "", processed_schema_codes

        schema_codes_to_process = []
        for name in self.dependencies():
            sm = self.cls(name)
            if (
                # si la creation de sql est permise pour ce schema
                sm.sql_processing()
                # et si la table n'existe pas déjà
                and (not sm.sql_table_exists())
                # et si le code sql pour ce schema ne vient pas d'être crée par un appel précédent à sql_txt_process
                and (name not in processed_schema_codes)
            ):
                schema_codes_to_process.append(name)

        txt = "-- process schema : {}\n".format(self.schema_code())
        if schema_codes_to_process:
            txt += "--\n-- and dependencies : {}\n".format(", ".join(schema_codes_to_process))
        txt += "\n\n"

        if self.schema_code() not in processed_schema_codes:
            schema_codes_to_process.insert(0, self.schema_code())

        # schemas
        sql_schema_names = []
        for name in schema_codes_to_process:
            sm = self.cls(name)
            if sm.sql_schema_name() not in sql_schema_names and not sm.sql_schema_exists():
                sql_schema_names.append(sm.sql_schema_name())

        for sql_schema_name in sql_schema_names:
            txt += "---- sql schema {sql_schema_name}\n\n".format(sql_schema_name=sql_schema_name)
            txt += "CREATE SCHEMA IF NOT EXISTS {sql_schema_name};\n\n".format(
                sql_schema_name=sql_schema_name
            )

        # actions
        for action in [
            "sql_txt_create_table",
            "slq_txt_unique_key_constraint",
            "sql_txt_primary_key_constraints",
            "sql_txt_foreign_key_constraints",
            "sql_txt_nomenclature_type_constraints",
            "sql_txt_process_correlations",
            "sql_txt_process_triggers",
            "sql_txt_process_index",
        ]:
            for name in schema_codes_to_process:
                sm = self.cls(name)
                txt_action = getattr(sm, action)()
                if txt_action:
                    txt += "{}\n".format(txt_action)

        return txt, processed_schema_codes + schema_codes_to_process