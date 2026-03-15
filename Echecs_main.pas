program Echecs;

uses
  Crt,
  uIHMConsole,
  uGestionPartie;

var
  choix : integer;
  quitter : boolean;

begin
  quitter := False;

  repeat
    AfficherTitre;
    Writeln('1 - Nouvelle partie');
    Writeln('2 - Reprendre la derniere partie sauvegardee');
    Writeln('0 - Quitter');
    Writeln;
    Write('Votre choix : ');
    Readln(choix);

    case choix of
      1: JouerNouvellePartie;
      2: JouerPartieDepuisFichier('sauvegarde.dat');
      0: quitter := True;
    else
      Writeln;
      Writeln('Choix invalide. Appuyez sur Entree pour continuer...');
      Readln;
    end;
  until quitter;
end.

