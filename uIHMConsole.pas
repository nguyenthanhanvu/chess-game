unit uIHMConsole;

{ Interface console du jeu d'echecs :
  - affichage du titre et du menu
  - affichage de l'echiquier
  - saisie des cases (clavier ou fleches) }

interface

uses
  uTypesEchecs,
  uPlateauEtPieces;

{ Titre de l'application }
procedure AfficherTitre;

{ Menu principal simple }
procedure AfficherMenu;

{ Lecture du choix dans le menu }
function LireChoixMenu: integer;

{ Affiche l'echiquier actuel (appel de AfficherPlateau du module plateau) }
procedure AfficherEchiquierConsole(const Plateau : TPlateau;
                                   const Pieces  : TEnsemblePieces);

{ Version simple : saisie de la case en tapant colonne et ligne }
procedure DemanderCase(const Libelle : string; var C : TCoordonnee);

{ Version avec curseur : deplacement avec les fleches puis validation par Entree }
procedure DemanderCaseAvecCurseur(const Libelle : string; var C : TCoordonnee;
                                  const Plateau : TPlateau;
                                  const Pieces  : TEnsemblePieces);

{ Message d'erreur basique }
procedure AfficherMessageErreur(const Msg : string);

implementation

uses
  Crt;

procedure AfficherTitre;
begin
  ClrScr;
  Writeln('          JEU D''ECHECS CRÉÉ PAR AN ET MOHAMMED     ');
  Writeln;
end;

procedure AfficherMenu;
begin
  Writeln('1 - Nouvelle partie');
  Writeln('0 - Quitter');
  Writeln;
  Write('Votre choix : ');
end;

function LireChoixMenu: integer;
var
  c : integer;
begin
  Readln(c);
  LireChoixMenu := c;
end;

procedure AfficherEchiquierConsole(const Plateau : TPlateau;
                                   const Pieces  : TEnsemblePieces);
begin
  Writeln;
  Writeln('Echiquier actuel :');
  Writeln;
  AfficherPlateau(Plateau, Pieces);
  Writeln;
end;

procedure DemanderCase(const Libelle : string; var C : TCoordonnee);
var
  x, y : integer;
begin
  Writeln;
  Writeln(Libelle);
  Write('  Colonne (1..', BOARD_SIZE, ') : ');
  Readln(x);
  Write('  Ligne   (1..', BOARD_SIZE, ') : ');
  Readln(y);

  C.Colonne := x;
  C.Ligne   := y;
end;

{ Affichage du plateau avec une case "survolee" par le curseur}

procedure AfficherPlateauAvecCurseur(const Plateau : TPlateau;
                                     const Pieces  : TEnsemblePieces;
                                     const Curseur : TCoordonnee);
var
  ligne, col : integer;
  idx        : integer;
begin
  { En-tete des colonnes }
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

      if (ligne = Curseur.Ligne) and (col = Curseur.Colonne) then
      begin
        { Case sous le curseur : on met des crochets }
        if idx = 0 then
          Write('[.]')
        else
          Write('[', Pieces[idx].Symbole, ']');
      end
      else
      begin
        if idx = 0 then
          Write(' . ')
        else
          Write(' ', Pieces[idx].Symbole, ' ');
      end;
    end;
    Writeln;
  end;
end;

{ Saisie avec curseur et touches flechees}

procedure DemanderCaseAvecCurseur(const Libelle : string; var C : TCoordonnee;
                                  const Plateau : TPlateau;
                                  const Pieces  : TEnsemblePieces);
var
  x, y    : integer;    { coordonnees courantes du curseur dans la grille }
  ch      : char;       { caractere lu au clavier (fleches, entree, etc.) }
  code    : integer;    { code special renvoye par ReadKey pour les fleches }
  fini    : boolean;    { indique si l'utilisateur a valide son choix }
  cur     : TCoordonnee;{ position courante convertie en coordonnee d'echiquier }
begin
  { Position de depart du curseur (Coin inférieur gauche) }
  x := 1;
  y := 1;
  fini := False;


  repeat
    ClrScr;
    Writeln(Libelle);
    Writeln;
    cur.Colonne := x;
    cur.Ligne   := y;
    AfficherPlateauAvecCurseur(Plateau, Pieces, cur);
    Writeln;
    Writeln('Utilisez les fleches pour deplacer le curseur, Entree pour valider.');

    ch := ReadKey;
    if ch = #0 then
    begin
      ch := ReadKey;
      code := Ord(ch);
      case code of
        72: if y < BOARD_SIZE then Inc(y);  { fleche haut }
        80: if y > 1 then Dec(y);           { fleche bas }
        75: if x > 1 then Dec(x);           { fleche gauche }
        77: if x < BOARD_SIZE then Inc(x);  { fleche droite }
      end;
    end
    else if ch = #13 then
      fini := True;
  until fini;
   C.Colonne := x;
   C.Ligne := y;
end;

procedure AfficherMessageErreur(const Msg : string);
begin
  Writeln;
  Writeln('*** Erreur : ', Msg);
  Writeln;
end;

end.

