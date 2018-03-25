unit Orcamentos;

interface

uses
  Windows, DMBase,u_dataedit,DB,wtsStream,Classes,WtsClient,wtsConstraints,
  millenium_Variants,LinkList;

type
  TOrcamentos = class(Tdataedit)
  private
    FDenominacoes: TwtsRecordset;
    FFieldsCalcPesoPeca: TStringList;
    FCurDataSet: TDataSet;
    procedure FrameDataChange(Sender:TObject; Field:TField);
    procedure FrameRecordDataChange(Sender: TObject; Const RecordName:String; Field: TField);

    function Param(const AFieldName: string): TField;
    function CalcularPesoPeca(const ADenominacao: Integer): Real;

    procedure ReprocessaQuantidadePedidaMateriaPrima(const APesoPeca: Real; AQuantidadePedida:Integer);
    procedure GetVarValueCurDataSet(sender: TObject; const varname: string; var value: variant);
    
    function CalculaCustoUnitarioMateriaPrima(APrecoCusto,APercICMS,APercPIS,APercCofins,APercFrete,APercRefugo,AQuantidadeTotal: Double; AQuantidadePedida: Integer): Real;
    function ResolverCalculo(const AFormula: string;AOnVarValue: TOnGetVarValue): Real;
    procedure CalcularTotais;
    function TotalizaDataSet(const AData: TDataSet;AFieldName:string): Real;
    function TotalizaRecordSet(const ARecordName,ATransaction,AFieldName:string): Real;
    function ConsultarCustoMateriaPrima(AProduto: Integer): Double;
    function ConsultarCustoTotalMaquina(AMaquina: Integer): Double;
    function ConsultarPercentualImposto(AImposto: Integer): Double;
    function ConsultarPercentualOutrosCustos(ADespesa: Integer): Double;
    procedure ReprocessaImpostos;
    procedure ReprocessaOutrosCustos;
  protected
    FInternalChanging : Boolean;
    procedure Initialize;override;
    procedure Finalize;override;
    procedure BeforeCreateLink;override;
    procedure LinkClick(Sender: TObject);override;
    procedure Refresh(ASender: TObject); override;
  end;

implementation

//QUANTIDADE_ESTOQUE

{ TOrcamentos }

procedure TOrcamentos.Initialize;
begin
  inherited;                                        
  MainMethodFrame.OnDataChanged := FrameDataChange;
  MainMethodFrame.OnRecordDataChange := FrameRecordDataChange;
  //MainMethodFrame.OnGetFieldInfo := FrameGetFieldInfo;
  //MainMethodFrame.OnLookupButtonClick := FrameLookupClick;
  FInternalChanging := False;

  wtsCallEx('MILLENIUM!DELCA.DENOMINACOES.Lista',[],[],FDenominacoes);
  FFieldsCalcPesoPeca := TStringList.Create;
  FFieldsCalcPesoPeca.Add('ALTURA');
  FFieldsCalcPesoPeca.Add('LARGURA');
  FFieldsCalcPesoPeca.Add('PESO_ESPECIFICO');
  FFieldsCalcPesoPeca.Add('COMPRIMENTO');
  FFieldsCalcPesoPeca.Add('DIAMENTRO');
  FFieldsCalcPesoPeca.Add('DIAMETRO_MEDIO');
  FFieldsCalcPesoPeca.Add('ESPIRAS');
  FFieldsCalcPesoPeca.Add('DIAMETRO_PAREDE');
end;

procedure TOrcamentos.Finalize;
begin
  FDenominacoes.Free;
  FFieldsCalcPesoPeca.Free;
  inherited;
end;

function TOrcamentos.ResolverCalculo(const AFormula:string; AOnVarValue: TOnGetVarValue): Real;
var
   ExprEval: TConstraintParser;
begin
  Result := 0;
  ExprEval := TConstraintParser.Create;
  try
    ExprEval.OnGetVarValue := AOnVarValue;
    ExprEval.Prepare(AFormula);
    Result := ExprEval.Run;
  finally
    ExprEVal.Free;
  end;
end;

procedure TOrcamentos.GetVarValueCurDataSet(sender: TObject; const varname: string; var value: variant);

begin
  OutputDebugString(Pchar(varname)) ;
  if (varname = 'QUANTIDADE_PEDIDA') then
    value := Param(varname).AsVariant
  else
    value := FCurDataSet.FieldValues[varname];
  if VarNotValid(value) then
    value := 0;
end;

function TOrcamentos.CalcularPesoPeca(const ADenominacao: Integer): Real;
begin
  Result := 0;
  if FDenominacoes.Locate(['DENOMINACAO'],[ADenominacao]) then
    Result :=  ResolverCalculo(FDenominacoes.FieldValuesByName['FORMULA_PESO_PRODUTO'],GetVarValueCurDataSet);
