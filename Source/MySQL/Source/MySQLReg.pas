unit MySQLReg;

interface {********************************************************************}

procedure Register();

implementation {***************************************************************}

uses
  Classes, DesignIntf, DesignEditors,
  MySQLDB, MySQLDBGrid;

procedure Register();
begin
  RegisterComponents('MySQL', [TMySQLConnection, TMySQLQuery, TMySQLDataSet, TMySQLTable, TMySQLMonitor, TMySQLDBGrid]);
end;

end.
