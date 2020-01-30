unit uConsultaCEP;

interface

uses
  System.SysUtils, System.JSON, REST.Client, System.Generics.Collections, IPPeerClient;

const
  URL_PREFIXO = 'http://viacep.com.br/ws/';
  URL_SUFIXO = '/json/';

  JSON_ERRO = 'erro';
  JSON_CEP = 'cep';
  JSON_LOGRADOURO = 'logradouro';
  JSON_COMPLEMENTO = 'complemento';
  JSON_BAIRRO = 'bairro';
  JSON_LOCALIDADE = 'localidade';
  JSON_UF = 'uf';
  JSON_UNIDADE = 'unidade';
  JSON_IBGE = 'ibge';
  JSON_GIA = 'gia';

type
  ECEPInvalidoException = class(Exception);
  EFalhaComunicacaoException = class(Exception);
  EUFInvalidaException = class(Exception);
  ECidadeInvalidaException = class(Exception);
  ELogradouroInvalidoException = class(Exception);
  ECEPNaoLocalizadoException = class(Exception);
  EEnderecoNaoLocalizadoException = class(Exception);

  TConsultaCEPEndereco = class
  strict private
    FLogradouro: String;
    FIBGE: String;
    FBairro: String;
    FUF: String;
    FCEP: String;
    FUnidade: String;
    FComplemento: String;
    FGIA: String;
    FCidade: String;
  public
    function ToString: string;

    property CEP: String read FCEP write FCEP;
    property Logradouro: String read FLogradouro write FLogradouro;
    property Cidade: String read FCidade write FCidade;
    property UF: String read FUF write FUF;
    property Complemento: String read FComplemento write FComplemento;
    property Bairro: String read FBairro write FBairro;
    property Unidade: String read FUnidade write FUnidade;
    property IBGE: String read FIBGE write FIBGE;
    property GIA: String read FGIA write FGIA;
  end;

  TConsultaCEPEnderecoList = class(TObjectList<TConsultaCEPEndereco>)
  public
    function ToString: string;
  end;


  TConsultaCEP = class
  strict private
    FRetornoJSONExecute: string;

    procedure DoRESTRequestAfterExecute(Sender: TCustomRESTRequest);
    procedure Consultar(_AURL: String);
    procedure ValidarCEP(_ACEP: String);
    procedure ValidarEndereco(_AUF, _ACidade, _ALogradouro: String);

    function GetURL(_ACEP: string): string; overload;
    function GetURL(_AUF, _ACidade, _ALogradouro: String): string; overload;

    function ProcessarRetorno: TConsultaCEPEnderecoList;
  public
    constructor Create;

    function ConsultarEnderecoPeloCEP(_ACEP: String): TConsultaCEPEnderecoList;
    function ConsultarCEPPeloEndereco(_AUF, _ACidade, _ALogradouro: String): TConsultaCEPEnderecoList;
  end;

implementation

uses
  REST.Json, System.StrUtils;

function CharInSet(C: AnsiChar; const CharSet: TSysCharSet): Boolean;
begin
  Result := C in CharSet;
end;

function CharIsNum(const C: AnsiChar): Boolean;
begin
  Result := CharInSet(C, ['0'..'9']) ;
end ;

function OnlyNumber(_AValue: String): String;
var
  x : integer ;
  ALenValue : integer;
begin
  Result   := '';
  ALenValue := Length( _AValue ) ;

  for x := 1 to ALenValue  do
  begin
     if CharIsNum(AnsiChar(_AValue[x])) then
        Result := Result + _AValue[x];
  end;
end;

function IsJSONArray(_AJSONStr: String): Boolean;
begin
  Result := Pos('[{', _AJSONStr) > 0;
end;

{ TConsultaCEP }

procedure TConsultaCEP.Consultar(_AURL: String);
var
  ARESTClient: TRESTClient;
  ARESTRequest: TRESTRequest;
  ARESTResponse: TRESTResponse;
