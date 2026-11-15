import { Injectable, inject, signal } from '@angular/core';
import { UserService } from './user.service';

@Injectable({ providedIn: 'root' })
export class PendingCountService {
  private userService = inject(UserService);
  readonly count = signal(0);

  refresh(): void {
    this.userService.countPending().subscribe({
      next: (n) => this.count.set(n),
      error: () => {}
    });
  }
}