unit uDataModule;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls;

type
  TdmData = class(TDataModule)
    stylbkcopperdark: TStyleBook;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmData: TdmData;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
