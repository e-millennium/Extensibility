unit uUploadProfileOracle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, oracle_utils, wtsstream, wtsClient, Gauges, UTF8;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Edituser: TEdit;
    Editpass: TEdit;
    GroupBox2: TGroupBox;
    GAUGE: TGauge;
    Label4: TLabel;
    Label5: TLabel;
    Button1: TButton;
    GroupBox3: TGroupBox;
    Label6: TLabel;
    Button2: TButton;
    edtIDClie: TEdit;
    Label3: TLabel;
    EditUrl: TEdit;
    lblInicio: TLabel;
    lblTermino: TLabel;
    lbltempoEstimado: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure SeparaNomes(ANomeCompleto: string; var APrimeiro, AUltimo: string);
begin
  APrimeiro := Trim(Copy(ANomeCompleto,1,Pos(' ',ANomeCompleto)));
  AUltimo := Trim(Copy(ANomeCompleto,Pos(' ',ANomeCompleto),MaxInt));
  if APrimeiro='' then
    APrimeiro := AUltimo;
end;

function SoNumeros(AValue: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(AValue) do
    if AValue[I] in ['0'..'9'] then
      Result := Result+ AValue[I];
end;

function FormatarTelefone(ADDD,ANumero: string): string;
var
  DDD,ParteA,ParteB,ParteC,Numero: string;
begin
  DDD := SoNumeros(ADDD);
  Numero := SoNumeros(ANumero);
  if Length(Numero) = 9 then
  begin
    ParteA := Copy(Numero,1,5);
    ParteB := Copy(Numero,6,4);
  end else
  if Length(Numero) = 8 then
  begin
    ParteA := Copy(Numero,1,4);
    ParteB := Copy(Numero,5,4);
  end;
  if (ParteA<>'') and (ParteB<>'') then
    ParteC := ParteA+'-'+ParteB
  else
    ParteC := Numero;
  Result := '('+DDD+') '+ParteC;
end;

function TranslateBool(AValue: Variant): string;
begin
  Result := 'false';
  if (VarToStr(AValue) = 'T') or (VarToStr(AValue) = '1') then
    Result := 'true';
end;

function GetSexo(AValue: string): string;
begin
  Result := 'female';
  if AValue='F' then
    Result := 'female'
  else
  if AValue='M' then
    Result := 'male';
end;

function GetJson(const AData:TwtsRecordset): string;
var
  NomeCompleto, Primeiro, Ultimo,
  ContatoEndereco,PrimeiroContato,UltimoContato,
  Sexo,DDD,Fone,TagFoneFixo,ATagFoneCelular,TagPessoaFisica,TagPessoaJuridica,TagFoneEnd: string;
begin
    //Nome do cliente
    if VarToStr(AData.FieldValuesByName['NOME']) = '' then
      SeparaNomes(VarToStr(AData.FieldValuesByName['NOME_FANTASIA']), Primeiro, Ultimo)
    else
      SeparaNomes(VarToStr(AData.FieldValuesByName['NOME']), Primeiro, Ultimo);

    //Contato endereco
    PrimeiroContato := Primeiro;
    UltimoContato := Ultimo;
    if VarToStr(AData.FieldValuesByName['ENDERECO_CONTATO']) <> '' then
      SeparaNomes(VarToStr(AData.FieldValuesByName['ENDERECO_CONTATO']), PrimeiroContato, UltimoContato);

    Sexo := getSexo(VarToStr(AData.FieldValuesByName['SEXO']));

    TagFoneFixo := '';
    DDD := VarToStr(AData.FieldValuesByName['DDD_FIXO']);
    Fone := VarToStr(AData.FieldValuesByName['FONE_FIXO']);
    if (DDD <> '') and ((Fone <> '')) then
      TagFoneFixo := '   "pjTelefoneFixo":"'+FormatarTelefone(DDD,Fone)+'",';

    ATagFoneCelular := '';
    DDD := VarToStr(AData.FieldValuesByName['DDD_CELULAR']);
    Fone := VarToStr(AData.FieldValuesByName['FONE_CELULAR']);
    if (DDD <> '') and ((Fone <> '')) then
      ATagFoneCelular := '   "pjCelular":"'+FormatarTelefone(DDD,Fone)+'",';

    TagFoneFixo := '';
    DDD := VarToStr(AData.FieldValuesByName['ENDERECO_DDD']);
    Fone := VarToStr(AData.FieldValuesByName['ENDERECO_FONE']);
    if (DDD = '') and ((Fone = '')) then
    begin
      DDD := VarToStr(AData.FieldValuesByName['DDD_FIXO']);
      Fone := VarToStr(AData.FieldValuesByName['FONE_FIXO']);
    end;
    if (DDD = '') and ((Fone = '')) then
    begin
      DDD := VarToStr(AData.FieldValuesByName['DDD_CELULAR']);
      Fone := VarToStr(AData.FieldValuesByName['FONE_CELULAR']);
    end;
    if (DDD <> '') and ((Fone <> '')) then
      TagFoneEnd := '   "phoneNumber":"'+FormatarTelefone(DDD,Fone)+'",';

    TagPessoaFisica := '';
    if VarToStr(AData.FieldValuesByName['CPF']) <> '' then
      TagPessoaFisica :=     '   "pjNomeDoResponsavel":"'+VarToStr(AData.FieldValuesByName['NOME'])+'",'+
                             '   "pjCpfDoResponsavel":"'+VarToStr(AData.FieldValuesByName['CPF'])+'",'+
                             '   "dateOfBirth":"",';

    TagPessoaJuridica := '';
    if VarToStr(AData.FieldValuesByName['CNPJ']) <> '' then
      TagPessoaFisica := '   "pessoaJuridica":true,'+
                         '   "pjRazaoSocial":"'+VarToStr(AData.FieldValuesByName['NOME'])+'",'+
                         '   "pjNomeFantasia":"'+VarToStr(AData.FieldValuesByName['NOME_FANTASIA'])+'",'+
                         '   "pjCnpj":"'+VarToStr(AData.FieldValuesByName['CNPJ'])+'",'+
                         '   "pjInscricaoEstadual":"'+VarToStr(AData.FieldValuesByName['INSCRICAO_ESTADUAL'])+'",'+
                         '   "pjInscricaoMunicipal":"'+VarToStr(AData.FieldValuesByName['INSCRICAO_MUNICIPAL'])+'",';
   
    Result :=

    '{'+
    '   "firstName":"'+Primeiro+'",'+
    '   "lastName":"'+Ultimo+'",'+
    '   "gender":"'+Sexo+'",'+
    '   "active":true,'+
    '   "locale":"pt_BR",'+
    '   "login":"'+LowerCase(VarToStr(AData.FieldValuesByName['EMAIL']))+'",'+
    '   "password":"Mudar@123",'+
    '   "email":"'+LowerCase(VarToStr(AData.FieldValuesByName['EMAIL']))+'",'+
    '   "receiveEmail":"yes",'+
    TagFoneFixo+
    ATagFoneCelular+
    TagPessoaFisica+
    TagPessoaJuridica+
    '"user_atacado":'+TranslateBool(AData.FieldValuesByName['ATACADO'])+','+
    '   "shippingAddresses":['+
    '      {'+
    '         "isDefaultAddress":true,'+
    '         "alias":"Endere�o Principal",'+
    '         "country":"BR",'+
    '         "lastName":"'+UltimoContato+'",'+
    '         "firstName":"'+PrimeiroContato+'",'+
    TagFoneEnd+
    '         "address3":"'+VarToStr(AData.FieldValuesByName['ENDERECO_COMPLEMENTO'])+'",'+
    '         "city":"'+VarToStr(AData.FieldValuesByName['ENDERECO_CIDADE'])+'",'+
    '         "address2":"'+VarToStr(AData.FieldValuesByName['ENDERECO_NUMERO'])+'",'+
    '         "address1":"'+VarToStr(AData.FieldValuesByName['ENDERECO'])+'",'+
    '         "postalCode":"'+VarToStr(AData.FieldValuesByName['ENDERECO_CEP'])+'",'+
    '         "county":"'+VarToStr(AData.FieldValuesByName['ENDERECO_BAIRRO'])+'",'+
    '         "state":"'+VarToStr(AData.FieldValuesByName['ENDERECO_ESTADO'])+'"'+
    '      }'+
    '   ]'+
    '}';

    Result := UTF8Encode(Result);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Clientes: TwtsRecordset;
  Json,JsonResp,Token,grantType: string;
  V: Variant;
  Ok,Erro: Integer;
  Inicio,Termino,Estimado: TDateTime;
  Ref,QtdTime: Integer;
begin
  grantType := 'grant_type=password&username='+Edituser.Text+'&password='+Editpass.Text;
  Ok := 0;
  Erro := 0;
  Ref := 0;
  QtdTime := 30;
  
  wtsCallEx('MILLENIUM!UPLOADORACLE.CLIENTES.LISTAR',[],[],Clientes);

  lblInicio.Caption := FormatDateTime('hh:nn:ss',Now);
  lblInicio.Refresh;
  Inicio := Now;
  GAUGE.MaxValue := Clientes.RecordCount;
  Clientes.First;
  while not Clientes.Eof do
  begin
    Inc(Ref);
    try
      Json := GetJson(Clientes);
      JsonResp := RestClientCenter(Token,grantType,'post',EditUrl.Text,'/ccadmin/v1/profiles',Json);
      wtsCall('MILLENIUM!UPLOADORACLE.CLIENTES.MarcarOK',['ID','MSG'],[Clientes.FieldValuesByName['ID'],JsonResp],V);
      inc(Ok);
     except on e: exception do
       begin
         wtsCall('MILLENIUM!UPLOADORACLE.CLIENTES.MarcarErro',['ID','MSG'],[Clientes.FieldValuesByName['ID'],e.Message],V);
         Inc(Erro);
       end;
    end;
    Clientes.Next;
    GAUGE.Progress := Clientes.RecNo;
    //GAUGE.Refresh;
    Label4.Caption := IntToStr(Ok);
    Label5.Caption := IntToStr(Erro);
    //Label4.Refresh;
    //Label5.Refresh;
    //lbltempoEstimado.Refresh;
    if Ref >= QtdTime then
    begin
      Estimado := ((Now-Inicio)/Ref) * (GAUGE.MaxValue-GAUGE.Progress);
      lbltempoEstimado.Caption := FormatDateTime('hh:nn:ss',Estimado);
      Ref := 0;
      Inicio := Now;
    end;
    Application.ProcessMessages;
  end;
  lblTermino.Caption := FormatDateTime('hh:nn:ss',Now);
  lblTermino.Refresh;
  ShowMessage('FIM');
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  JsonResp,Token,grantType: string;
begin                      //client_credentials
  grantType := 'grant_type=password&username='+Edituser.Text+'&password='+Editpass.Text;
  JsonResp := RestClientCenter(Token,grantType,'delete',EditUrl.Text,'/ccagent/v1/profiles/'+edtIDClie.Text,'');
  ShowMessage(JsonResp);
end;

end.
