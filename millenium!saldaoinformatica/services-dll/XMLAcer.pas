unit XMLAcer;

interface

uses
  Windows, Classes, SysUtils, XpBase, XpParser, XpDOM, ResUnit, contnrs,UTF8;

type
   TTicketEventDetail = class
   private
     procedure LoadFromNode(ANode: TXpElement);
   public
     SequenceNo:string;
     ToWareHouse:string;
     FromWarehouse:string;
     ProductNumber:string;
     Quantity:Integer;
     SerialNumber:string;
     UnitPrice:Real;
   end;

   TTicketEventDetails = class(TObjectList)
   private
     procedure LoadFromNode(ANode: TXpElement);
    function GetItem(index: Integer): TTicketEventDetail;
   public
     function Add:TTicketEventDetail;
     property Items[index:Integer]: TTicketEventDetail read GetItem;
   end;

   TTicketEventTrailer = class
   private
     procedure LoadFromNode(ANode: TXpElement);
   public
      XMLFileName:string;
      //AckStatus:string;
      //AckRemarks:string;
   end;

   TTicketEventHeader = class
   private
     procedure LoadFromNode(ANode: TXpElement);
   public
      EventType:string;
      CustomerName:string;
      CustomerAddress:string;
      Address2:string;
      District:string;
      CustomerState:string;
      City:string;
      ZipCode:string;
      CustomerType:string;
      CPFCNPJNumber:string;
      StateRegNumber:string;
      PhoneNumber:string;
      Email:string;
      CSSTicketNumber:string;
      WarrantyStatus:string;
      TicketEventDetails:TTicketEventDetails;
      constructor Create;
      destructor Destroy;override;
   end;

   TTicketEventHeaders = class(TObjectList)
   private
     procedure LoadFromNode(ANode: TXpElement);
    function GetItem(index: Integer): TTicketEventHeader;
   public
     function Add:TTicketEventHeader;
     property Items[index:Integer]: TTicketEventHeader read GetItem;
   end;

   TAcerXML = class
   private
     FXmlDocument:string;
     procedure LoadFromNode(ANode: TXpElement);
   public
     TicketEventHeaders: TTicketEventHeaders;
     TicketEventTrailer: TTicketEventTrailer;
     procedure LoadFromStream(AStream: string);
     procedure LoadFromFile(const AFileName:string);
     constructor Create;
     destructor Destroy;override;
   end;

   
implementation

{ TTicketEventHeader }

function GetNodeValue(ANode:TXpElement; ATagName:string): string;
var
   N: TXpElement;
begin
  Result := '';
  N := ANode.FindElement(ATagName);
  if N <> nil then
    Result := N.StringValue;
end;

constructor TTicketEventHeader.Create;
begin
  inherited;
  TicketEventDetails := TTicketEventDetails.Create;
end;

destructor TTicketEventHeader.Destroy;
begin
  TicketEventDetails.Free;
  inherited;
end;

procedure TTicketEventHeader.LoadFromNode(ANode: TXpElement);
begin
  EventType := GetNodeValue(ANode,'EventType');
  CustomerName := GetNodeValue(ANode,'CustomerName');
  CustomerAddress := GetNodeValue(ANode,'CustomerAddress');
  Address2 := GetNodeValue(ANode,'Address2');
  District := GetNodeValue(ANode,'District');
  CustomerState := GetNodeValue(ANode,'CustomerState');
  City := GetNodeValue(ANode,'City');
  ZipCode := GetNodeValue(ANode,'ZipCode');
  CustomerType := GetNodeValue(ANode,'CustomerType');
  CPFCNPJNumber := GetNodeValue(ANode,'CPFCNPJNumber');
  StateRegNumber := GetNodeValue(ANode,'StateRegNumber');
  PhoneNumber := GetNodeValue(ANode,'PhoneNumber');
  Email := GetNodeValue(ANode,'Email');
  CSSTicketNumber := GetNodeValue(ANode,'CSSTicketNumber');
  WarrantyStatus := GetNodeValue(ANode,'WarrantyStatus');

  TicketEventDetails.LoadFromNode(ANode)
end;               

{ TTicketEventHeaders }

function TTicketEventHeaders.Add: TTicketEventHeader;
begin
  Result := TTicketEventHeader.Create;
  inherited Add(Result);
