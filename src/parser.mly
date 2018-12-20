/* parser */
%{
  open Ast
  open Location
%}
%token USE
%token MODEL
%token CONSTANT
%token ROLE
%token IDENTIFIED
%token BY
%token REF
%token ASSET
%token BEGIN_EXTENTION
%token LBRACKET
%token RBRACKET
%token LBRACE
%token RBRACE
%token EQUAL
%token COLON
%token SEMI_COLON
%token <string> IDENT
%token <int> NUMBER
%token EOF
%type <Ast.model> main
%start main
%%

main:
| impl=implementation EOF { impl }

implementation:
| e=entities { Imodel e }

%inline entities:
| xs=entity+ { xs }

entity_r:
 | x=use      { x }
 | x=model    { x }
 | x=constant { x }
 | x=role     { x }
 | x=asset    { x }

%inline entity:
| e=loc(entity_r) { e }

use:
| USE x=ident { Tuse x }

model:
| MODEL x=ident { Tmodel x }

constant:
| CONSTANT x=ident y=ident { Tconstant (x, y) }

role:
| ROLE _ext=option(extention) x=ident { Trole x }

asset:
| ASSET x=ident _id=option(IDENTIFIED BY y=ident { y })
    EQUAL fields=braced(fields)
    { Tasset (x, fields) }

%inline fields:
| xs=field+ { xs }

field_r:
| x=ident COLON y=ident boption(REF) SEMI_COLON
    { Tfield (x, y) }

%inline field:
| f=loc(field_r) { f }

extention:
| BEGIN_EXTENTION ids=idents RBRACKET { ids }

%inline ident:
| x=loc(IDENT) { x }

%inline idents:
| xs=ident+ { xs }

%inline braced(X):
| LBRACE x=X RBRACE { x }

%inline loc(X):
| x=X {
    { pldesc = x;
      plloc  = Location.make $startpos $endpos; }
  }