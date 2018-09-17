unit CSVUtils;

interface {********************************************************************}

type
  TCSVStrings = array of string;
  TCSVValues = array of record
    Text: PChar;
    Length: Integer;
  end;

function CSVEscape(Value: PChar; ValueLen: Integer; Escaped: PChar; EscapedLen: Integer; Quoter: Char = '"'; Quote: Boolean = True): Integer; overload;
function CSVEscape(const Value: string; const Quoter: Char = '"'; const Quote: Boolean = True): string; overload;
procedure CSVSplitValues(const TextLine: string; const Delimiter, Quoter: Char; var Values: TCSVStrings); overload;
function CSVSplitValues(const Text: string; var Index: Integer; const Delimiter, Quoter: Char; var Values: TCSVValues; const TextComplete: Boolean = True): Boolean; overload;
function CSVUnescape(const Text: string; const Quoter: Char = '"'): string; overload;
function CSVUnescape(const Text: PChar; const Length: Integer; const Quoter: Char = '"'): string; overload;
function CSVUnescape(Value: PChar; ValueLen: Integer; Unescaped: PChar; UnescapedLen: Integer; Quoter: Char = '"'): Integer; overload;

implementation {***************************************************************}

uses
  Windows,
  SysUtils, SysConst;

function CSVEscape(Value: PChar; ValueLen: Integer; Escaped: PChar; EscapedLen: Integer; Quoter: Char = '"'; Quote: Boolean = True): Integer;
begin
  if (Assigned(Escaped)) then
  begin
    if (EscapedLen < 1) then
      Exit(0); // Too few space in Escaped!
    Escaped^ := Quoter; Inc(Escaped); Dec(EscapedLen);
  end;
  Result := 1;

  while (ValueLen > 0) do
  begin
    if (Assigned(Escaped)) then
    begin
      if (EscapedLen < 1) then
        Exit(0); // Too few space in Escaped!
      Escaped^ := Value^; Inc(Escaped); Dec(EscapedLen);
    end;
    Inc(Result);
    if (Value^ = Quoter) then
    begin
      if (Assigned(Escaped)) then
      begin
        if (EscapedLen < 1) then
          Exit(0); // Too few space in Escaped!
        Escaped^ := Quoter; Inc(Escaped); Dec(EscapedLen);
      end;
      Inc(Result);
    end;
    Inc(Value);
    Dec(ValueLen);
  end;

  if (Assigned(Escaped)) then
  begin
    if (EscapedLen < 1) then
      Exit(0); // Too few space in Escaped!
    Escaped^ := Quoter;
  end;
  Inc(Result);
end;

function CSVEscape(const Value: string; const Quoter: Char = '"'; const Quote: Boolean = True): string;
var
  Len: Integer;
begin
  Len := CSVEscape(PChar(Value), Length(Value), nil, 0, '"', Quote);
  SetLength(Result, Len);
  CSVEscape(PChar(Value), Length(Value), PChar(Result), Len, '"', Quote);
end;

procedure CSVSplitValues(const TextLine: string; const Delimiter, Quoter: Char; var Values: TCSVStrings);
var
  I, Index: Integer;
  CSVValues: TCSVValues;
begin
  Index := 1;
  CSVSplitValues(TextLine, Index, Delimiter, Quoter, CSVValues);
  SetLength(Values, Length(CSVValues));
  for I := 0 to Length(Values) - 1 do
  begin
    SetLength(Values[I], CSVUnescape(CSVValues[I].Text, CSVValues[I].Length, nil, 0));
    CSVUnescape(CSVValues[I].Text, CSVValues[I].Length, PChar(Values[I]), Length(Values[I]));
  end;
end;

function CSVSplitValues(const Text: string; var Index: Integer; const Delimiter, Quoter: Char; var Values: TCSVValues; const TextComplete: Boolean = True): Boolean; overload;
var
  Len: Integer;
  Value: PChar;
  ValueIndex: Integer;
  ValueLen: Integer;
