%{
// =====================================================================================================
// Definition Section
// ==================

//
// Includes
//

#include <string.h>

// Must be before "Parser.hpp".
#include "Common/Enums.h"
#include "Parsers/AST.h"

#include "Parser.hpp"

//
// Function Prototypes
//
void SaveBool(bool);
void SaveInt();
void SaveDouble();
void SaveString();
void SaveIdentifier();

//
// Global Variables
//
%}

%{
// -------------------------------------------------------------
//
// Options
//
%}

%option never-interactive
%option nounistd

%{
// -------------------------------------------------------------
//
// Start States
//
%}

%s BLOCK_COMMENT

%{
// -------------------------------------------------------------
//
// Pattern Definitions (Substitutions)
//
%}

DIGIT                               [0-9]
INTEGER                             {DIGIT}+

FLOAT                               ({DIGIT}*\.{DIGIT}+)|({DIGIT}+\.{DIGIT}*)
EXP                                 ([eE][-+]?{INTEGER})
REAL                                ({INTEGER}{EXP}|{FLOAT}{EXP}?)

SINGLE_QUOTED_STR                   \'([^'\n])*\'
DOUBLE_QUOTED_STR                   \"([^"\n])*\"
STRING                              ({SINGLE_QUOTED_STR}|{DOUBLE_QUOTED_STR})

LETTER                              [a-zA-Z_]
IDENTIFIER                          {LETTER}({LETTER}|{DIGIT})*

WHITESPACE                          [ \t\r\n]+
EOL                                 \n

%%

%{
// =====================================================================================================
// Rules Section
// =============
%}

%{
// SELECT
%}
<INITIAL>(?i:SELECT)                return SELECT;
<INITIAL>(?i:DISTINCT)              return DISTINCT;
<INITIAL>(?i:AS)                    return AS;
<INITIAL>(?i:FROM)                  return FROM;
<INITIAL>(?i:RECURSIVE)             return RECURSIVE;

%{
// JOIN, UNION
%}
<INITIAL>(?i:JOIN)                  return JOIN;
<INITIAL>(?i:LEFT)                  return LEFT;
<INITIAL>(?i:RIGHT)                 return RIGHT;
<INITIAL>(?i:CROSS)                 return CROSS;
<INITIAL>(?i:INNER)                 return INNER;
<INITIAL>(?i:OUTER)                 return OUTER;
<INITIAL>(?i:USING)                 return USING;
<INITIAL>(?i:ON)                    return ON;
<INITIAL>(?i:UNION)                 return UNION;

%{
// WHERE
%}
<INITIAL>(?i:WHERE)                 return WHERE;

%{
// ORDER BY
%}
<INITIAL>(?i:ORDER)                 return ORDER;
<INITIAL>(?i:BY)                    return BY;
<INITIAL>(?i:ASC)                   return ASC;
<INITIAL>(?i:DESC)                  return DESC;

%{
// GROUP BY
%}
<INITIAL>(?i:GROUP)                 return GROUP;
<INITIAL>(?i:HAVING)                return HAVING;

%{
// LIMIT
%}
<INITIAL>(?i:TAKE)                  return LIMIT;
<INITIAL>(?i:LIMIT)                 return LIMIT;
<INITIAL>(?i:OFFSET)                return OFFSET;

%{
// CREATE
%}
<INITIAL>(?i:CREATE)                return CREATE;
<INITIAL>(?i:FOLDER)                return DIRECTORY;
<INITIAL>(?i:DIRECTORY)             return DIRECTORY;
<INITIAL>(?i:DIR)                   return DIRECTORY;
<INITIAL>(?i:IF)                    return IF;
<INITIAL>(?i:EXISTS)                return EXISTS;

%{
// UPDATE
%}
<INITIAL>(?i:UPDATE)                return UPDATE;
<INITIAL>(?i:SET)                   return SET;

%{
// INSERT
%}
<INITIAL>(?i:INSERT)                return INSERT;
<INITIAL>(?i:INTO)                  return INTO;
<INITIAL>(?i:VALUES?)               return VALUES;

