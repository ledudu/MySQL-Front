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
function CSVSplitValues(const Text: string; var TextIndex: Integer; const Delimiter, Quoter: Char; var Values: TCSVValues; const TextComplete: Boolean = True): Boolean; overload;
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
            else if ((Value[1] = Delimiter)
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

//function CSVSplitValues(const Text: string; var Index: Integer; const Delimiter, Quoter: Char; var Values: TCSVValues; const TextComplete: Boolean = True): Boolean; overload;
//label
//  StartL, Start2, Start3, StartE,
//  Quoted, QuotedL, QuotedLE, QuotedE,
//  Unquoted, UnquotedL, UnquotedE,
//  Finish, FinishL, Finish2, Finish3, Finish4, Finish5, FinishE, FinishE2, FinishE3;
//var
//  EOF: LongBool;
//  EOL: LongBool;
//  NewIndex: Integer;
//  Len: Integer;
//  Value: Integer;
//  ValueLength: Integer;
//  ValueText: PChar;
//  OldIndex: Integer;
//  NewValues: TCSVValues;
//  NewResult: Boolean;
//begin
//  OldIndex := Index;
//  Result := False;
//  if (Index > Length(Text)) then
//    SetLength(Values, 0)
//  else
//  begin
//    Len := Length(Text) - (Index - 1);
//    NewIndex := Index;
//    Value := 0;
//    EOL := False;
//    EOF := False;
//
//    repeat
//      if (Value >= Length(Values)) then
//        SetLength(Values, 2 * Value + 1);
//
//      asm
//        PUSH ES
//        PUSH ESI
//        PUSH EDI
//        PUSH EBX
//
//        MOV ESI,PChar(Text)              // Get character from Text
//        ADD ESI,NewIndex                 // Add Index twice
//        ADD ESI,NewIndex                 //   since 1 character = 2 byte
//        SUB ESI,2                        // Index based on "1" in string
//
//        MOV ECX,Len                      // Numbers of character in Text
//
//      // -------------------
//
//        MOV ValueText,ESI                // Start of value
//      StartL:
//        CMP ECX,0                        // On character in Text?
//        JE Finish                        // No!
//        MOV AX,[ESI]                     // Get character from Text
//        CMP AX,10                        // Character = LineFeed?
//        JE Finish                        // Yes!
//      Start2:
//        CMP AX,13                        // Character = CarrigeReturn?
//        JE Finish                        // Yes!
//      StartE:
//        CMP AX,Quoter                    // Character = Quoter?
//        JE Quoted                        // No!
//        JMP Unquoted
//
//      // -------------------
//
//      Unquoted:
//        CMP ECX,0                        // End of Text?
//        JE Finish                        // Yes!
//      UnquotedL:
//        MOV AX,[ESI]                     // Get character from Text
//        CMP AX,Delimiter                 // Character = Delimiter?
//        JE UnquotedE                     // Yes!
//        CMP AX,10                        // Character = NewLine?
//        JE UnquotedE                     // Yes!
//        CMP AX,13                        // Character = CarrigeReturn?
//        JE UnquotedE                     // Yes!
//        CMP AX,26                        // Character = EndOfFile?
//        JE UnquotedE                     // Yes!
//        ADD ESI,2                        // One character handled!
//        LOOP UnquotedL                   // Next character, if available
//        CMP TextComplete,True            // Text completely handled?
//        JNE FinishE                      // No!
//        MOV EOF,True
//      UnquotedE:
//        JMP Finish
//
//      // -------------------
//
//      Quoted:
//        ADD ESI,2                        // Step over starting Quoter
//        DEC ECX                          // Quoter handled
//        JZ QuotedE                       // End of Text!
//      QuotedL:
//        MOV AX,[ESI]                     // Get character from Text
//        CMP AX,Quoter                    // Character = (first) Quoter?
//        JNE QuotedLE                     // No!
//        ADD ESI,2                        // Step over Quoter
//        DEC ECX                          // Ending Quoter handled
//        JZ QuotedE                       // End of Text!
//        MOV AX,[ESI]                     // Get character from Text
//        CMP AX,Quoter                    // Character = (second) Quoter?
//        JNE QuotedE                      // No!
//      QuotedLE:
//        ADD ESI,2                        // One character handled!
//        LOOP QuotedL                     // Next character, if available
//        CMP TextComplete,True            // Text completely handled?
//        JNE FinishE                      // No!
//        MOV EOF,True
//      QuotedE:
//        JMP Finish
//
//      // -------------------
//
//      Finish:
//        MOV EAX,ESI                      // Calculate length of Values[Value]
//        SUB EAX,ValueText
//        SHR EAX,1                        // 2 bytes = 1 character
//        MOV ValueLength,EAX
//
//      FinishL:
//        CMP ECX,1                        // Is there one characters left in SQL?
//        JB FinishE                       // No!
//        MOV AX,[ESI]                     // Current character in Text
//        CMP AX,0                         // Character = EOS?
//        JNE Finish2                      // No!
//        ADD ESI,2                        // Step over LineFeed
//        DEC ECX                          // One character handled
//        JMP FinishL
//      Finish2:
//        CMP AX,10                        // Character = NewLine?
//        JNE Finish3                      // No!
//        MOV EOL,True
//        ADD ESI,2                        // Step over LineFeed
//        DEC ECX                          // One character handled
//        JMP FinishL
//      Finish3:
//        CMP AX,13                        // Character = CarrigeReturn?
//        JNE Finish4                      // No!
//        MOV EOL,True
//        ADD ESI,2                        // Step over CarrigeReturn
//        DEC ECX                          // One character handled
//        JMP FinishL
//      Finish4:
//        CMP AX,26                        // Character = EndOfFile?
//        JNE Finish5                      // Yes!
//        ADD ESI,2                        // Step over CarrigeReturn
//        DEC ECX                          // One character handled
//        MOV EOF,True
//        JMP FinishE
//      Finish5:
//        CMP AX,Delimiter                 // Character = Delimter?
//        JNE FinishE                      // No!
//        ADD ESI,2                        // Step over Delimiter
//        DEC ECX                          // One character handled (Delimiter)
//        JMP FinishE
//
//      FinishE:
//        MOV Len,ECX                      // Length of Text
//
//        CMP EOL,True                     // Current character = EndOfLine?
//        JE FinishE2                      // Yes!
//        CMP EOF,True                     // Current character = EndOfFile?
//        JE FinishE2                      // Yes!
//        CMP TextComplete,True            // Text complete?
//        JNE FinishE3                     // No!
//        CMP ECX,0                        // All characters handled?
//        JA FinishE3                      // No!
//      FinishE2:
//        MOV @Result,True                 // Result := EOL or EOF or all character handled
//
//      FinishE3:
//        MOV EAX,ESI                      // Calculate new Index in Text
//        SUB EAX,PChar(Text)
//        SHR EAX,1                        // 2 bytes = 1 character
//        INC EAX                          // Index based on "1" in string
//        MOV NewIndex,EAX                 // Index in Text
//
//        POP EBX
//        POP EDI
//        POP ESI
//        POP ES
//      end;
//
//      if (ValueText = #26 {EndOfFile}) then
//        SetLength(Values, 0)
//      else
//      begin
//        Values[Value].Text := ValueText;
//        Values[Value].Length := ValueLength;
//        Inc(Value);
//      end;
//    until (Result or (Len = 0));
//
//    if (Result) then
//      Index := NewIndex;
//
//    if (Value <> Length(Values)) then
//      SetLength(Values, Value);
//  end;
//end;

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

