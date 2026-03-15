unit uMouvementsEchecs;

{ Gestion des mouvements de pieces sur le plateau }

interface

uses
uTypesEchecs,
uPlateauEtPieces;

{ Retourne True s'il y a une piece sur la case Pos }
function CaseOccupee(const Plateau : TPlateau; const Pos : TCoordonnee) : Boolean;

{ Renvoie l'indice de la piece situee sur la case Pos 
(0 si la case est vide ) }
function IndexPieceSurCase(const Plateau : TPlateau; const Pos : TCoordonnee) : Integer;

{ Deplace une piece de FromPos vers ToPos :
  - met a jour le plateau (indices)
  - gere une eventuelle prise (EstVivante := False)
  - met a jour la position et le flag ADejaBouge de la piece }

procedure  DeplacerPiece(var Plateau : TPlateau ; var Pieces : TEnsemblePieces; const FromPos, ToPos : Tcoordonnee);

implementation 
function CaseOccupee (const Plateau : TPlateau; const Pos : Tcoordonnee) : Boolean;
begin 
	{ On considere que Pos est deja dans les bornes 1..BOARD_SIZE }
    CaseOccupee := (Plateau[Pos.Ligne, Pos.Colonne] <> 0);
end; 

function IndexPieceSurCase(const Plateau : TPlateau; const Pos : TCoordonnee) : integer;
begin 
	IndexPieceSurCase := Plateau[Pos.Ligne, Pos.Colonne];
end;

procedure  DeplacerPiece(var Plateau : TPlateau ; var Pieces : TEnsemblePieces; const FromPos, ToPos : Tcoordonnee);
var 
  idxFrom, idxTo : Integer;
  pieceFrom: TPiece;
  dx, dy: integer;
  i: integer;
  caseCapture: TCoordonnee;
  colTourOrig, colTourDest, idxTour : integer;  
  { Gestion du roque :
  colTourOrig  = position initiale de la tour
  colTourDest  = nouvelle position de la tour lors du roque
  idxTour      = index de la tour a deplacer }
begin

	{Index de la piece a deplacer}
	idxFrom := Plateau [FromPos.Ligne, FromPos.Colonne];

	{ Rien a faire si case de depart vide }
	if idxFrom = 0 then 
		Exit;
	pieceFrom := Pieces[idxFrom];

    dx := ToPos.Colonne - FromPos.Colonne;
    dy := ToPos.Ligne - FromPos.Ligne;
    {   Gestion eventuelle de la prise en passant     }
    if (pieceFrom.TypePiece = Pion) then
    begin
    { Cas ou le pion se deplace en diagonale sur une case vide :
      ca peut correspondre a une prise en passant }
    if (Plateau[ToPos.Ligne,ToPos.Colonne] = 0) and ((dx=1) or (dx=-1)) then
    begin
    caseCapture := FromPos;                       
	{ En passant :
	le pion capture n'est pas sur la case d'arrivee (ToPos),
	mais sur la case lateralement adjacente : meme ligne,
	et colonne egale a celle vers laquelle le pion se deplace. }
	caseCapture.Colonne := ToPos.Colonne;
    
    idxTo := Plateau[caseCapture.Ligne, caseCapture.Colonne];
    if (idxTo <> 0) and (Pieces[idxTo].TypePiece = Pion) and (Pieces[idxTo].Couleur <> pieceFrom.Couleur) and 
    (Pieces[idxTo].PeutEtrePrisEnPassant) then
    begin 
    { On retire le pion capture en passant }
    Pieces[idxTo].EstVivante := False ;
    Plateau[caseCapture.Ligne, caseCapture.Colonne] := 0; 
    end;
   end;
  end;
   {Prise Classique sur la case d'arrive}
    idxTo := Plateau [ToPos.Ligne, ToPos.Colonne];
	
	{ Gestion de la prise : on marque la piece capturee comme non vivante }
	if idxTo <> 0 then 
		Pieces[idxTo].EstVivante := False;
    {Mise a jour des flags en passant pour tous les pions }
    
    { Par defaut, aucun pion n'est vulnerable a la prise en passant }
    For i := 1 to NB_PIECES do
		if (Pieces[i].EstVivante) and (Pieces[i].TypePiece = Pion) then
	Pieces[i].PeutEtrePrisEnPassant := False;
	
	{ Le pion qui avance de 2 cases devient vulnerable a la prise
    en passant au coup suivant }
    if (pieceFrom.TypePiece = Pion) and ((dy = 2) or (dy = -2)) then
    Pieces[idxFrom].PeutEtrePrisenPassant := True;
     { Gestion du roque : si le roi se deplace de 2 colonnes sur la meme ligne }
  if (pieceFrom.TypePiece = Roi) and (dy = 0) and (Abs(dx) = 2) then
  begin
    if dx = 2 then
    begin
      { Petit roque : le roi va vers la droite, la tour vient de la colonne 8 }
      colTourOrig := BOARD_SIZE;          { 8 }
      colTourDest := ToPos.Colonne - 1;   { 6 }
    end
    else
    begin
      { Grand roque : le roi va vers la gauche, la tour vient de la colonne 1 }
      colTourOrig := 1;                   { 1 }
      colTourDest := ToPos.Colonne + 1;   { 4 }
    end;

    idxTour := Plateau[FromPos.Ligne, colTourOrig];

    if idxTour <> 0 then
    begin
      { Deplacement de la tour sur le plateau }
      Plateau[FromPos.Ligne, colTourOrig] := 0;
      Plateau[FromPos.Ligne, colTourDest] := idxTour;

      { Mise a jour de la tour correspondante }
      { Lors du roque, la tour ne se deplace qu'horizontalement :
  seule la colonne change, la ligne reste identique }
      Pieces[idxTour].Position.Ligne   := FromPos.Ligne;
      Pieces[idxTour].Position.Colonne := colTourDest;
      Pieces[idxTour].ADejaBouge       := True;
    end;
  end;
    
      { Deplacement generale de la piece }
    
	{ mise a jour du plateau :
	- la case de depart est maintenant vide (0)
	- la case d'arrivee contient l'index de la piece deplacee }
    Plateau[FromPos.Ligne, FromPos.Colonne] := 0;
    Plateau[ToPos.Ligne, ToPos.Colonne] := idxFrom;
    { Mise a jour de la piece deplacee :
	- sa position devient la case d'arrivee
	- le drapeau ADejaBouge passe a True (utile pour le pion et le roque) }
	Pieces[idxFrom].Position   := ToPos;
	Pieces[idxFrom].ADejaBouge := True;

    
      {Promotion des pions}
    if (Pieces[idxFrom].TypePiece = Pion) then
    begin
   { Pion blanc atteint la derniere ligne }
    if (Pieces[idxFrom].Couleur = CouleurBlanche) and (Pieces[idxFrom].Position.Ligne = BOARD_SIZE) then
    begin
		Pieces[idxFrom].TypePiece := Dame;
		Pieces[idxFrom].Symbole := 'D';
	end;
     { Pion noir atteint la premiere ligne }
	if (Pieces[idxFrom].Couleur = CouleurNoire) and (Pieces[idxFrom].Position.Ligne = 1) then
	begin
		Pieces[idxFrom].TypePiece := Pion;
		Pieces[idxFrom].Symbole := 'd';
	end;
		
		
end;

end;
end.
		
	










 