begin
  ARESTClient := TRESTClient.Create(_AURL);
  try
    ARESTClient.Accept := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
    ARESTClient.AcceptCharset := 'UTF-8, *;q=0.8';
    ARESTClient.AcceptEncoding := 'identity';
    ARESTClient.ContentType := 'application/json';
    ARESTClient.BaseURL := _AURL;
    ARESTClient.RaiseExceptionOn500 := False;
    ARESTClient.HandleRedirects := True;

    ARESTResponse := TRESTResponse.Create(nil);
    try
      ARESTResponse.ContentType := 'application/json';
      ARESTRequest := TRESTRequest.Create(nil);
      try
        ARESTRequest.Accept := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
        ARESTRequest.AcceptCharset := 'UTF-8, *;q=0.8';
        ARESTRequest.Client := ARESTClient;
        ARESTRequest.Response := ARESTResponse;
        ARESTRequest.SynchronizedEvents := False;
        ARESTRequest.OnAfterExecute := DoRESTRequestAfterExecute;

        try
          ARESTRequest.Execute;
        except
          raise EFalhaComunicacaoException.Create('Falha de comunicação com o servidor.');
        end;
      finally
        ARESTRequest.Free
      end;
    finally
      ARESTResponse.Free;
    end;
  finally
    ARESTClient.Free;
  end;
end;

function TConsultaCEP.ConsultarCEPPeloEndereco(_AUF, _ACidade, _ALogradouro: String): TConsultaCEPEnderecoList;
begin
  Result := nil;

  ValidarEndereco(_AUF, _ACidade, _ALogradouro);
  Consultar(GetURL(_AUF, _ACidade, _ALogradouro));
  Result := ProcessarRetorno;
end;

function TConsultaCEP.ConsultarEnderecoPeloCEP(_ACEP: String): TConsultaCEPEnderecoList;
begin
  Result := nil;

  ValidarCEP(_ACEP);
  Consultar(GetURL(OnlyNumber(_ACEP)));
  Result := ProcessarRetorno;
end;

constructor TConsultaCEP.Create;
begin
  FRetornoJSONExecute := EmptyStr;
end;

procedure TConsultaCEP.DoRESTRequestAfterExecute(Sender: TCustomRESTRequest);
begin
  FRetornoJSONExecute := EmptyStr;

  if Assigned(Sender.Response.JSONValue) then
    FRetornoJSONExecute := TJson.Format(Sender.Response.JSONValue);
end;

function TConsultaCEP.GetURL(_AUF, _ACidade, _ALogradouro: String): string;
var
  ALocalizador: string;
begin
  ALocalizador := Format('%s/%s/%s', [_AUF.Trim, _ACidade.Trim, _ALogradouro.Trim]);
  Result := Concat(URL_PREFIXO, ALocalizador, URL_SUFIXO);
end;

function TConsultaCEP.ProcessarRetorno: TConsultaCEPEnderecoList;

  procedure SetDadosEndereco(_AJsonEndereco: TJSONObject);
  var
    AConsultaCEPEndereco: TConsultaCEPEndereco;
    AJsonPairEndereco: TJSONPair;
  begin
    for AJsonPairEndereco in _AJsonEndereco do
      if SameStr(AJsonPairEndereco.JsonString.Value, JSON_ERRO) then
        raise ECEPNaoLocalizadoException.Create('CEP não localizado.')
      else Break;

    AConsultaCEPEndereco := TConsultaCEPEndereco.Create;
    try
      for AJsonPairEndereco in _AJsonEndereco do
      begin
        if SameStr(AJsonPairEndereco.JsonString.Value, JSON_LOGRADOURO) then
          AConsultaCEPEndereco.Logradouro := AJsonPairEndereco.JsonValue.Value
        else if SameStr(AJsonPairEndereco.JsonString.Value, JSON_COMPLEMENTO) then
          AConsultaCEPEndereco.Complemento := AJsonPairEndereco.JsonValue.Value
        else if SameStr(AJsonPairEndereco.JsonString.Value, JSON_BAIRRO) then
          AConsultaCEPEndereco.Bairro := AJsonPairEndereco.JsonValue.Value
        else if SameStr(AJsonPairEndereco.JsonString.Value, JSON_LOCALIDADE) then
          AConsultaCEPEndereco.Cidade := AJsonPairEndereco.JsonValue.Value
        else if SameStr(AJsonPairEndereco.JsonString.Value, JSON_UF) then
          AConsultaCEPEndereco.UF := AJsonPairEndereco.JsonValue.Value
        else if SameStr(AJsonPairEndereco.JsonString.Value, JSON_CEP) then
          AConsultaCEPEndereco.CEP := AnsiReplaceStr(AJsonPairEndereco.JsonValue.Value, '-', EmptyStr)
        else if SameStr(AJsonPairEndereco.JsonString.Value, JSON_UNIDADE) then
          AConsultaCEPEndereco.Unidade := AJsonPairEndereco.JsonValue.Value
        else if SameStr(AJsonPairEndereco.JsonString.Value, JSON_IBGE) then
          AConsultaCEPEndereco.IBGE := AJsonPairEndereco.JsonValue.Value
        else if SameStr(AJsonPairEndereco.JsonString.Value, JSON_GIA) then
          AConsultaCEPEndereco.GIA := AJsonPairEndereco.JsonValue.Value;
      end;

      Result.Add(AConsultaCEPEndereco);
    except
      AConsultaCEPEndereco.Free;
    end;
  end;

  procedure SetDadosRetorno;
  var
    AJsonObj: TJSONObject;
    AJsonArray: TJSONArray;
    AJsonValue,
    AJsonValueItem: TJSONValue;
    x: Integer;
  begin
    AJsonValue := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(FRetornoJSONExecute), 0) as TJSONValue;
    try
      if AJsonValue is TJSONArray then
      begin
        AJsonArray := TJSONArray(AJsonValue);

        if AJsonArray.Count = 0 then
          raise ECEPNaoLocalizadoException.Create('Endereço não localizado.')
        else
          for AJsonValueItem in AJsonArray do
            SetDadosEndereco(TJSONObject(AJsonValueItem));
      end else
      begin
        AJsonObj := TJSONObject(AJsonValue);
        SetDadosEndereco(AJsonObj);
      end;
    finally
      AJsonValue.Free;
    end;
  end;

