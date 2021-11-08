unit Customer.Controller;

interface

uses
  MVCFramework, MVCFramework.Commons, MVCFramework.Serializer.Commons,
  MVCFramework.ActiveRecord, System.Generics.Collections,
  Redis.Client,
  Redis.Commons,
  Redis.NetLib.indy,
  Redis.Values;

type

  [MVCPath('/api')]
  TCustomerController = class(TMVCController)
  public
    [MVCPath('/customer/($id)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetCustomerByID(id : Integer);


    constructor Create; override;
    destructor Destroy; override;

  end;

implementation

uses
  System.SysUtils, MVCFramework.Logger, System.StrUtils, Factory.Connection,
  Model.Customer;

procedure TCustomerController.GetCustomerByID(id : Integer);
var
  LCustomers : TCustomerModel;
  LRedisClient : IRedisClient;
  LValue : TRedisString;
begin

  LRedisClient := NewRedisClient();

  LValue := LRedisClient.GET(id.ToString);
  if LValue.HasValue then
  begin
    Writeln('Utilizando Cache Redis');
    Render(LValue.Value);
    Exit;
  end;


  LCustomers := TMVCActiveRecord.GetByPK<TCustomerModel>(id);
  Writeln('Acessando banco de dados!');

  LRedisClient.&SET(id.ToString, Serializer.SerializeObject(LCustomers), 10);
  Render(LCustomers)
end;

constructor TCustomerController.Create;
begin
  inherited;
  ActiveRecordConnectionsRegistry.AddDefaultConnection(TFDConnectionFactory.Connection);
end;


destructor TCustomerController.Destroy;
begin
  ActiveRecordConnectionsRegistry.RemoveDefaultConnection;
  inherited;
end;

end.
