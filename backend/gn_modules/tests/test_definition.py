"""
Test pour valider
- que les définition contenues dans le module sont valides
- les messages des remontées d'erreurs

reste à tester (a minima)
ERR_DEF_EMPTY_FILE
ERR_TEMPLATE_NOT_FOUND
ERR_TEMPLATE_UNRESOLVED_FIELDS
"""

import pytest
from gn_modules.definition import DefinitionMethods
from gn_modules.utils.cache import get_global_cache
from gn_modules.utils.errors import get_errors, clear_errors, errors_txt
from gn_modules.utils.env import definitions_test_dir


@pytest.mark.usefixtures(scope="session")
class TestDefinitions:
    def test_init_gn_module(self):
        """
        On teste si l'initialisation du module s'est bien déroulée
        - s'il n'y a pas d'erreur dans les définitions
        - si on a bien des schemas, modules et layout à minima
        - si le traitement de ces définition n'entraîne par d'erreurs
        """

        # pas d'erreurs à l'initialisation de gn_modules
        assert (
            len(get_errors()) == 0
        ), "Il ne doit pas y avoir d'erreur à ce stade (initialisation module)"

        # on a bien chargé des schemas, modules, layouts
        assert len(DefinitionMethods.definition_codes("reference")) > 0
        assert len(DefinitionMethods.definition_codes("module")) > 0
        assert len(DefinitionMethods.definition_codes("layout")) > 0
        assert len(DefinitionMethods.definition_codes("schema")) > 0
        assert len(DefinitionMethods.definition_codes("template")) > 0
        assert len(DefinitionMethods.definition_codes("use_template")) > 0

        # on a bien les références
        # - pour les définitions
        for reference_key in ["schema", "schema_auto", "import", "module"]:
            assert get_global_cache(["reference", reference_key]) is not None

        # - pour la validation
        for reference_key in [
            "geometry",
            "linestring",
            "multilinestring",
            "multipolygon",
            "point",
            "polygon",
        ]:
            assert get_global_cache(["reference", reference_key]) is not None

    def test_load_definition(self, file_path=None, error_code=None):
        """
        tests sur le chargement des fichiers yml
        et sur la remontée des erreurs
        lors de l'utilisation de la methode DefinitionMethods.load_definition_file
        """

        clear_errors()

        if file_path is None:
            return

        definition = DefinitionMethods.load_definition_file(file_path)
        # s'il n'y pas d'erreur de code
        # on s'assure que le chargement du fichier s'est bien passé
        if error_code is None:
            assert (
                len(get_errors()) == 0
            ), "Il ne doit pas y avoir d'erreur à ce stade (load_definition)"
            assert definition is not None
            definition_type, definition_code = DefinitionMethods.get_definition_type_and_code(
                definition
            )
            assert definition_type is not None
            assert definition_code is not None

            return definition

        assert get_errors()[0]["code"] == error_code

        return definition

    def check_errors(
        self, definition_type=None, definition_code=None, error_code=None, context=None
    ):

        if definition_type is None:
            return

        # si le code d'erreur n'est pas défini, on s'assure qu'il n'y a pas d'erreur
        if error_code is None:
            assert (
                len(get_errors()) == 0
            ), f"({context}) : il ne doit pas y avoir d'erreur à ce stade"

        else:
            assert (
                len(get_errors()) == 1
            ), f"({context}) : on s'attend à voir remonter une erreur (et non {len(get_errors())})"

            # on teste si le code de l'erreur est celui attendu
            assert (
                get_errors()[0]["code"] == error_code
            ), f"({context}) : le code d'erreur attendu est {error_code} (et non {get_errors()[0]['code']})"

            # on teste si la definition a bien été supprimé
            assert (
                get_global_cache([definition_type, definition_code]) is None
            ), "({context}) : la definition erronée aurait du être supprimée du cache"

    def test_check_references(self):
        """
        test si le schema de validation est valide (selon la référence de schemas de validation)
        """
        clear_errors()
        self.test_load_definition(definitions_test_dir / "check_references_fail.reference.yml")
        DefinitionMethods.check_references()

        assert (
            len(get_errors()) == 1
        ), f"check references, on s'attend à voir remonter une erreur (et non {len(get_errors())})"
        get_errors()[0]["code"] == "ERR_VALID_REF"
        clear_errors()

    def test_local_check_definition(self, file_path=None, error_code=None):
        """
        test sur l'utilisation et la remontée des erreurs
        de la méthode local_check_definition
        """

        clear_errors()

        if file_path is None:
            return

        # chargment de la definition (+ test que tout est ok)
        definition = self.test_load_definition(file_path)

        definition_type, definition_code = DefinitionMethods.get_definition_type_and_code(
            definition
        )

        DefinitionMethods.check_references()

        DefinitionMethods.local_check_definition(definition_type, definition_code)

        self.check_errors(definition_type, definition_code, error_code, "local_check")

        return definition

    def test_global_check_definition(self, file_path=None, error_code=None):
        """
        test sur l'utilisation et la remontée des erreurs
        de la méthode global_check_definition et associées
        TODO
        """

        clear_errors()

        if file_path is None:
            return

        definition = self.test_local_check_definition(file_path)

        definition_type, definition_code = DefinitionMethods.get_definition_type_and_code(
            definition
        )

        DefinitionMethods.global_check_definition(definition_type, definition_code)

        self.check_errors(definition_type, definition_code, error_code, "global_check")

        return definition

    def test_process_template(self, file_path=None, error_code=None):

        clear_errors()

        if file_path is None:
            return

        definition = self.test_local_check_definition(file_path)

        definition_type, definition_code = DefinitionMethods.get_definition_type_and_code(definition)

        assert definition_type == 'use_template'

        DefinitionMethods.process_template(definition_code)

        self.check_errors(definition_type, definition_code, error_code, 'process_template')

    def test_load_definition_json_ok(self):
        # load json ok
        return self.test_load_definition(definitions_test_dir / "load_definition_ok.schema.json")

    def test_load_definition_yml_ok(self):
        # load yml ok
        return self.test_load_definition(definitions_test_dir / "load_definition_ok.schema.yml")

    def test_load_definition_json_fail(self):
        # load json fail
        return self.test_load_definition(
            definitions_test_dir / "load_definition_fail.json", "ERR_LOAD_JSON"
        )

    def test_load_definition_yml_fail(self):
        # load yml fail
        return self.test_load_definition(
            definitions_test_dir / "load_definition_fail.yml", "ERR_LOAD_YML"
        )

    def test_load_definition_list_fail(self):
        # load list fail
        return self.test_load_definition(
            definitions_test_dir / "load_definition_list_fail.yml", "ERR_LOAD_LIST"
        )

    def test_load_definition_unknown_fail(self):
        # load unknown fail
        return self.test_load_definition(
            definitions_test_dir / "load_definition_unknown_fail.yml", "ERR_LOAD_UNKNOWN"
        )

    def test_load_definition_existing_fail(self):
        # load existing fail
        return self.test_load_definition(
            definitions_test_dir / "load_definition_existing_fail.schema.yml", "ERR_LOAD_EXISTING"
        )

    def test_load_definition_file_name_fail(self):
        # ERR_LOAD_FILE_NAME
        return self.test_load_definition(
            definitions_test_dir / "load_definition_file_name_fail.layout.yml",
            "ERR_LOAD_FILE_NAME",
        )

    def test_local_check_definition_dynamic(self):
        """
        test de remontée des erreur de validation des layout pour les éléments dynamiques
        """

        return self.test_local_check_definition(
            definitions_test_dir / "local_check_definition_dyn_fail.layout.yml",
            "ERR_LOCAL_CHECK_DYNAMIC",
        )

    def test_local_check_definition_no_ref_for_type(self):
        """
        ERR_LOCAL_CHECK_NO_REF_FOR_TYPE
        """

        return self.test_local_check_definition(
            definitions_test_dir / "local_check_definition_no_ref_for_type_fail.gloubi.yml",
            "ERR_LOCAL_CHECK_NO_REF_FOR_TYPE",
        )

    def test_global_check_definition_missing_schema(self):
        """
        test global pour vérifier la remontée de missing schema
        """
        return self.test_global_check_definition(
            definitions_test_dir / "global_check_schema_codes_fail.schema.yml",
            "ERR_GLOBAL_CHECK_MISSING_SCHEMA",
        )

    def test_global_check_definition_missing_dependencies(self):
        """
        test global pour vérifier la remontée de missing schema
        """
        return self.test_global_check_definition(
            definitions_test_dir / "global_check_dependencies_fail.data.yml",
            "ERR_GLOBAL_CHECK_MISSING_DEPENDENCIES",
        )

    def test_template_not_found_fail(self):
        """
        ERR_TEMPLATE_NOT_FOUND
        """

        return self.test_process_template(
            definitions_test_dir / "process_template_not_found_fail.use_template.yml",
            "ERR_TEMPLATE_NOT_FOUND",
        )

    def test_template(self):
        """
        Tests sur ce que l'on attend d'un template
        """

        clear_errors()

        # si la definition du module m_monitoring_test
        # créé à partir du template m_monitoring.module_template
        # possède bien les éléments attendus

        definition = DefinitionMethods.get_definition("module", "m_monitoring_test_1")
        assert definition.get("pages") is not None

        assert definition["code"] == "m_monitoring_test_1"