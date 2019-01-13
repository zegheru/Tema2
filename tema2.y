%{
	#include<stdio.h>
	#include<string.h>
	#include<stdlib.h>
	
	int yylex();
	int yyerror(const char *msg);

     	int EsteCorecta = 1;

	char msg[500];

	extern int numarColoana;
	extern int numarLinie;

	class TVAR
	{
	     char* nume;
	     int valoare;
	     TVAR* next;
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
             void add(char* n, int v = -1);
             int getValue(char* n);
	     void setValue(char* n, int v);
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->next = NULL;
	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

         void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }

         int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	  void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->valoare = v;
	      }
	      tmp = tmp->next;
	    }
	  }

	TVAR* inst = NULL;

%}

%union { char* sir; int val; } 

%token <sir> TOK_PROGRAM TOK_VAR TOK_BEGIN TOK_END TOK_INTEGER TOK_DIV TOK_READ TOK_POINT
%token <sir> TOK_WRITE TOK_FOR TOK_DO TOK_TO
%token <sir> TOK_SEMICOL TOK_COLON TOK_ASSIGNEMENT TOK_PLUS TOK_MINUS
%token <sir> TOK_MULTIPLY TOK_COMMA TOK_ERROR

%token <sir> TOK_VARIABLE 
%token <val> TOK_NUMBER TOK_LEFT TOK_RIGHT

%type <sir> idlist
%type <val> exp term factor

%start prog

%%

prog:		TOK_PROGRAM progname TOK_VAR declist TOK_BEGIN stmtlist TOK_END TOK_POINT;
		
progname:	TOK_VARIABLE;

declist:	dec 
		|
		declist TOK_SEMICOL dec;

dec: 		idlist TOK_COLON type
		{
			char* aux = (char*)malloc(sizeof(char)*20);
			strcpy(aux, $1);
			char* tok = (char*)malloc(sizeof(char)*20);
			
			tok = strtok(aux, "+");
			while(tok != NULL)
			{
				if(inst->exists(tok) == 1)
				{
					sprintf(msg, "variable %s was already declared\n", tok);
					yyerror(msg);
				}
				else
				{
					inst->add(tok, 0);
				}
				tok = strtok(NULL, "+");
			}
		}
		;

type: 		TOK_INTEGER;

idlist: 	TOK_VARIABLE
		|
		idlist TOK_COMMA TOK_VARIABLE
		{
			strcat($$, "+");
			strcat($$, $3);
		}
		;

stmtlist: 	stmt
		|
		stmtlist TOK_SEMICOL stmt;

stmt:		assign
		|
		read
		|
		write
		|
		for;

assign: 	TOK_VARIABLE TOK_ASSIGNEMENT exp;

exp:		term
		|
		exp TOK_PLUS term
		|
		exp TOK_MINUS term;

term:		factor
		|
		term TOK_MULTIPLY factor
		|
		term TOK_DIV factor
		{
			if($3 == 0)
			{
				sprintf(msg, "divided by 0\n");
				yyerror(msg);
			}
		}
		;
factor: 	TOK_VARIABLE
		{
			if(inst->exists($1))
			{
				if(inst->getValue($1) == 0)
				{
					sprintf(msg, "variable %s was not initialised\n", $1);
					yyerror(msg);
				}
			}
			else
			{
				sprintf(msg, "variable %s was not declared\n", $1);
				yyerror(msg);
			}
			
		}
		|
		TOK_NUMBER
		|
		TOK_LEFT exp TOK_RIGHT;

read: 		TOK_READ TOK_LEFT idlist TOK_RIGHT
		{
			char* aux = (char*)malloc(sizeof(char)*20);
			strcpy(aux, $3);
			char* tok = (char*)malloc(sizeof(char)*20);
			
			tok = strtok(aux, "+");
			while(tok != NULL)
			{
				if(inst->exists(tok) == 1)
				{
					inst->setValue(tok, 1);
				}
				else
				{
					sprintf(msg, "variable %s was already declared\n", tok);
					yyerror(msg);
					
				}
				tok = strtok(NULL, "+");
			}
		}
		;

write: 		TOK_WRITE TOK_LEFT idlist TOK_RIGHT
		{
			char* aux = (char*)malloc(sizeof(char)*20);
			strcpy(aux, $3);
			char* tok = (char*)malloc(sizeof(char)*20);
			
			tok = strtok(aux, "+");
			while(tok != NULL)
			{
				if(inst->exists(tok) == 0)
				{
					sprintf(msg, "variable %s was not declared\n", tok);
					yyerror(msg);
				}
				else 
				{
					if(inst->getValue(tok) == -1)
					{
						sprintf(msg, "variable %s was not initialised\n", tok);
						yyerror(msg);
					}
					else
					{
						printf("%s = %d\n", tok, inst->getValue(tok));
					}
				}
				tok = strtok(NULL, "+");
			}
		}
		;

for: 		TOK_FOR indexexp TOK_DO body;

indexexp:	TOK_VARIABLE TOK_ASSIGNEMENT exp TOK_TO exp;
		{
			
		}

body: 		stmt
		|
		TOK_BEGIN stmtlist TOK_END;

%%

int main()
{
	yyparse();
	
	if(EsteCorecta == 1)
	{
		printf("CORECTA\n");		
	}
	else
		printf("INCORECT\n");
	
	return 0;
}

int yyerror(const char *msg)
{
	EsteCorecta = 0;
	printf("Error: %s %d %d\n", msg, numarLinie, numarColoana);
	return 1;
}


