end;

function TTicketEventHeaders.GetItem(index: Integer): TTicketEventHeader;
begin
  Result := TTicketEventHeader(inherited Items[index]);
end;

procedure TTicketEventHeaders.LoadFromNode(ANode: TXpElement);
var
  I: Integer;
begin
  if ANode= nil then
    Exit;
  for I := 0 to ANode.ChildNodes.Length-1 do
  begin
    if SameText((ANode.ChildNodes.Item(I) as TXpElement).TagName,'TicketEventHeader') then
      Add.LoadFromNode(ANode.ChildNodes.Item(I) as TXpElement);
  end;
end;

{ TTicketEventDetail }

procedure TTicketEventDetail.LoadFromNode(ANode: TXpElement);
begin
  if ANode=nil then
    Exit;
  SequenceNo := GetNodeValue(ANode,'SequenceNo');
  ToWareHouse := GetNodeValue(ANode,'ToWareHouse');
  FromWarehouse := GetNodeValue(ANode,'FromWarehouse');
  ProductNumber := GetNodeValue(ANode,'ProductNumber');
  Quantity := StrToInt64Def(GetNodeValue(ANode,'Quantity'),1);
  SerialNumber := GetNodeValue(ANode,'SerialNumber');
  try
    UnitPrice := StrToFloat(GetNodeValue(ANode,'UnitPrice'));
  except
    UnitPrice := 0
  end;
end;

{ TAcerXML }
constructor TAcerXML.Create;
begin
  inherited;
  TicketEventHeaders := TTicketEventHeaders.Create;
  TicketEventTrailer := TTicketEventTrailer.Create;
end;

destructor TAcerXML.Destroy;
begin
  TicketEventHeaders.Free;
  TicketEventTrailer.Free;
  inherited;
end;

procedure TAcerXML.LoadFromStream(AStream: string);
var
  DomXml :TXpObjModel;
  Node: TXpElement;
begin
  DomXml := TXpObjModel.Create(nil);
  try
    try
      DomXml.RaiseErrors := True;
      DomXml.LoadMemory(AStream[1],Length(AStream));
      FXmlDocument := DomXml.XmlDocument;
    except on E:Exception do
      raise Exception.Create('XML com formato inválido ' +#13#10 +#13#10 +'Motivo :'+#13#10 + E.Message);
    end;
    Node := DomXml.Document.DocumentElement.FindElement('XML_ABBS_HEADER');
    LoadFromNode(Node);

    Node := DomXml.Document.DocumentElement.FindElement('TRAILER');
    TicketEventTrailer.LoadFromNode(Node);

  finally
    FreeAndNil(DomXml);
  end;
end;

procedure TAcerXML.LoadFromFile(const AFileName: string);
var
  SS: TStringList;
begin
  SS := TStringList.Create;
  SS.LoadFromFile(AFileName);
  try
    LoadFromStream(UTF8Encode(SS.Text));
  finally
    SS.Free;
  end;
end;

procedure TAcerXML.LoadFromNode(ANode: TXpElement);
begin
  if ANode = nil then
    Exit;

  TicketEventHeaders.LoadFromNode(ANode);
end;

{ TTicketEventDetails }

function TTicketEventDetails.Add: TTicketEventDetail;
begin
  Result := TTicketEventDetail.Create;
  inherited Add(Result);
end;

function TTicketEventDetails.GetItem(index: Integer): TTicketEventDetail;
begin
  Result := TTicketEventDetail(inherited Items[index]);
end;

procedure TTicketEventDetails.LoadFromNode(ANode: TXpElement);
var
  I: Integer;
begin
  if ANode= nil then
    Exit;
  for I := 0 to ANode.ChildNodes.Length-1 do
  begin
    if SameText((ANode.ChildNodes.Item(I) as TXpElement).TagName,'TicketEventDetail') then
      Add.LoadFromNode(ANode.ChildNodes.Item(I) as TXpElement);
  end;
end;

{ TTicketEventTrailer }

procedure TTicketEventTrailer.LoadFromNode(ANode: TXpElement);
begin
  XMLFileName := GetNodeValue(ANode,'FILE_NAME');
 // AckStatus := GetNodeValue(ANode,'AckStatus');
 // AckRemarks := GetNodeValue(ANode,'AckRemarks');
end;

end.
