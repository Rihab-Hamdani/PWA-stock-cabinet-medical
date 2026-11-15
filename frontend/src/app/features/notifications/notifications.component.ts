import { Component, OnInit, inject } from '@angular/core';
import { Location } from '@angular/common';
import { RouterLink } from '@angular/router';
import { NotificationService } from '../../core/services/notification.service';

@Component({
  selector: 'app-notifications',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './notifications.component.html',
  styleUrl: './notifications.component.scss'
})
export class NotificationsComponent implements OnInit {
  notifs = inject(NotificationService);
  private location = inject(Location);

  ngOnInit(): void {
    this.notifs.refresh();
  }

  retour(): void {
    this.location.back();
  }

  activer(): void {
    this.notifs.demanderPermission();
  }
}
