import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [ReactiveFormsModule, RouterLink],
  templateUrl: './register.component.html',
  styleUrl: './register.component.scss'
})
export class RegisterComponent {
  private fb = inject(FormBuilder);
  private auth = inject(AuthService);
  private router = inject(Router);

  chargement = signal(false);
  erreur = signal('');
  succes = signal(false);

  form = this.fb.nonNullable.group({
    nom: ['', Validators.required],
    prenom: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]],
    motDePasse: ['', [Validators.required, Validators.minLength(6)]]
  });

  submit(): void {
    if (this.form.invalid) return;
    this.chargement.set(true);
    this.erreur.set('');

    const { nom, prenom, email, motDePasse } = this.form.getRawValue();
    this.auth.register(nom, prenom, email, motDePasse).subscribe({
      next: () => {
        this.chargement.set(false);
        this.succes.set(true);
      },
      error: (err) => {
        this.chargement.set(false);
        this.erreur.set(
          err?.status === 409
            ? 'Un compte existe déjà avec cet email.'
            : 'Inscription impossible. Réessayez.'
        );
      }
    });
  }
}