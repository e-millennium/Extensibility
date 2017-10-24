unit millenium_mmmadeira_movimentacao;

interface

uses
  Windows, Classes, wtsServerObjs, SysUtils, ServerCfgs, millenium_variants;

implementation

procedure Executa(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  Evento,Movimentacao,Produtos,Lancamentos,OrigemContabil: IwtsWriteData;
  ContaContabil: Variant;
  C: IwtsCommand;
begin
  C := DataPool.Open('MILLENIUM');

  C.Dim('EVENTO',Input.GetParamByName('EVENTO'));
  C.Execute('SELECT:EVENTO ME.* FROM MMM_EVENTOS ME '+
            'INNER JOIN EVENTOS E ON (ME.EVENTO = E.EVENTO) '+
            'WHERE ME.EVENTO=:EVENTO AND ME.GERAR_TITULO_EXTRA = TRUE AND E.NF = TRUE;');

  Evento := C.CreateRecordset;

  if Evento.EOF then
    Exit;

  C.Dim('EVENTO',Input.GetParamByName('EVENTO'));
  C.Dim('ROMANEIO',Input.GetParamByName('ROMANEIO'));
  C.Execute('SELECT M.FILIAL,'+
            '       M.CONTA,'+
            '       M.DATA,'+
            '       M.CONTA,'+
            '       CP.TIPO_PGTO,'+
            '       M.FORNECEDOR,'+
            '       M.COD_OPERACAO,'+
            '       M.TIPO_OPERACAO,'+
            '       M.CONDICOES_PGTO,'+
            '       F.CC_DEBITO '+
            'FROM MOVIMENTO M '+
            'LEFT JOIN CONDICOES_PGTO CP ON (CP.CONDICOES_PGTO = M.CONDICOES_PGTO) '+
            'LEFT JOIN NF ON (NF.COD_OPERACAO = M.COD_OPERACAO) AND '+
            '                (NF.TIPO_OPERACAO = M.TIPO_OPERACAO) '+
            'LEFT JOIN FORNECEDORES F ON (F.FORNECEDOR = M.FORNECEDOR) '+
            'WHERE M.EVENTO=:EVENTO AND '+
            '      M.ROMANEIO=:ROMANEIO; ');

  Movimentacao := C.CreateRecordset;

  C.Dim('TIPO_OPERACAO',Movimentacao.GetFieldByName('TIPO_OPERACAO'));
  C.Dim('COD_OPERACAO',Movimentacao.GetFieldByName('COD_OPERACAO'));
  C.Execute('SELECT MAX(E.SIGLA_TITULO_EXTRA||PE.NOTA) AS NF, '+
            '       SUM(PE.QUANTIDADE*PE.PRECO) * AVG(E.PERC_MOVIMENTO/100)  AS TOTAL_PRODUTOS '+
            'FROM MOVIMENTO M '+
            'INNER JOIN PRODUTOS_EVENTOS PE ON (PE.TIPO_OPERACAO = M.TIPO_OPERACAO) AND '+
            '                                  (PE.COD_OPERACAO = M.COD_OPERACAO) '+
            'INNER JOIN MMM_EVENTOS E ON (E.EVENTO = M.EVENTO) '+
            'WHERE PE.TIPO_OPERACAO=:TIPO_OPERACAO AND '+
            '      PE.COD_OPERACAO=:COD_OPERACAO AND '+
            '      PE.QUANTIDADE > 0;');

  Produtos := C.CreateRecordset;

  C.Dim('TIPO_OPERACAO',Movimentacao.GetFieldByName('TIPO_OPERACAO'));
  C.Dim('COD_OPERACAO',Movimentacao.GetFieldByName('COD_OPERACAO'));
  C.Execute('DELETE FROM MMM_MOVIMENTO_LANC WHERE TIPO_OPERACAO=:TIPO_OPERACAO AND COD_OPERACAO=:COD_OPERACAO;');


  C.Dim('CONDICOES_PGTO', Movimentacao.GetFieldByName('CONDICOES_PGTO'));
  C.Dim('TOTAL_PRODUTOS',Produtos.GetFieldByName('TOTAL_PRODUTOS'));
  C.Dim('DATA',Movimentacao.GetFieldByName('DATA'));
  C.Dim('NF',Produtos.GetFieldByName('NF'));
  C.Execute('#CALL MILLENIUM.EVENTOS.GERA_LANCAMENTOS(CONDICOES_PGTO=:CONDICOES_PGTO,VALOR_FINAL=:TOTAL_PRODUTOS,DATA_INICIAL=:DATA,JUROS=0,DOCUMENTO=:NF)');

  Lancamentos := C.CreateRecordset;

  OrigemContabil := DataPool.CreateRecordset('MILLENIUM.TITULOS.ORIGEM_CONTABIL');

  ContaContabil := Evento.GetFieldByName('PCONTA');
  if VarNotValid(ContaContabil) then
    ContaContabil := Movimentacao.GetFieldByName('CC_DEBITO');

  Lancamentos.First;
  while not Lancamentos.EOF do
  begin
    OrigemContabil.Clear;
    if VarIsValid(ContaContabil) then
    begin
      OrigemContabil.New;
      OrigemContabil.SetFieldByName('CONTA_CONTABIL',ContaContabil);
      OrigemContabil.SetFieldByName('VALOR',Lancamentos.GetFieldByName('VALOR_INICIAL'));
      OrigemContabil.SetFieldByName('CENTRO_CUSTOS',Unassigned);
      OrigemContabil.SetFieldByName('HISTORICO',Lancamentos.GetFieldByName('DOCUMENTO'));
      OrigemContabil.Add;
    end;  

    C.Dim('CONTA',Movimentacao.GetFieldByName('CONTA'));
    C.Dim('DATA_EMISSAO',Movimentacao.GetFieldByName('DATA'));
    C.Dim('DATA_VENCIMENTO',Lancamentos.GetFieldByName('DATA_VENCIMENTO'));
    C.Dim('VALOR_INICIAL',Lancamentos.GetFieldByName('VALOR_INICIAL'));
    C.Dim('TIPO_PGTO',Movimentacao.GetFieldByName('TIPO_PGTO'));
    C.Dim('N_DOCUMENTO',Lancamentos.GetFieldByName('DOCUMENTO'));
    C.Dim('FILIAL',Movimentacao.GetFieldByName('FILIAL'));
    C.Dim('TIPO_TITULO_EXTRA',Evento.GetFieldByName('TIPO_TITULO_EXTRA'));
    C.Dim('FORNECEDOR',Movimentacao.GetFieldByName('FORNECEDOR'));
    C.DimAsData('ORIGEM_CONTABIL',OrigemContabil);
    C.Dim('TIPO_OPERACAO',Movimentacao.GetFieldByName('TIPO_OPERACAO'));
    C.Dim('COD_OPERACAO',Movimentacao.GetFieldByName('COD_OPERACAO'));
    C.Execute('#CALL:LANC MILLENIUM.LANCAMENTOS.INCLANCAMENTO('+
              '         CONTA=:CONTA,'+
              '         DATA_EMISSAO=:DATA_EMISSAO,'+
              '         DATA_VENCIMENTO=:DATA_VENCIMENTO,'+
              '         VALOR_INICIAL=:VALOR_INICIAL,'+
              '         TIPO_PGTO=:TIPO_PGTO,'+
              '         N_DOCUMENTO=:N_DOCUMENTO,'+
              '         FILIAL=:FILIAL,'+
              '         EFETUADO=FALSE,'+
              '         OBS="LANÇAMENTO AUTOMATICO NOTA",'+
              '         PREVISAO=FALSE,'+
              '         CREDITO=TRUE,'+
              '         ACRES_DECRES=0,'+
              '         PRORROGADO=FALSE,'+
              '         DEVOLVIDO=FALSE,'+
              '         PROTESTO=FALSE,'+
              '         CARTORIO=FALSE,'+
              '         DESCONTADO=FALSE,'+
              '         TIPO_COBRANCA="C",'+
              '         TIPO=:TIPO_TITULO_EXTRA,'+
              '         GERADOR="F",'+
              '         COD=:FORNECEDOR,'+
              '         TITULO=TRUE,'+
              '         ORIGEM_CONTABIL=:ORIGEM_CONTABIL);'+
              'INSERT INTO MMM_MOVIMENTO_LANC (COD_OPERACAO,TIPO_OPERACAO,LANCAMENTO) VALUES (:COD_OPERACAO,:TIPO_OPERACAO,:LANC.LANCAMENTO) #RETURN(MOVIMENTO_LANCA);');

    Lancamentos.Next;
  end;

end;


initialization
   wtsRegisterProc('MOVIMENTACAO.Executa',Executa);

end.
