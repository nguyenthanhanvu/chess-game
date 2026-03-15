unit uGestionPartie;

{ Gestion du deroulement d'une partie complete }

interface

uses
  uTypesEchecs,
  uPlateauEtPieces,
  Crt,
  uIHMConsole,
  uMouvementsEchecs,
  uReglesDeplacement,
  uEchecEtMat,
  uSauvegardeEchecs;

{ Lance une nouvelle partie (plateau initialise) }
procedure JouerNouvellePartie;

{ Reprend une partie a partir d'un fichier de sauvegarde.
  Si le fichier est introuvable ou invalide, un message sera affiche. }
procedure JouerPartieDepuisFichier(const NomFichier : string);

implementation



procedure ChangerJoueur(var Joueur : TCouleur);
begin
  if Joueur = CouleurBlanche then
    Joueur := CouleurNoire
  else
    Joueur := CouleurBlanche;
end;


{ Boucle principale d'une partie, a partir d'un etat deja initialise }
procedure BouclePartie(var Plateau : TPlateau;
                       var Pieces : TEnsemblePieces;
                       var JoueurCourant : TCouleur);
var
  finPartie : boolean;
  depart, arrivee: TCoordonnee;
  PlateauTmp : TPlateau;
  PiecesTmp : TEnsemblePieces;
  idxDepart : integer;
  ok : boolean;
  touche : char;
begin
  finPartie := False;

  repeat
    AfficherTitre;
    AfficherEchiquierConsole(Plateau, Pieces);

    { Verification mat / pat avant le tour }
    if JoueurMat(Plateau, Pieces, JoueurCourant) then
    begin
      Writeln;
      if JoueurCourant = CouleurBlanche then
        Writeln('Echec et mat : les blancs sont mates. Les noirs gagnent.')
      else
        Writeln('Echec et mat : les noirs sont mates. Les blancs gagnent.');
      finPartie := True;
    end
    else if JoueurPat(Plateau, Pieces, JoueurCourant) then
    begin
      Writeln;
      Writeln('Pat : partie nulle, aucun coup legal disponible.');
      finPartie := True;
    end;

    if finPartie then
    begin
      Writeln;
      Writeln('Appuyez sur Entree pour revenir au menu.');
      repeat
        touche := ReadKey;
      until touche = #13;  
      Exit;
    end;


    {Selection de la piece a deplacer }

    ok := False;
    repeat
      DemanderCaseAvecCurseur('Selectionnez la piece a deplacer : ',
                               depart, Plateau, Pieces);

      idxDepart := IndexPieceSurCase(Plateau, depart);

      if idxDepart = 0 then
        AfficherMessageErreur('Aucune piece sur cette case.')
      else if Pieces[idxDepart].Couleur <> JoueurCourant then
        AfficherMessageErreur('Cette piece n''appartient pas au joueur courant.')
      else
        ok := True;
    until ok;

    {Selection de la case d'arrivee}

    DemanderCaseAvecCurseur('Selectionnez la case d''arrivee : ',
                             arrivee, Plateau, Pieces);

    {Verification du deplacement}

    if not DeplacementValide(Plateau, Pieces, depart, arrivee) then
    begin
      AfficherMessageErreur('Deplacement non valide pour cette piece.');
      Writeln('Appuyez sur Entree pour continuer...');
      Readln;
      Continue;
    end;

    { Simulation pour verifier que le coup ne laisse pas le joueur en echec }
    PlateauTmp := Plateau;
    PiecesTmp  := Pieces;
    DeplacerPiece(PlateauTmp, PiecesTmp, depart, arrivee);

    if JoueurEnEchec(PlateauTmp, PiecesTmp, JoueurCourant) then
    begin
      AfficherMessageErreur('Ce coup laisse votre roi en echec.');
      Writeln('Appuyez sur Entree pour continuer...');
      Readln;
      Continue;
    end;

    {Coup valide : on l'applique vraiment}

    Plateau := PlateauTmp;
    Pieces  := PiecesTmp;

    { Autosauvegarde apres chaque coup }
    SauvegarderPartie('sauvegarde.dat', Plateau, Pieces, JoueurCourant);

    { Changement de joueur }
    ChangerJoueur(JoueurCourant);

  until finPartie;
end;

procedure JouerNouvellePartie;
var
  Plateau       : TPlateau;
  Pieces        : TEnsemblePieces;
  JoueurCourant : TCouleur;
begin
  InitialiserPieces(Pieces, Plateau);
  JoueurCourant := CouleurBlanche;

  { On autosauvegarde tout de suite l'etat initial }
  SauvegarderPartie('sauvegarde.dat', Plateau, Pieces, JoueurCourant);

  BouclePartie(Plateau, Pieces, JoueurCourant);
end;

{ Procédure : JouerPartieDepuisFichier
  Rôle : Charger une partie depuis un fichier de sauvegarde.
  Si le chargement échoue, l’utilisateur doit appuyer
  sur la touche ENTREE pour revenir au menu.
  Entrée: NomFichier ensuite nom du fichier à charger.
  Sortie : Aucune.}
procedure JouerPartieDepuisFichier(const NomFichier : string);
var
  Plateau       : TPlateau;
  Pieces        : TEnsemblePieces;
  JoueurCourant : TCouleur;
  ok            : boolean;
  touche        : char;   { Sert à lire une touche du clavier }
begin
  { On tente de charger la sauvegarde }
  ChargerPartie(NomFichier, Plateau, Pieces, JoueurCourant, ok);

  { Si le chargement échoue }
  if not ok then
  begin
    AfficherTitre;
    AfficherMessageErreur('Impossible de charger la sauvegarde : ' + NomFichier);
    Writeln('Appuyez sur ENTREE pour revenir au menu.');

    {On utilise ReadKey pour lire immédiatement une touche du clavier.
La touche ENTREE correspond au code ASCII #13.
On boucle tant que l’utilisateur n’a pas appuyé sur ENTREE.}
    repeat
      touche := ReadKey;         { Lecture d’une touche }
    until touche = #13;          { #13 = touche ENTREE }

    Exit;                        { Retour au menu principal }
  end;

  { Si le chargement est réussi, on lance la boucle de jeu }
  BouclePartie(Plateau, Pieces, JoueurCourant);
end;


end.



