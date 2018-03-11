program pUOI;

{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  uUOI in 'uUOI.pas' {frmmain},
  uDataModule in 'uDataModule.pas' {dmData: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfrmmain, frmmain);
  Application.CreateForm(TdmData, dmData);
  Application.Run;
end.
