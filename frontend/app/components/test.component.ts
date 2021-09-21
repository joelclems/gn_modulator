import { Component, OnInit, Input, SimpleChanges } from "@angular/core";
import { ActivatedRoute, Router, ParamMap } from "@angular/router";
import { ModulesConfigService } from "../services/config.service";
import { mergeMap, concatMap } from "@librairies/rxjs/operators";
import { Observable, of, forkJoin } from "@librairies/rxjs";

@Component({
  selector: "modules-test",
  templateUrl: "test.component.html",
  styleUrls: ["test.component.scss"],
})
export class TestComponent implements OnInit {

  componentInitialized = false;

  // route parameters
  moduleCode = null;
  schemaName = null;
  value = null;

  schemaConfig = null;


  constructor(
    private _route: ActivatedRoute,
    private _mConfig: ModulesConfigService,    
  ) {}

  ngOnInit() {
    this.process();
  }

  process() {
    this._route.paramMap
    .pipe(
      mergeMap((params) => {
        this.moduleCode = params.get('moduleCode');
        this.schemaName = params.get('schemaName');
        this.value = params.get('value');
        return this._mConfig.loadConfig(this.moduleCode, this.schemaName)
      }),
      mergeMap((schemaConfig) => {
        this.schemaConfig = schemaConfig; 
        return of(true)
      }),
    ).subscribe(() => {
      this.componentInitialized = true;
    });
  }

}
