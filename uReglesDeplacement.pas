unit uReglesDeplacement;
{Ce module verifie si un deplacement est legal pour une piece donnee.
  Il ne modifie pas le plateau : il ne fait qu'analyser la validite.}

interface

uses
  uTypesEchecs,
  uPlateauEtPieces,
  uMouvementsEchecs; 

{ Renvoie True si le deplacement de FromPos vers ToPos est autorise
  pour la piece situee sur FromPos. }
  function DeplacementValide(const Plateau : TPlateau; const Pieces  : TEnsemblePieces; const FromPos, ToPos : TCoordonnee) : boolean;
implementation

{ Vérifie que la trajectoire entre deux cases est libre (hors case finale).
  Utilisee pour Tour, Fou, Dame. }
function TrajectoireLibre(const Plateau : TPlateau; const FromPos, ToPos : TCoordonnee) : boolean;
var 
	dL,dC: integer;   { delta ligne / delta colonne }
	stepL, stepC : integer;  { direction normalisee (+1, 0, -1) }
	cur : TCoordonnee; { position courante sur la trajectoire }
begin 
	TrajectoireLibre := False;
	dL := ToPos.Ligne - FromPos.Ligne;
	dC := ToPos.Colonne - FromPos.Colonne;
	if (dL = 0 ) and (dC = 0 ) then Exit; 
	
	if dL = 0 then stepL := 0 else stepL := dL div Abs(dL); { normalise le mouvement vertical en +1 ou -1 }
	if dC = 0 then stepC := 0 else stepC := dC div Abs(dC); { normalise le mouvement horizontale en +1 ou -1 }
	
	cur := FromPos;
	Repeat
		cur.Ligne := cur.Ligne + stepL; { avance d'une case sur la ligne }
		cur.Colonne := cur.Colonne + stepC; { avance d'une case sur la colonne } 
	  { Atteint la case finale -> OK }
		if (cur.Ligne = ToPos.Ligne) and (cur.Colonne = ToPos.Colonne) then
		begin 
			TrajectoireLibre := True;
			Exit;
	    end;
	    
	   { Une piece bloque la trajectoire }
	   if CaseOccupee(Plateau, cur) then 
		Exit;
	until False; {boucle volontairement infinie : la sortie ne depend pas de la condition, 
                 mais des EXIT dans le corps (arrivee ou obstacle). }
end;
    
    {Deplacements specifiques aux pieces }

function DeplacementTour (const Plateau : TPlateau; const FromPos, ToPos : Tcoordonnee) : boolean;
begin
     { la tour se deplace uniquement en ligne ou en colonne }
	if (FromPos.Ligne = ToPos.Ligne) or (FromPos.Colonne = ToPos.Colonne) then
	DeplacementTour := TrajectoireLibre(Plateau, FromPos, ToPos) { verifie qu'aucune piece ne bloque }
	else 
	DeplacementTour := False;
end;

function DeplacementFou(const Plateau : TPlateau; const FromPos, ToPos : Tcoordonnee) : boolean;
begin
 { deplacement en diagonale : |dL| = |dC| }
	if Abs(ToPos.Ligne - FromPos.Ligne) = Abs(ToPos.Colonne - FromPos.Colonne) then
		DeplacementFou := TrajectoireLibre(Plateau, FromPos, ToPos)
	else 
		DeplacementFou := False;
end;

function DeplacementDame(const Plateau : TPlateau; const FromPos, ToPos :Tcoordonnee) : boolean;
begin
	{ la dame combine les mouvements de la tour (ligne/colonne)
  et du fou (diagonales) }
    DeplacementDame := DeplacementTour(Plateau, FromPos, ToPos) or DeplacementFou(Plateau, FromPos, ToPos);
end;

function DeplacementCavalier(const FromPos, ToPos : TCoordonnee) : boolean;
var
  dL, dC : integer;
begin
  dL := Abs(ToPos.Ligne   - FromPos.Ligne);
  dC := Abs(ToPos.Colonne - FromPos.Colonne);
{ le cavalier se deplace toujours en 'L' :
  combinaison de 2 cases dans une direction et 1 case dans l'autre }
  DeplacementCavalier := ((dL = 2) and (dC = 1)) or ((dL = 1) and (dC = 2));
end;

function DeplacementRoi(const FromPos, ToPos : TCoordonnee) : boolean;
begin
  { le roi ne peut se deplacer que d'une case autour de sa position,
  horizontalement, verticalement ou diagonalement.}
  DeplacementRoi :=(Abs(ToPos.Ligne   - FromPos.Ligne) <= 1) and
  (Abs(ToPos.Colonne - FromPos.Colonne) <= 1) and
  not ((ToPos.Ligne = FromPos.Ligne) and
  (ToPos.Colonne = FromPos.Colonne));
end;

function DeplacementRoiRoque(const Plateau : TPlateau;
                             const Pieces  : TEnsemblePieces;
                             const idxRoi  : integer;
                             const FromPos, ToPos : TCoordonnee) : boolean;
var
  pieceRoi, pieceTour : TPiece; { pieces impliquees dans le roque : roi + tour }
  dx : integer; { deplacement horizontal du roi (±2 en cas de roque) }
  colTourOrig : integer; { colonne initiale de la tour impliquée }
  colDebut    : integer; { premiere colonne parcourue par le roi lors du roque }
  colFin      : integer;  { derniere colonne (destination) du roi en roque }
  c           : integer;  { colonne courante utilisee pour verifier le passage }
  caseInter   : TCoordonnee; { case intermediaire que traverse le roi }
  idxTour     : integer; { index de la tour impliquée dans le roque }
begin
  DeplacementRoiRoque := False;

  pieceRoi := Pieces[idxRoi];          { recuperation de la piece roi }


  { Doit etre un roi vivant qui n'a jamais bouge }
  if (pieceRoi.TypePiece <> Roi) or (not pieceRoi.EstVivante) or (pieceRoi.ADejaBouge) then
    Exit;

  { Deplacement horizontal sur la meme ligne }
  if FromPos.Ligne <> ToPos.Ligne then
    Exit;

  dx := ToPos.Colonne - FromPos.Colonne;

  { Le roi doit se deplacer de 2 cases vers la gauche ou vers la droite }
  if dx = 2 then
    colTourOrig := BOARD_SIZE       { Petit roque : tour de la colonne 8 }
  else if dx = -2 then
    colTourOrig := 1                { Grand roque : tour de la colonne 1 }
  else
    Exit;

  { La case d'arrivee du roi doit etre vide (le roque ne capture pas) }
  if Plateau[ToPos.Ligne, ToPos.Colonne] <> 0 then
    Exit;

  { verification de la presence de la tour :
  la case (ligne du roi, colonne d'origine de la tour) doit contenir la tour
  correspondante ; sinon le roque n'est pas possible }
  idxTour := Plateau[FromPos.Ligne, colTourOrig];
  if idxTour = 0 then
    Exit;

  pieceTour := Pieces[idxTour];

  if (pieceTour.TypePiece <> Tour) or
     (pieceTour.Couleur <> pieceRoi.Couleur) or
     (not pieceTour.EstVivante) or
     (pieceTour.ADejaBouge) then
    Exit;

  { On verifie qu'aucune piece n'est situee entre le roi et la tour.
  Le roque se fait sur la meme ligne, donc seule la colonne change. }
  caseInter.Ligne := FromPos.Ligne;

	if colTourOrig = BOARD_SIZE then
	begin
		{ Petit roque :
		- le roi part de sa colonne et se dirige vers la tour situee en fin de rangée
		- on doit verifier toutes les cases entre les deux pieces }
		colDebut := FromPos.Colonne + 1;   { case immediatement a droite du roi }
		colFin   := colTourOrig - 1;    { case juste avant la tour }

	end
	else
	begin
	{ Grand roque :
    - la tour se trouve a gauche du roi (petites colonnes)
    - le roi se deplace vers les colonnes decroissantes
    On doit verifier toutes les cases situees entre la tour et le roi :
      colDebut = premiere case a droite de la tour
      colFin   = case juste avant celle du roi }
	colDebut := colTourOrig + 1;        { colonne suivant la tour }
	colFin   := FromPos.Colonne - 1;    { colonne precedent la position du roi }
end;


    { parcours des cases situees entre le roi et la tour :
	chaque case doit etre vide pour autoriser le roque }
	for c := colDebut to colFin do
	begin
		caseInter.Colonne := c;  { case actuelle a verifier }
	{ si une piece occupe cette case, le chemin n'est pas libre :
	le roque est invalide }
		if Plateau[caseInter.Ligne, caseInter.Colonne] <> 0 then
			Exit;
	end;


  { Si on arrive ici, les conditions de roque "geometriques" sont remplies }
  DeplacementRoiRoque := True;
end;


function DeplacementPion(const Plateau : TPlateau;
                         const Pieces  : TEnsemblePieces;
                         const idxPion : integer;
                         const FromPos, ToPos : TCoordonnee) : boolean;
var
  dx, dy : integer; { ecart horizontal et vertical }
  dir : integer; { sens de deplacement du pion : +1 (blanc) ou -1 (noir) }
  caseInter, caseCapt : TCoordonnee; { case intermediaire / case du pion pris en passant }
  idxCible : integer; { index eventuel d'une piece cible }

begin
  DeplacementPion := False;
   { differences de position }

  dx := ToPos.Colonne - FromPos.Colonne;
  dy := ToPos.Ligne   - FromPos.Ligne;
   { direction du pion selon sa couleur }
  if Pieces[idxPion].Couleur = CouleurBlanche then
    dir := 1
  else
    dir := -1;
  { Avance simple d'une case vers l'avant, sans prise }
  if (dx = 0) and (dy = dir) then
  begin
    { la case d'arrivee doit etre vide }
    if not CaseOccupee(Plateau, ToPos) then
      DeplacementPion := True;
    Exit;
  end;

  { Avance de deux cases depuis la rangée de depart }
  if (dx = 0) and (dy = 2 * dir) then
  begin
    { impossible si le pion a deja bouge une fois }
    if Pieces[idxPion].ADejaBouge then Exit;

    { la case intermediaire doit etre vide }
    caseInter := FromPos;
    caseInter.Ligne := FromPos.Ligne + dir;

    if CaseOccupee(Plateau, caseInter) then Exit;
    { la case d'arrivee doit aussi etre vide }
    if CaseOccupee(Plateau, ToPos) then Exit;

    DeplacementPion := True;
    Exit;
  end;

  { Prise en diagonale (classique ou en passant) }
  if (dy = dir) and ((dx = 1) or (dx = -1)) then
  begin
    { Cas 1 : prise classique sur une piece adverse }
    if CaseOccupee(Plateau, ToPos) then
    begin
      DeplacementPion := True;
      Exit;
    end;
	{ Cas 2 : prise en passant -> la case d'arrivee est vide, 
	mais un pion adverse peut etre capture lateralement }
	caseCapt := FromPos;                        { meme ligne que le pion jouant }
	caseCapt.Colonne := ToPos.Colonne;         { colonne du pion adverse potentiellement pris }

	idxCible := Plateau[caseCapt.Ligne, caseCapt.Colonne];

	{ Conditions d'une prise en passant :
	- une piece est presente lateralement (idxCible <> 0)
	- c'est un pion
	- de couleur opposee
	- et marque comme "PeutEtrePrisEnPassant" suite a un double pas precedant }
	if (idxCible <> 0) and
   (Pieces[idxCible].TypePiece = Pion) and
   (Pieces[idxCible].Couleur <> Pieces[idxPion].Couleur) and
   (Pieces[idxCible].PeutEtrePrisEnPassant) then
	begin
		{ toutes les conditions sont reunies : la prise en passant est valide }
		DeplacementPion := True;
		Exit;
	end;
  end;
end;

   {Deplacement Global (piece quelconque)}

function DeplacementValide(const Plateau : TPlateau;
                           const Pieces  : TEnsemblePieces;
                           const FromPos, ToPos : TCoordonnee) : boolean;
var
  idxFrom, idxTo : integer;  { indices eventuels sur le plateau }
  pieceFrom      : TPiece;   { piece a deplacer }
begin
  DeplacementValide := False;

  { aucune piece sur la case de depart -> mouvement impossible }
  idxFrom := Plateau[FromPos.Ligne, FromPos.Colonne];
  if idxFrom = 0 then Exit;

  pieceFrom := Pieces[idxFrom];

  { Interdiction de prendre une piece de meme couleur }
  idxTo := Plateau[ToPos.Ligne, ToPos.Colonne];
  if (idxTo <> 0) and
     (Pieces[idxTo].Couleur = pieceFrom.Couleur) then
    Exit;

  { Delegation aux regles specifiques de chaque type de piece }
  case pieceFrom.TypePiece of
    Tour     : DeplacementValide := DeplacementTour(Plateau, FromPos, ToPos);
    Fou      : DeplacementValide := DeplacementFou(Plateau, FromPos, ToPos);
    Dame     : DeplacementValide := DeplacementDame(Plateau, FromPos, ToPos);
    Cavalier : DeplacementValide := DeplacementCavalier(FromPos, ToPos);
    Roi      :
      begin
        { Deplacement normal du roi OU roque }
        if DeplacementRoi(FromPos, ToPos) then
          DeplacementValide := True
        else
          DeplacementValide :=
            DeplacementRoiRoque(Plateau, Pieces, idxFrom, FromPos, ToPos);
      end;

    Pion     : DeplacementValide :=
                  DeplacementPion(Plateau, Pieces, idxFrom, FromPos, ToPos);
  else
    DeplacementValide := False;
  end;
end;

end.

  

		
		
	
	
 
	
	
	
	
		
		
    
    
	
	
	
	
	