begin
  Result := nil;

  if FRetornoJSONExecute = EmptyStr then
    raise EFalhaComunicacaoException.Create('Falha de comunicação com o servidor ou dados inválidos.');

  Result := TConsultaCEPEnderecoList.Create(True);
  SetDadosRetorno;
end;

function TConsultaCEP.GetURL(_ACEP: string): string;
begin
  Result := Concat(URL_PREFIXO, _ACEP.Trim, URL_SUFIXO);
end;

procedure TConsultaCEP.ValidarCEP(_ACEP: String);
begin
  _ACEP := OnlyNumber(_ACEP) ;
  if (_ACEP.Trim = EmptyStr) or (Length(_ACEP.Trim) <> 8) then
    raise ECEPInvalidoException.Create('CEP inválido.');
end;

procedure TConsultaCEP.ValidarEndereco(_AUF, _ACidade, _ALogradouro: String);
begin
  if _AUF.Trim = EmptyStr then
    raise EUFInvalidaException.Create('UF inválida.');

  if (_ACidade.Trim = EmptyStr) or (Length(_ACidade.Trim) < 2) then
    raise ECidadeInvalidaException.Create('Cidade inválida.');

  if (_ALogradouro.Trim = EmptyStr) or (Length(_ALogradouro.Trim) < 2) then
    raise ELogradouroInvalidoException.Create('Logradouro inválido.');
end;

{ TConsultaCEPEndereco }

function TConsultaCEPEndereco.ToString: string;

  function GetText(_ALabel, _AValue: String): string;
  begin
    Result := Format('%s = %s', [_ALabel, _AValue]) + #13+#10;
  end;
begin
  Result := Concat( GetText(JSON_CEP, FCEP),
                    GetText(JSON_LOGRADOURO, FLogradouro),
                    GetText(JSON_LOCALIDADE, FCidade),
                    GetText(JSON_UF, FUF),
                    GetText(JSON_COMPLEMENTO, FComplemento),
                    GetText(JSON_BAIRRO, FBairro),
                    GetText(JSON_UNIDADE, FUnidade),
                    GetText(JSON_IBGE, FIBGE),
                    GetText(JSON_GIA, FGIA) );
end;

{ TConsultaCEPEnderecoList }

function TConsultaCEPEnderecoList.ToString: string;
var
  AConsultaCEPEndereco: TConsultaCEPEndereco;
  ACount: Integer;

  function GetTitleRegistro(_ANroReg: Integer): string;
  begin
    Result := Format('============ REGISTRO %d ============ ', [_ANroReg]);
  end;
begin
  Result := EmptyStr;
  ACount := 1;

  for AConsultaCEPEndereco in Self do
  begin
    if Count > 0 then
      Result := Concat(Result, #13, #10, GetTitleRegistro(ACount),  #13, #10);
    Result := Result + AConsultaCEPEndereco.ToString;
    Inc(ACount);
  end;

  Result := Trim(Result);
end;

end.
