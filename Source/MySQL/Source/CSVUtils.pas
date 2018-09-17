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
function CSVUnescape(const Text: PChar; const Length: Integer; const Unescaped: PChar; const UnescapedLen: Integer; const Quoter: Char = '"'): Integer; overload;

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
label
  StartL, Start2, Start3, StartE,
  Quoted, QuotedL, QuotedLE, QuotedE,
  Unquoted, UnquotedL, UnquotedE,
  Finish, FinishL, Finish2, Finish3, Finish4, Finish5, FinishE, FinishE2, FinishE3;
var
  EOF: LongBool;
  EOL: LongBool;
  NewIndex: Integer;
  Len: Integer;
  Value: Integer;
  ValueLength: Integer;
  ValueText: PChar;
begin
  Result := False;
  if (Index > Length(Text)) then
    SetLength(Values, 0)
  else
  begin
    Len := Length(Text) - (Index - 1);
    NewIndex := Index;
    Value := 0;
    EOL := False;
    EOF := False;

    repeat
      if (Value >= Length(Values)) then
        SetLength(Values, 2 * Value + 1);

      asm
        PUSH ES
        PUSH ESI
        PUSH EDI
        PUSH EBX

        MOV ESI,PChar(Text)              // Get character from Text
        ADD ESI,NewIndex                 // Add Index twice
        ADD ESI,NewIndex                 //   since 1 character = 2 byte
        SUB ESI,2                        // Index based on "1" in string

        MOV ECX,Len                      // Numbers of character in Text

      // -------------------

        MOV ValueText,ESI                // Start of value
      StartL:
        CMP ECX,0                        // On character in Text?
        JE Finish                        // No!
        MOV AX,[ESI]                     // Get character from Text
        CMP AX,10                        // Character = LineFeed?
        JE Finish                        // Yes!
      Start2:
        CMP AX,13                        // Character = CarrigeReturn?
        JE Finish                        // Yes!
      StartE:
        CMP AX,Quoter                    // Character = Quoter?
        JE Quoted                        // No!
        JMP Unquoted

      // -------------------

      Unquoted:
        CMP ECX,0                        // End of Text?
        JE Finish                        // Yes!
      UnquotedL:
        MOV AX,[ESI]                     // Get character from Text
        CMP AX,Delimiter                 // Character = Delimiter?
        JE UnquotedE                     // Yes!
        CMP AX,10                        // Character = NewLine?
        JE UnquotedE                     // Yes!
        CMP AX,13                        // Character = CarrigeReturn?
        JE UnquotedE                     // Yes!
        CMP AX,26                        // Character = EndOfFile?
        JE UnquotedE                     // Yes!
        ADD ESI,2                        // One character handled!
        LOOP UnquotedL                   // Next character, if available
        CMP TextComplete,True            // Text completely handled?
        JNE FinishE                      // No!
        MOV EOF,True
      UnquotedE:
        JMP Finish

      // -------------------

      Quoted:
        ADD ESI,2                        // Step over starting Quoter
        DEC ECX                          // Quoter handled
        JZ QuotedE                       // End of Text!
      QuotedL:
        MOV AX,[ESI]                     // Get character from Text
        CMP AX,Quoter                    // Character = (first) Quoter?
        JNE QuotedLE                     // No!
        ADD ESI,2                        // Step over Quoter
        DEC ECX                          // Ending Quoter handled
        JZ QuotedE                       // End of Text!
        MOV AX,[ESI]                     // Get character from Text
        CMP AX,Quoter                    // Character = (second) Quoter?
        JNE QuotedE                      // No!
      QuotedLE:
        ADD ESI,2                        // One character handled!
        LOOP QuotedL                     // Next character, if available
        CMP TextComplete,True            // Text completely handled?
        JNE FinishE                      // No!
        MOV EOF,True
      QuotedE:
        JMP Finish

      // -------------------

      Finish:
        MOV EAX,ESI                      // Calculate length of Values[Value]
        SUB EAX,ValueText
        SHR EAX,1                        // 2 bytes = 1 character
        MOV ValueLength,EAX

      FinishL:
        CMP ECX,1                        // Is there one characters left in SQL?
        JB FinishE                       // No!
        MOV AX,[ESI]                     // Current character in Text
        CMP AX,0                         // Character = EOS?
        JNE Finish2                      // No!
        ADD ESI,2                        // Step over LineFeed
        DEC ECX                          // One character handled
        JMP FinishL
      Finish2:
        CMP AX,10                        // Character = NewLine?
        JNE Finish3                      // No!
        MOV EOL,True
        ADD ESI,2                        // Step over LineFeed
        DEC ECX                          // One character handled
        JMP FinishL
      Finish3:
        CMP AX,13                        // Character = CarrigeReturn?
        JNE Finish4                      // No!
        MOV EOL,True
        ADD ESI,2                        // Step over CarrigeReturn
        DEC ECX                          // One character handled
        JMP FinishL
      Finish4:
        CMP AX,26                        // Character = EndOfFile?
        JNE Finish5                      // Yes!
        ADD ESI,2                        // Step over CarrigeReturn
        DEC ECX                          // One character handled
        MOV EOF,True
        JMP FinishE
      Finish5:
        CMP AX,Delimiter                 // Character = Delimter?
        JNE FinishE                      // No!
        ADD ESI,2                        // Step over Delimiter
        DEC ECX                          // One character handled (Delimiter)
        JMP FinishE

      FinishE:
        MOV Len,ECX                      // Length of Text

        CMP EOL,True                     // Current character = EndOfLine?
        JE FinishE2                      // Yes!
        CMP EOF,True                     // Current character = EndOfFile?
        JE FinishE2                      // Yes!
        CMP TextComplete,True            // Text complete?
        JNE FinishE3                     // No!
        CMP ECX,0                        // All characters handled?
        JA FinishE3                      // No!
      FinishE2:
        MOV @Result,True                 // Result := EOL or EOF or all character handled

      FinishE3:
        MOV EAX,ESI                      // Calculate new Index in Text
        SUB EAX,PChar(Text)
        SHR EAX,1                        // 2 bytes = 1 character
        INC EAX                          // Index based on "1" in string
        MOV NewIndex,EAX                 // Index in Text

        POP EBX
        POP EDI
        POP ESI
        POP ES
      end;

      if (ValueText = #26 {EndOfFile}) then
        SetLength(Values, 0)
      else
      begin
        Values[Value].Text := ValueText;
        Values[Value].Length := ValueLength;
        Inc(Value);
      end;
    until (Result or (Len = 0));

    if (Result) then
      Index := NewIndex;

    if (Value <> Length(Values)) then
      SetLength(Values, Value);
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

function CSVUnescape(const Text: PChar; const Length: Integer; const Unescaped: PChar; const UnescapedLen: Integer; const Quoter: Char = '"'): Integer;
label
  StringL, StringS, StringQ, StringLE,
  Error, Finish;
var
  Quoted: Boolean;
begin
  asm
        PUSH ES
        PUSH ESI
        PUSH EDI
        PUSH EBX

        PUSH DS                          // string operations uses ES
        POP ES
        CLD                              // string operations uses forward direction

        MOV ESI,Text                     // Copy characters from Text
        MOV EDI,Unescaped                //   to Unescaped
        MOV ECX,Length                   // Length of Text string
        MOV EDX,UnescapedLen             // Length of Unescaped

        MOV EBX,0                        // Result

        CMP ESI,0                        // No string?
        JE Error                         // Yes!
        CMP ECX,0                        // Empty string?
        JE Error                         // Yes!

        MOV Quoted,False
        MOV AX,Quoter
        CMP [ESI],AX                     // Quoted Value?
        JNE StringL                      // No!
        MOV Quoted,True
        DEC ECX                          // One character handled
        ADD ESI,2                        // Step over starting Quoter

      StringL:
        LODSW                            // Character from Value
        CMP AX,Quoter                    // Quoter in Value?
        JNE StringS                      // No!
        MOV @Result,EBX
        CMP ECX,0                        // End of Value?
        JE Finish
        CMP [ESI],AX                     // Two Quoters?
        JE StringQ
        CMP Quoted,True                  // Quoted Value?
        JE Finish                        // Yes!
      StringQ:
        DEC ECX                          // One character handled
        LODSW                            // Character from Value
        CMP AX,Quoter                    // Second Quoter
        JE StringS                       // Yes!
        MOV @Result,EBX
        JMP Finish

      StringS:
        INC EBX                          // One character needed
        CMP EDI,0                        // Calculate length only?
        JE StringLE                      // Yes!
        STOSW                            // Store character into Unescaped

      StringLE:
        LOOP StringL                     // Next character in Data!
        MOV @Result,EBX
        JMP Finish

      // -------------------

      Error:
        MOV @Result,0                    // Too few space in Escaped!

      Finish:
        POP EBX
        POP EDI
        POP ESI
        POP ES
  end;
end;

function CSVUnquote(const Quoted: PChar; const QuotedLength: Integer; const Unquoted: PChar; const UnquotedLength: Integer; const Quoter: Char = '"'): Integer;
label
  Copy,
  Unquote, UnquoteL, UnquoteS, UnquoteLE, UnquoteE,
  Finish;
asm
        PUSH ES
        PUSH ECX
        PUSH EAX
        PUSH EDX
        PUSH ESI
        PUSH EDI

        MOV ESI,Quoted                   // Copy characters from Quoted
        MOV EDI,Unquoted                 //   to Unquoted
        MOV ECX,QuotedLength             // Number of characters of Quoted
        MOV EDX,UnquotedLength           // Number of characters of Unquoted

        PUSH DS                          // string operations uses ES
        POP ES
        CLD                              // string operations uses forward direction

        MOV Result,0
        TEST ESI,-1                      // Quoted = nil?
        JZ Finish                        // Yes!
        TEST QuotedLength,-1             // QuotedLength = 0?
        JZ Finish                        // Yes!
        MOV AX,[ESI]                     // Quoted[0] = Quoter?
        CMP AX,Quoter
        JE Unquote                       // Yes!

      Copy:
        CMP UnquotedLength,QuotedLength  // Enough space in Unquoted?
        JB Finish                        // No!
        TEST EDI,-1                      // Unquoted = nil?
        JZ Finish                        // Yes!
        MOV Result,ECX
        REPNE MOVSW                      // Copy normal characters to Result
        JMP Finish

      Unquote:
        ADD ESI,2                        // Step over starting Quoter
        DEC ECX                          // Ignore the starting Quoter
        JZ Finish                        // No characters left!

      UnquoteL:
        LODSW                            // Load character from Data
        CMP AX,Quoter                    // Previous character = Quoter?
        JNE UnquoteS                     // No!
        DEC ECX                          // Ignore Quoter
        JZ UnquoteE                      // End of Data!
        MOV AX,[ESI]
        CMP AX,Quoter                    // Second Quoter?
        JNE UnquoteE                     // No!
        ADD ESI,2                        // Step over second Quoter
      UnquoteS:
        TEST EDI,-1                      // Unquoted = nil?
        JZ UnquoteLE                     // Yes!
        CMP EDX,0                        // Space left in Unquoted?
        JE Finish                        // No!
        STOSW                            // Store character into Unquoted
        DEC EDX
      UnquoteLE:
        LOOP UnquoteL                    // Next character

      UnquoteE:
        CMP ECX,0                        // All characters handled?
        JNE Finish                       // No!

        MOV EAX,UnquotedLength           // Calculate new Unquoted Length
        SUB EAX,EDX
        MOV Result,EAX

      Finish:
        POP EDI
        POP ESI
        POP EDX
        POP ECX
        POP EAX
        POP ES
end;

begin
  CSVEscape('"Hallo"Welt');
end.

