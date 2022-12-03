unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IdMappedPortTCP, IdIPWatch, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ExtCtrls, IdCustomTCPServer, IdContext;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnConnect: TButton;
    btnDisconnect: TButton;
    cmboISP: TComboBox;
    cmboMethod: TComboBox;
    IdIPWatch1: TIdIPWatch;
    IdMappedPortTCP1: TIdMappedPortTCP;
    Label1: TLabel;
    Label10: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    mmoLogs: TMemo;
    Panel1: TPanel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Shape1: TShape;
    Shape2: TShape;
    txtHeader: TEdit;
    txtHost: TEdit;
    txtlistenPort: TEdit;
    txtPort: TEdit;
    txtProxy: TEdit;
    procedure btnConnectClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure IdMappedPortTCP1Execute(AContext: TIdContext);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnConnectClick(Sender: TObject);
begin
  //when user clicks this button to connect ,we disable it so they cant press it
  //twice
  btnConnect.Visible:= False;
  //if the user wants to disconnect ,enable the button
  btnDisconnect.Visible:=True;
  //give our machine local ip adress(localhost) and port
  IdMappedPortTCP1.Bindings.Add.IP:= '127.0.0.1';
  IdMappedPortTCP1.Bindings.Add.Port:= StrToInt(txtlistenPort.text);

  //establish connection to the proxy inserted in the text field and it port
  IdMappedPortTCP1.MappedHost:= StrToInt(txtProxy.Text);
  IdMappedPortTCP1.MappedPort:=StrToInt(txtPort.Text);

  //make sure IdMappedPortTCP1 is active
  IdMappedPortTCP1.Active:=True;




end;

procedure TForm1.btnDisconnectClick(Sender: TObject);
begin
//when user clicks this button to disconnect ,we enable the Connect button
  btnConnect.Visible:= True;
  //....and disable the disconnect button
  btnDisconnect.Visible:=False;

  //turn off tcp connection
  IdMappedPortTCP1.Active:=False;
  IdMappedPortTCP1.Bindings.Clear;


end;

procedure TForm1.IdMappedPortTCP1Execute(AContext: TIdContext);
var
  httpHeaderX : String ;
  httpPayloadX: String;

begin
 //execute payload injection and format into a string;put the string the memo box
  mmoLogs.Lines.Add(InjectStrX(AContext));
 //  use POS function to search for words like get,post,head in the paylod,if
 //not found return a 0
if (POS('GET',InjectStrX(AContext)<> 0) or(POS('HEAD',InjectStrX(AContext) <> 0)
 or (POS('CONNECT',InjectStrX(AContext) <> 0) or (POS('HTTP',InjectStrX(AContext) <> 0)
 or (POS('http',InjectStrX(AContext) <> 0) or (POS('https',InjectStrX(AContext) <> 0)
 then
  begin
      //
      httpHeaderX:= InjectHeaderX(InjectStrX(AContext),
              'Proxy-Connection : Keep-Alive'+#13#10#13 +
              'Connection:Keep-Alive'#131015 );

       //payload methods
      httpPayloadX:=cmboMethod.Text + ' ' + txtHeader.Text
       + 'HTTP/1.1'#13#10#13 +
       'User-Agent: '#13#10 +
       'Connection:Keep-Alive#13#10 +
       'Host:' + txtHost.Text + #13#10 + InjectStrX(AContext);
       ;
       IdMappedPortContext(AContext).OutboundClient.IOHandler.Write(InjectBtsX(httpHeaderX));
       Sleep(1000);
       IdMappedPortContext(AContext).NetData := InjectBtsX(httpPayloadX);






 end;

end;

procedure TForm1.IdMappedPortTCP1OutboundData(AContext: TIdContext);
begin
  //
  if POS (txtFrom.Text,InjectStrX(AContext) <> 0 then
  begin
         IdMappedPortContext(AContext).NetData := InjectBtsX( StringReplace(
         InjectStrX(AContext),txtFrom.Text,txtTo.Text,[rfReplaceAll]);
  end;

end;


end.

