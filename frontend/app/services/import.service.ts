import { Injectable, Injector } from '@angular/core';
import { ModulesConfigService } from './config.service';
import { ModulesRequestService } from './request.service';

@Injectable()
export class ModulesImportService {
  _mConfig: ModulesConfigService;
  _mRequest: ModulesRequestService;

  constructor(private _injector: Injector) {
    this._mRequest = this._injector.get(ModulesRequestService);
    this._mConfig = this._injector.get(ModulesConfigService);
  }

  importRequest(moduleCode, object_code, data, params = {}) {
    return this._mRequest.postRequestWithFormData(
      `${this._mConfig.backendModuleUrl()}/import/${moduleCode}/${object_code}/${
        data.id_import || ''
      }`,
      {
        data: data.id_import ? {} : data,
        params,
      }
    );
  }

  processMessage(data) {
    if (!data.id_import) {
      return {
        html: `
          <h5> Etape 1/3</h5> 
          <h6>Chargement et validation des données</h6>
          Veuillez choisir un fichier et appuyer sur Valider`,
        class: 'info',
      };
    }

    if (data.status == 'READY') {
      return {
        html: `
          <h5> Etape 1/3</h5> 
          <h6>Insertion des données</h6>
          <p>- Nombre de lignes ${data.res.nb_raw}</p>
          <p>- Nombre d'insertion ${data.res.nb_insert}</p>
          <p>- Nombre de mise à jour ${data.res.nb_update} ${
          data.options.enable_update ? '' : '(MAJ Non autorisée)'
        }</p>
          Veuillez appuyer sur valider pour insérer les données`,
        class: 'info',
      };
    }

    if (data.status == 'DONE') {
      return {
        html: `
          <h5> Etape 3/3</h5> 
          <h6>Import Terminé</h6>
          `,
        class: 'info',
      };
    }
  }

  importHTMLMsgSuccess(impt) {
    let txtImport = `<h5>Import réussi</h5>`;
    let res = impt.res;

    if (res.nb_data) {
      txtImport += `data: ${res.nb_data}<br>`;
    }

    if (res.nb_raw != res.nb_data) {
      txtImport += `raw: ${res.nb_raw}<br>`;
    }

    if (res.nb_insert) {
      txtImport += `insert: ${res.nb_insert}<br>`;
    }

    if (res.nb_update) {
      txtImport += `update: ${res.nb_update}<br>`;
    }

    if (res.nb_unchanged) {
      txtImport += `unchanged: ${res.nb_unchanged}<br>`;
    }
    return txtImport;
  }

  importHTMLMsgError(impt) {
    let txtImport = `<h4>${impt.errors.length} erreurs</h4>`;

    let txtErrorRequired;
    for (let error of impt.errors.filter((e) => e.code == 'ERR_IMPORT_REQUIRED')) {
      if (!txtErrorRequired) {
        txtErrorRequired = `<h5>Champs requis manquants</h5>`;
      }
      txtErrorRequired += `<b>${error.key}</b> ${error.lines.length} ligne(s): [${error.lines}]<br>`;
    }
    if (txtErrorRequired) {
      txtImport += '<hr>';
      txtImport += txtErrorRequired;
    }

    let txtErrorUnresolved;
    for (let error of impt.errors.filter((e) => e.code == 'ERR_IMPORT_UNRESOLVED')) {
      if (!txtErrorUnresolved) {
        txtErrorUnresolved = `<h5>Champs non résolus</h5>`;
      }
      txtErrorUnresolved += `<b>${error.key}</b> ${error.lines.length} ligne(s): [${error.lines}]<br>`;
      if (error.values) {
        txtErrorUnresolved += `Valeurs parmi : ${error.values
          .map((v) => v.cd_nomenclature)
          .join(', ')}<br>`;
      }
    }
    if (txtErrorUnresolved) {
      txtImport += '<hr>';
      txtImport += txtErrorUnresolved;
    }

    for (let error of impt.errors.filter(
      (e) => !['ERR_IMPORT_REQUIRED', 'ERR_IMPORT_UNRESOLVED'].includes(e.code)
    )) {
      txtImport += '<hr>';
      txtImport += `${error.code}: ${error.msg}`;
    }

    return txtImport;
  }
}
