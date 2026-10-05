import { Component, inject, OnInit, OnDestroy, signal } from '@angular/core';
import { RouterOutlet, RouterLink, RouterLinkActive } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { UserService } from '../../../core/services/user.service';

@Component({
  selector: 'app-shell',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  templateUrl: './shell.component.html',
  styleUrl: './shell.component.scss'
})
export class ShellComponent implements OnInit, OnDestroy {
  auth = inject(AuthService);
  private userService = inject(UserService);

  comptesEnAttente = signal(0);
  private timer: ReturnType<typeof setInterval> | null = null;

  ngOnInit(): void {
    if (this.auth.isMedecin()) {
      this.chargerComptesEnAttente();
      this.timer = setInterval(() => this.chargerComptesEnAttente(), 60000);
    }
  }

  ngOnDestroy(): void {
    if (this.timer) clearInterval(this.timer);
  }

  chargerComptesEnAttente(): void {
    this.userService.countPending().subscribe({
      next: (n) => this.comptesEnAttente.set(n),
      error: () => {}
    });
  }
}