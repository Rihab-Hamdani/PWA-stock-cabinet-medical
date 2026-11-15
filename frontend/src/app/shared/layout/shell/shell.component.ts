import { Component, inject, OnInit, OnDestroy } from '@angular/core';
import { Router, RouterOutlet, RouterLink, RouterLinkActive } from '@angular/router';
import { AuthService } from "../../../core/services/auth.service";
import { PendingCountService } from '../../../core/services/pending-number.service';
import { RappelService } from '../../../core/services/rappel.service';

@Component({
  selector: 'app-shell',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  templateUrl: './shell.component.html',
  styleUrl: './shell.component.scss'
})
export class ShellComponent implements OnInit, OnDestroy {
  auth = inject(AuthService);
  private pending = inject(PendingCountService);
  private router = inject(Router);
  private rappelService = inject(RappelService);

  comptesEnAttente = this.pending.count;
  annonce = this.rappelService.annonce;
  private timer: ReturnType<typeof setInterval> | null = null;

  ngOnInit(): void {
    this.rappelService.demarrer();
    if (this.auth.isMedecin()) {
      this.pending.refresh();
      this.timer = setInterval(() => this.pending.refresh(), 30000);
    }
  }

  ngOnDestroy(): void {
    this.rappelService.arreter();
    if (this.timer) clearInterval(this.timer);
  }

  ouvrirAnnonce(): void {
    const a = this.annonce();
    this.rappelService.fermerAnnonce();
    if (a) this.router.navigateByUrl(a.lien);
  }

  fermerAnnonce(): void {
    this.rappelService.fermerAnnonce();
  }
}