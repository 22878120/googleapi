{==============================================================================|
|������: Google API � Delphi                                                   |
|==============================================================================|
|unit: GFeedBurner                                                             |
|==============================================================================|
|��������: ������ ��� ��������� ������ ������� � FeedBurner.                   |
|==============================================================================|
|�����������:                                                                  |
|1. ��� ������ � HTTP-���������� ������������ ���������� Synapse (httpsend.pas)|
|2. ��� �������� XML-���������� ������������ ���������� NativeXML              |
|==============================================================================|
| �����: Vlad. (vlad383@gmail.com)                                             |
| ����:                                                                        |
| ������: ��. ����                                                             |
| Copyright (c) 2009-2010 WebDelphi.ru                                         |
|==============================================================================|
| ������������ ����������                                                      |
|==============================================================================|
| ������ ����������� ����������� ��������������� ���� ���ܻ, ��� ������ ����   |
| ��������, ���� ���������� ��� ���������������, �������, �� �� �������������  |
| ���������� �������� �����������, ������������ �� ��� ����������� ����������  |
| � ����������� ����. �� � ����� ������ ������ ��� ��������������� �� �����    |
| ��������������� �� ����� � ���������� ������, ������� ��� ������ ����������  |
| �� ����������� ����������, �������� ��� �����, ��������� ��, �������         |
| �������� ��� ��������� � ����������� ������������ ��� ��������������         |
| ������������ ����������� ��� ����� ���������� � ����������� ������������.    |
|                                                                              |
| This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF        |
| ANY KIND, either express or implied. |                                       |
|==============================================================================|
| ���������� ����������                                                        |
|==============================================================================|
| ��������� ���������� ������ ����� ����� � ����������� �� ������:             |
| http://github.com/googleapi                                                  |
|==============================================================================|
| ������� ������                                                               |
|==============================================================================|
|                                                                              |
|==============================================================================}
unit GFeedBurner;

interface

uses Windows,SysUtils, Classes, Dialogs,wininet,
     DateUtils, StrUtils,NativeXML;

resourcestring
  rsErrDate =      '���� %s �� ����� ��������������, ��� ��� ��� ������� �������.';
  rsErrDateRange = '��������� ���� �� ����� ���� ������ ��������.';
  rsErrEntry = '������������ ��� XML-����. ��� ���� ������ ��� <entry>';

const
  {������ ������}
  GFeedBurnerVersion = 0.1;
  {������ URL ��� ������� � �������� API}
  AwaAPIParamURL = 'api/awareness/%s/%s';
  DateFormat = 'YYYY-MM-DD';
  APIVersion='1.0';

type
{���������� ���� Entry ��� ������� GetFeedData}
 TBasicEntry = class(TCollectionItem)
  private
   Fdate: TDate;
   Fcirculation: integer;
   Fhits: integer;
   Freach: integer;
   Fdownloads: integer;
   FNode: TXMLNode;
  procedure SetNode(const Value: TXMLNode);
  public
   constructor Create(Collection: TCollection);override;
   procedure ParseXML(Node:TXMLNode);
   property Date: TDate read FDate;//���� �� ������� �������� ������
   property Circulation: integer read FCirculation;//�������������� ���������� �����, ��������� �� ���
   property Hits: integer read FHits;//���������� �������� ������ �� ����
   property Reach: integer read FReach;//����� ���������
   property Downloads: integer read FDownloads;//���������� ������� ������
   property Node: TXMLNode read FNode write SetNode;//���� XML ��� �������
 end;

  TFeedBurner = class;
  TItemChangeEvent = procedure(Item: TCollectionItem) of object;

  TFeedData = class(TCollection)
  private
    FFeedBurner: TFeedBurner;
    FOnItemChange: TItemChangeEvent;
    function GetItem(Index: Integer): TBasicEntry;
    procedure SetItem(Index: Integer; const Value: TBasicEntry);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
    procedure DoItemChange(Item: TCollectionItem); dynamic;
  public
    constructor Create(FeedBurner: TFeedBurner);
    function Add: TBasicEntry;
   property Items[Index: Integer]: TBasicEntry read GetItem write SetItem; default;
  published
    property OnItemChange: TItemChangeEvent read FOnItemChange write FOnItemChange;
end;


  EFeedBurner = class(Exception)
  public

  end;

//type
  TSender = class(TObject)
  public
    constructor Create;
    function SendRequest(const Method {����� �������� ������� GET ��� POST},
                               ParamsStr: string {������ ����������}): AnsiString;
end;

//type
  TRangeType = (rtContinuous,rtDescrete);

