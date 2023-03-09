"""gn_modulator import init

Revision ID: 3920371728d8
Revises: d3f266c7b1b6
Create Date: 2023-03-03 14:31:35.339631

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = "3920371728d8"
down_revision = "d3f266c7b1b6"
branch_labels = None
depends_on = None


def upgrade():
    op.execute(
        """
CREATE TABLE gn_modulator.t_imports(
    id_import SERIAL NOT NULL,
    id_digitiser INTEGER,
    schema_code VARCHAR,
    data_file_path VARCHAR,
    mapping_file_path VARCHAR,
    csv_delimiter VARCHAR,
    data_type VARCHAR,
    res JSONB,
    tables JSONB,
    errors JSONB,
    sql JSONB
);

ALTER TABLE gn_modulator.t_imports
    ADD CONSTRAINT pk_gn_modulator_t_imports_id_import PRIMARY KEY (id_import);

ALTER TABLE pr_sipaf.t_passages_faune
    ADD CONSTRAINT fk_modulator_t_impt_t_role_id_digitiser FOREIGN KEY (id_digitiser)
    REFERENCES utilisateurs.t_roles(id_role)
    ON UPDATE CASCADE ON DELETE SET NULL;

    """
    )
    pass


def downgrade():
    op.execute(
        """
    DROP TABLE gn_modulator.t_imports;
    """
    )
    pass