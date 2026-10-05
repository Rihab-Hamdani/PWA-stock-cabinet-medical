export type Role = 'MEDECIN' | 'SECRETAIRE';

export interface CategoryTrash {
  id: string;
  nom: string;
  deletedAt: string;
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
  assurance?: string;
  montantPaye?: number;
  remarques?: string;
}

export interface Dashboard {
  produitsEnRupture: number;
  produitsSousLeSeuil: number;
  mouvementsAujourdHui: number;
  montantDuJour: number | null;
  montantPerdu: number | null;
  valeurDuStock: number | null;
  alertes: Product[];
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

export interface PatientDto {
  id: string;
  prenom: string;
  nom: string;
  telephone?: string;
  examenDemande?: string;
  dateRdv?: string;
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
  assurance?: string | null;
  montantPaye?: number | null;
  remarques?: string | null;
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