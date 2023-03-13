import pytest
from gn_modulator.imports.models import TImport
from gn_modulator.utils.commons import getAttr
from geonature.utils.env import db


@pytest.mark.skip()
def test_data_file(
    schema_code=None, data_file_path=None, mapping_file_path=None, expected_infos={}
):
    with db.session.begin_nested():
        # ici _insert_data est à true pour intégrer les avec un insert
        # et non un copy qui ne marche pas en test
        impt = TImport(
            schema_code=schema_code,
            data_file_path=data_file_path,
            mapping_file_path=mapping_file_path,
            _insert_data=True,
        )
        db.session.add(impt)
    assert impt.id_import is not None

    impt.process_import_schema()

    import_infos = impt.as_dict()

    expected_errors = expected_infos.pop("errors", [])

    if len(expected_errors) == 0:
        # on teste si le nombre d'erreur est bien nul
        assert len(import_infos["errors"]) == 0, import_infos["errors"]
    else:
        # on teste si on rencontre bien les erreurs attendues parmi les erreurs rencontrées
        assert len(expected_errors) == len(import_infos["errors"])
        for expected_error in expected_errors:
            assert (
                len([e for e in import_infos["errors"] if expected_error["code"] == e["code"]]) > 0
            ), f"L'erreur de code {expected_error['code']} n'a pas été trouvée"

    for key in expected_infos:
        txt_err = f"schema_code: {schema_code}, key: {key},  expected: {expected_infos.get(key)}, import: {getAttr(import_infos, key)}"
        assert getAttr(import_infos, key) == expected_infos.get(key), txt_err

    return import_infos


@pytest.mark.skip()
def test_import_code(import_code=None, data_dir_path=None, expected_infos=[]):
    imports = TImport.process_import_code(
        import_code, data_dir_path, insert_data=True, commit=False
    )
    assert len(imports) > 0

    for impt in imports:
        assert len(impt.errors) == 0

    for index, expected_info in enumerate(expected_infos):
        impt = imports[index]
        import_infos = impt.as_dict()
        for key in expected_info:
            txt_err = f"schema_code: {impt.schema_code}, key: {key},  expected: {expected_info.get(key)}, import: {getAttr(import_infos, key)}"
            assert getAttr(import_infos, key) == expected_info.get(key), txt_err
