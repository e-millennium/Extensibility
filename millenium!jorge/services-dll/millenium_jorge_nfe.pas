unit millenium_jorge_nfe;

interface

uses
  wtsServerObjs, Classes, XmlNFe;

implementation

procedure ListaStatus(Input:IwtsInput;Output:IwtsOutput;DataPool:IwtsDataPool);
var
  C: IwtsCommand;
  Buf: TStringList;
  XmlNFe: TXmlNFe;
  I: Integer;
  SS: TStringStream;
begin
  C := DataPool.Open('MILLENIUM');

  Buf := TStringList.Create;
  try
    Buf.LoadFromFile('C:\wts\QueryPartilhaSJ.sql');
    C.Execute(Buf.GetText);
    while not C.EOF do
    begin
      Output.NewRecord;
      for I := 0 to C.FieldCount -1 do
        if Output.IndexOfField(PChar(C.FieldName(I))) >-1 then
          Output.SetFieldByName(C.FieldName(I),C.GetFieldByName(PChar(C.FieldName(I))));

      XmlNFe := TXmlNFe.Create;
      try
        SS := TStringStream.Create(C.GetFieldAsString('CONTEUDO'));
        SS.Position := 0;
        if SS.Size > 0 then
          XmlNFe.LoadFromStream(SS);

        for I := 0 to XmlNFe.Total.Count-1 do
        begin
          Output.SetFieldByName('V_ICMS_UF_DEST',XmlNFe.Total.Items[I].vICMSUFDest);
          Output.SetFieldByName('V_ICMS_UF_REMET',XmlNFe.Total.Items[I].vICMSUFRemet);
        end;
      finally
        XmlNFe.Free;
        SS.Free;
      end;
      C.Next;
    end;
  finally
    Buf.Free;
  end;
end;

initialization
  wtsRegisterProc('NFE.Lista_Status', ListaStatus);

end.
