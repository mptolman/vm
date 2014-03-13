import std.ascii;
import std.conv;
import std.stdio;
import std.stream;
import std.string;
import queue;

enum TType : byte
{
    LABEL,
    OPCODE,
    REGISTER,
    OPAREN,
    CPAREN,
    COMMA,
    INT_DIRECTIVE,
    INT_LITERAL,
    BYT_DIRECTIVE,
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
        _file   = new BufferedFile(fileName);
        _tokens = new Queue!Token;
    }

    Token peek()
    {
        if (!_tokens.empty)
            return _tokens.front;

        loadMoreTokens();
        return peek();
    }

    Token next()
    {
        if (!_tokens.empty) {
            auto t = _tokens.front;
            _tokens.pop();
            return t;
        }

        loadMoreTokens();
        return next();
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

    void loadMoreTokens()
    {
        static char[] buffer;

        if (_file.eof) {
            _tokens.push(Token(TType.EOF, null, _lineNum));
            return;
        }

        _line = to!string(_file.readLine(buffer));
        _line ~= '\n';
        ++_lineNum;

        for (_pos = 0; _pos < _line.length;) {
            char c  = _line[_pos];
            _lexeme = [c];

            if (isWhite(c)) {
                ++_pos;
            }
            else if (isAlpha(c)) {
                alpha();
            }
            else if (c == '.') {
                directive();
            }
            else if (isDigit(c)) {
                int_literal();
            }
            else if (c == '\'') {
                byt_literal();
            }
            else if (c == '-') {
                minus();
            }
            else if (c == ',') {
                ++_pos;
                _tokens.push(Token(TType.COMMA, _lexeme, _lineNum));
            }
            else if (c == '(') {
                ++_pos;
                _tokens.push(Token(TType.OPAREN, _lexeme, _lineNum));
            }
            else if (c == ')') {
                ++_pos;
                _tokens.push(Token(TType.CPAREN, _lexeme, _lineNum));
            }
            else if (c == ';') {
                break;
            }
            else {
                ++_pos;
                _tokens.push(Token(TType.UNKNOWN, _lexeme, _lineNum));
            }
        }
    }

    auto collectWhile(bool function(char c) f)
    {
        string tok;
        while (_pos < _line.length) {
            if (f(_line[_pos]))
                tok ~= _line[_pos++];
            else
                break;
        }
        return tok;
    }

    void alpha()
    {
        ++_pos;
        _lexeme ~= collectWhile(c => isAlphaNum(c) || c == '_');
        _tokens.push(Token(_lexeme in tokMap ? tokMap[_lexeme] : TType.LABEL, _lexeme, _lineNum));
    }

    void directive()
    {
        ++_pos;
        _lexeme ~= collectWhile(c => isAlpha(c));
        if (_lexeme == ".BYT")
            _tokens.push(Token(TType.BYT_DIRECTIVE, _lexeme, _lineNum));
        else if (_lexeme == ".INT")
            _tokens.push(Token(TType.INT_DIRECTIVE, _lexeme, _lineNum));
        else
            _tokens.push(Token(TType.UNKNOWN, _lexeme, _lineNum));
    }

    void int_literal()
    {
        ++_pos;
        _lexeme ~= collectWhile(c => isDigit(c));
        _tokens.push(Token(TType.INT_LITERAL, _lexeme, _lineNum));
    }

    void byt_literal()
    {
        ++_pos;
        _tokens.push(Token(TType.BYT_DELIM, _lexeme, _lineNum));
        _lexeme = collectWhile(c => c != '\'');
        if (_lexeme.length)
            _tokens.push(Token(TType.BYT_LITERAL, _lexeme, _lineNum));
        if (_pos < _line.length)
            _tokens.push(Token(TType.BYT_DELIM, [_line[_pos]], _lineNum));
    }

    void minus()
    {
        if (isDigit(_line[_pos+1])) {
            int_literal();
        }
        else {
            ++_pos;
            _tokens.push(Token(TType.UNKNOWN, _lexeme, _lineNum));
        }
    }

    static this()
    {
        tokMap = [
            "R0"  : TType.REGISTER,
            "R1"  : TType.REGISTER,
            "R2"  : TType.REGISTER,
            "R3"  : TType.REGISTER,
            "R4"  : TType.REGISTER
        ];
    }
}

void main()
{
    auto tokens = std.stdio.File(r"C:\tokens.txt", "w");

    Lexer lex = new Lexer(r"asm\proj2.asm");
    Token t;
    do {
        t = lex.next();
        tokens.writeln(t);
    } while (t.type != TType.EOF);
}