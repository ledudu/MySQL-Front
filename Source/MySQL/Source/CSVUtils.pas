unit CSVUtils;

interface {********************************************************************}

type
  TCSVStrings = array of string;
  TCSVValues = array of record
    Text: PChar;
    Length: Integer;
  end;

function CSVEscape(Value: PChar; ValueLen: Integer; Escaped: PChar; EscapedLen: Integer; Quoter: Char = '"'): Integer; overload;
function CSVEscape(const Value: string; const Quoter: Char = '"'): string; overload;
procedure CSVSplitValues(const TextLine: string; const Delimiter, Quoter: Char; var Values: TCSVStrings); overload;
function CSVSplitValues(const Text: string; var TextIndex: Integer; const Delimiter, Quoter: Char; var Values: TCSVValues; const TextComplete: Boolean = True): Boolean; overload;
function CSVUnescape(const Text: string; const Quoter: Char = '"'): string; overload;
function CSVUnescape(const Text: PChar; const Length: Integer; const Quoter: Char = '"'): string; overload;
function CSVUnescape(Value: PChar; ValueLen: Integer; Unescaped: PChar; UnescapedLen: Integer; Quoter: Char = '"'): Integer; overload;

implementation {***************************************************************}

uses
  Windows,
  SysUtils, SysConst;

function CSVEscape(Value: PChar; ValueLen: Integer; Escaped: PChar; EscapedLen: Integer; Quoter: Char = '"'): Integer;
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

function CSVEscape(const Value: string; const Quoter: Char = '"'): string;
var
  Len: Integer;
begin
  Len := CSVEscape(PChar(Value), Length(Value), nil, 0, '"');
  SetLength(Result, Len);
  CSVEscape(PChar(Value), Length(Value), PChar(Result), Len, '"');
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

function CSVSplitValues(const Text: string; var TextIndex: Integer; const Delimiter, Quoter: Char; var Values: TCSVValues; const TextComplete: Boolean = True): Boolean; overload;
var
  EOF: Boolean;
  EOL: Boolean;
  TextLen: Integer;
  Value: PChar;
  ValueLen: Integer;
  ValuesIndex: Integer;
begin
  Result := False;
  if (TextIndex > Length(Text)) then
    SetLength(Values, 0)
  else
  begin
    Value := PChar(@Text[TextIndex]);
    ValueLen := Length(Text) - TextIndex + 1;

    ValuesIndex := 0;
    TextLen := ValueLen;
    if ((Value^ <> #10) and (Value^ <> #13)) then
      while (TextLen > 0) do
      begin
        if (ValuesIndex >= Length(Values)) then
          SetLength(Values, 2 * ValuesIndex + 1);
        Values[ValuesIndex].Text := Value;

        if (Value^ = Delimiter) then
          // Do nothing
        else if (Value^ <> Quoter) then
          while ((Value^ <> #10)
            and (Value^ <> #13)
            and (Value^ <> #26)
            and (Value^ <> Quoter)
            and (Value^ <> Delimiter)
            and (TextLen > 0)) do
          begin
            Inc(Value); Dec(TextLen);
          end
        else
        begin
          Inc(Value); Dec(TextLen); // Initial quoter
          while (TextLen > 0) do
          begin
            if (Value^ <> Quoter) then
            begin
              Inc(Value); Dec(TextLen); // Normal char
            end
            else if ((TextLen = 1)
              or (Value[1] = Delimiter)
              or (Value[1] = #10)
              or (Value[1] = #13)
              or (Value[1] = #26)) then
            begin
              Inc(Value); Dec(TextLen); // Final quoter
              break;
            end
            else
            begin
              Inc(Value); Dec(TextLen); // Escaping quoter
              Inc(Value); Dec(TextLen); // Quoter
            end;
          end;
        end;
        Values[ValuesIndex].Length := ValueLen - TextLen;
        Dec(ValueLen, Values[ValuesIndex].Length);
        Inc(ValuesIndex);
        if ((TextLen = 0) or (Value^ = #10) or (Value^ = #13) or (Value^ = #26)) then
          break;
        Inc(Value); Dec(TextLen); Dec(ValueLen); // Delmitner
      end;

    EOL := False; EOF := False;
    while (TextLen > 0) do
      if (Value^ = #0) then
      begin
        Inc(Value); Dec(TextLen);
      end
      else if ((Value^ = #10) or (Value^ = #13)) then
      begin
        Inc(Value); Dec(TextLen);
        EOL := True;
      end
      else if (Value^ = #26) then
      begin
        Inc(Value); Dec(TextLen);
        EOF := True;
        break;
      end
      else
        break;

    Result := EOL or EOF or TextComplete and (TextLen = 0);

    if (Result) then
      TextIndex := 1 + Value - PChar(Text);

    if (ValuesIndex <> Length(Values)) then
      SetLength(Values, ValuesIndex);
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