//type
  TDateRange = class(TStringList)
  public
    procedure Add(Date:TDate);overload;
    procedure AddRange(StartDate,EndDate: TDate;RangeType:TRangeType=rtContinuous);
end;

//type
  TFeedBurner = class(TComponent)
  private
     FFeedURL: string;//URL ����, ��������, http://feeds.feedburner.com/myDelphi
     Furi: string;
     FDates: TDateRange;
     FFeedData:TFeedData;//������ �� ����
     function GetServerDate(aDate: TDate):string;
    procedure SetFeedData(const Value: TFeedData);
    procedure SetRange(const Value: TDateRange);
    procedure SetFeedURL(const Value: string);
    //�������� �� ������ ��� ������������ ������� ��� ������������� � �������
    function GetDateRangeParam(index:integer):string;
  public
     constructor Create(AOwner: TComponent);override;
     procedure GetFeedData();
     destructor Destroy;override;
     property   FeedData:TFeedData read FFeedData write SetFeedData;
     property   DateRange:TDateRange read FDates write SetRange;
     property   FeedURL: string read FFeedURL write SetFeedURL;
end;

implementation

{ TFeedBurner }

constructor TFeedBurner.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFeedData:=TFeedData.Create(self);
  FDates:=TDateRange.Create;
end;

destructor TFeedBurner.Destroy;
begin
  FFeedData.Destroy;
  inherited;
end;

function TFeedBurner.GetDateRangeParam(index: integer): string;
begin
  if (index>FDates.Count-1)or(index<0) then Exit;
  Result:='dates='+FDates[index];
end;

procedure TFeedBurner.GetFeedData;
const APIMethod = 'GetFeedData';
var   XMLDoc:TNativeXML;
      Params: string;
      i,j:integer;
      List:TXMLNodeList;
begin
  XMLDoc:=TNativeXml.Create;


  with TSender.Create do
    begin
      if FDates.Count>0 then
        begin
          List:=TXmlNodeList.Create;
          for i:= 0 to FDates.Count - 1 do
            begin
              XMLDoc.ReadFromString(SendRequest('GET',Format(AwaAPIParamURL,[APIVersion,APIMethod+'?uri='+FURI+'&'+GetDateRangeParam(i)])));
              List.Clear;
              XMLDoc.Root.NodeByName('feed').NodesByName('entry',List);
              for j:=0 to List.Count - 1 do
                FFeedData.Add.Node:=List[j]
            end;
          FreeAndNil(List);
        end
      else
        begin
          XMLDoc.ReadFromString(SendRequest('GET',Format(AwaAPIParamURL,[APIVersion,APIMethod+'?uri='+FURI])));
          FFeedData.Add.Node:=XMLDoc.Root.NodeByName('feed').NodeByName('entry');
        end;
    end;

  FreeAndNil(XMLDoc)
end;

function TFeedBurner.GetServerDate(aDate: TDate): string;
begin
  Result:=FormatDateTime(DateFormat,aDate);
end;

procedure TFeedBurner.SetFeedData(const Value: TFeedData);
begin
  FFeedData.Assign(Value);
end;

procedure TFeedBurner.SetFeedURL(const Value: string);
var s:string;
begin
  FFeedURL:=Value;
  s:=ReverseString(FFeedURL);
  Furi:=ReverseString(Copy(s,1,pos('/',s)-1));
end;

procedure TFeedBurner.SetRange(const Value: TDateRange);
begin
  FDates.Assign(Value);
end;

{ TSender }

{ TSender }

constructor TSender.Create;
begin
  inherited Create;
end;

function TSender.SendRequest(const Method, ParamsStr: string): AnsiString;
  function DataAvailable(hRequest: pointer; out Size : cardinal): boolean;
  begin
    result := wininet.InternetQueryDataAvailable(hRequest, Size, 0, 0);
  end;
var hInternet,hConnect,hRequest : Pointer;
    dwBytesRead,I,L : Cardinal;
