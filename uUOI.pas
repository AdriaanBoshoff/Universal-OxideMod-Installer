unit uUOI;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, uDataModule,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox, IniFiles, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, System.Zip, IdSSLOpenSSL;

type

  TDownload = class;

  Tfrmmain = class(TForm)
    lbl1: TLabel;
    grpgameselection: TGroupBox;
    cbbgames: TComboBox;
    pb1: TProgressBar;
    btninstall: TButton;
    lblprogress: TLabel;
    lblstatus: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    procedure SaveiniString(Section, Name, Value: string);
    function LoadiniString(Section, Name, Value: string): string;
    procedure FormCreate(Sender: TObject);
    procedure cbbgamesChange(Sender: TObject);
    procedure btninstallClick(Sender: TObject);
  private
    { Private declarations }
    ini_settings: string;
    val, endval: Integer;
  public
    { Public declarations }
  end;

  TDownload = class(TThread)
  private
    httpclient: TIdHTTP;
    SocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
    url: string;
    filename: string;
    maxprogressbar: integer;
    progressbarstatus: integer;
    procedure ExtractZip(ZipFile: string; ExtractPath: string);
    procedure idhttp1Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure idhttp1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure UpdateProgressBar;
    procedure SetMaxProgressBar;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: boolean; aurl, afilename: string);
    destructor Destroy; override;
  end;

var
  frmmain: Tfrmmain;

implementation

{$R *.fmx}

{ Thread }

constructor TDownload.Create(CreateSuspended: boolean; aurl, afilename: string);
begin
  inherited Create(CreateSuspended);
  httpclient := TIdHTTP.Create(nil);
  SocketOpenSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  SocketOpenSSL.SSLOptions.SSLVersions := [ sslvSSLv23 ];
  httpclient.Request.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36';
  httpclient.IOHandler := SocketOpenSSL;
  httpclient.HandleRedirects := True;
  httpclient.OnWorkBegin := idhttp1WorkBegin;
  httpclient.OnWork := idhttp1Work;
  url := aurl;
  filename := afilename;
end;

procedure TDownload.idhttp1Work(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  progressbarstatus := AWorkCount;
  Queue(UpdateProgressBar);

end;

procedure TDownload.idhttp1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  maxprogressbar := AWorkCountMax;
  Queue(SetMaxProgressBar);
end;

procedure TDownload.Execute;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    httpclient.Get(url, Stream);
    Stream.SaveToFile(filename);
    frmmain.lblstatus.Text := 'Done Downloading. Extracting...';
    ExtractZip('oxide.zip', GetCurrentDir);
  finally
    Stream.Free;
  end;
end;

procedure TDownload.UpdateProgressBar;
begin
  frmmain.pb1.Value := progressbarstatus;
  frmmain.lblprogress.Text := IntToStr(progressbarstatus) + ' / ' + IntToStr(maxprogressbar);
  frmmain.lblstatus.Text := 'Downloading...';
end;

procedure TDownload.SetMaxProgressBar;
begin
  frmmain.pb1.Max := maxprogressbar;
end;

destructor TDownload.Destroy;
begin
  FreeAndNil(httpclient);
  inherited Destroy;
end;

procedure TDownload.ExtractZip(ZipFile, ExtractPath: string);
begin
  if TZipFile.IsValid(ZipFile) then
  begin
    TZipFile.ExtractZipFile(ZipFile, ExtractPath);
    DeleteFile(ZipFile);
    DeleteFile('HashInfo.txt');
    DeleteFile('OpenSSL License.txt');
    DeleteFile('openssl.exe');
    DeleteFile('ReadMe.txt');
    frmmain.lblstatus.Text := 'Done.';
    frmmain.btninstall.Enabled := True;
    frmmain.cbbgames.Enabled := True;
  end
  else
  begin
    ShowMessage('There was an error extracting or downloading the files.');
    frmmain.lblstatus.Text := 'Error!';
  end;
end;

{ Tfrmmain }

procedure Tfrmmain.btninstallClick(Sender: TObject);
var
  DownloadThread: TDownload;
  link: string;
begin
  if cbbgames.ItemIndex = -1 then
    begin
      ShowMessage('You have to choose a game!');
      Exit
    end;

  case cbbgames.ItemIndex of
    0 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-Rust.zip';
    1 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-RustLegacy.zip';
    2 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-Unturned.zip';
    3 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-TheForest.zip';
    4 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-Hurtworld.zip';
    5 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-Blackwake.zip';
    6 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-Blockstorm.zip';
    7 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-FortressCraft.zip';
    8 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-FromTheDepths.zip';
    9 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-GangBeasts.zip';
    10 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-InterstellarRift.zip';
    11 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-MedievalEngineers.zip';
    12 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-Nomad.zip';
    13 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-PlanetExplorers.zip';
    14 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-ReignOfKings.zip';
    15 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-SavageLands.zip';
    16 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-SevenDays.zip';
    17 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-SpaceEngineers.zip';
    18 : link := 'https://www.github.com/OxideMod/Oxide/releases/download/latest/Oxide-Terraria.zip';
  end;

  pb1.Value := 0;
  btninstall.Enabled := False;
  cbbgames.Enabled := False;
  lblstatus.Text := 'Starting Download...';
  DownloadThread := TDownload.Create(true, link, 'oxide.zip');
  DownloadThread.FreeOnTerminate := true;
  DownloadThread.Start;
end;

procedure Tfrmmain.cbbgamesChange(Sender: TObject);
begin
  SaveiniString('App Settings', 'last_game', cbbgames.ItemIndex.ToString);
end;

procedure Tfrmmain.FormCreate(Sender: TObject);
begin
  Application.Title := 'Universal OxideMod Installer';
  ini_settings := '.\uoi-settings.ini';
  cbbgames.ItemIndex := StrToInt(LoadiniString('App Settings', 'last_game', '0'));

  if not FileExists('libeay32.dll') or not FileExists('ssleay32.dll') then
  begin
    ShowMessage('Some files seem to be missing. Please re-download this software.');
    Application.Terminate;
  end;

end;

function Tfrmmain.LoadiniString(Section, Name, Value: string): string;
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(ini_settings);
  try
    Result := ini.ReadString(Section, Name, Value);
  finally
    ini.Free;
  end;
end;

procedure Tfrmmain.SaveiniString(Section, Name, Value: string);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(ini_settings);
  try
    ini.WriteString(Section, Name, Value);
  finally
    ini.Free;
  end;
end;

end.
