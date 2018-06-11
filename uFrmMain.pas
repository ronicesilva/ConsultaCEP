unit uFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask, uConsultaCEP;

type
  TFrmMain = class(TForm)
    PanelConsulta: TPanel;
    RadioGroupTipoConsulta: TRadioGroup;
    GroupBoxDados: TGroupBox;
    LabelCEP: TLabel;
    LabelLogradouro: TLabel;
    LabelLocalidade: TLabel;
    LabelUF: TLabel;
    MaskEditCEP: TMaskEdit;
    EditLogradouro: TEdit;
    EditLocalidade: TEdit;
    EditUF: TEdit;
    GroupBoxRetorno: TGroupBox;
    MemoJSONRetorno: TMemo;
    ButtonConsultar: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure SetEnabledControls;
    procedure DoOnClickRadioGroupTipoConsulta(Sender: TObject);

    procedure DoOnClickButtonConsultar(Sender: TObject);

    procedure Consultar;

    procedure ClearRetorno;
    procedure SetCaptionRetorno(_AQuantidade: Integer = -1);
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  uConsultaCEPManager;

{$R *.dfm}

{ TFrmMain }

procedure TFrmMain.ClearRetorno;
begin
  MemoJSONRetorno.Clear;
  SetCaptionRetorno;
end;

procedure TFrmMain.Consultar;
var
  AConsultaCEPEnderecoList: TConsultaCEPEnderecoList;
begin
  try
    ClearRetorno;

    try
      if RadioGroupTipoConsulta.ItemIndex = 0 then
        AConsultaCEPEnderecoList := TConsultaCEPManager.ConsultarEnderecoPeloCEP(MaskEditCEP.Text)
      else AConsultaCEPEnderecoList := TConsultaCEPManager.ConsultarCEPPeloEndereco(EditUF.Text, EditLocalidade.Text, EditLogradouro.Text);

      if Assigned(AConsultaCEPEnderecoList) then
      begin
        SetCaptionRetorno(AConsultaCEPEnderecoList.Count);
        MemoJSONRetorno.Lines.Add(AConsultaCEPEnderecoList.ToString);
      end
      else SetCaptionRetorno(0);
    finally
      AConsultaCEPEnderecoList.Free;
    end;
  except
    on e: Exception do
      MessageDlg(e.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFrmMain.DoOnClickButtonConsultar(Sender: TObject);
begin
  Consultar;
end;

procedure TFrmMain.DoOnClickRadioGroupTipoConsulta(Sender: TObject);
begin
  SetEnabledControls;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  RadioGroupTipoConsulta.OnClick := DoOnClickRadioGroupTipoConsulta;
  RadioGroupTipoConsulta.ItemIndex := 0;
  RadioGroupTipoConsulta.OnClick(Self);

  ButtonConsultar.OnClick := DoOnClickButtonConsultar;
end;

procedure TFrmMain.SetCaptionRetorno(_AQuantidade: Integer);
begin
  if _AQuantidade < 0 then
    GroupBoxRetorno.Caption := ' Retorno '
  else if _AQuantidade = 1 then
    GroupBoxRetorno.Caption := Format(' Retorno (%d registro) ', [_AQuantidade])
  else GroupBoxRetorno.Caption := Format(' Retorno (%d registros) ', [_AQuantidade]);
end;

procedure TFrmMain.SetEnabledControls;
begin
  LabelCEP.Enabled := RadioGroupTipoConsulta.ItemIndex = 0;
  MaskEditCEP.Enabled := RadioGroupTipoConsulta.ItemIndex = 0;

  LabelLogradouro.Enabled := RadioGroupTipoConsulta.ItemIndex = 1;
  EditLogradouro.Enabled := RadioGroupTipoConsulta.ItemIndex = 1;
  LabelLocalidade.Enabled := RadioGroupTipoConsulta.ItemIndex = 1;
  EditLocalidade.Enabled := RadioGroupTipoConsulta.ItemIndex = 1;
  LabelUF.Enabled := RadioGroupTipoConsulta.ItemIndex = 1;
  EditUF.Enabled := RadioGroupTipoConsulta.ItemIndex = 1;

  if MaskEditCEP.CanFocus then
    ActiveControl := MaskEditCEP
  else if EditLogradouro.CanFocus then
    ActiveControl := EditLogradouro;
end;

end.
