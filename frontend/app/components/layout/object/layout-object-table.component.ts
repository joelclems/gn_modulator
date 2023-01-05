import { Component, OnInit, Injector } from '@angular/core';
import { ModulesLayoutObjectComponent } from './layout-object.component';
import { Observable, of } from '@librairies/rxjs';
import { ModulesTableService } from '../../../services/table.service';
import tabulatorLangs from '../../base/table/tabulator-langs';
import Tabulator from 'tabulator-tables';
import utils from '../../../utils';

@Component({
  selector: 'modules-layout-object-table',
  templateUrl: 'layout-object-table.component.html',
  styleUrls: ['../../base/base.scss', 'layout-object-table.component.scss'],
})
export class ModulesLayoutObjectTableComponent
  extends ModulesLayoutObjectComponent
  implements OnInit
{
  tableId; // identifiant HTML pour la table;
  counterId; // identifiant HTML pour afficher le counter de données dans le footer;
  table; // object tabulator
  tab = document.createElement('div'); // element
  tableHeight; // hauteur de la table

  params;
  modalDeleteLayout = {
    code: 'm_monitoring.modal_delete',
  };
  _mTable: ModulesTableService;

  constructor(_injector: Injector) {
    super(_injector);
    this._name = 'layout-object-table';
    this._mTable = this._injector.get(ModulesTableService);
    this.tableId = `table_${this._id}`;
  }

  postInit() {}

  onRedrawElem(): void {
    this.onHeightChange(true);
    this.setCount();
  }

  columns() {
    return this._mTable.columnsTable(this.fields(), this.computedLayout, this.context);
  }

  drawTable(): void {
    this.table = new Tabulator(this.tab, {
      langs: tabulatorLangs,
      locale: 'fr',
      layout: 'fitColumns',
      placeholder: 'Pas de donnée disponible',
      ajaxFiltering: true,
      height: this.tableHeight || '200px',
      ajaxRequestFunc: this.ajaxRequestFunc,
      columns: this.columns(),
      ajaxURL: this.objectConfig().table.url,
      paginationSize: this.computedLayout.page_size || this.objectConfig().utils.page_size,
      pagination: 'remote',
      headerFilterLiveFilterDelay: 600,
      ajaxSorting: true,
      initialSort: this._mTable.processObjectSorters(this.computedLayout.sort),
      selectable: 1,
      columnMinWidth: 20,
      footerElement: `<span class="counter" id=counter></span>`,
      // tooltips:true,
      rowClick: this.onRowClick,
    });

    utils.waitForElement(this.tableId).then((elem: any) => {
      elem.appendChild(this.tab);
      this.isProcessing = false;
    });
  }

  onRowClick = (e, row) => {
    let action = utils.getAttr(e, 'target.attributes.action.nodeValue')
      ? utils.getAttr(e, 'target.attributes.action.nodeValue')
      : e.target.getElementsByClassName('action').length
      ? utils.getAttr(e.target.getElementsByClassName('action')[0], 'attributes.action.nodeValue')
      : 'selected';
    const value = this.getRowValue(row);

    if (['details', 'edit'].includes(action)) {
      this._mPage.processAction({
        action,
        context: this.context,
        value,
      });
    }

    if (action == 'delete') {
      this._mLayout.openModal('delete', this.getRowData(row));
    }

    if (action == 'selected') {
      this.setObject({ value });
    }
  };

  getRowValue(row) {
    const pkFieldName = this.pkFieldName();
    return this.getRowData(row)[pkFieldName];
  }

  getRowData(row) {
    return row._row.data;
  }

  /** ajaxRequestFunc
   *
   * la promesse qui va être appelée par le composant tabulator
   * - on se sert de la fonction getList du service _mData
   * - on gère les paramètre de route
   *  - page_size, page, filters, prefilters, sort
   *
   */
  ajaxRequestFunc = (url, config, paramsTable) => {
    return new Promise((resolve, reject) => {
      // calcul des paramètres
      // TODO traiter les paramètres venant des filtres de la table
      const params = {
        ...paramsTable,
        page_size: paramsTable.size,
        sort: this._mTable.processTableSorters(paramsTable.sorters),
      };

      if (!this.computedLayout.display_filters) {
        params.filters = this.getDataFilters();
      }

      // prefiltres
      const prefilters = this.getDataPreFilters();

      if (prefilters) {
        params.prefilters = prefilters;
      }

      const extendedParams = {
        ...params, // depuis tabulator
        fields: this.fields(), // fields
        flat_keys: true, // sortie à plat
      };

      // on garde les paramètres en mémoire pour les utiliser dans getPageNumber();
      this.params = extendedParams;

      // pour ne pas trainer sortersça dans l'api
      delete extendedParams['sorters'];

      this._mData.getList(this.moduleCode(), this.objectCode(), extendedParams).subscribe(
        (res) => {
          resolve(res);
          this.onHeightChange(true);

          if (this.getDataValue()) {
            setTimeout(() => {
              this.selectRow(this.getDataValue());
            }, 100);
          }

          //
          this.processTotalFiltered(res);
          this.setCount();

          return;
        },
        (fail) => {
          reject(fail);
        }
      );
    });
  };

  setCount() {
    utils.waitForElement('counter', document.querySelector(`#${this.tableId}`)).then(
      (counterElement) => {
        // (counterElement as any).innerHTML = `Nombre de données filtrées / total : <b>${res.filtered} /  ${res.total}</b>`;
        (counterElement as any).innerHTML = `<b>${this.context.nb_filtered || 0} /  ${
          this.context.nb_total || 0
        }</b>`;
      },
      (error) => {
        console.error('waitForElement erreur');
      }
    );
  }

  processValue(value) {
    if (!value) {
      return;
    }

    if (this.selectRow(value)) {
      return;
    }

    // TODO une seule requete pour les getPageNumber et setPage ??
    this._mData
      .getPageNumber(this.moduleCode(), this.objectCode(), value, this.params)
      .subscribe((res) => {
        // set Page
        this.table.setPage(res.page);
      });
  }

  selectRow(value, fieldName: any = null) {
    //
    if (!value) {
      return;
    }

    this.table.deselectRow();
    if (!fieldName) {
      fieldName = this.pkFieldName();
    }
    const row = this.table.getRows().find((row) => row.getData()[fieldName] == value);

    if (row) {
      this.table.selectRow(row);
    }

    return !!row;
  }

  processConfig() {
    this.drawTable();
  }

  processFilters() {
    this.drawTable();
  }

  onHeightChange(force = false) {
    if (!this.table) {
      return;
    }
    const docHeight = document.body.clientHeight;

    // si la taille du body n'a pas changé on retourne
    if (this.docHeightSave == docHeight && !force) {
      return;
    }

    if (this.docHeightSave > docHeight || !this.docHeightSave) {
      this.table.setHeight('50px');
    }

    this.docHeightSave = docHeight;

    setTimeout(() => {
      const elem = document.getElementById(this._id);
      if (!elem) {
        return;
      }
      this.tableHeight = `${elem.clientHeight}px`;
      this.table.setHeight(this.tableHeight);
    }, 10);
  }

  getData(): Observable<any> {
    return of(true);
  }

  refreshData(objectCode: any): void {
    if (objectCode == this.context.object_code) {
      this.drawTable();
    }
  }
}
