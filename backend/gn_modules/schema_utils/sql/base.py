'''
    SchemaMethods : SQL

    SQL text production methods for schema
'''

from sqlalchemy import inspect

from geonature.utils.env import DB

from ..errors import (
    SchemaProcessedPropertyError,
)

cache_sql_tables={}

class SchemaSqlBase():

    def get_sql_type(self, column_def, cor_table=False):
        field_type = column_def.get('type')

        sql_type = self.cls().c_get_type(field_type, "definition", 'sql')['type']

        if column_def.get('primary_key') and not cor_table:
            sql_type = 'SERIAL NOT NULL'

        if field_type == 'geometry':
            sql_type = 'GEOMETRY({}, {})'.format(
                column_def.get('geometry_type', 'GEOMETRY').upper(),
                column_def['srid']
            )

        if not sql_type:
            raise SchemaProcessedPropertyError(
                'Property type {} in processed_properties but not managed yet for SQL processing'
                .format(field_type)
            )

        return sql_type

    def sql_schema_name(self):
        '''
            from meta.sql_schema_name or id
        '''
        return self.meta('sql_schema_name', 'm_{}'.format(self.id().split('/')[-2]))

    def sql_table_name(self):
        '''
            from meta.sql_table_name or id
        '''
        return self.meta('sql_table_name', 't_{}s'.format(self.id().split('/')[-1]))

    def schema_dot_table(self):
        return '{}.{}'.format(self.sql_schema_name(), self.sql_table_name())

    @classmethod
    def c_get_schema_name_from_schema_dot_table(cls, schema_dot_table):
        for schema_name in cls.schema_names('schemas'):

            schema = cls.load_json_file_from_name(schema_name)
            sql_schema_name = schema.get('$meta', {}).get('sql_schema_name')
            sql_table_name = schema.get('$meta', {}).get('sql_table_name')

            if '{}.{}'.format(sql_schema_name, sql_table_name) == schema_dot_table:
                return schema_name

    @classmethod
    def c_sql_schema_dot_table_exists(cls, sql_schema_dot_table):
        sql_schema_name = sql_schema_dot_table.split('.')[0]
        sql_table_name = sql_schema_dot_table.split('.')[1]
        return cls.c_sql_table_exists(sql_schema_name, sql_table_name)

    @classmethod
    def c_sql_table_exists(cls, sql_schema_name, sql_table_name):
        return sql_table_name in inspect(DB.engine).get_table_names(sql_schema_name)

    @classmethod
    def c_sql_schema_exists(cls, sql_schema_name):
        return sql_schema_name in inspect(DB.engine).get_schema_names()

    def sql_schema_exists(self):
        '''
            check if sql schema exists
        '''
        return self.cls().c_sql_schema_exists(self.sql_schema_name())

    def sql_table_exists(self):
        '''
            check if sql table exists
        '''
        return self.cls().c_sql_table_exists(self.sql_schema_name(), self.sql_table_name())

    def sql_txt_create_schema(self):
        '''
            Create schema sql schema
        '''
        txt = 'CREATE SCHEMA  IF NOT EXISTS {};'.format(self.sql_schema_name())
        return txt

    def sql_txt_drop_schema(self):
        '''
            Drop schema sql schema

            Jamais de drop cascade !!!!!!!
        '''

        txt = 'DROP SCHEMA {};'.format(self.sql_schema_name())
        return txt

    def sql_processing(self):
        '''
            Variable meta
                - pour authoriser l'execution de script sql pour le schema
                - par defaut à False
        '''
        return self.meta("sql_processing", False)

    @classmethod
    def c_sql_exec_txt(cls, txt):
        '''
            - exec txt as sql
            - remove empty or comments or empty lines and exec sql
              - DB.engine.execute doesn't process sql text with comments
        '''

        # if not self.sql_processing():
        #     raise SchemaUnautorizedSqlError(
        #         "L'exécution de commandes sql n'est pas autorisé pour le schema {}"
        #         .format(self.schema_name())
        #     )

        txt_no_comment = '\n' .join(
            filter(
                lambda l: (l and not l.strip().startswith('--')),
                txt.split('\n')
            )
        )
        return DB.engine.execute(txt_no_comment)

    def sql_txt_drop_table(self):
        '''
            code sql qui permet de supprimer la table du schema
        '''
        txt = ''

        txt += 'DROP TABLE {}.{};'.format(self.sql_schema_name(), self.sql_table_name())

        return txt

    def sql_txt_process(self):
        '''
            process all sql for a schema
        '''

        cache_sql_tables = {}
        if not self.sql_processing():
            return ''

        processed_schema_names = []
        for name in self.dependencies():
            sm = self.cls()(name)
            if sm.sql_processing():  # and not sm.sql_table_exists():
                processed_schema_names.append(name)

        txt = "-- process schema : {}\n".format(self.schema_name())
        if processed_schema_names:
            txt += "--\n-- and dependancies : {}\n".format(', '.join(processed_schema_names))
        txt += '\n\n'

        processed_schema_names.insert(0, self.schema_name())

        # schemas
        sql_schema_names = []
        for name in processed_schema_names:
            sm = self.cls()(name)
            if sm.sql_schema_name() not in sql_schema_names:  # and not sm.sql_schema_exists():
                sql_schema_names.append(sm.sql_schema_name())

        for sql_schema_name in sql_schema_names:
            txt += '---- sql schema {sql_schema_name}\n\n'.format(sql_schema_name=sql_schema_name)
            txt += 'CREATE SCHEMA IF NOT EXISTS {sql_schema_name};\n\n'.format(sql_schema_name=sql_schema_name)

        # actions
        for action in [
            'sql_txt_create_table',
            'sql_txt_primary_key_constraints',
            'sql_txt_foreign_key_constraints',
            'sql_txt_nomenclature_type_constraints',
            'sql_txt_process_correlations',
            'sql_txt_process_triggers',
            'sql_txt_process_index',
        ]:
            for name in processed_schema_names:
                sm = self.cls()(name)
                txt_action = getattr(sm, action)()
                if txt_action:
                    txt += '{}\n'.format(txt_action)

        return txt