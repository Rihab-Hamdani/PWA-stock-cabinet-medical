import { Component, inject } from '@angular/core';
import { ConfirmService } from '../../../core/services/confirrm.service';

@Component({
  selector: 'app-confirm-dialog',
  standalone: true,
  templateUrl: './confirm-dialog.component.html',
  styleUrl: './confirm-dialog.component.scss'
})
export class ConfirmDialogComponent {
  confirm = inject(ConfirmService);
}