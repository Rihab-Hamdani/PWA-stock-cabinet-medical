import { Injectable, computed, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { NotificationsDto, RdvNotification, StockNotification } from '../models/models';

export interface Toast {
  id: string;
  titre: string;
  texte: string;
  lien: string;
  type: 'rdv' | 'rupture' | 'stock';
}

/**
 * Interroge le backend toutes les minutes et prévient l'utilisateur :
 *  - rendez-vous « en attente » qui commencent dans les X prochaines minutes (45 par défaut) ;
 *  - articles en rupture ou sous leur seuil d'alerte.
 * Chaque événement n'est signalé qu'une seule fois (mémorisé dans le navigateur),
 * via une notification système si elle est autorisée, et un bandeau dans l'application.
 */
@Injectable({ providedIn: 'root' })
export class NotificationService {
  private http = inject(HttpClient);

  private readonly DEJA_VUS_KEY = 'stock_notifs_vues';
  private readonly INTERVALLE_MS = 60_000;

  readonly stock = signal<StockNotification[]>([]);
  readonly rdv = signal<RdvNotification[]>([]);
  readonly rappelMinutes = signal(45);
  readonly toasts = signal<Toast[]>([]);
  readonly total = computed(() => this.stock().length + this.rdv().length);
  readonly permission = signal<NotificationPermission | 'unsupported'>(
    typeof Notification === 'undefined' ? 'unsupported' : Notification.permission
  );

  private timer: ReturnType<typeof setInterval> | null = null;

  start(): void {
    if (this.timer) return;
    this.refresh();
    this.timer = setInterval(() => this.refresh(), this.INTERVALLE_MS);
  }

  stop(): void {
    if (this.timer) clearInterval(this.timer);
    this.timer = null;
    this.stock.set([]);
    this.rdv.set([]);
    this.toasts.set([]);
  }

  refresh(): void {
    this.http.get<NotificationsDto>(`${environment.api}/notifications`).subscribe({
      next: (n) => {
        this.rappelMinutes.set(n.rappelMinutes);
        this.stock.set(n.stock);
        this.rdv.set(n.rdv);
        this.signalerNouveautes(n);
      },
      error: () => {}
    });
  }

  async demanderPermission(): Promise<void> {
    if (typeof Notification === 'undefined') return;
    const resultat = await Notification.requestPermission();
    this.permission.set(resultat);
  }

  fermerToast(id: string): void {
    this.toasts.update((t) => t.filter((x) => x.id !== id));
  }

  private signalerNouveautes(n: NotificationsDto): void {
    const vus = this.chargerVus();
    const nouveaux: Toast[] = [];

    for (const r of n.rdv) {
      const id = `rdv:${r.patientId}:${r.date}:${r.heure}`;
      if (vus.has(id)) continue;
      const examen = r.examen ? ` — ${r.examen}` : '';
      nouveaux.push({
        id,
        type: 'rdv',
        titre: `Rendez-vous à ${r.heure.slice(0, 5)}`,
        texte: `${r.prenom} ${r.nom}${examen} (dans ${r.minutesRestantes} min)`,
        lien: '/agenda'
      });
    }

    for (const s of n.stock) {
      // Une clé par « niveau » : on re-prévient si un article en stock bas passe en rupture.
      const id = `stock:${s.produitId}:${s.rupture ? 'rupture' : 'bas'}`;
      if (vus.has(id)) continue;
      nouveaux.push({
        id,
        type: s.rupture ? 'rupture' : 'stock',
        titre: s.rupture ? `Rupture : ${s.nom}` : `Stock bas : ${s.nom}`,
        texte: s.rupture
          ? 'Plus aucune unité en stock.'
          : `Reste ${s.quantite} ${s.unite} (seuil ${s.seuil}).`,
        lien: `/produits/${s.produitId}`
      });
    }

    // Un article revenu au-dessus du seuil doit pouvoir être re-signalé plus tard.
    const actifs = new Set([
      ...n.rdv.map((r) => `rdv:${r.patientId}:${r.date}:${r.heure}`),
      ...n.stock.map((s) => `stock:${s.produitId}:${s.rupture ? 'rupture' : 'bas'}`)
    ]);
    for (const id of [...vus]) {
      if (id.startsWith('stock:') && !actifs.has(id)) vus.delete(id);
    }

    if (nouveaux.length === 0) {
      this.sauverVus(vus);
      return;
    }

    nouveaux.forEach((t) => vus.add(t.id));
    this.sauverVus(vus);

    // Les RDV d'abord, puis le stock ; on évite d'inonder l'écran.
    this.toasts.update((t) => [...nouveaux, ...t].slice(0, 4));
    nouveaux.forEach((t) => this.notificationSysteme(t));
  }

  private async notificationSysteme(t: Toast): Promise<void> {
    if (typeof Notification === 'undefined' || Notification.permission !== 'granted') return;
    const options: NotificationOptions & { data?: unknown } = {
      body: t.texte,
      icon: 'icons/icon-192x192.png',
      badge: 'icons/icon-72x72.png',
      tag: t.id,
      // Lu par le service worker Angular : ouvre l'app sur la bonne page au clic.
      data: { onActionClick: { default: { operation: 'navigateLastFocusedOrOpen', url: t.lien } } }
    };
    try {
      const reg = await navigator.serviceWorker?.getRegistration();
      if (reg) {
        await reg.showNotification(t.titre, options);
        return;
      }
      new Notification(t.titre, options);
    } catch {
      // Notifications système indisponibles : le bandeau dans l'app suffit.
    }
  }

  private chargerVus(): Set<string> {
    try {
      const brut = localStorage.getItem(this.DEJA_VUS_KEY);
      return new Set(brut ? (JSON.parse(brut) as string[]) : []);
    } catch {
      return new Set();
    }
  }

  private sauverVus(vus: Set<string>): void {
    try {
      // On ne garde que les 300 dernières clés.
      localStorage.setItem(this.DEJA_VUS_KEY, JSON.stringify([...vus].slice(-300)));
    } catch {
      /* stockage indisponible */
    }
  }
}