end;

procedure TOrcamentos.ReprocessaQuantidadePedidaMateriaPrima(const APesoPeca: Real; AQuantidadePedida:Integer);
var
  R: TwtsRecordset;
begin
  R := TwtsRecordset.CreateFromStreamEx(TMemoryStream.Create,rdInput);
  try
    R.Transaction := 'MILLENIUM!DELCA.ORCAMENTOS.MATERIA_PRIMA';
    R.Data := Param('MATERIAS_PRIMA').AsString;
    R.First;
    while not R.Eof do
    begin
      R.FieldValuesByName['QUANTIDADE_TOTAL_USO'] := APesoPeca * AQuantidadePedida;
      R.FieldValuesByName['CUSTO_UNITARIO'] := CalculaCustoUnitarioMateriaPrima(VarToFloat(R.FieldValuesByName['PRECO_CUSTO']),
      VarToFloat(R.FieldValuesByName['ICMS']),VarToFloat(R.FieldValuesByName['PIS']),
      VarToFloat(R.FieldValuesByName['COFINS']),VarToFloat(R.FieldValuesByName['FRETE']),
      VarToFloat(R.FieldValuesByName['REFUGO']),VarToFloat(R.FieldValuesByName['QUANTIDADE_TOTAL_USO']),
      AQuantidadePedida);
      R.Update;
      R.Next;
    end;
    Param('MATERIAS_PRIMA').AsString := R.Data;
  finally
    R.Free;                
  end;
  ReprocessaImpostos;
  ReprocessaOutrosCustos;
end;

procedure TOrcamentos.ReprocessaImpostos;
begin
  
end;

procedure TOrcamentos.ReprocessaOutrosCustos;
begin

end;

procedure TOrcamentos.FrameDataChange(Sender: TObject; Field: TField);
begin
  inherited;
  if Field = nil then
    Exit;
  //Param('TOTAL_CACULADO').AsBoolean := False;

  FCurDataSet := Field.DataSet;
  FInternalChanging := True;
  try
    if FFieldsCalcPesoPeca.IndexOf(Field.FieldName) > -1 then
      Param('KG_PECA').AsFloat := CalcularPesoPeca(Param('DENOMINACAO').AsInteger);

    if (Field.FieldName = 'KG_PECA') or (Field.FieldName = 'QUANTIDADE_PEDIDA') then
      ReprocessaQuantidadePedidaMateriaPrima(Param('KG_PECA').AsFloat,Param('QUANTIDADE_PEDIDA').AsInteger);
      
  finally
    FInternalChanging := False;
  end;
end;

function TOrcamentos.CalculaCustoUnitarioMateriaPrima(APrecoCusto,APercICMS, APercPIS,
  APercCofins,APercFrete,APercRefugo,AQuantidadeTotal: Double; AQuantidadePedida: Integer): Real;
var
  ValorICMS,ValorPIS,ValorCofins,ValorFrete,ValorRefugo:Double;
begin
  ValorICMS := APrecoCusto * (APercICMS/100);
  ValorPIS := APrecoCusto * (APercPIS/100);
  ValorCofins := APrecoCusto * (APercCofins/100);
  ValorFrete := APrecoCusto * (APercFrete/100);
  ValorRefugo := APrecoCusto * (APercRefugo/100);

  Result := ((APrecoCusto * AQuantidadeTotal) + (ValorICMS+ValorPIS+ValorCofins)+(ValorFrete+ValorRefugo));{/AQuantidadePedida};
end;

function TOrcamentos.TotalizaDataSet(const AData: TDataSet;AFieldName:string): Real;
begin
  Result := 0;
  try
    AData.DisableControls;
    AData.First;
    while not AData.Eof do
    begin
      Result := Result + AData.FieldByName(AFieldName).AsFloat;
      AData.Next;
    end;
  finally
    AData.EnableControls;
  end;
end;

function TOrcamentos.TotalizaRecordSet(const ARecordName,ATransaction,AFieldName:string): Real;
var
  R: TwtsRecordset;
begin
  Result := 0;
  R := TwtsRecordset.CreateFromStreamEx(TMemoryStream.Create,rdInput);
  try
    R.Transaction := ATransaction;
    R.Data := Param(ARecordName).AsString;
    R.First;
    while not R.Eof do
    begin
      Result := Result + VarToFloat(R.FieldValuesByName[AFieldName]);
      R.Next;
    end;
  finally
    R.Free;
  end;
end;

function TOrcamentos.ConsultarCustoMateriaPrima(AProduto: Integer): Double;
var
  R: TwtsRecordset;
