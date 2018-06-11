unit uConsultaCEPManager;

interface

uses
  uConsultaCEP;

type
  TConsultaCEPManager = class
  public
    class function ConsultarEnderecoPeloCEP(_ACEP: String): TConsultaCEPEnderecoList;
    class function ConsultarCEPPeloEndereco(_AUF, _ACidade, _ALogradouro: String): TConsultaCEPEnderecoList;
  end;

implementation

{ TConsultaCEPManager }

class function TConsultaCEPManager.ConsultarCEPPeloEndereco(_AUF, _ACidade, _ALogradouro: String): TConsultaCEPEnderecoList;
var
  AConsultaCEP: TConsultaCEP;
begin
  AConsultaCEP := TConsultaCEP.Create;
  try
    Result := AConsultaCEP.ConsultarCEPPeloEndereco(_AUF, _ACidade, _ALogradouro);
  finally
    AConsultaCEP.Free;
  end;
end;

class function TConsultaCEPManager.ConsultarEnderecoPeloCEP(_ACEP: String): TConsultaCEPEnderecoList;
var
  AConsultaCEP: TConsultaCEP;
begin
  AConsultaCEP := TConsultaCEP.Create;
  try
    Result := AConsultaCEP.ConsultarEnderecoPeloCEP(_ACEP);
  finally
    AConsultaCEP.Free;
  end;
end;

end.
