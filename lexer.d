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
        file   = new BufferedFile(fileName);
        tokens = new Queue!Token;
    }

    auto next()
    {
        if (tokens.empty)
            loadMoreTokens();

        auto t = tokens.front;
        tokens.pop();
        return t;
    }

    auto peek()
    {
        if (tokens.empty)
            loadMoreTokens();

        return tokens.front;
    }
private:
    Queue!Token tokens;
    Stream file;

    char[] currentLine;
    size_t currentLineNum;
    size_t currentPos;

    static immutable TType[string] tokMap;
    static immutable BUFFER_SIZE = 500;

    void loadMoreTokens()
    {
        static char[] buffer;

        while (!file.eof) {
            currentLine = file.readLine(buffer);            
            ++currentLineNum;

            for (currentPos=0; currentPos < currentLine.length; ++currentPos) {
                auto c = currentLine[currentPos];

                if (isWhite(c)) {
                    // ignore whitespace
                }
                else if (isAlpha(c)) {
                    alpha();
                }
                else if (c == '.') {
                    directive();
                }
                else if (isDigit(c) || c == '-') {
                    int_literal();
                }
                else if (c == '\'') {
                    byt_literal();
                }
                else if (c == ',') {
                    tokens.push(Token(TType.COMMA, to!string(c), currentLineNum));
                }
                else if (c == '(') {
                    tokens.push(Token(TType.OPAREN, to!string(c), currentLineNum));
                }
                else if (c == ')') {
                    tokens.push(Token(TType.CPAREN, to!string(c), currentLineNum));
                }
                else if (c == ';') {
                    break;
                }
                else {
                    tokens.push(Token(TType.UNKNOWN, to!string(c), currentLineNum));
                }
            }

            //if (tokens.size >= BUFFER_SIZE)
            //  break;
        }

        if (file.eof)
            tokens.push(Token(TType.EOF, null, currentLineNum));
    }

    auto collectWhile(bool function(char c) f)
    {
        string tok;

        while (currentPos < currentLine.length) {
            if (f(currentLine[currentPos])) {
                tok ~= currentLine[currentPos++];
            }
            else {
                --currentPos;
                break;
            }
        }

        return tok;
    }

    void alpha()
    {
        string tok = [currentLine[currentPos++]];
        tok ~= collectWhile(c => isAlphaNum(c) || c == '_');
        tokens.push(Token(tok in tokMap ? tokMap[tok] : TType.LABEL, tok, currentLineNum));
    }

    void directive()
    {
        string tok = [currentLine[currentPos++]];
        tok ~= collectWhile(c => isAlpha(c));
        if (tok == ".BYT")
            tokens.push(Token(TType.BYT_DIRECTIVE, tok, currentLineNum));
        else if (tok == ".INT")
            tokens.push(Token(TType.INT_DIRECTIVE, tok, currentLineNum));
        else
            tokens.push(Token(TType.UNKNOWN, tok, currentLineNum));
    }

    void int_literal()
    {
        string tok = [currentLine[currentPos++]];
        tok ~= collectWhile(c => isDigit(c));
        if (tok[0] == '-' && tok.length <= 1)
            tokens.push(Token(TType.UNKNOWN, tok, currentLineNum));
        else
            tokens.push(Token(TType.INT_LITERAL, tok, currentLineNum));
    }

    void byt_literal()
    {
        ++currentPos;
        string tok = collectWhile(c => c != '\'');
        if (currentLine[currentPos+1] == '\'') {
            ++currentPos;
            tokens.push(Token(TType.BYT_LITERAL, tok, currentLineNum));
        }
        else
            tokens.push(Token(TType.UNKNOWN, tok, currentLineNum));
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
    while (t.type != TType.EOF) {
        t = lex.next();
        tokens.writeln(t);
    }
}