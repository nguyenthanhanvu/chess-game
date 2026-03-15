unit uTypesEchecs;

{ Unit contenant les types communs du projet Echecs }

interface

const
  BOARD_SIZE = 8;  { Echiquier classique : 8 x 8 cases }

type
  { Couleur d'une pièce / d'un joueur }
  TCouleur = (CouleurBlanche, CouleurNoire, AucuneCouleur);

  { Type de pièce présente (ou non) sur l'échiquier }
  TTypePiece = (AucunePiece, Roi, Dame, Tour, Fou, Cavalier, Pion);

  { Coordonnées d'une case : ligne (1..8) et colonne (1..8) }
  TCoordonnee = record
    Ligne   : 1..BOARD_SIZE;
    Colonne : 1..BOARD_SIZE;
  end;

  { Description d'une pièce d'échecs }
  TPiece = record
    TypePiece  : TTypePiece;   { Roi, Dame, Tour, ... }
    Couleur    : TCouleur;     { Blanche / Noire }
    Position   : TCoordonnee;  { Sa case actuelle }
    Symbole    : string;    { Caractère utilisé à l'affichage }
    EstVivante : boolean;      { False si la pièce a été capturée }
    ADejaBouge : boolean;      { Utile pour le roque, la prise en passant, ... }
    PeutEtrePrisEnPassant : boolean;
  end;

  { Plateau logique :
      0  = case vide
      n>0 = index d'une pièce dans un tableau de pièces }
  TPlateau = array[1..BOARD_SIZE, 1..BOARD_SIZE] of integer;

implementation

end.
  
