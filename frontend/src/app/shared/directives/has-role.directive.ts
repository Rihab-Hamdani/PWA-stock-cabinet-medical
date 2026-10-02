import { Directive, effect, inject, input, TemplateRef, ViewContainerRef } from '@angular/core';
import { AuthService } from '../../core/services/auth.service';
import { Role } from '../../core/models/models';

/**
 * Affiche l'élément uniquement si l'utilisateur a l'un des rôles donnés.
 * Usage : <button *appHasRole="'MEDECIN'">Supprimer</button>
 *         <div *appHasRole="['MEDECIN','SECRETAIRE']">…</div>
 */
@Directive({
  selector: '[appHasRole]',
  standalone: true
})
export class HasRoleDirective {
  private tpl = inject(TemplateRef<unknown>);
  private vcr = inject(ViewContainerRef);
  private auth = inject(AuthService);

  private allowed: Role[] = [];
  private shown = false;

  readonly appHasRole = input.required<Role | Role[]>();

  constructor() {
    effect(() => {
      const value = this.appHasRole();
      this.allowed = Array.isArray(value) ? value : [value];
      // dépend du user courant (signal) → se recalcule à la connexion/déconnexion
      const ok = this.auth.hasRole(...this.allowed);
      this.render(ok);
    });
  }

  private render(ok: boolean): void {
    if (ok && !this.shown) {
      this.vcr.createEmbeddedView(this.tpl);
      this.shown = true;
    } else if (!ok && this.shown) {
      this.vcr.clear();
      this.shown = false;
    }
  }
}