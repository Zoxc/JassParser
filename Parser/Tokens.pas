unit Tokens;

interface

type
  TTokenType = (// General
                ttNone,
                ttExpression,
                ttLine,
                ttEnd,
                ttIdentifier,
                ttNumber,
                ttOctal,
                ttReal,
                ttHex,
                ttRawId,
                ttString,

                // Signs
                ttColon,
                ttComma,
                ttSemicolon,
                ttCurlyOpen,
                ttCurlyClose,
                ttParentOpen,
                ttParentClose,
                ttSquareOpen,
                ttSquareClose,
                ttAssign,

                // Comparasions
                ttEqual,
                ttNotEqual,
                ttLess,
                ttLessOrEqual,
                ttGreater,
                ttGreaterOrEqual,

                // Operators
                ttAdd,
                ttSub,
                ttDiv,
                ttMul,

                // Keywords
                ttGlobals, ttEndGlobals,
                ttFunction, ttEndFunction,
                ttNull, ttTrue, ttFalse,
                ttTakes, ttReturns, ttNothing,
                ttConstant, ttNative,
                ttType, ttExtends, ttArray,
                ttSet, ttCall,
                ttAnd, ttNot, ttOr,
                ttReturn, ttLocal,
                ttIf, ttEndIf, ttThen, ttElse, ttElseIf,
                ttLoop, ttEndLoop, ttExitwhen,

                {$IFDEF VJASS}
                ttLibrary, ttLibrary_Once, ttEndLibrary, ttRequires, ttNeeds, ttUses, ttInitializer,
                ttScope, ttEndScope,
                ttInterface, ttEndInterface, ttDefaults,
                ttStruct, ttEndStruct,
                ttMethod, ttEndMethod, ttOperator,
                ttPrivate, ttPublic, ttStub, ttStatic,
                ttDelegate, ttKeyword, ttReadOnly,
                {$ENDIF}

                ttDebug
                );

const
   TokenName: array [TTokenType] of PAnsiChar = (
      // General
      'none',
      'expression',
      'newline',
      'end',
      'identifier',
      'number',
      'octal number',
      'floating point',
      'hex number',
      'raw id',
      'string',

      // Signs
      'colon',
      'comma',
      'semicolon',
      'opening curly bracket',
      'closing curly bracket',
      'opening parenthesis',
      'closing parenthesis',
      'opening square bracket',
      'closing square bracket',
      'assignment',

      'equal',
      'not equal',
      'less',
      'less or equal',
      'greater',
      'greater or equal',

      // Operators
      'addition',
      'subtraction',
      'division',
      'multiplication',

      //Keywords
      'globals', 'endglobals',
      'function', 'endfunction',
      'null', 'true', 'false',
      'takes', 'returns', 'nothing',
      'constant', 'native',
      'type', 'extends', 'array',

      'set', 'call',
      'and', 'not', 'or',

      'return', 'local',
      'if', 'endif', 'then', 'else', 'elseif',
      'loop', 'endloop', 'exitwhen',
      
      {$IFDEF VJASS}
      'library', 'library_once', 'endlibrary', 'requires', 'needs', 'uses', 'initializer',
      'scope', 'endscope',
      'interface', 'endinterface', 'defaults',
      'struct', 'endstruct',
      'method', 'endmethod', 'operator',
      'private', 'public', 'stub', 'static',
      'delegate', 'keyword', 'readonly',
      {$ENDIF}

      'debug'
    );

  White = [#1..#9, #11..#12, #14..#32];

  Alpha = ['A'..'Z', 'a'..'z'];

  Num =  ['0'..'9'];

  Octal =  ['0'..'7'];

  Hex = Num + ['A'..'F', 'a'..'f'];

  Ident = Alpha + Num + ['_'];

  Operators = ['/', '*', '+', '-', '{', '}', '(', ')', ',', ';', ':', '='];

  LineEnd = [#10, #13, #0];

  Known = Ident + White + Operators + LineEnd;

implementation

end.
