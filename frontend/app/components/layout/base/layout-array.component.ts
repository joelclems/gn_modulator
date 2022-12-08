import { Component, OnInit, Injector } from '@angular/core';
import { ModulesFormService } from '../../../services/form.service';

import { ModulesLayoutComponent } from './layout.component';

import utils from '../../../utils';

@Component({
  selector: 'modules-layout-array',
  templateUrl: 'layout-array.component.html',
  styleUrls: ['../../base/base.scss', 'layout-array.component.scss'],
})
export class ModulesLayoutArrayComponent extends ModulesLayoutComponent implements OnInit {
  /** options pour les elements du array */

  // arrayOptions: Array<any>;

  constructor(private _formService: ModulesFormService, _injector: Injector) {
    super(_injector);
    this._name = 'layout-array';
    this.bPostComputeLayout = true;
  }

  arrayElemContext(index) {
    const data_keys = utils.copy(this.context.data_keys);
    data_keys.push(this.layout.key);
    data_keys.push(index);
    const arrayElemContext = {
      form_group: this.context.form_group,
      data_keys,
    };
    for (const key of Object.keys(this.context).filter(
      (key) => !['form_group', 'data_keys'].includes(key)
    )) {
      arrayElemContext[key] = this.context[key];
    }

    return arrayElemContext;
  }

  processAction(action) {
    if (action.type == 'remove-array-element') {
      this.data[this.layout.key].splice(action.index, 1);
      this._formService.setControl({
        context: this.context,
        data: this.data,
        layout: this.computedLayout,
      });
      this._mLayout.reComputeLayout('');
    } else {
      this.emitAction(action);
    }
  }

  addArrayElement() {
    this.data[this.layout.key].push({});
    this._formService.setControl({
      context: this.context,
      data: this.data,
      layout: this.computedLayout,
    });
    // pour forcer le check de la validation ??
    this._mLayout.reComputeLayout('');
  }
}
