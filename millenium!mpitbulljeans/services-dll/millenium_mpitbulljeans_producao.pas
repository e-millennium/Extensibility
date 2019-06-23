unit millenium_mpitbulljeans_producao;

interface

uses
  Windows,Classes,wtsServerObjs,SysUtils, millenium_variants;

implementation

procedure DistibruirLotes(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  C,N: IwtsCommand;
  SituacaoProducao, Distribuicoes, Situacoes: IwtsWriteData;
  FieldsNames,FieldsParamNames,FieldValues: string;
  SL,NovosLotes: TStringList;
  I,X,QuantidadePorLote,SaldoLote: Integer;
  FieldValue: Variant;
  FieldName: string;
  NumeroLote: string;
  QuantidadeTotalEnviado,QuantidadeTotalSituacao: Integer;
  procedure SolicitarNumerosLotes(const AQuantidadePorLote, AQuantidade: Integer; ALotes: TStringList);
  var
     I: Integer;
     QuantidadeLotes,Saldo,QuantidadeLote: Integer;
     C: IwtsCommand;
  begin
    C := DataPool.Open('MILLENIUM');
    QuantidadeLotes := AQuantidade div AQuantidadePorLote;
    if (QuantidadeLotes * AQuantidadePorLote) < AQuantidade then
      Inc(QuantidadeLotes);
    Saldo := AQuantidade;
    for I := 1 to QuantidadeLotes do
    begin
      QuantidadeLote := AQuantidadePorLote;
      if QuantidadeLote > Saldo then
        QuantidadeLote := Saldo;
      C.Execute('#CALL MILLENIUM.PRODUCAO.NextLote()');
      ALotes.Values[C.AsString['LOTE']] := IntToStr(QuantidadeLote);
      Dec(Saldo,AQuantidadePorLote);
    end;
  end;
begin
  C := DataPool.Open('MILLENIUM');
  N := DataPool.Open('MILLENIUM');
  Situacoes := DataPool.CreateRecordset('WTSSYSTEM.INTERNALTYPES.INTEGERARRAY');
  Distribuicoes := Input.GetParamAsData('DISTRIBUICOES');
  SL := TStringList.Create;
  NovosLotes := TStringList.Create;

  //Situações
  Distribuicoes.First;
  while not Distribuicoes.EOF do
  begin
    SL.Clear;
    ExtractStrings([','],[],PChar(Distribuicoes.AsString['SITUACOES']),SL);
    for I := 0 to SL.Count-1 do
    if not Situacoes.Locate(['ITEM'],[SL[I]]) then
    begin
      Situacoes.New;
      Situacoes.Value['ITEM'] := SL[I];
      Situacoes.Add
    end;
    Distribuicoes.Next;
  end;

  //Não é permitido que seja distribuido produtos em fases diferentes
  Situacoes.First;
  C.DimAsData('SITUACOES',Situacoes);
  C.Execute('SELECT COUNT(*) AS QTDE FROM(SELECT DISTINCT FASE FROM SITUACAO_PRODUCAO WHERE SITUACAO IN #MAKELIST(SITUACOES,ITEM));');
  if C.Value['QTDE'] > 1 then
    raise Exception.Create('Não é permitido distribuição de produtos em fases diferentes');

  //Total do banco de dados
  Situacoes.First;
  C.Dim('PRODUCAO',Input.Value['PRODUCAO']);
  C.Execute('SELECT SUM(QUANTIDADE) AS QTDE FROM SITUACAO_PRODUCAO WHERE PRODUCAO =:PRODUCAO;');
  QuantidadeTotalSituacao := C.Value['QTDE'];

  QuantidadeTotalEnviado := 0;
  Distribuicoes.First;
  while not Distribuicoes.EOF do
  begin
    QuantidadeTotalEnviado := QuantidadeTotalEnviado + Distribuicoes.Value['QUANTIDADE'];
    Distribuicoes.Next;
  end;

  if (QuantidadeTotalSituacao <> QuantidadeTotalEnviado) then
    raise Exception.Create('A Quantidade distribuida ('+IntToStr(QuantidadeTotalEnviado)+') é diferente da quantidade na produção ('+IntToStr(QuantidadeTotalSituacao)+')' );

  //Vamos garantir que só temos uma situação produção por produto
  Situacoes.First;
  C.DimAsData('SITUACOES',Situacoes);
  C.Execute('SELECT COUNT(*) AS QTDE '+
            'FROM (SELECT ESTAMPA,COR,TAMANHO,LOTE '+
                  'FROM SITUACAO_PRODUCAO '+
                  'WHERE SITUACAO IN #MAKELIST(SITUACOES,ITEM) '+
                  'GROUP BY ESTAMPA,COR,TAMANHO,LOTE '+
                  'HAVING COUNT(*) > 1);');
  if C.Value['QTDE'] > 0 then
    raise Exception.Create('Não é permitido distribuição de produtos que já foram "Movimentados"');

  //
  Situacoes.First;
  C.DimAsData('SITUACOES',Situacoes);
  C.Execute('SELECT * FROM SITUACAO_PRODUCAO WHERE SITUACAO IN #MAKELIST(SITUACOES,ITEM) ORDER BY LOTE');
  SituacaoProducao := C.CreateRecordset;

  //FieldsNames
  for X := 0 to SituacaoProducao.FieldCount -1 do
  begin
    if SituacaoProducao.FieldName(X) <> 'SITUACAO' then
    begin
      FieldsNames := FieldsNames + SituacaoProducao.FieldName(X)+',';
      FieldsParamNames := FieldsParamNames + ':'+SituacaoProducao.FieldName(X)+',';
    end;
  end;
  SetLength(FieldsNames,Length(FieldsNames)-1);
  SetLength(FieldsParamNames,Length(FieldsParamNames)-1);

  Distribuicoes.Order(['ESTAMPA','COR','TAMANHO','QUANTIDADE','CANAL_VENDA']);
  Distribuicoes.First;
  while not Distribuicoes.EOF do
  begin
    //Vamos criar uma nova linha da situação com base na selecionada
    if SituacaoProducao.Locate(['ESTAMPA','COR','TAMANHO'],[Distribuicoes.Value['ESTAMPA'],Distribuicoes.Value['COR'],Distribuicoes.Value['TAMANHO']]) then
    begin
      NovosLotes.Clear;
      QuantidadePorLote := Distribuicoes.Value['QUANTIDADE'];
      SolicitarNumerosLotes(QuantidadePorLote, Distribuicoes.Value['QUANTIDADE'],NovosLotes);
      for I := 0 to NovosLotes.Count-1 do
      begin
        NumeroLote := NovosLotes.Names[I];
        for X := 0 to SituacaoProducao.FieldCount -1 do
        begin
          FieldValue := SituacaoProducao.GetField(X);
          FieldName := SituacaoProducao.FieldName(X);
          if SameText(FieldName,'QUANTIDADE') then
            FieldValue := NovosLotes.Values[NumeroLote]
          else
          if SameText(FieldName,'LOTE') then
            FieldValue := NumeroLote;

          N.Dim(PChar(FieldName),FieldValue);
        end;
         N.Execute(PChar('INSERT INTO SITUACAO_PRODUCAO ('+FieldsNames+')  VALUES ('+FieldsParamNames+')  #RETURN(SITUACAO)')) ;

         C.Dim('PRODUCAO',Input.Value['PRODUCAO']);
         C.Dim('SITUACAO',N.Value['SITUACAO']);
         C.Dim('CANAL_VENDA',Distribuicoes.Value['CANAL_VENDA']);
         C.Dim('ESTAMPA',Distribuicoes.Value['ESTAMPA']);
         C.Dim('COR',Distribuicoes.Value['COR']);
         C.Dim('TAMANHO',Distribuicoes.Value['TAMANHO']);
         C.Dim('LOTE',NumeroLote);
         C.Execute('INSERT INTO PIT_CANAIS_VENDA_PRODUCAO (PRODUCAO,SITUACAO,CANAL_VENDA,ESTAMPA,COR,TAMANHO,LOTE,SITUACAO_ORIGEM,USUARIO,DATA_HORA) '+
                   '                               VALUES (:PRODUCAO,:SITUACAO,:CANAL_VENDA,:ESTAMPA,:COR,:TAMANHO,:LOTE,NULL,#USER(),#NOW()) '+
                   '                               #RETURN(CANAL_VENDA_PRODUCAO);');
      end;
    end else
      raise Exception.Create('Erro lógico. processo abortado.');;
    Distribuicoes.Next;
  end;

  Situacoes.First;
  C.DimAsData('SITUACOES',Situacoes);
  C.Execute('DELETE FROM SITUACAO_PRODUCAO WHERE SITUACAO IN #MAKELIST(SITUACOES,ITEM)');

  SL.Free;
  NovosLotes.Free;
end;

procedure Andamento(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  Valores: IwtsWriteData;
  C: IwtsCommand;
  NovaSituacaoProducao,CanalVenda: Integer;
begin
  C := DataPool.Open('MILLENIUM');
  Valores := Input.GetParamAsData('VALORES');
  while not Valores.EOF do
  begin
    C.Dim('PRODUCAO',Input.Value['PRODUCAO']);
    C.Dim('SITUACAO',Valores.Value['SITUACAO']);
    C.Dim('LOTE',Valores.Value['LOTE']);
    C.Execute('SELECT CANAL_VENDA FROM PIT_CANAIS_VENDA_PRODUCAO WHERE PRODUCAO=:PRODUCAO AND SITUACAO=:SITUACAO AND LOTE=:LOTE AND CANAL_VENDA IS NOT NULL');
    if not C.EOF then
    begin
      CanalVenda := C.Value['CANAL_VENDA'];

      C.Dim('PRODUCAO',Input.Value['PRODUCAO']);
      C.Dim('LOTE',Valores.Value['LOTE']);
//      C.Dim('FASEI',Valores.Value['FASEI']);                                                                  // AND FASE=:FASEI
      C.Execute('SELECT MAX(SITUACAO) AS SITUACAO FROM SITUACAO_PRODUCAO WHERE PRODUCAO=:PRODUCAO AND LOTE=:LOTE');
      if C.EOF then
        raise Exception.Create('Não foi encontrado o novo numero da situação produção para atrinuir ao canal de vendas');

      NovaSituacaoProducao := C.Value['SITUACAO'];

      C.Dim('PRODUCAO',Input.Value['PRODUCAO']);
      C.Dim('SITUACAO',NovaSituacaoProducao);
      C.Dim('CANAL_VENDA',CanalVenda);
      C.Dim('ESTAMPA',Valores.Value['ESTAMPA']);
      C.Dim('COR',Valores.Value['COR']);
      C.Dim('TAMANHO',Valores.Value['TAMANHO']);
      C.Dim('LOTE',Valores.Value['LOTE']);
      C.Execute('INSERT INTO PIT_CANAIS_VENDA_PRODUCAO (PRODUCAO,SITUACAO,CANAL_VENDA,ESTAMPA,COR,TAMANHO,LOTE) '+
                '                               VALUES (:PRODUCAO,:SITUACAO,:CANAL_VENDA,:ESTAMPA,:COR,:TAMANHO,:LOTE) '+
                '                               #RETURN(CANAL_VENDA_PRODUCAO);');
    end;
    Valores.Next;
  end;
end;

procedure EVNovaSituacao_producao(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  C,N: IwtsCommand;
  CanalVenda: Integer;
begin
  if VarNotValid(Input.Value['SITUACAO_PRODUCAO_ORIGEM']) then
    Exit;

  C := DataPool.Open('MILLENIUM');
  N := DataPool.Open('MILLENIUM');
  
  //Se situação produção antiga tem, devemos copiar os valores para nova situacao produção
  C.Dim('SITUACAO',Input.Value['SITUACAO_PRODUCAO_ORIGEM']);
  C.Execute('SELECT CANAL_VENDA FROM PIT_CANAIS_VENDA_PRODUCAO WHERE SITUACAO=:SITUACAO AND CANAL_VENDA IS NOT NULL');
  if not C.EOF then
  begin
    CanalVenda := C.Value['CANAL_VENDA'];

    N.Dim('SITUACAO',Input.Value['SITUACAO_PRODUCAO_DESTINO']);
    N.Execute('SELECT * FROM SITUACAO_PRODUCAO WHERE SITUACAO=:SITUACAO');

    C.Dim('PRODUCAO',N.Value['PRODUCAO']);
    C.Dim('SITUACAO',N.Value['SITUACAO']);
    C.Dim('CANAL_VENDA',CanalVenda);
    C.Dim('ESTAMPA',N.Value['ESTAMPA']);
    C.Dim('COR',N.Value['COR']);
    C.Dim('TAMANHO',N.Value['TAMANHO']);
    C.Dim('LOTE',N.Value['LOTE']);
    C.Dim('SITUACAO_ORIGEM',Input.Value['SITUACAO_PRODUCAO_ORIGEM']);
    C.Execute('INSERT INTO PIT_CANAIS_VENDA_PRODUCAO (PRODUCAO,SITUACAO,CANAL_VENDA,ESTAMPA,COR,TAMANHO,LOTE,SITUACAO_ORIGEM,USUARIO,DATA_HORA) '+
              '                               VALUES (:PRODUCAO,:SITUACAO,:CANAL_VENDA,:ESTAMPA,:COR,:TAMANHO,:LOTE,:SITUACAO_ORIGEM,#USER(),#NOW()) '+
              '                               #RETURN(CANAL_VENDA_PRODUCAO);');
  end;
end;

initialization
  wtsRegisterProc('PRODUCAO.DISTIBRUIRLOTES',DistibruirLotes);
  wtsRegisterProc('PRODUCAO.Andamento',Andamento);
  wtsRegisterProc('PRODUCAO.ev_nova_situacao_producao',EVNovaSituacao_producao);

end.
