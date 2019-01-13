%{
	#include"y.tab.h"
	int numarLinie = 1;
	int numarColoana = 1;
%}

%%

"PROGRAM"			{ numarColoana += 7; return TOK_PROGRAM; }
"VAR"				{ numarColoana += 3; return TOK_VAR; }
"BEGIN"				{ numarColoana += 5; return TOK_BEGIN; }
"END"				{ numarColoana += 3; return TOK_END; }
"INTEGER"			{ numarColoana += 7; return TOK_INTEGER; }
"DIV"				{ numarColoana += 3; return TOK_DIV; }
"READ"				{ numarColoana += 4; return TOK_READ; }
"WRITE"				{ numarColoana += 5; return TOK_WRITE; }
"FOR"				{ numarColoana += 3; return TOK_FOR; }
"DO"				{ numarColoana += 2; return TOK_DO; }
"TO"				{ numarColoana += 2; return TOK_TO; }
":="				{ numarColoana += 2; return TOK_ASSIGNEMENT; }
":"				{ numarColoana ++; return TOK_COLON; }
";"				{ numarColoana ++; return TOK_SEMICOL; }
"," 				{ numarColoana ++; return TOK_COMMA; }
"("				{ numarColoana ++; return TOK_LEFT; }
")"				{ numarColoana ++; return TOK_RIGHT; }
"+"				{ numarColoana ++; return TOK_PLUS; }
"-"				{ numarColoana ++; return TOK_MINUS; }
"*"				{ numarColoana ++; return TOK_MULTIPLY; }
0|[1-9][0-9]*			{ numarColoana += strlen(yytext); 
				  yylval.val = atoi(yytext); 
				  return TOK_NUMBER; }
[a-zA-Z][a-zA-Z0-9_]* 		{ numarColoana += strlen(yytext); 
				  yylval.sir = new char[strlen(yytext)+1]; 
				  strcpy(yylval.sir,yytext); 
				  return TOK_VARIABLE;}
\.				{ numarColoana ++; return TOK_POINT; }
[ ]				{ numarColoana ++; }	
\n				{ numarLinie ++; numarColoana = 1; }
.				{ numarColoana ++; return TOK_ERROR; }

%%


