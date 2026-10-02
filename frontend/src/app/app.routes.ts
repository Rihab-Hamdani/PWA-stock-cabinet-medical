import { Routes } from '@angular/router';
import { authGuard, medecinGuard } from './core/guards/auth.guard';
import { ShellComponent } from './shared/layout/shell/shell.component';

export const routes: Routes = [
  {
    path: 'login',
    loadComponent: () =>
      import('./features/auth/login/login.component').then((m) => m.LoginComponent)
  },
  {
    path: 'register',
    loadComponent: () =>
      import('./features/auth/register/register.component').then((m) => m.RegisterComponent)
  },
  {
    path: 'mot-de-passe-oublie',
    loadComponent: () =>
      import('./features/auth/forgot-password/forgot-password.component').then((m) => m.ForgotPasswordComponent)
  },
  {
    path: 'reinitialiser-mot-de-passe',
    loadComponent: () =>
      import('./features/auth/reset-password/reset-password.component').then((m) => m.ResetPasswordComponent)
  },
  {
    path: '',
    canActivate: [authGuard],
    component: ShellComponent,
    children: [
      {
        path: 'dashboard',
        loadComponent: () =>
          import('./features/dashboard/dashboard.component').then((m) => m.DashboardComponent)
      },
      {
        path: 'categories',
        loadComponent: () =>
          import('./features/categories/category-list/category-list.component').then((m) => m.CategoryListComponent)
      },
      {
        path: 'produits/nouveau',
        loadComponent: () =>
          import('./features/products/product-form/product-form.component').then((m) => m.ProductFormComponent)
      },
      {
        path: 'produits/:id',
        loadComponent: () =>
          import('./features/products/product-detail/product-detail.component').then((m) => m.ProductDetailComponent)
      },
      {
        path: 'produits/:id/modifier',
        loadComponent: () =>
          import('./features/products/product-form/product-form.component').then((m) => m.ProductFormComponent)
      },
      {
        path: 'patients',
        loadComponent: () =>
          import('./features/patients/patient-list/patient-list.component').then((m) => m.PatientListComponent)
      },
      {
        path: 'patients/nouveau',
        loadComponent: () =>
          import('./features/patients/patient-form/patient-form.component').then((m) => m.PatientFormComponent)
      },
      {
        path: 'comptes-en-attente',
        canActivate: [medecinGuard],
        loadComponent: () =>
          import('./features/admin/pending-accounts/pending-accounts.component').then((m) => m.PendingAccountsComponent)
      },
      {
        path: 'profil',
        loadComponent: () =>
          import('./features/profile/profile.component').then((m) => m.ProfileComponent)
      },
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' }
    ]
  },
  { path: '**', redirectTo: 'dashboard' }
];