%{
// DELETE, DROP
%}
<INITIAL>(?i:DELETE)                return DELETE;
<INITIAL>(?i:DROP)                  return DROP;

%{
// Other Keywords
%}
<INITIAL>(?i:USE)                   return USE;
<INITIAL>(?i:OPTIMIZE)              return OPTIMIZE;
<INITIAL>(?i:WITH)                  return WITH;

%{
// Special Functions
%}
<INITIAL>(?i:IN)                    return IN;
<INITIAL>(?i:LIKE)                  return LIKE;
<INITIAL>(?i:BETWEEN)               return BETWEEN;

%{
// Operators
%}
<INITIAL>[-+*/%&|^~<>=(),.:;]       return yytext[0];
<INITIAL>"<<"                       return SHL;
<INITIAL>">>"                       return SHR;
<INITIAL>"&&"                       return AND;
<INITIAL>(?i:AND)                   return AND;
<INITIAL>"||"                       return OR;
<INITIAL>(?i:OR)                    return OR;
<INITIAL>"!"                        return NOT;
<INITIAL>(?i:NOT)                   return NOT;
<INITIAL>"IS"                       return IS;
<INITIAL>"=="                       return EQ;
<INITIAL>"!="                       return NE;
<INITIAL>"<>"                       return NE;
<INITIAL>">="                       return GE;
<INITIAL>"<="                       return LE;

%{
// Values
%}
<INITIAL>(?i:null)                                      return TOKEN_NULL;
<INITIAL>(?i:false)                 SaveBool(false);    return TOKEN_BOOL;
<INITIAL>(?i:true)                  SaveBool(true);     return TOKEN_BOOL;
<INITIAL>{INTEGER}                  SaveInt();          return TOKEN_INTEGER;
<INITIAL>{REAL}                     SaveDouble();       return TOKEN_DOUBLE;
<INITIAL>{STRING}                   SaveString();       return TOKEN_STRING;
<INITIAL>{IDENTIFIER}               SaveIdentifier();   return TOKEN_IDENTIFIER;

%{
// Comments
%}
<INITIAL>"#"(.)*                    /* Ignore */ ;
<INITIAL>"--"(.)*                   /* Ignore */ ;
<INITIAL>"//"(.)*                   /* Ignore */ ;
<INITIAL>"/*"                       BEGIN BLOCK_COMMENT;
<BLOCK_COMMENT>"*/"                 BEGIN INITIAL;
<BLOCK_COMMENT>.                    /* Ignore */ ;

%{
// Others
%}
<INITIAL>{WHITESPACE}               /* Ignore */ ;
<INITIAL>.                          printf(">> Error: %s\n", yytext);

%%

// =====================================================================================================
// User Subroutines Section
// ========================

void SaveBool(bool value)
{
    yylval.val_Bool = value;
}

void SaveInt()
{
    yylval.val_Int = std::stoi(yytext);
}

void SaveDouble()
{
    yylval.val_Double = std::stod(yytext);
}

void SaveString()
{
    yylval.val_String = strdup(yytext + 1);
    yylval.val_String[yyleng - 2] = 0;
}

void SaveIdentifier()
{
    yylval.val_String = strdup(yytext);
}

/**
 * When a lexer encounters an end of file, it optionally calls the routine `yywrap()` to find
 * out what to do next. If `yywrap()` returns 0, the scanner continues scanning, while if it
 * returns 1, the scanner returns a zero token to report the end-of-file. If your lexer does not
 * use `yywrap()` to switch files, the option `%option noyywrap` removes the calls to `yywrap()`.
 * The special token `<<EOF>>` is usually a better way to handle end-of-file situations.
 * The standard version of yywrap() in the flex library always returns 1, but if you use
 * `yywrap()`, you should replace it with one of your own. If `yywrap()` returns 0 to indicate
 * that there is more input, it needs first to adjust `yyin` to point to a new file, probably
 * using `fopen()`.
 */
int yywrap()
{
    return 1;
}
