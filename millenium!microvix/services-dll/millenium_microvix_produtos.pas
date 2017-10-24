unit millenium_microvix_produtos;

interface

uses
  wtsServerObjs, SysUtils, wtsDB, wtsDB_ODBC, DB, WTSDSUtils, Classes, millenium_variants;

implementation

var
  Database:IwtsConnection;

procedure CreateConnectionMSSQL;
var
  dbpath,uname,pass,cp,dbtype,Shadow:String;
  fact:IwtsConnectionFactory;
begin
  ParseDataCurrSource('MICROVIX', dbpath, uname, pass, cp, dbtype, Shadow );

  CreateConnectionFactory(dbtype,fact);

  if fact=nil then
    raise Exception.Create('No driver found for MSSQL');

  Database := fact.CreateConnection('MICROVIX');
end;

procedure Exportar(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  Origem: IwtsCommand;
  Destino: IwtsQuery;
  InicioProcesso: TDateTime;
  Produtos: IwtsData;
  UpdateProd: Boolean;
  
  procedure PrcessaAuxiliar(const TabelaOrigem, CodigoOrigem, DescricaoOrigem, TabelaDestino, CodigoDestino, DescricaoDestino: string);
  begin
    Origem := DataPool.Open('MILLENIUM');
    Origem.Execute(PChar('SELECT DISTINCT '+CodigoOrigem+', '+DescricaoOrigem+' FROM '+TabelaOrigem));

    Destino.Close;
    Destino.Sql := 'INSERT INTO '+TabelaDestino+' ('+CodigoDestino+','+DescricaoDestino+') VALUES (:CODIGO,:DESCRICAO)';
    while not Origem.EOF do
    begin
      try
        Destino.Params.Bind(Destino.Params.IndexOf('CODIGO'),Integer(ftString),Origem.GetFieldByName(PChar(CodigoOrigem)));
        Destino.Params.Bind(Destino.Params.IndexOf('DESCRICAO'),Integer(ftString),Origem.GetFieldByName(PChar(DescricaoOrigem)));
        Destino.ExecSql;
        Origem.Next;
      except on e: exception do
        begin
          if Pos('PRIMARY KEY',e.message) > 0 then
            Origem.Next;
        end;
      end;
    end;
  end;

begin
  InicioProcesso := Now;
  CreateConnectionMSSQL;
  Database.StartTransaction;

  Destino := Database.CreateQuery;
  try
    try
      Produtos := Input.GetParamAsData('PRODUTOS');

      PrcessaAuxiliar('DEPARTAMENTOS','COD_DEPARTAMENTO','DESCRICAO','SETORES','CODIGO','NOME_SETOR');
      PrcessaAuxiliar('DIVISOES','COD_DIVISAO','DESCRICAO','LINHAS','CODIGO','NOME_LINHA');
      PrcessaAuxiliar('MARCAS','COD_MARCA','DESCRICAO','MARCAS','CODIGO','NOME_MARCA');
      PrcessaAuxiliar('COLECOES','COD_COLECAO','DESCRICAO','COLECOES','CODIGO','NOME_COLECAO');
      PrcessaAuxiliar('SUBCOLECOES','COD_SUBCOLECAO','DESCRICAO','ESPESSURAS','CODIGO','NOME_ESPESSURA');
      PrcessaAuxiliar('TIPOS','COD_TIPO','DESCRICAO','CLASSIFICACOES','CODIGO','NOME_CLASSIFICACAO');
      PrcessaAuxiliar('TAMANHOS','TAMANHO','TAMANHO','GRADE1','CODIGO','NOME_GRADE1');
      PrcessaAuxiliar('CORES','COD_COR','DESCRICAO','GRADE2','CODIGO','NOME_GRADE2');
      PrcessaAuxiliar('TABELAS_PRECO','COD_TPRECO','DESCRICAO','PRODUTOS_TABELAS','CODIGO','DESCRICAO');


      PrcessaAuxiliar('CEST','CODCEST','DESCRICAO','CLASSIFICACAO_CEST_PRODUTO','CODIGO','DESCRICAO');

      PrcessaAuxiliar('CLASSIFICACAO_FIS','DESCRICAO','OBS','CLASSIFICACAO_NCM_PRODUTO','CODIGO','DESCRICAO');
      
      //
      Origem.Execute('SELECT MJ.CNPJ, '+
                     '       TV.COD_TPRECO AS TABELA_VENDA, '+
                     '       TC.COD_TPRECO AS TABELA_CUSTO '+
                     'FROM MICROVIX_TABELA_LOJA MJ '+
                     'INNER JOIN TABELAS_PRECO TV ON (TV.TABELA = MJ.TABELA_VENDA) '+
                     'INNER JOIN TABELAS_PRECO TC ON (TC.TABELA = MJ.TABELA_CUSTO)');
      if not Origem.EOF then
      begin
        Destino.Close;
        Destino.Sql := 'INSERT INTO PRODUTOS_TABELAS_LOJAS (CNPJ_LOJA,COD_TABELA_CUSTO,COD_TABELA_VENDA) VALUES (:CNPJ_LOJA,:COD_TABELA_CUSTO,:COD_TABELA_VENDA);';
        while not Origem.EOF do
        begin
          Destino.Params.Bind(0,Integer(ftString),Origem.GetFieldByName('CNPJ'));
          Destino.Params.Bind(1,Integer(ftString),Origem.GetFieldByName('TABELA_CUSTO'));
          Destino.Params.Bind(2,Integer(ftString),Origem.GetFieldByName('TABELA_VENDA'));
          Destino.ExecSql;
          
          Origem.Next;
        end;

        //Origem.Execute('#SET(TBL, ${#CREATETABLE(PRODUTO VARCHAR(50)}); '+
        //               'CREATE INDEX #REPLACE(TBL) ON #REPLACE(TBL) (PRODUTO); '+
        //               '#EACH()
      end;


      UpdateProd := VarToBool(Input.GetParamByName('UPDATE_PROD')) or (Produtos.EOF);
      
      Origem := DataPool.Open('MILLENIUM');
      Origem.DimAsData('PRODUTOS',Input.GetParamAsData('PRODUTOS'));
      Origem.Dim('UPDATE_PROD', UpdateProd);
      Origem.Execute('#CALL MILLENIUM!MICROVIX.PRODUTOS.LISTAR(PRODUTOS=:PRODUTOS,UPDATE_PROD=:UPDATE_PROD);');

      Destino.Sql := 'INSERT INTO PRODUTOS(CODIGO,NOME_PRODUTO,COD_FORNECEDOR,REFERENCIA,COD_AUXILIAR,COD_BARRA,COD_SETOR,COD_LINHA,COD_MARCA,'+
                      '  COD_COLECAO,COD_ESPESSURA,COD_CLASSIFICACAO,COD_GRADE1,COD_GRUPO2,UNIDADE,ORIGEM_MERCADORIA,CEST,NCM,PRECO_CUSTO,PRECO_VENDA) '+
                      'VALUES (:CODIGO,:NOME_PRODUTO,:COD_FORNECEDOR,:REFERENCIA,:COD_AUXILIAR,:COD_BARRA,:COD_SETOR,:COD_LINHA,:COD_MARCA,'+
                      '  :COD_COLECAO,:COD_ESPESSURA,:COD_CLASSIFICACAO,:COD_GRADE1,:COD_GRUPO2,:UNIDADE,:ORIGEM_MERCADORIA,:CEST,:NCM,:PRECO_CUSTO,:PRECO_VENDA)';
      Destino.Prepare;
      
      while not Origem.EOF do
      begin
        Output.NewRecord;
        Output.SetFieldByName('CODIGO',Origem.GetFieldByName('CODIGO'));
        try
          Destino.Params.Bind(Destino.Params.IndexOf('CODIGO'),Integer(ftString),Origem.GetFieldByName('CODIGO'));
          Destino.Params.Bind(Destino.Params.IndexOf('NOME_PRODUTO'),Integer(ftString), Origem.GetFieldByName('NOME_PRODUTO'));
          Destino.Params.Bind(Destino.Params.IndexOf('COD_FORNECEDOR'),Integer(ftString), Origem.GetFieldByName('COD_FORNECEDOR'));
          Destino.Params.Bind(Destino.Params.IndexOf('REFERENCIA'),Integer(ftString), Origem.GetFieldByName('REFERENCIA'));
          Destino.Params.Bind(Destino.Params.IndexOf('COD_AUXILIAR'),Integer(ftString),Origem.GetFieldByName('COD_AUXILIAR'));
          Destino.Params.Bind(Destino.Params.IndexOf('COD_BARRA'),Integer(ftString), Origem.GetFieldByName('COD_BARRA'));
          Destino.Params.Bind(Destino.Params.IndexOf('COD_SETOR'),Integer(ftString), Origem.GetFieldByName('COD_SETOR'));
          Destino.Params.Bind(Destino.Params.IndexOf('COD_LINHA'),Integer(ftString), Origem.GetFieldByName('COD_LINHA'));
          Destino.Params.Bind(Destino.Params.IndexOf('COD_MARCA'),Integer(ftString), Origem.GetFieldByName('COD_MARCA'));
          Destino.Params.Bind(Destino.Params.IndexOf('COD_COLECAO'),Integer(ftString), Origem.GetFieldByName('COD_COLECAO'));
          Destino.Params.Bind(Destino.Params.IndexOf('COD_ESPESSURA'),Integer(ftString), Origem.GetFieldByName('COD_ESPESSURA'));
          Destino.Params.Bind(Destino.Params.IndexOf('COD_CLASSIFICACAO'),Integer(ftString), Origem.GetFieldByName('COD_CLASSIFICACAO'));
          Destino.Params.Bind(Destino.Params.IndexOf('COD_GRADE1'),Integer(ftString), Origem.GetFieldByName('COD_GRADE1'));
          Destino.Params.Bind(Destino.Params.IndexOf('COD_GRUPO2'),Integer(ftString), Origem.GetFieldByName('COD_GRUPO2'));
          Destino.Params.Bind(Destino.Params.IndexOf('UNIDADE'),Integer(ftString), Origem.GetFieldByName('UNIDADE'));
          Destino.Params.Bind(Destino.Params.IndexOf('ORIGEM_MERCADORIA'),Integer(ftInteger), Origem.GetFieldByName('ORIGEM_MERCADORIA'));
          Destino.Params.Bind(Destino.Params.IndexOf('CEST'),Integer(ftString), Origem.GetFieldByName('CEST'));
          Destino.Params.Bind(Destino.Params.IndexOf('NCM'),Integer(ftString), Origem.GetFieldByName('NCM'));
          Destino.Params.Bind(Destino.Params.IndexOf('PRECO_CUSTO'),Integer(ftFloat), Origem.GetFieldByName('PRECO_CUSTO'));
          Destino.Params.Bind(Destino.Params.IndexOf('PRECO_VENDA'),Integer(ftFloat), Origem.GetFieldByName('PRECO_VENDA'));
          Destino.ExecSql;

          Output.SetFieldByName('EXPORTADO',True);
          
        except on e: exception do
          begin
            Output.SetFieldByName('EXPORTADO',False);
            if Pos('PRIMARY KEY',e.message) > 0 then
              Output.SetFieldByName('MENSAGEM','Produto já existe na base de dados da microvix')
            else
              Output.SetFieldByName('MENSAGEM',E.message);
          end;
        end;
        Origem.Next;
      end;
      //
      if UpdateProd then
      begin
        Origem.Dim('ULTIMA_ATUA_PROD',InicioProcesso);
        Origem.Execute('UPDATE MICROVIX SET ULTIMA_ATUA_PROD=:ULTIMA_ATUA_PROD');
      end;
      Database.Commit;
    except
      begin
        Database.Rollback;
        raise
      end;
    end;
  finally
    Database := nil;
    Destino := nil;
  end;
end;

initialization
  wtsRegisterProc('PRODUTOS.Exportar',Exportar);


end.
