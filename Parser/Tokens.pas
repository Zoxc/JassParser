unit Tokens;

interface

type
  TTokenType = (// General
                ttNone,
                ttLine,
                ttEnd,
                ttIdentifier,
                ttNumber,

                // Signs
                ttColon,
                ttComma,
                ttSemicolon,
                ttCurlyOpen,
                ttCurlyClose,
                ttParentOpen,
                ttParentClose,
                ttEqual,

                // Operators
                ttAdd,
                ttSub,
                ttDiv,
                ttMul,
                ttMod,

                // Keywords
                ttGlobals, ttEndGlobals,
                ttFunction, ttEndFunction,
                ttTakes, ttReturns,
                ttConstant, ttNative,
                ttType, ttExtends, ttArray,
                ttLibrary, ttEndLibrary, ttRequires, ttNeeds, ttUses, ttInitializer,
                ttSet, ttCall,
                ttAnd, ttNot, ttOr,
                ttScope, ttEndScope,
                ttInterface, ttEndInterface, ttDefaults,
                ttStruct, ttEndStruct,
                ttMethod, ttEndMethod, ttOperator,
                ttReturn, ttLocal,
                ttIf, ttEndIf, ttThen, ttElse, ttElseIf,
                ttLoop, ttEndLoop, ttExitwhen,
                ttPrivate, ttPublic, ttStub, ttStatic,
                ttDelegate, ttKeyword
                );

const
   TokenName: array [TTokenType] of PAnsiChar  =  (
                  // General
                  'none',
                  'newline',
                  'end',
                  'identifier',
                  'number',

                  // Signs
                  'colon',
                  'comma',
                  'semicolon',
                  'opening curly bracket',
                  'closing curly bracket',
                  'opening parenthesis',
                  'closing parenthesis',
                  'equal',

                  // Operators
                  'addition',
                  'subtraction',
                  'division',
                  'multiplication',
                  'mod',

                  //Keywords
                  'globals', 'endglobals',
                  'function', 'endfunction',
                  'takes', 'returns',
                  'constant', 'native',
                  'type', 'extends', 'array',
                  'library', 'endlibrary', 'requires', 'needs', 'uses', 'initializer',
                  'set', 'call',
                  'and', 'not', 'or',
                  'scope', 'endscope',
                  'interface', 'endinterface', 'defaults',
                  'struct', 'endstruct',
                  'method', 'endmethod', 'operator',
                  'return', 'local',
                  'if', 'endif', 'then', 'else', 'elseif',
                  'loop', 'endloop', 'exitwhen',
                  'private', 'public', 'stub', 'static',
                  'delegate', 'keyword'
                  );

implementation

end.
