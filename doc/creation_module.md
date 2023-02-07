# Création d'un module

## Aide au développement

En phase de développement, il est pratique d'avoir l'application flask qui redémarre automatiquement en cas de changement des fichiers de
configuration (yml). Pour cela vous pouvez lancer l'application avec les commandes suivantes :

```bash
source <GEONATURE_DIR>/backend/venv/bin/activate
export extra_files="$(find -L <GEONATURE_DIR>/external_modules/modules/config -type f -name \*.yml | sed -n '1{h};1!{H};${g;s/\n/:/pg}')"
export FLASK_APP=geonature.app; export FLASK_DEBUG=1;
flask run --port 8000 --host 0.0.0.0 --extra-files="$extra_files"
```

Pour voir les changements de la configuration au niveau du frontend, il faudra recharger la page du navigateur (`CTRL + MAJ + R` ou `MAJ + F5`).

Nous prenons comme exemple un projet de suivi de parcs éoliens.

## Configuration du module

La structure du dossier de la configuration du module est la suivante :

```
/
    # fichier de configuration du module
    module.yml

    # fichiers de définition des objects (tables, modèles) associés à ce module
    definitions/

    # données addionelles
    features/

    # fichiers images, médias, etc..
    assets/

    # fichiers contenant la configuration des pages du modules
    layouts/
```

### `module.yml`

Dictionnaire définissant la configuration du module, avec les clés suivantes :

- **module** :
   - informations destinées à la table `gn_commons.t_modules`

     ```
     module :
        module_code : m_eole
        module_label : Modules de suivi éolien
        module_desc : POC pour le projet suivi éolien
        module_picto : fa-puzzle-piece
        active_frontend : true
     ```

- **objects** :
   - permet de définir les données qui vont être manipulées dans ce module :   
      - pour chaque clé on va définir :   
         - **schema_code** : défini la table
         - **cruved** : quelles sont les api qui vont être ouvertes et pour quels type d'action
         - **prefilters** :
            - par exemple pour les gîtes on souhaite avoir seulement les sites de catégorie `gîtes`
            - `prefilters : category.code = GIT`
            - l'API créée pour cet object (et ce module) appliquera toujours les pré-filtres definis ici
         - **label** : redéfinition du nom de l'objet
         - **labels** : redéfinition du nom (pluriel de l'objet
         - **genre** : `'M'|'F'` redéfinition du genre de l'objet (masculin / féminin)
         - **map** : 
            - **style** : style css des layers :
               - **color**
            - **bring_to_front** : *boolean*, si l'on souhaite ramener ces éléments au premier plan
         - **exports** : liste des noms d'export (`export_code`) associés à l'objet

- **tree** : un dictionnaire qui définit une hiérachie entre les pages, classiquement :
   - site
      -visite
         - observation

- **pages** : la définition des pages qui composent le module_label
   - pages
      - parc_list
         - url : '' 
         - layout : 
            - code : m_eole.parc_list

- **exports** :
   - m_sipaf.pf : # code de l'export ou `export_code`
      - export_label : Test
      - object_code : pf
      - fields : 
         - id_passage_faune 
         - ...