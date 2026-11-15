export type Role = 'MEDECIN' | 'SECRETAIRE';

export interface CategoryTrash {
  id: string;
  nom: string;
  deletedAt: string;
}

export type StatutRdv = 'PLANIFIE' | 'EN_CONSULTATION' | 'TERMINE' | 'ANNULE';

export const STATUTS_RDV: { valeur: StatutRdv; libelle: string }[] = [
  { valeur: 'PLANIFIE', libelle: 'En attente' },
  { valeur: 'EN_CONSULTATION', libelle: 'Chez la docteure' },
  { valeur: 'TERMINE', libelle: 'Terminé' },
  { valeur: 'ANNULE', libelle: 'Annulé' }
];

export interface StockNotification {
  produitId: string;
  nom: string;
  unite: string;
  quantite: number;
  seuil: number;
  rupture: boolean;
}

export interface RdvNotification {
  patientId: string;
  prenom: string;
  nom: string;
  examen: string | null;
  date: string;
  heure: string;
  minutesRestantes: number;
}

export interface NotificationsDto {
  rappelMinutes: number;
  stock: StockNotification[];
  rdv: RdvNotification[];
}

export interface PatientDto {
  id: string;
  prenom: string;
  nom: string;
  telephone?: string;
  examenDemande?: string;
  dateRdv?: string;
  heureRdv?: string;
  statut: StatutRdv;
  paye: boolean;
}

export interface PatientDetail {
  id: string;
  email?: string;
  prenom: string;
  nom: string;
  dateNaissance?: string;
  sexe?: string;
  telephone?: string;
  adresse?: string;
  examenDemande?: string;
  medecinTraitant?: string;
  clinique?: string;
  dateRdv?: string;
  heureRdv?: string;
  statut: StatutRdv;
  paye: boolean;
  assurance?: string;
  montantPaye?: number;
  remarques?: string;
}

export interface PatientRequest {
  email?: string | null;
  prenom: string;
  nom: string;
  dateNaissance?: string | null;
  sexe?: string | null;
  telephone?: string | null;
  adresse?: string | null;
  examenDemande?: string | null;
  medecinTraitant?: string | null;
  clinique?: string | null;
  dateRdv?: string | null;
  heureRdv?: string | null;
  statut?: StatutRdv;
  paye?: boolean;
  assurance?: string | null;
  montantPaye?: number | null;
  remarques?: string | null;
}

export interface Dashboard {
  produitsEnRupture: number;
  produitsSousLeSeuil: number;
  mouvementsAujourdHui: number;
  depensesStockDuJour: number | null;
  recettesPatientsDuJour: number | null;
  alertes: Product[];
  patientsEnAttentePaiement: PatientDto[];
  rdvDuJour: PatientDto[];
}

export interface User {
  id: string;
  nom: string;
  prenom: string;
  email: string;
  telephone?: string;
  role: Role;
  actif: boolean;
}

export interface MovementHistorique {
  id: string;
  type: MovementType;
  quantite: number;
  dateMouvement: string;
  heureMouvement: string;
  prixUnitaireHt?: number;
  prixTotalHt?: number;
  prixTotalTtc?: number;
  fournisseurNom?: string;
  numeroFacture?: string;
  motif?: string;
  utilisateurNom: string;
}


export interface LoginResponse {
  token: string;
  user: User;
}

export interface Category {
  id: string;
  nom: string;
}

export interface Supplier {
  id: string;
  nom: string;
  telephone?: string;
  email?: string;
  actif: boolean;
}

export interface Product {
  id: string;
  nom: string;
  categorieId: string;
  categorieNom: string;
  unite: string;
  quantiteActuelle: number;
  seuilAlerte: number;
  prixUnitaireHt: number;
  datePeremption?: string;
  numeroLot?: string;
  enRupture: boolean;
}

export type MovementType = 'ENTREE' | 'SORTIE';

export interface Movement {
  id: string;
  produitId: string;
  produitNom: string;
  type: MovementType;
  quantite: number;
  dateMouvement: string;
  heureMouvement: string;
  prixUnitaireHt?: number;
  tva?: number;
  prixUnitaireTtc?: number;
  prixTotalHt?: number;
  prixTotalTtc?: number;
  fournisseurId?: string;
  numeroFacture?: string;
  motif?: string;
  utilisateurNom: string;
}

export type AlertStatus = 'ACTIVE' | 'COMMANDEE' | 'RESOLUE';

export interface Alert {
  id: string;
  produitId: string;
  produitNom: string;
  statut: AlertStatus;
  quantiteActuelle: number;
  seuil: number;
  dateCreation: string;
  dateCommande?: string;
  commandeParNom?: string;
}

export type TypeRappel = 'RDV_PROCHE' | 'STOCK_RUPTURE' | 'STOCK_BAS';

export interface Rappel {
  id: string;
  type: TypeRappel;
  titre: string;
  message: string;
  lien: string;
}