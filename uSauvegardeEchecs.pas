unit uSauvegardeEchecs;

{ Sauvegarde et chargement d'une partie d'echecs dans un fichier }

interface

uses
  uTypesEchecs,
  uPlateauEtPieces;

type
  { Etat complet d'une partie a un instant donne }
  TEtatPartie = record
    Plateau : TPlateau;
    Pieces : TEnsemblePieces;
    JoueurCourant : TCouleur;
  end;

{ Sauvegarde la partie dans le fichier NomFichier.
  Le fichier est cree (ecrase s'il existe deja). }
procedure SauvegarderPartie(const NomFichier : string;
                            const Plateau : TPlateau;
                            const Pieces : TEnsemblePieces;
                            const JoueurCourant : TCouleur);

{ Charge la partie depuis le fichier NomFichier.
  - Ok = True si le chargement a reussi
  - Plateau, Pieces et JoueurCourant sont remplis en consequence. }
procedure ChargerPartie(const NomFichier : string;
                        var Plateau : TPlateau;
                        var Pieces  : TEnsemblePieces;
                        var JoueurCourant : TCouleur;
                        var Ok  : boolean);

implementation

procedure SauvegarderPartie(const NomFichier : string;
                            const Plateau : TPlateau;
                            const Pieces : TEnsemblePieces;
                            const JoueurCourant : TCouleur);
var
  f : file of TEtatPartie;{ fichier binaire contenant un enregistrement TEtatPartie }
  etat : TEtatPartie; { structure regroupant tout l'état courant de la partie }
begin
  { On remplit la structure avec l'état actuel du jeu }
  etat.Plateau := Plateau; { position des pieces sur l'echiquier }
  etat.Pieces := Pieces; { liste complete des pieces (positions, ...) }
  etat.JoueurCourant := JoueurCourant;{ couleur du joueur dont c'est le tour }

  Assign(f, NomFichier);{ association du fichier logique au nom fourni }
  Rewrite(f);{ ouverture du fichier en écriture binaire (efface l'ancien contenu) }
  Write(f, etat);{ écriture d'un seul enregistrement contenant tout l'état de la partie }
  Close(f);{ fermeture du fichier pour garantir la sauvegarde }
end;


procedure ChargerPartie(const NomFichier : string;
                        var Plateau : TPlateau;
                        var Pieces : TEnsemblePieces;
                        var JoueurCourant : TCouleur;
                        var Ok : boolean);
var
  f : file of TEtatPartie; { fichier binaire contenant un enregistrement TEtatPartie }
  etat : TEtatPartie; { structure temporaire pour lire les données du fichier }
  code : integer; { code d'erreur potentiel lors de l'ouverture du fichier }
begin
  Ok := False;  { on supposera le chargement rate tant qu'il n'est pas valide }

  Assign(f, NomFichier);{ lien entre le fichier logique et le nom fourni }
  Reset(f); { ouverture du fichier en lecture binaire }
  code := IOResult; { vérification de succès ou d’échec de l'ouverture }

  if code <> 0 then
    Exit;  { fichier introuvable ou inaccessible donc on sort sans modifier l'état du jeu }

  { Lecture de l'enregistrement unique contenant tout l'état de la partie }
  Read(f, etat);
  Close(f);

  { Mise à jour des structures du programme avec les valeurs chargées }
  Plateau := etat.Plateau; { reconstruction du plateau }
  Pieces  := etat.Pieces;  { restauration de l'ensemble des pieces }
  JoueurCourant := etat.JoueurCourant;{ indication du joueur dont c'était le tour }

  Ok := True; { chargement réussi }
end;

end.


