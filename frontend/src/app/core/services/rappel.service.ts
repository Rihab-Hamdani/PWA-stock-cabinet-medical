import { Injectable, computed, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { Rappel } from '../models/models';

const CLE_VUS = 'stock_rappels_vus';

export interface Annonce {
  titre: string;
  message: string;
  lien: string;
}

@Injectable({ providedIn: 'root' })
export class RappelService {
  private http = inject(HttpClient);

  readonly rappels = signal<Rappel[]>([]);
  readonly annonce = signal<Annonce | null>(null);
  readonly total = computed(() => this.rappels().length);

  readonly disponible = typeof Notification !== 'undefined' && window.isSecureContext;
  readonly permission = signal<string>(typeof Notification === 'undefined' ? 'indisponible' : Notification.permission);

  private vus = this.lireVus();
  private timer: ReturnType<typeof setInterval> | null = null;
  private minuteurAnnonce: ReturnType<typeof setTimeout> | null = null;

  demarrer(): void {
    if (this.timer) return;
    this.rafraichir();
    this.timer = setInterval(() => this.rafraichir(), 30000);
  }

  arreter(): void {
    if (this.timer) clearInterval(this.timer);
    this.timer = null;
    this.rappels.set([]);
    this.annonce.set(null);
  }

  rafraichir(): void {
    this.http.get<Rappel[]>(`${environment.api}/rappels`).subscribe({
      next: (liste) => {
        this.rappels.set(liste);

        // On oublie les alertes disparues : si un article retombe sous le seuil plus tard, on prévient de nouveau
        const ids = new Set(liste.map((r) => r.id));
        this.vus = new Set([...this.vus].filter((id) => ids.has(id)));

        const nouveaux = liste.filter((r) => !this.vus.has(r.id));
        nouveaux.forEach((r) => this.vus.add(r.id));
        this.ecrireVus();

        if (nouveaux.length > 0) this.annoncer(nouveaux);
      },
      error: () => {}
    });
  }

  fermerAnnonce(): void {
    this.annonce.set(null);
  }

  async demanderPermission(): Promise<void> {
    if (typeof Notification === 'undefined') return;
    const resultat = await Notification.requestPermission();
    this.permission.set(resultat);
  }

  private annoncer(nouveaux: Rappel[]): void {
    const un = nouveaux.length === 1;
    const titre = un ? nouveaux[0].titre : `${nouveaux.length} nouvelles alertes`;
    const message = un ? nouveaux[0].message : nouveaux.map((r) => r.titre).join(' · ');
    const lien = un ? nouveaux[0].lien : '/rappels';

    this.annonce.set({ titre, message, lien });
    if (this.minuteurAnnonce) clearTimeout(this.minuteurAnnonce);
    this.minuteurAnnonce = setTimeout(() => this.annonce.set(null), 10000);

    if ('vibrate' in navigator) navigator.vibrate(200);
    this.notifierSysteme(titre, message);
  }

  private notifierSysteme(titre: string, message: string): void {
    try {
      if (typeof Notification === 'undefined' || Notification.permission !== 'granted') return;
      if ('serviceWorker' in navigator) {
        navigator.serviceWorker.getRegistration().then((reg) => {
          try {
            if (reg) reg.showNotification(titre, { body: message });
            else new Notification(titre, { body: message });
          } catch { /* certains navigateurs mobiles refusent le constructeur */ }
        });
      } else {
        new Notification(titre, { body: message });
      }
    } catch { /* l'annonce dans l'application reste visible */ }
  }

  private lireVus(): Set<string> {
    try {
      return new Set<string>(JSON.parse(localStorage.getItem(CLE_VUS) ?? '[]'));
    } catch {
      return new Set<string>();
    }
  }

  private ecrireVus(): void {
    try {
      localStorage.setItem(CLE_VUS, JSON.stringify([...this.vus]));
    } catch { /* stockage indisponible */ }
  }
}