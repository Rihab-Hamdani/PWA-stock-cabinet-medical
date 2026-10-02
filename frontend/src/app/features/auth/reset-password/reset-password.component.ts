import { Component, OnInit, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators, AbstractControl, ValidationErrors } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';

function motsDePasseIdentiquesValidator(group: AbstractControl): ValidationErrors | null {
  const mdp = group.get('nouveauMotDePasse')?.value;
  const confirmation = group.get('confirmation')?.value;
  return mdp === confirmation ? null : { mismatch: true };
}

@Component({
  selector: 'app-reset-password',
  standalone: true,
  imports: [ReactiveFormsModule, RouterLink],
  templateUrl: './reset-password.component.html',
  styleUrl: './reset-password.component.scss'
})
export class ResetPasswordComponent implements OnInit {
  private fb = inject(FormBuilder);
  private auth = inject(AuthService);
  private route = inject(ActivatedRoute);
  private router = inject(Router);

  token = signal('');
  chargement = signal(false);
  erreur = signal('');
  succes = signal(false);

  form = this.fb.nonNullable.group({
    nouveauMotDePasse: ['', [Validators.required, Validators.minLength(6)]],
    confirmation: ['', Validators.required]
  }, { validators: motsDePasseIdentiquesValidator });

  ngOnInit(): void {
    this.token.set(this.route.snapshot.queryParamMap.get('token') ?? '');
  }

  submit(): void {
    if (this.form.invalid || !this.token()) return;
    this.chargement.set(true);
    this.erreur.set('');

    this.auth.resetPassword(this.token(), this.form.getRawValue().nouveauMotDePasse).subscribe({
      next: () => {
        this.chargement.set(false);
        this.succes.set(true);
        setTimeout(() => this.router.navigate(['/login']), 2000);
      },
      error: () => {
        this.chargement.set(false);
        this.erreur.set('Lien invalide ou expiré. Refaites une demande.');
      }
    });
  }
}