begin
  wtsCallEx('MILLENIUM!DELCA.PRODUTOSMP.ConsultarPrecoCusto',['PRODUTO','TABELA'],[AProduto,190],R);
  try
    Result := VarToFloat(R.FieldValuesByName['PRECO_CUSTO']);
  finally
    R.Free;
  end;
end;

function TOrcamentos.ConsultarCustoTotalMaquina(AMaquina: Integer): Double;
var
  R: TwtsRecordset;
begin
  wtsCallEx('MILLENIUM!DELCA.MAQUINAS.ConsultarCustoTotal',['MAQUINA'],[AMaquina],R);
  try
    Result := VarToFloat(R.FieldValuesByName['TOTAL_MAQUINA']);
  finally
    R.Free;
  end;
end;

function TOrcamentos.ConsultarPercentualImposto(AImposto: Integer): Double;
var
  R: TwtsRecordset;
begin
  wtsCallEx('MILLENIUM!DELCA.ORCAMENTOS.IMPOSTOS.Consultar',['IMPOSTO'],[AImposto],R);
  try
    Result := VarToFloat(R.FieldValuesByName['PERCENTUAL']);
  finally
    R.Free;
  end;
end;

function TOrcamentos.ConsultarPercentualOutrosCustos(ADespesa: Integer): Double;
var
  R: TwtsRecordset;
begin                                                  
  wtsCallEx('MILLENIUM!DELCA.ORCAMENTOS.DEPESAS.Consultar',['IMPOSTO'],[ADespesa],R);
  try
    Result := VarToFloat(R.FieldValuesByName['PERCENTUAL']);
  finally
    R.Free;
  end;
end;

procedure TOrcamentos.FrameRecordDataChange(Sender: TObject;const RecordName: String; Field: TField);
begin
  inherited;
  if Field = nil then
    Exit;
 // Param('TOTAL_CACULADO').AsBoolean := False;
  FCurDataSet := Field.DataSet;

  if (RecordName = 'MATERIAS_PRIMA') then
  begin
    if Field.FieldName = 'PRODUTO' then
      Field.DataSet.FieldByName('PRECO_CUSTO').AsFloat := ConsultarCustoMateriaPrima(FCurDataSet.FieldByName('PRODUTO').AsInteger);

    Field.DataSet.FieldByName('QUANTIDADE_TOTAL_USO').AsFloat := Param('QUANTIDADE_PEDIDA').AsInteger * Param('KG_PECA').AsFloat;

    Field.DataSet.FieldByName('CUSTO_UNITARIO').AsFloat :=

    CalculaCustoUnitarioMateriaPrima(FCurDataSet.FieldByName('PRECO_CUSTO').AsFloat,
      FCurDataSet.FieldByName('ICMS').AsFloat,FCurDataSet.FieldByName('PIS').AsFloat,
      FCurDataSet.FieldByName('COFINS').AsFloat,FCurDataSet.FieldByName('FRETE').AsFloat,
      FCurDataSet.FieldByName('REFUGO').AsFloat,FCurDataSet.FieldByName('QUANTIDADE_TOTAL_USO').AsFloat,
      Param('QUANTIDADE_PEDIDA').AsInteger);

  end else
  if (RecordName = 'PROCESSOS') and ((Field.FieldName='MAQUINA') or (Field.FieldName='SETUP_QUANTIDADE') or (Field.FieldName='SETUP_TEMPO')or (Field.FieldName='SETUP_TEMPO')) then
  begin
    if Field.FieldName='MAQUINA' then
      Field.DataSet.FieldByName('CUSTO_HORA_MAQUINA').AsFloat :=  ConsultarCustoTotalMaquina(FCurDataSet.FieldByName('MAQUINA').AsInteger);

    if Field.DataSet.FieldByName('CUSTO_HORA_MAQUINA').AsFloat > 0 then
      Field.DataSet.FieldByName('CUSTO_UNITARIO').AsFloat := (Field.DataSet.FieldByName('TEMPO').AsFloat + (Field.DataSet.FieldByName('SETUP_QUANTIDADE').AsFloat * Field.DataSet.FieldByName('SETUP_TEMPO').AsFloat)) * (Field.DataSet.FieldByName('CUSTO_HORA_MAQUINA').AsFloat/60)
  end else
  if (RecordName = 'SERVICOS') and ((Field.FieldName='QUANTIDADE') or (Field.FieldName='UNITARIO')) then
  begin
    Field.DataSet.FieldByName('TOTAL').AsFloat := Field.DataSet.FieldByName('QUANTIDADE').AsFloat * Field.DataSet.FieldByName('UNITARIO').AsFloat;
  end else
  if (RecordName = 'IMPOSTOS') and (Field.FieldName='IMPOSTO') then
  begin
    CalcularTotais;
    Field.DataSet.FieldByName('PERCENTUAL').AsFloat := ConsultarPercentualImposto(Field.DataSet.FieldByName('IMPOSTO').AsInteger);
    Field.DataSet.FieldByName('VALOR').AsFloat := ((Param('TOTAL_MATERIA_PRIMA').AsFloat + Param('TOTAL_PROCESSOS').AsFloat) * (Field.DataSet.FieldByName('PERCENTUAL').AsFloat/100));
  end else
  if (RecordName = 'OUTROS_CUSTOS') and (Field.FieldName='DESPESA') then
  begin
    CalcularTotais;
    Field.DataSet.FieldByName('PERCENTUAL').AsFloat := ConsultarPercentualOutrosCustos(Field.DataSet.FieldByName('DESPESA').AsInteger);
    Field.DataSet.FieldByName('VALOR').AsFloat := ((Param('TOTAL_MATERIA_PRIMA').AsFloat + Param('TOTAL_PROCESSOS').AsFloat) * (Field.DataSet.FieldByName('PERCENTUAL').AsFloat/100));
  end;


