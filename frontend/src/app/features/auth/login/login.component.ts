import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [ReactiveFormsModule, RouterLink],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss'
})
export class LoginComponent {
  private fb = inject(FormBuilder);
  private auth = inject(AuthService);
  private router = inject(Router);

  chargement = signal(false);
  erreur = signal('');

  form = this.fb.nonNullable.group({
    email: ['', [Validators.required, Validators.email]],
    motDePasse: ['', Validators.required]
  });

  submit(): void {
  if (this.form.invalid) return;
  this.chargement.set(true);
  this.erreur.set('');

  const { email, motDePasse } = this.form.getRawValue();
  this.auth.login(email, motDePasse).subscribe({
    next: () => this.router.navigate(['/dashboard']),
    error: () => {
      this.erreur.set('Email ou mot de passe incorrect');
      this.chargement.set(false);
    }
  });
}
}