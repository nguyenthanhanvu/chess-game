unit uPlateauEtPieces;

{ Gestion du plateau (matrice de cases) et des pièces au début de la partie }

interface

uses
  uTypesEchecs;

const
  NB_PIECES = 32;  { 16 blanches + 16 noires }

type
  { Tableau regroupant toutes les pièces du jeu }
  TEnsemblePieces = array[1..NB_PIECES] of TPiece;

{ Met toutes les cases du plateau à 0 (case vide) }
procedure InitialiserPlateau(var Plateau : TPlateau);

{ Crée les 32 pièces, les place sur l'échiquier et remplit le plateau }
procedure InitialiserPieces(var Pieces  : TEnsemblePieces;
                            var Plateau : TPlateau);

{ Met à jour le plateau pour placer l'index d'une pièce sur une case donnée }
procedure PlacerPiece(var Plateau : TPlateau;
                      const Index : integer;
                      const Pos   : TCoordonnee);

{ Affichage simple du plateau }
procedure AfficherPlateau(const Plateau : TPlateau;
                          const Pieces  : TEnsemblePieces);

implementation

{ Petit raccourci pour initialiser une pièce }
Procedure InitPiece(var P : Tpiece; AType : TTypePiece; ACouleur : TCouleur; ALigne : integer; AColone : Integer);
begin
 P.TypePiece := AType;
 P.Couleur := Acouleur;
 P.Position.Ligne := ALigne;
 P.Position.Colonne := AColone;
 P.EstVivante := True;
 P.ADejaBouge := False;


 { Choix d'un symbole simple pour l'affichage console } 
 { Remarque :
  Les symboles Unicode des pieces apparaissent inverses (blanc/noir) 
  dans le terminal de l'ecole. 
  Pour corriger l'affichage, on attribue volontairement le symbole 
  oppose a la couleur logique de la piece. }
case AType of 
Roi : if ACouleur = CouleurBlanche then P.Symbole := '♚'
      else P.Symbole := '♔';
Dame : if ACouleur = CouleurBlanche then P.Symbole := '♛'
       else P.Symbole := '♕';
Tour : if ACouleur = CouleurBlanche then P.Symbole := '♜'
       else P.Symbole := '♖';
Fou : if ACouleur = CouleurBlanche then P.Symbole := '♝'
      else P.Symbole := '♗';
Cavalier : if ACouleur = CouleurBlanche then P.Symbole := '♞'
           else P.Symbole := '♘';
Pion : if ACouleur = CouleurBlanche then P.Symbole := '♟'
       else P.Symbole := '♙';
else 
P.symbole := ' ';
end;

end;

{ Met toutes les cases du plateau à 0 (case vide) }
procedure InitialiserPlateau(var Plateau : TPlateau);
var
  i, j : integer;
begin
  for i := 1 to BOARD_SIZE do
    for j := 1 to BOARD_SIZE do
      Plateau[i, j] := 0;
end;

{ Met à jour le plateau pour placer l'index d'une pièce sur une case donnée }
procedure PlacerPiece(var Plateau : TPlateau;
                      const Index : integer;
                      const Pos   : TCoordonnee);
begin
  Plateau[Pos.Ligne, Pos.Colonne] := Index;
end;

{ Crée les 32 pièces, les place sur l'échiquier et remplit le plateau }
procedure InitialiserPieces(var Pieces  : TEnsemblePieces;
                            var Plateau : TPlateau);
var
  i : integer;
begin
  InitialiserPlateau(Plateau);

  { Rangée des pièces blanches (ligne 1) }
  InitPiece(Pieces[1],  Tour,     CouleurBlanche, 1, 1);
  PlacerPiece(Plateau, 1, Pieces[1].Position);

  InitPiece(Pieces[2],  Cavalier, CouleurBlanche, 1, 2);
  PlacerPiece(Plateau, 2, Pieces[2].Position);

  InitPiece(Pieces[3],  Fou,      CouleurBlanche, 1, 3);
  PlacerPiece(Plateau, 3, Pieces[3].Position);

  InitPiece(Pieces[4],  Dame,     CouleurBlanche, 1, 4);
  PlacerPiece(Plateau, 4, Pieces[4].Position);

  InitPiece(Pieces[5],  Roi,      CouleurBlanche, 1, 5);
  PlacerPiece(Plateau, 5, Pieces[5].Position);

  InitPiece(Pieces[6],  Fou,      CouleurBlanche, 1, 6);
  PlacerPiece(Plateau, 6, Pieces[6].Position);

  InitPiece(Pieces[7],  Cavalier, CouleurBlanche, 1, 7);
  PlacerPiece(Plateau, 7, Pieces[7].Position);

  InitPiece(Pieces[8],  Tour,     CouleurBlanche, 1, 8);
  PlacerPiece(Plateau, 8, Pieces[8].Position);

  { Pions blancs (ligne 2) }
  for i := 1 to 8 do
  begin
    InitPiece(Pieces[8 + i], Pion, CouleurBlanche, 2, i);
    PlacerPiece(Plateau, 8 + i, Pieces[8 + i].Position);
  end;

  { Rangée des pièces noires (ligne 8) }
  InitPiece(Pieces[17], Tour,     CouleurNoire, 8, 1);
  PlacerPiece(Plateau, 17, Pieces[17].Position);

  InitPiece(Pieces[18], Cavalier, CouleurNoire, 8, 2);
  PlacerPiece(Plateau, 18, Pieces[18].Position);

  InitPiece(Pieces[19], Fou,      CouleurNoire, 8, 3);
  PlacerPiece(Plateau, 19, Pieces[19].Position);

  InitPiece(Pieces[20], Dame,     CouleurNoire, 8, 4);
  PlacerPiece(Plateau, 20, Pieces[20].Position);

  InitPiece(Pieces[21], Roi,      CouleurNoire, 8, 5);
  PlacerPiece(Plateau, 21, Pieces[21].Position);

  InitPiece(Pieces[22], Fou,      CouleurNoire, 8, 6);
  PlacerPiece(Plateau, 22, Pieces[22].Position);

  InitPiece(Pieces[23], Cavalier, CouleurNoire, 8, 7);
  PlacerPiece(Plateau, 23, Pieces[23].Position);

  InitPiece(Pieces[24], Tour,     CouleurNoire, 8, 8);
  PlacerPiece(Plateau, 24, Pieces[24].Position);

  { Pions noirs (ligne 7) }
  for i := 1 to 8 do
  begin
    InitPiece(Pieces[24 + i], Pion, CouleurNoire, 7, i);
    PlacerPiece(Plateau, 24 + i, Pieces[24 + i].Position);
  end;
end;

{ Affichage simple du plateau }
procedure AfficherPlateau(const Plateau : TPlateau;
                          const Pieces  : TEnsemblePieces);
var
  ligne, col : integer;
  idx        : integer;
begin
  Write('   ');
  for col := 1 to BOARD_SIZE do
    Write(' ', col, ' ');
  Writeln;

  for ligne := BOARD_SIZE downto 1 do
  begin
    Write(ligne:2, ' ');
    for col := 1 to BOARD_SIZE do
    begin
      idx := Plateau[ligne, col];
      if idx = 0 then
        Write(' . ')
      else
        Write(' ', Pieces[idx].Symbole, ' ');
    end;
    Writeln;
  end;
end;

end.
