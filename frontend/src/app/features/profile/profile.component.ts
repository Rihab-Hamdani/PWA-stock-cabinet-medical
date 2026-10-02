import { Component, inject } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-profile',
  standalone: true,
  templateUrl: './profile.component.html',
  styleUrl: './profile.component.scss'
})
export class ProfileComponent {
  auth = inject(AuthService);
  private router = inject(Router);

  deconnexion(): void {
    this.auth.logout();
    this.router.navigate(['/login']);
  }
}