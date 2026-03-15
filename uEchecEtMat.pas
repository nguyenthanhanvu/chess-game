unit uEchecEtMat;

{ Analyse de la position : echec, echec et mat, pat }

interface

uses
  uTypesEchecs,
  uPlateauEtPieces,
  uMouvementsEchecs,
  uReglesDeplacement;

{ Renvoie True si le joueur de couleur Joueur est en echec
  dans la position donnee par Plateau / Pieces. }
function JoueurEnEchec(const Plateau : TPlateau;
                       const Pieces  : TEnsemblePieces;
                       const Joueur  : TCouleur) : boolean;

{ Renvoie True si le joueur est en echec ET n'a aucun coup legal
  pour sortir de cette situation -> echec et mat. }
function JoueurMat(const Plateau : TPlateau;
                   const Pieces  : TEnsemblePieces;
                   const Joueur  : TCouleur) : boolean;

{ Renvoie True si le joueur n'est pas en echec mais n'a aucun coup legal
  -> situation de pat (nulle). }
function JoueurPat(const Plateau : TPlateau;
                   const Pieces  : TEnsemblePieces;
                   const Joueur  : TCouleur) : boolean;

implementation

{Fonctions internes}

function TrouverRoi(const Pieces : TEnsemblePieces;
                    const Joueur : TCouleur;
                    var PosRoi   : TCoordonnee) : boolean;
var
  i : integer;
begin
  TrouverRoi := False;

  { on parcourt l'ensemble des pieces pour identifier le roi
    appartenant au joueur (couleur) et encore en jeu }
  for i := 1 to NB_PIECES do
  begin
    if (Pieces[i].EstVivante) and          { la piece n'est pas capturee }
       (Pieces[i].Couleur = Joueur) and    { correspond au joueur courant }
       (Pieces[i].TypePiece = Roi) then    { et il s'agit bien du roi }
    begin
      PosRoi := Pieces[i].Position;        { on renvoie sa position }
      TrouverRoi := True;                  { roi trouve }
      Exit;                                { la recherche peut s'arreter ici }
    end;
  end;
end;


function JoueurEnEchec(const Plateau : TPlateau;
                       const Pieces  : TEnsemblePieces;
                       const Joueur  : TCouleur) : boolean;
var
  posRoi : TCoordonnee;
  i : integer;
  posAtt : TCoordonnee;
begin
  JoueurEnEchec := False;

  { On cherche la position du roi du joueur }
  if not TrouverRoi(Pieces, Joueur, posRoi) then
    Exit;   { Roi introuvable -> on considere qu'il n'est pas en echec }

  { On parcourt toutes les pieces adverses vivantes }
  for i := 1 to NB_PIECES do
  begin
    if (Pieces[i].EstVivante) and
       (Pieces[i].Couleur <> Joueur) then
    begin
      posAtt := Pieces[i].Position;

      { Si une piece adverse peut se deplacer sur la case du roi,
        alors le roi est en echec. }
      if DeplacementValide(Plateau, Pieces, posAtt, posRoi) then
      begin
        JoueurEnEchec := True;
        Exit;
      end;
   end;
  end;
end;

function AucunCoupLegal(const Plateau : TPlateau;
                        const Pieces  : TEnsemblePieces;
                        const Joueur  : TCouleur) : boolean;
var
  i, l, c : integer;                 { indices pour parcourir les pieces et les cases }
  fromPos, toPos : TCoordonnee;      { position de depart et d'arrivee d'un coup teste }
  PlateauTmp : TPlateau;             { copie du plateau pour simuler un coup }
  PiecesTmp  : TEnsemblePieces;      { copie de la liste des pieces pour la simulation }

begin
  { On suppose ici que la position initiale est valide.
    L'objectif est de verifier s'il existe AU MOINS un coup legal
    qui laisse le roi du joueur hors d'echec. }

  AucunCoupLegal := True;

	for i := 1 to NB_PIECES do
	begin
	{ on ne considere que les pieces vivantes du joueur courant }
	if (Pieces[i].EstVivante) and (Pieces[i].Couleur = Joueur) then
	begin
		fromPos := Pieces[i].Position;   { position de depart de la piece }

		{ On teste toutes les cases de destination possibles sur l'echiquier }
		for l := 1 to BOARD_SIZE do
			for c := 1 to BOARD_SIZE do
			begin
				toPos.Ligne   := l;
				toPos.Colonne := c;

			{ on ignore le "coup" qui ne deplace pas la piece }
			if (fromPos.Ligne = toPos.Ligne) and
			(fromPos.Colonne = toPos.Colonne) then
				Continue;

			{ verification des regles de mouvement propres a la piece }
			if DeplacementValide(Plateau, Pieces, fromPos, toPos) then
			begin
				{ on simule le coup sur une copie du plateau et des pieces }
				PlateauTmp := Plateau;
				PiecesTmp  := Pieces;
				DeplacerPiece(PlateauTmp, PiecesTmp, fromPos, toPos);

            { si la simulation montre que le joueur n'est plus en echec,
            alors il existe au moins un coup legal pour ce joueur }
			if not JoueurEnEchec(PlateauTmp, PiecesTmp, Joueur) then
			begin
				AucunCoupLegal := False;   { il existe un coup legal }
				Exit;                      { inutile de continuer }
			end;
        end;
      end;
  end;
end;

end;

function JoueurMat(const Plateau : TPlateau;
                   const Pieces  : TEnsemblePieces;
                   const Joueur  : TCouleur) : boolean;
begin
  { Echec et mat = en echec ET aucun coup legal disponible }
  if JoueurEnEchec(Plateau, Pieces, Joueur) then
    JoueurMat := AucunCoupLegal(Plateau, Pieces, Joueur)
  else
    JoueurMat := False;
end;

function JoueurPat(const Plateau : TPlateau;
                   const Pieces  : TEnsemblePieces;
                   const Joueur  : TCouleur) : boolean;
begin
  { Pat = pas en echec ET aucun coup legal }
  if JoueurEnEchec(Plateau, Pieces, Joueur) then
    JoueurPat := False
  else
    JoueurPat := AucunCoupLegal(Plateau, Pieces, Joueur);
end;

end.

