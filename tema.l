%{
	#include "y.tab.h"

	int lineNo = 1;
	int colNo = 1;
%}

%%
"+"				{ colNo++; return TOK_PLUS; }
"-"				{ colNo++; return TOK_MINUS; }
"*"				{ colNo++;  return TOK_MULTIPLY; }
"/"				{ colNo++;  return TOK_DIVIDE; }
"("				{ colNo++;  return TOK_LEFT; }
")"				{ colNo++;  return TOK_RIGHT; }
";"				{ colNo++;  return ';'; }
":"				{ colNo++;  return ':'; }
"."				{ colNo++;  return '.'; }
","				{ colNo++;  return ','; }
":="				{ colNo += 2;  return TOK_ASSIGN; }
"PROGRAM"			{ colNo += 7;  return TOK_PROG; }
"BEGIN"				{ colNo += 5;  return TOK_BEG; }
"END"				{ colNo += 3;  return TOK_END; }
"VAR"				{ colNo += 3;  return TOK_VAR; }
"INTEGER"			{ colNo += 7;  return TOK_INTEGER; }
"FOR"				{ colNo += 3;  return TOK_FOR; }
"DO" 				{ colNo += 2;  return TOK_DO; }
"TO"				{ colNo += 2;  return TOK_TO; }
"READ" 				{ colNo += 4; yylloc.first_line = lineNo; yylloc.first_column = colNo;   return TOK_READ; }
"WRITE"				{ colNo += 5; yylloc.first_line = lineNo; yylloc.first_column = colNo;   return TOK_WRITE; }
[1-9][0-9]*|0	{ yylloc.first_line = lineNo; yylloc.first_column = colNo; colNo+=strlen(yytext); yylval.num = atoi(yytext);  return TOK_INT; }
[a-zA-Z][a-zA-Z0-9]* { yylloc.first_line = lineNo; yylloc.first_column = colNo; colNo+=strlen(yytext); yylval.sir = new char[strlen(yytext)+1]; strcpy(yylval.sir,yytext);  return TOK_ID;}
[ ]				{ colNo++; }
\r\n			{ lineNo++; colNo=1; }
\n				{ lineNo++; colNo=1; }
.				{ colNo++;  return TOK_ERROR; }
%%
