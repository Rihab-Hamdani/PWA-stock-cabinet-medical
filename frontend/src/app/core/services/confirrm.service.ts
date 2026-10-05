import { Injectable, signal } from '@angular/core';

export interface ConfirmOptions {
  titre: string;
  message: string;
  texteConfirmer?: string;
  texteAnnuler?: string;
  danger?: boolean;
}

@Injectable({ providedIn: 'root' })
export class ConfirmService {
  readonly ouvert = signal(false);
  readonly options = signal<ConfirmOptions>({ titre: '', message: '' });
  private resolver: ((valeur: boolean) => void) | null = null;

  ask(options: ConfirmOptions): Promise<boolean> {
    this.options.set(options);
    this.ouvert.set(true);
    return new Promise<boolean>((resolve) => {
      this.resolver = resolve;
    });
  }

  repondre(valeur: boolean): void {
    this.ouvert.set(false);
    this.resolver?.(valeur);
    this.resolver = null;
  }
}