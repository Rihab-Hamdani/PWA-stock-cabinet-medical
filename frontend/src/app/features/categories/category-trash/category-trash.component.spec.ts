import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CategoryTrashComponent } from './category-trash.component';

describe('CategoryTrashComponent', () => {
  let component: CategoryTrashComponent;
  let fixture: ComponentFixture<CategoryTrashComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CategoryTrashComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(CategoryTrashComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
