import { Injectable, Injector } from '@angular/core';
import { ModulesDataService } from './data.service';
import { ModulesFormService } from './form.service';
import { ModulesConfigService } from './config.service';
import utils from '../utils';
@Injectable()
export class ModulesObjectService {
  _mData: ModulesDataService;
  _mConfig: ModulesConfigService;
  // _mLayout: ModulesLayoutService;

  constructor(private _injector: Injector) {
    this._mData = this._injector.get(ModulesDataService);
    this._mConfig = this._injector.get(ModulesConfigService);
    // this._mLayout = this._injector.get(ModulesLayoutService);
  }

  processFormLayout(moduleCode, objectCode) {
    const objectConfig = this._mConfig.objectConfig(moduleCode, objectCode);
    const moduleConfig = this._mConfig.moduleConfig(moduleCode);
    const schemaLayout = objectConfig.form.layout;
    const geometryType = this._mConfig.geometryType(moduleCode, objectCode);
    const geometryFieldName = this._mConfig.geometryFieldName(moduleCode, objectCode);
    return {
      type: 'form',
      appearance: 'fill',
      direction: 'row',
      items: [
        {
          type: 'map',
          key: geometryFieldName,
          edit: true,
          geometry_type: geometryType,
          gps: true,
          hidden: !geometryFieldName,
          flex: geometryFieldName ? '1' : '0',
          zoom: 12,
        },
        {
          items: [
            // {
            //   "type": "message",
            //   "json": "__f__data",
            //   'flex': '0'
            // },
            // {
            //   "type": "message",
            //   "json": "__f__formGroup.value",
            //   'flex': '0'
            // },
            {
              type: 'breadcrumbs',
              flex: '0',
            },
            {
              title: [
                '__f__{',
                `  const id = data.${objectConfig.utils.pk_field_name};`,
                '  return id',
                '    ? `Modification ' +
                  objectConfig.display.du_label +
                  ' ${data.' +
                  objectConfig.utils.label_field_name +
                  '}`',
                `    : "Création ${objectConfig.display.d_un_nouveau_label}";`,
                '}',
              ],
              flex: '0',
            },
            {
              flex: '0',
              type: 'message',
              html: `__f__"Veuillez saisir une geometrie sur la carte"`,
              class: 'error',
              hidden: `__f__${!objectConfig.utils.geometry_field_name} || data.${
                objectConfig.utils.geometry_field_name
              }?.coordinates`,
            },
            {
              items: schemaLayout,
              overflow: true,
            },
            {
              flex: '0',
              direction: 'row',
              items: [
                {
                  flex: '0',
                  type: 'button',
                  color: 'primary',
                  title: 'Valider',
                  icon: 'done',
                  description: 'Enregistrer le contenu du formulaire',
                  action: 'submit',
                  disabled: '__f__!(formGroup.valid )',
                },
                {
                  flex: '0',
                  type: 'button',
                  color: 'primary',
                  title: 'Annuler',
                  icon: 'refresh',
                  description: "Annuler l'édition",
                  action: 'cancel',
                },
                {
                  // comment le mettre à gauche
                  flex: '0',
                  type: 'button',
                  color: 'warn',
                  title: 'Supprimer',
                  icon: 'delete',
                  description: 'Supprimer le passage à faune',
                  action: {
                    type: 'modal',
                    modal_name: 'delete',
                  },

                  hidden: `__f__data.ownership > ${moduleConfig.cruved['D']} || !data.${objectConfig.utils.pk_field_name}`,
                },
                this.modalDeleteLayout(objectConfig),
              ],
            },
          ],
        },
      ],
    };
  }

  modalDeleteLayout(objectConfig, modalName: any = null) {
    return {
      type: 'modal',
      modal_name: modalName || 'delete',
      title: `Confirmer la suppression de l'élément`,
      direction: 'row',
      items: [
        {
          type: 'button',
          title: 'Suppression',
          action: 'delete',
          icon: 'delete',
          color: 'warn',
        },
        {
          type: 'button',
          title: 'Annuler',
          action: 'close',
          icon: 'refresh',
          color: 'primary',
        },
      ],
    };
  }

  processPropertiesLayout(moduleCode, objectCode) {
    const objectConfig = this._mConfig.objectConfig(moduleCode, objectCode);
    const moduleConfig = this._mConfig.moduleConfig(moduleCode);
    return {
      // direction: "row",
      items: [
        // {
        //   type: "map",
        //   key: objectConfig.utils.geometry_field_name,
        //   hidden: !objectConfig.utils.geometry_field_name
        // },
        // {
        //   items: [
        {
          title: `__f__"Propriétés ${objectConfig.display.du_label} " + data.${objectConfig.utils.label_field_name}`,
          flex: '0',
        },
        {
          items: objectConfig.details.layout,
          overflow: true,
        },
        {
          type: 'button',
          color: 'primary',
          title: 'Éditer',
          description: `Editer ${objectConfig.display.le_label}`,
          action: 'edit',
          hidden: `__f__data.ownership > ${moduleConfig.cruved['U']}`,
          flex: '0',
        },
      ],
      // },
      // ],
    };
  }

  onSubmit(moduleCode, objectCode, data, layout) {
    if (!data) {
      return;
    }

    const fields = this.getFields(moduleCode, objectCode, layout);

    const processedData = utils.processData(data, layout);

    const id = this._mConfig.objectId(moduleCode, objectCode, data);

    const request = id
      ? this._mData.patch(moduleCode, objectCode, id, processedData, {
          fields,
        })
      : this._mData.post(moduleCode, objectCode, processedData, {
          fields,
        });

    return request;
  }

  onDelete(moduleCode, objectCode, data) {
    return this._mData.delete(
      moduleCode,
      objectCode,
      this._mConfig.objectId(moduleCode, objectCode, data)
    );
  }

  getFields(moduleCode, objectCode, layout) {
    const fields = utils.getLayoutFields(layout);

    if (
      this._mConfig.geometryFieldName(moduleCode, objectCode) &&
      this._mConfig.geometryFieldName(moduleCode, objectCode)
    ) {
      fields.push(this._mConfig.geometryFieldName(moduleCode, objectCode));
    }

    if (!fields.includes(this._mConfig.pkFieldName(moduleCode, objectCode))) {
      fields.push(this._mConfig.pkFieldName(moduleCode, objectCode));
    }

    return fields;
  }
}