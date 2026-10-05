import { Component, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { AuthService } from '../../core/services/auth.service';
import { UserService } from '../../core/services/user.service';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [ReactiveFormsModule],
  templateUrl: './profile.component.html',
  styleUrl: './profile.component.scss'
})
export class ProfileComponent {
  auth = inject(AuthService);
  private userService = inject(UserService);
  private router = inject(Router);
  private fb = inject(FormBuilder);

  modeEdition = signal(false);
  enregistrement = signal(false);
  erreur = signal('');

  form = this.fb.nonNullable.group({
    prenom: ['', Validators.required],
    nom: ['', Validators.required],
    telephone: ['']
  });

  ouvrirEdition(): void {
    const u = this.auth.user();
    if (!u) return;
    this.form.patchValue({ prenom: u.prenom, nom: u.nom, telephone: u.telephone || '' });
    this.erreur.set('');
    this.modeEdition.set(true);
  }

  annulerEdition(): void {
    this.modeEdition.set(false);
  }

  enregistrer(): void {
    if (this.form.invalid) return;
    this.enregistrement.set(true);
    this.erreur.set('');

    this.userService.updateMyProfile(this.form.getRawValue()).subscribe({
      next: (user) => {
        this.auth.updateLocalUser(user);
        this.enregistrement.set(false);
        this.modeEdition.set(false);
      },
      error: () => {
        this.enregistrement.set(false);
        this.erreur.set('Impossible de mettre à jour le profil.');
      }
    });
  }

  deconnexion(): void {
    this.auth.logout();
    this.router.navigate(['/login']);
  }
}