end;

procedure TOrcamentos.CalcularTotais;
begin
  Param('TOTAL_MATERIA_PRIMA').AsFloat := TotalizaRecordSet('MATERIAS_PRIMA','MILLENIUM!DELCA.ORCAMENTOS.MATERIA_PRIMA','CUSTO_UNITARIO');
  Param('TOTAL_SERVICOS').AsFloat := TotalizaRecordSet('SERVICOS','MILLENIUM!DELCA.ORCAMENTOS.SERVICO','TOTAL');
  Param('TOTAL_PROCESSOS').AsFloat := TotalizaRecordSet('PROCESSOS','MILLENIUM!DELCA.ORCAMENTOS.PROCESSO','CUSTO_UNITARIO');
  Param('TOTAL_CUSTO').AsFloat := Param('TOTAL_MATERIA_PRIMA').AsFloat+Param('TOTAL_SERVICOS').AsFloat+Param('TOTAL_PROCESSOS').AsFloat;

  Param('TOTAL_IMPOSTOS').AsFloat := TotalizaRecordSet('IMPOSTOS','MILLENIUM!DELCA.ORCAMENTOS.IMPOSTO','TOTAL');
  Param('TOTAL_OUTROS_CUSTOS').AsFloat := TotalizaRecordSet('OUTROS_CUSTOS','MILLENIUM!DELCA.ORCAMENTOS.CUSTO_EXTRA','TOTAL');
  Param('TOTAL_DESPESAS').AsFloat := Param('TOTAL_IMPOSTOS').AsFloat+Param('TOTAL_OUTROS_CUSTOS').AsFloat;

  Param('TOTAL_CACULADO').AsBoolean := True;
end;

function TOrcamentos.Param(const AFieldName: string): TField;
begin
  Result := MainMethodFrame.ParamsView.FieldByName(AFieldName);
end;

procedure TOrcamentos.BeforeCreateLink;
begin
  inherited;
  AddLink('Calcular Total Orçamento','calcular_total','',-3,ltNone,lcLink);
end;

procedure TOrcamentos.LinkClick(Sender: TObject);
begin
  if TLink(Sender).Destiny = 'calcular_total' then
    CalcularTotais
  else
    inherited;
end;

procedure TOrcamentos.Refresh(ASender: TObject);
begin
  CalcularTotais;
  inherited;
end;

initialization
  RegisterDocClass(TOrcamentos);

end.


{
list:'0','BARRA';'1','MOLAS';'2','TUBO(REDONDO)';'3','TUBO(QUADRADO/RETANGULAR)';'4','FITA';

IF(DENOMINACAO=4,((((ALTURA*LARGURA*PESO_ESPECIFICO))*COMPRIMENTO)/1000),
IF(DENOMINACAO=1,((((3.14159/4)*DIAMENTRO*DIAMENTRO)*(DIAMETRO_MEDIO*3.14159)*ESPIRAS*PESO_ESPECIFICO)/1000),
IF(DENOMINACAO=3,(((2*DIAMETRO_PAREDE*(LARGURA+ALTURA-(2*DIAMETRO_PAREDE))*PESO_ESPECIFICO)*COMPRIMENTO)/1000),
IF(DENOMINACAO=2,((((DIAMENTRO-DIAMETRO_PAREDE)*DIAMETRO_PAREDE*COMPRIMENTO)*PESO_ESPECIFICO)/1000),
IF(DENOMINACAO=0,((3.14159*((DIAMENTRO/2000)*DIAMENTRO/2000)*(COMPRIMENTO/1000)*(PESO_ESPECIFICO*1000000))),0)
))))}

