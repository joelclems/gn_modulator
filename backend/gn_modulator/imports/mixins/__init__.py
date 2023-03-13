from pathlib import Path
from geonature.utils.env import db
from gn_modulator.definition import DefinitionMethods

from .check import ImportMixinCheck
from .data import ImportMixinData
from .insert import ImportMixinInsert
from .mapping import ImportMixinMapping
from .process import ImportMixinProcess
from .raw import ImportMixinRaw
from .relation import ImportMixinRelation
from .update import ImportMixinUpdate
from .utils import ImportMixinUtils


class ImportMixin(
    ImportMixinRelation,
    ImportMixinCheck,
    ImportMixinData,
    ImportMixinInsert,
    ImportMixinMapping,
    ImportMixinProcess,
    ImportMixinRaw,
    ImportMixinUpdate,
    ImportMixinUtils,
):
    def process_import_schema(self):
        self.init_import()
        if self.errors:
            return self
        db.session.flush()

        self.process_data_table()
        if self.errors:
            return self
        db.session.flush()

        self.process_mapping_view()
        if self.errors:
            return self
        db.session.flush()

        self.process_check_types()
        if self.errors:
            return self
        db.session.flush()

        self.process_raw_view()
        if self.errors:
            return self
        db.session.flush()

        self.process_view()
        if self.errors:
            return self
        db.session.flush()

        self.process_check_required()
        self.process_check_resolve_keys()

        if self.errors:
            return self
        db.session.flush()

        self.process_insert()
        if self.errors:
            return self
        db.session.flush()

        self.process_update()
        if self.errors:
            return self
        db.session.flush()

        self.process_relations()
        if self.errors:
            return self
        db.session.flush()

        self.res["nb_unchanged"] = (
            self.res["nb_process"] - self.res["nb_insert"] - self.res["nb_update"]
        )

        return self

    @classmethod
    def process_import_code(cls, import_code, data_dir_path, insert_data=True, commit=True):
        print(f"\nProcess scenario d'import {import_code}")

        # get import definition
        import_definitions = DefinitionMethods.get_definition("import", import_code)
        import_definitions_file_path = DefinitionMethods.get_file_path("import", import_code)

        # for all definition items
        imports = []
        for import_definition in import_definitions["items"]:
            # récupération du fichier de données
            data_file_path = (
                Path(data_dir_path) / import_definition["data"]
                if import_definition.get("data")
                else Path(data_dir_path)
            )

            # récupération du fichier pre-process, s'il est défini
            mapping_file_path = (
                Path(import_definitions_file_path).parent / import_definition["mapping"]
                if import_definition.get("mapping")
                else None
            )

            impt = cls(
                schema_code=import_definition["schema_code"],
                data_file_path=data_file_path,
                mapping_file_path=mapping_file_path,
                _insert_data=False,
            )

            # pour éviter d'avoir à recharger les données
            if import_definition.get("keep_raw") and len(imports):
                impt.tables["data"] = imports[-1].tables["data"]

            db.session.add(impt)
            # flush ??

            impt.process_import_schema()
            imports.append(impt)

            if impt.errors:
                print(f"Il y a des erreurs dans l'import {import_definition['schema_code']}")
                for error in impt.errors:
                    print(f"- {error['code']} : {error['msg']}")
                return imports
            print(impt.pretty_infos())

        if commit:
            db.session.commit()
        print(f"Import {import_code} terminé")
        return imports
