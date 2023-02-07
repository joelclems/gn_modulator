from sqlalchemy import orm, and_, nullslast


class SchemaRepositoriesUtil:
    """
    custom getattr: retrouver les attribut d'un modele ou des relations du modèles
    """

    __abstract__ = True

    def custom_getattr(self, Model, field_name, query=None, condition=None):
        """
        getattr pour un modèle, étendu pour pouvoir traiter les 'rel.field_name'

        on utilise des alias pour pouvoir gérer les cas plus compliqués

        query pour les filtres dans les api
        condition pour les filtres dans les column_properties

        exemple:

            on a deux relations de type nomenclature
            et l'on souhaite filtrer la requête par rapport aux deux

        TODO gerer plusieurs '.'
        exemple
        http://localhost:8000/modules/schemas.sipaf.pf/rest/?page=1&page_size=13&sorters=[{%22field%22:%22id_pf%22,%22dir%22:%22asc%22}]&filters=[{%22field%22:%22areas.type.coe_type%22,%22type%22:%22=%22,%22value%22:%22DEP%22}]&fields=[%22id_pf%22,%22nom_pf%22,%22ownership%22]
        """

        if "." not in field_name:
            # cas simple
            model_attribute = getattr(Model, field_name)

            return model_attribute, query

        else:
            # cas avec un ou plusieurs '.', recursif

            field_names = field_name.split(".")

            rel = field_names[0]
            relationship = getattr(Model, rel)

            col = ".".join(field_names[1:])

            # pour recupérer le modèle correspondant à la relation
            relation_entity = relationship.mapper.entity

            if query is not None and condition is None:
                # on fait un alias
                relation_entity = orm.aliased(relationship.mapper.entity)

                query = query.join(relation_entity, relationship, isouter=True)

                # query = query.options(orm.contains_eager(relationship))

            elif condition:
                # TODO gérer les alias si filtres un peu plus tordus ??
                query = and_(query, relationship._query_clause_element())

            return self.custom_getattr(relation_entity, col, query, condition)

    def get_sorters(self, Model, sort, query):
        order_bys = []

        for s in sort:
            sort_dir = "+"
            sort_field = s
            if s[-1] == "-":
                sort_field = s[:-1]
                sort_dir = s[-1]

            model_attribute, query = self.custom_getattr(Model, sort_field, query)

            if model_attribute is None:
                continue

            order_by = model_attribute.desc() if sort_dir == "-" else model_attribute.asc()

            # nullslast
            order_by = nullslast(order_by)
            order_bys.append(order_by)

        return order_bys, query

    def get_sorter(self, Model, sorter, query):
        sort_field = sorter["field"]
        sort_dir = sorter["dir"]

        model_attribute, query = self.custom_getattr(Model, sort_field, query)

        order_by = model_attribute.desc() if sort_dir == "desc" else model_attribute.asc()

        order_by = nullslast(order_by)

        return order_by, query

    def process_page_size(self, page, page_size, query):
        """
        LIMIT et OFFSET
        """

        if page_size and int(page_size) > 0:
            query = query.limit(page_size)

            if page and int(page) > 1:
                offset = (int(page) - 1) * int(page_size)
                query = query.offset(offset)

        return query