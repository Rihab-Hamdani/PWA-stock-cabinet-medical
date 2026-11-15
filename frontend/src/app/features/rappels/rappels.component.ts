import { Component, OnInit, inject } from '@angular/core';
import { Router } from '@angular/router';
import { RappelService } from '../../core/services/rappel.service';
import { Rappel } from '../../core/models/models';

@Component({
  selector: 'app-rappels',
  standalone: true,
  templateUrl: './rappels.component.html',
  styleUrl: './rappels.component.scss'
})
export class RappelsComponent implements OnInit {
  service = inject(RappelService);
  private router = inject(Router);

  ngOnInit(): void {
    this.service.rafraichir();
  }

  ouvrir(r: Rappel): void {
    this.router.navigateByUrl(r.lien);
  }

  activer(): void {
    this.service.demanderPermission();
  }
}