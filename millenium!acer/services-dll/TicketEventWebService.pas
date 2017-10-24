// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://css-uat.acer.com/MicroSigaIntegration/TicketEventWebService.asmx?wsdl
//  >Import : http://css-uat.acer.com/MicroSigaIntegration/TicketEventWebService.asmx?wsdl:0
// Encoding : utf-8
// Version  : 1.0
// (06/09/2017 19:40:07 - - $Rev: 7010 $)
// ************************************************************************ //

unit TicketEventWebService;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_OPTN = $0001;


type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Borland types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"
  // !:schema          - "http://www.w3.org/2001/XMLSchema"


  GetInBoundDataResult = TXMLData;      { "http://tempuri.org/"[CplxMxd] }
  GetIssuedDataResult = TXMLData;      { "http://tempuri.org/"[CplxMxd] }
  GetUnIssueDataResult = TXMLData;      { "http://tempuri.org/"[CplxMxd] }
  GetNonCaseIssueDataResult = TXMLData;      { "http://tempuri.org/"[CplxMxd] }
  GetOutBoundDataResult = TXMLData;      { "http://tempuri.org/"[CplxMxd] }
  ResponseXml     = TXMLData;       { "http://tempuri.org/"[CplxMxd] }
  ResponseXml2    = TXMLData;       { "http://tempuri.org/"[CplxMxd] }

  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // soapAction: http://tempuri.org/%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : TicketEventWebServiceSoap
  // service   : TicketEventWebService
  // port      : TicketEventWebServiceSoap
  // URL       : http://css-uat.acer.com/MicroSigaIntegration/TicketEventWebService.asmx
  // ************************************************************************ //
  TicketEventWebServiceSoap = interface(IInvokable)
  ['{C3ADAE94-BB76-F047-473C-40B958D321C2}']
    function  GetInBoundData(const Request: WideString): GetInBoundDataResult; stdcall;
    function  GetIssuedData(const Request: WideString): GetIssuedDataResult; stdcall;
    function  GetUnIssueData(const Request: WideString): GetUnIssueDataResult; stdcall;
    function  GetNonCaseIssueData(const Request: WideString): GetNonCaseIssueDataResult; stdcall;
    function  GetOutBoundData(const Request: WideString): GetOutBoundDataResult; stdcall;
    function  UpdateFileACKStatus(const ResponseXml: ResponseXml): WideString; stdcall;
    function  UpdateTicketACKStatus(const ResponseXml: ResponseXml2): WideString; stdcall;
  end;

function GetTicketEventWebServiceSoap(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): TicketEventWebServiceSoap;


implementation
  uses SysUtils;

function GetTicketEventWebServiceSoap(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): TicketEventWebServiceSoap;
const
  defWSDL = 'http://css-uat.acer.com/MicroSigaIntegration/TicketEventWebService.asmx?wsdl';
  defURL  = 'http://css-uat.acer.com/MicroSigaIntegration/TicketEventWebService.asmx';
  defSvc  = 'TicketEventWebService';
  defPrt  = 'TicketEventWebServiceSoap';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as TicketEventWebServiceSoap);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;


initialization
  InvRegistry.RegisterInterface(TypeInfo(TicketEventWebServiceSoap), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(TicketEventWebServiceSoap), 'http://tempuri.org/%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(TicketEventWebServiceSoap), ioDocument);
  RemClassRegistry.RegisterXSInfo(TypeInfo(GetInBoundDataResult), 'http://tempuri.org/', 'GetInBoundDataResult');
  RemClassRegistry.RegisterXSInfo(TypeInfo(GetIssuedDataResult), 'http://tempuri.org/', 'GetIssuedDataResult');
  RemClassRegistry.RegisterXSInfo(TypeInfo(GetUnIssueDataResult), 'http://tempuri.org/', 'GetUnIssueDataResult');
  RemClassRegistry.RegisterXSInfo(TypeInfo(GetNonCaseIssueDataResult), 'http://tempuri.org/', 'GetNonCaseIssueDataResult');
  RemClassRegistry.RegisterXSInfo(TypeInfo(GetOutBoundDataResult), 'http://tempuri.org/', 'GetOutBoundDataResult');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ResponseXml), 'http://tempuri.org/', 'ResponseXml');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ResponseXml2), 'http://tempuri.org/', 'ResponseXml2', 'ResponseXml');

end.