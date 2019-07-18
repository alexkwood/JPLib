﻿unit JPL.RTTI;

interface

uses 
  Winapi.Windows, System.SysUtils, System.Classes,
  //Dialogs,
  System.Rtti, System.TypInfo;




function GetPropertyAsObject(const Obj: TObject; const PropertyName: string): TObject;
function TryGetPropertyAsObject(const Obj: TObject; const PropertyName: string; out OutObj: TObject): Boolean;

function GetPropertyAsClass(const Obj: TObject; const PropertyName: string): TClass;
function TryGetPropertyAsClass(const Obj: TObject; const PropertyName: string; out OutClass: TClass): Boolean;

function SetPropertyText(Obj: TObject; PropertyName: string; Text: string): Boolean;

  
implementation


function SetPropertyText(Obj: TObject; PropertyName: string; Text: string): Boolean;
var
  RContext: TRttiContext;
  RType: TRttiType;
  RProperty: TRttiProperty;
  Kind: TTypeKind;
  UPropName: string;
begin
  Result := False;
  if not Assigned(Obj) then Exit;
  UPropName := UpperCase(PropertyName);


  RContext := TRttiContext.Create;
  try
    RType := RContext.GetType(Obj.ClassType);

    for RProperty in RType.GetProperties do
    begin
      if UpperCase(RProperty.Name) = UPropName then
      begin
        if not RProperty.IsWritable then Exit;
        Kind := RProperty.GetValue(Obj).Kind;
        if Kind <> tkUString then Exit;
        RProperty.SetValue(Obj, Text);
        Result := True;
      end;
    end;

  finally
    RContext.Free;
  end;

end;


function GetPropertyAsObject(const Obj: TObject; const PropertyName: string): TObject;
var
  RContext: TRttiContext;
  RType: TRttiType;
  RProperty: TRttiProperty;
  UPropName: string;
begin
  Result := nil;
  if not Assigned(Obj) then Exit;
  UPropName := UpperCase(PropertyName);

  RContext := TRttiContext.Create;
  try
    RType := RContext.GetType(Obj.ClassType);

    for RProperty in RType.GetProperties do
    begin
      if UpperCase(RProperty.Name) = UPropName then
      begin
        if RProperty.PropertyType.TypeKind = tkClass then Result := RProperty.GetValue(Obj).AsType<TObject>;
        Break;
      end;
    end;

  finally
    RContext.Free;
  end;

end;

function TryGetPropertyAsObject(const Obj: TObject; const PropertyName: string; out OutObj: TObject): Boolean;
begin
  OutObj := GetPropertyAsObject(Obj, PropertyName);
  Result := OutObj <> nil;
end;


function GetPropertyAsClass(const Obj: TObject; const PropertyName: string): TClass;
var
  RContext: TRttiContext;
  RType: TRttiType;
  RProperty: TRttiProperty;
  UPropName: string;
begin
  Result := nil;
  if not Assigned(Obj) then Exit;
  UPropName := UpperCase(PropertyName);

  RContext := TRttiContext.Create;
  try
    RType := RContext.GetType(Obj.ClassType);

    for RProperty in RType.GetProperties do
    begin
      if UpperCase(RProperty.Name) = UPropName then
      begin
        if RProperty.PropertyType.TypeKind = tkClass then Result := TRttiInstanceType(RProperty.PropertyType).MetaclassType;
        Break;
      end;
    end;

  finally
    RContext.Free;
  end;

end;

function TryGetPropertyAsClass(const Obj: TObject; const PropertyName: string; out OutClass: TClass): Boolean;
begin
  OutClass := GetPropertyAsClass(Obj, PropertyName);
  Result := OutClass <> nil;
end;


end.