begin
  Result := False;
  if (Index > Length(Text)) then
    SetLength(Values, 0)
  else
  begin
    Value := PChar(@Text[Index]);
    ValueLen := Length(Text) - Index + 1;

    ValueIndex := 0;
    Len := ValueLen;
    if ((Value^ <> #10) and (Value^ <> #13)) then
      while (Len > 0) do
      begin
        if (ValueIndex >= Length(Values)) then
          SetLength(Values, 2 * ValueIndex + 1);
        Values[ValueIndex].Text := Value;

        if (Value^ <> Quoter) then
          while ((Value^ <> #10)
            and (Value^ <> #13)
            and (Value^ <> #26)
            and (Value^ <> Quoter)
            and (Value^ <> Delimiter)
            and (Len > 0)) do
          begin
            Inc(Value); Dec(Len);
          end
        else
        begin
          Inc(Value); Dec(Len); // Initial quoter
          while (Len > 0) do
          begin
            if ((Value^ = #10)
              or (Value^ = #13)
              or (Value^ = #26)) then
              break
            else if (Value^ <> Quoter) then
            begin
              Inc(Value); Dec(Len); // Escaping quoter
            end
            else if ((Len = 1)
              or (Value[1] = Delimiter)
              or (Value[1] = #10)
              or (Value[1] = #13)
              or (Value[1] = #26)) then
            begin
              Inc(Value); Dec(Len); // Final quoter
              break;
            end
            else
            begin
              Inc(Value); Dec(Len); // Escaping quoter
              Inc(Value); Dec(Len); // Quoter
            end;
          end;
        end;
        Values[ValueIndex].Length := ValueLen - Len;
        Dec(ValueLen, Values[ValueIndex].Length);
        Inc(Index, Values[ValueIndex].Length);
        Inc(ValueIndex);
        if ((Len = 0) or (Value^ = #10) or (Value^ = #13) or (Value^ = #26)) then
          break;
        Assert(Value^ = Delimiter);
        Inc(Value); Dec(Len); Dec(ValueLen);
        Inc(Index, 1);
      end;

    if (ValueIndex <> Length(Values)) then
      SetLength(Values, ValueIndex);

    Result := (Len = 0) or (Value^ = #10) or (Value^ = #13) or (Value^ = #26);
  end;
end;

function CSVUnescape(const Text: string; const Quoter: Char = '"'): string;
var
  Len: Integer;
begin
  Len := CSVUnescape(PChar(Text), Length(Text), nil, 0, Quoter);
  SetLength(Result, Len);
  CSVUnescape(PChar(Text), Length(Text), PChar(Result), Length(Result), Quoter);
end;

function CSVUnescape(const Text: PChar; const Length: Integer; const Quoter: Char = '"'): string;
var
  Len: Integer;
begin
  Len := CSVUnescape(Text, Length, nil, 0, Quoter);
  SetLength(Result, Len);
  CSVUnescape(Text, Length, PChar(Result), System.Length(Result), Quoter);
end;

function CSVUnescape(Value: PChar; ValueLen: Integer; Unescaped: PChar; UnescapedLen: Integer; Quoter: Char = '"'): Integer;
begin
  Result := 0;
  if (Value^ = Quoter) then // Initial quoter?
  begin
    Inc(Value); Dec(ValueLen);
  end;
  while (ValueLen > 0) do
  begin
    if (Value^ = Quoter) then
    begin
      if (ValueLen = 1) then // Finial quoter?
        Exit(Result);
      Inc(Value); Dec(ValueLen); // Step over escaping quoter
    end;
    if (Assigned(Unescaped)) then
    begin
      if (UnescapedLen < 1) then
        Exit(0);
      Unescaped^ := Value^; Inc(Unescaped); Dec(UnescapedLen);
    end;
    Inc(Value); Dec(ValueLen); Inc(Result);
  end;
end;

end.