begin
try
 hInternet := InternetOpen(PChar('GFeedBurner'),INTERNET_OPEN_TYPE_PRECONFIG,Nil,Nil,0);
 if Assigned(hInternet) then
    begin
      //'http:///api/awareness/%s/%s';
      //��������� ������
      hConnect := InternetConnect(hInternet,PChar('feedburner.google.com'),
                                  INTERNET_DEFAULT_HTTP_PORT,nil,nil,
                                  INTERNET_SERVICE_HTTP,0,1);
      if Assigned(hConnect) then
        begin
          //��������� ������
          hRequest := HttpOpenRequest(hConnect,PChar(uppercase(Method)),
                      PChar(ParamsStr),
                      HTTP_VERSION,nil,Nil,INTERNET_FLAG_RELOAD or
                      INTERNET_FLAG_NO_CACHE_WRITE or
                      INTERNET_FLAG_PRAGMA_NOCACHE or
                      INTERNET_FLAG_KEEP_CONNECTION, 1);
          if Assigned(hRequest) then
            begin
              //���������� ������
              I := 1;
              if HttpSendRequest(hRequest,nil,0,nil,0) then
                begin
                  repeat
                  DataAvailable(hRequest, L);//�������� ���-�� ����������� ������
                  if L = 0 then break;
                  SetLength(Result,L + I);
                  if InternetReadFile(hRequest,@Result[I],sizeof(L),dwBytesRead) then//�������� ������ � �������
                  else break;
                  inc(I,dwBytesRead);
                  until dwBytesRead = 0;
                  Result[I] := #0;
                end;
            end;
            InternetCloseHandle(hRequest);
        end;
        InternetCloseHandle(hConnect);
    end;
    InternetCloseHandle(hInternet);
except
  InternetCloseHandle(hRequest);
  InternetCloseHandle(hConnect);
  InternetCloseHandle(hInternet);
end;
end;


{ TDateRange }

procedure TDateRange.Add(Date: TDate);
begin
  if Date>Now then
    raise EFeedBurner.CreateFmt(rsErrDate,[DateToStr(Trunc(Date))]);
    AddRange(Date,Date);
end;

procedure TDateRange.AddRange(StartDate, EndDate:TDate;RangeType:TRangeType);
var i:integer;
    DateStr:string;
begin
  if (StartDate>Now) then
    raise EFeedBurner.CreateFmt(rsErrDate,[DateToStr(Trunc(StartDate))]);
  if (EndDate>Now) then
    raise EFeedBurner.CreateFmt(rsErrDate,[DateToStr(Trunc(EndDate))]);
  if StartDate>EndDate then
    raise EFeedBurner.Create(rsErrDateRange)
  else
    if StartDate=EndDate then
      begin
        Add(FormatDateTime(DateFormat,StartDate)+'='+FormatDateTime(DateFormat,EndDate));
        Exit;
      end;
  if RangeType=rtContinuous then
    Add(FormatDateTime(DateFormat,StartDate)+','+FormatDateTime(DateFormat,EndDate))
  else
    begin
      DateStr:=FormatDateTime(DateFormat,StartDate);
      for i:=1 to DaysBetween(StartDate,EndDate)-1 do
         DateStr:=DateStr+'/'+FormatDateTime(DateFormat,IncDay(StartDate,i));
      Add(DateStr);
    end;
end;

{ TBasicEntry }


{ TBasicEntry }

constructor TBasicEntry.Create(Collection: TCollection);
begin
  inherited Create(Collection);
end;

procedure TBasicEntry.ParseXML(Node: TXMLNode);
var FormatSet: TFormatSettings;
begin
  if Node=nil then Exit;

  if LowerCase(Node.Name)<>'entry' then
    raise EFeedBurner.Create(rsErrEntry);

  GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, FormatSet);
  FormatSet.DateSeparator := '-';
  FormatSet.ShortDateFormat := DateFormat;
  FDate := StrToDate(Node.ReadAttributeString('date'), FormatSet);

  Fcirculation:=Node.ReadAttributeInteger('circulation');
  Fhits:=Node.ReadAttributeInteger('hits');
  Freach:=Node.ReadAttributeInteger('reach');
  Fdownloads:=Node.ReadAttributeInteger('downloads');

  Changed(false);
end;

procedure TBasicEntry.SetNode(const Value: TXMLNode);
begin
  if FNode<>Value then
    begin
      FNode := Value;
      ParseXML(Node);
    end;
end;

{ TFeedData }

function TFeedData.Add: TBasicEntry;
begin
  Result := TBasicEntry(inherited Add)
end;

constructor TFeedData.Create(FeedBurner: TFeedBurner);
begin
  inherited Create(TBasicEntry);
  FeedBurner := FeedBurner;
end;

procedure TFeedData.DoItemChange(Item: TCollectionItem);
begin
  if Assigned(FOnItemChange) then
    FOnItemChange(Item)
end;

function TFeedData.GetItem(Index: Integer): TBasicEntry;
begin
  Result := TBasicEntry(inherited GetItem(Index))
end;

function TFeedData.GetOwner: TPersistent;
begin
  Result := FFeedBurner
end;

procedure TFeedData.SetItem(Index: Integer; const Value: TBasicEntry);
begin
  inherited SetItem(Index, Value)
end;

procedure TFeedData.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  DoItemChange(Item)
end;

end.
