import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-forgot-password',
  standalone: true,
  imports: [ReactiveFormsModule, RouterLink],
  templateUrl: './forgot-password.component.html',
  styleUrl: './forgot-password.component.scss'
})
export class ForgotPasswordComponent {
  private fb = inject(FormBuilder);
  private auth = inject(AuthService);

  chargement = signal(false);
  envoye = signal(false);

  form = this.fb.nonNullable.group({
    email: ['', [Validators.required, Validators.email]]
  });

  submit(): void {
    if (this.form.invalid) return;
    this.chargement.set(true);

    this.auth.forgotPassword(this.form.getRawValue().email).subscribe({
      next: () => {
        this.chargement.set(false);
        this.envoye.set(true);
      },
      error: () => {
        this.chargement.set(false);
        this.envoye.set(true); // même message qu'en cas de succès, pour ne jamais révéler si l'email existe
      }
    });
  }
}