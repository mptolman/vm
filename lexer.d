import std.ascii;
import std.conv;
import std.stream;
import queue;

enum TType : byte
{
    LABEL,
    REGISTER,
    OPCODE,
    OPAREN,
    CPAREN,
    COMMA,
    DIRECTIVE,
    INT_LITERAL,
    BYT_DELIM,
    BYT_LITERAL,
    EOF,
    UNKNOWN
}

struct Token
{
    TType type;
    string lexeme;
    size_t line;
}

class Lexer
{
public:
    this(string fileName)
    {
        _file   = new BufferedFile(fileName, FileMode.In);
        _tokens = new Queue!Token;
    }

    auto peek()
    {
        if (_tokens.empty)
            loadMoreTokens();

        return _tokens.front;
    }

    auto next()
    {
        if (_tokens.empty)
            loadMoreTokens();

        auto t = _tokens.front;
        _tokens.pop();
        return t;
    }

    void rewind()
    {
        _file.seek(0, SeekPos.Set);
        _tokens.clear();
        _lineNum = 0;
    }

private:
    Stream _file;
    Queue!Token _tokens;

    string _line;
    string _lexeme;
    size_t _pos;
    size_t _lineNum;

    static immutable TType[string] tokMap;
    static immutable size_t BUFFER_SIZE = 500;

    void loadMoreTokens()
    {
        static char[] buffer;

        while(!_file.eof) {
            _line = to!string(_file.readLine(buffer));
            _line ~= '\n';
            ++_lineNum;

            for (_pos = 0; _pos < _line.length;) {
                char c  = _line[_pos++];
                _lexeme = [c];

                if (isWhite(c)) {
                    // ignore whitespace
                }                
                else if (isAlpha(c))
                    alpha();

                else if (isDigit(c))
                    int_literal();

                else if (c == '\'')
                    byt_literal();

                else if (c == '.')
                    directive();

                else if (c == '-')
                    minus();

                else if (c == ',')
                    _tokens.push(Token(TType.COMMA, _lexeme, _lineNum));

                else if (c == '(')
                    _tokens.push(Token(TType.OPAREN, _lexeme, _lineNum));

                else if (c == ')')
                    _tokens.push(Token(TType.CPAREN, _lexeme, _lineNum));

                else if (c == ';')
                    break;

                else
                    _tokens.push(Token(TType.UNKNOWN, _lexeme, _lineNum));
            }

            if (_tokens.size >= BUFFER_SIZE)
                break;
        }

        if (_file.eof)
            _tokens.push(Token(TType.EOF, null, _lineNum));        
    }

    auto collectWhile(bool function(char c) f)
    {
        string tok;

        for (; _pos < _line.length; ++_pos) {
            if (f(_line[_pos]))
                tok ~= _line[_pos];
            else
                break;
        }

        return tok;
    }

    void alpha()
    {
        _lexeme ~= collectWhile(c => isAlphaNum(c) || c == '_');
        _tokens.push(Token(_lexeme in tokMap ? tokMap[_lexeme] : TType.LABEL, _lexeme, _lineNum));
    }

    void directive()
    {
        _lexeme ~= collectWhile(c => isAlpha(c));
        _tokens.push(Token(_lexeme in tokMap ? tokMap[_lexeme] : TType.UNKNOWN, _lexeme, _lineNum));   
    }

    void int_literal()
    {
        _lexeme ~= collectWhile(c => isDigit(c));
        _tokens.push(Token(TType.INT_LITERAL, _lexeme, _lineNum));
    }

    void byt_literal()
    {
        _tokens.push(Token(TType.BYT_DELIM, _lexeme, _lineNum));
        _lexeme = collectWhile(c => c != '\'');
        if (_lexeme.length)
            _tokens.push(Token(TType.BYT_LITERAL, replaceEscapeChars(_lexeme), _lineNum));
        if (_pos < _line.length)
            _tokens.push(Token(TType.BYT_DELIM, [_line[_pos++]], _lineNum));
    }

    void minus()
    {
        if (isDigit(_line[_pos]))
            int_literal();
        else
            _tokens.push(Token(TType.UNKNOWN, _lexeme, _lineNum));
    }

    static this()
    {
        tokMap = [
            ".INT" : TType.DIRECTIVE,
            ".BYT" : TType.DIRECTIVE,
            "R0"   : TType.REGISTER,
            "R1"   : TType.REGISTER,
            "R2"   : TType.REGISTER,
            "R3"   : TType.REGISTER,
            "R4"   : TType.REGISTER,
            "R5"   : TType.REGISTER,
            "R6"   : TType.REGISTER,
            "R7"   : TType.REGISTER,
            "R8"   : TType.REGISTER,
            "R9"   : TType.REGISTER,
            "PC"   : TType.REGISTER,
            "SP"   : TType.REGISTER,
            "SB"   : TType.REGISTER,
            "SL"   : TType.REGISTER,
            "FP"   : TType.REGISTER,
            "HP"   : TType.REGISTER,
            "ADD"  : TType.OPCODE,
            "ADI"  : TType.OPCODE,
            "AND"  : TType.OPCODE,
            "BGT"  : TType.OPCODE,
            "BLK"  : TType.OPCODE,
            "BLT"  : TType.OPCODE,
            "BNZ"  : TType.OPCODE,
            "BRZ"  : TType.OPCODE,
            "CMP"  : TType.OPCODE,
            "DIV"  : TType.OPCODE,
            "END"  : TType.OPCODE,
            "JMP"  : TType.OPCODE,
            "JMR"  : TType.OPCODE,
            "LCK"  : TType.OPCODE,
            "LDA"  : TType.OPCODE,
            "LDB"  : TType.OPCODE,
            "LDR"  : TType.OPCODE,
            "MOV"  : TType.OPCODE,
            "MUL"  : TType.OPCODE,
            "OR"   : TType.OPCODE,
            "RUN"  : TType.OPCODE,
            "STB"  : TType.OPCODE,
            "STR"  : TType.OPCODE,
            "SUB"  : TType.OPCODE,            
            "TRP"  : TType.OPCODE,
            "ULK"  : TType.OPCODE
        ];
    }
}

auto replaceEscapeChars(string s)
{
    string result;
    bool escape;

    foreach (c; s) {
        if (escape) {
            if (c == '0')
                result ~= '\0';
            else if (c == '\\')
                result ~= '\\';
            else if (c == 't')
                result ~= '\t';
            else if (c == 'n')
                result ~= '\n';
            escape = false;
            continue;
        }
        if (c == '\\') {
            escape = true;
            continue;
        }
        result ~= c;
    }

    return result;
}