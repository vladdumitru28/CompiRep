%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	
	using namespace std;
	
	int yylex();
	int yyerror(const char *msg);
    	int EsteCorecta = 1;
	char msg[100];
	
	class List
	{
		char *id;
		bool isInit;
		List *next;
	   public:
		static List *head;
		static List *tail;
		List(char *n);
		List();
		bool exists(char *n);
		void add(char *n);
		void setInit (char *n);
		bool getInit(char *n);	
	};
	
	List* List::head = NULL;
	List* List::tail = NULL;
	List::List()
	{
		next = NULL;
		id = NULL;
		isInit = 0;
	}
	List::List(char *n)
	{
		this->id = new char[strlen(n)+1];
		strcpy(this->id,n);
		this->isInit = 0;
		this->next = NULL;	
	}
	bool List::exists(char *n)
	{
		List *temp = List::head;
		while(temp != NULL)
		{
			if(strcmp(temp->id,n) == 0)
				return 1;
			temp = temp->next;
		}
		return 0;
	}
	void List::add(char *n)
	{
		List *nElem = new List(n);
		if(List::head == NULL)
			List::head = List::tail = nElem; 
		else{
			List::tail->next = nElem;
			List::tail = nElem;
		}
	}
	void List::setInit(char *n)
	{
		List *temp = List::head;
		while(temp != NULL)
		{
			if(strcmp(temp->id,n) == 0)
			{temp->isInit = 1; break;}
			temp = temp->next;
		}
	}
	bool List::getInit(char *n)
	{
		List *temp = List::head;
		while(temp != NULL)
		{
			if(strcmp(temp->id,n) == 0)
			{return temp->isInit; break;}
			temp = temp->next;
		}
	}
	
	List *ts;
%}

%start prog
%union {int num; char* sir;}
%token TOK_PLUS TOK_MINUS TOK_MULTIPLY TOK_DIVIDE TOK_LEFT TOK_RIGHT TOK_ERROR TOK_ASSIGN
%token TOK_PROG TOK_BEG TOK_END TOK_VAR TOK_INTEGER TOK_FOR TOK_DO TOK_TO
%token TOK_READ TOK_WRITE
%token TOK_INT
%token <sir> TOK_ID
%type <sir> id_list
%locations

%left TOK_PLUS TOK_MINUS
%left TOK_MULTIPLY TOK_DIVIDE

%%

prog :  
	|
	TOK_PROG prog_name TOK_VAR dec_list TOK_BEG stmt_list TOK_END'.'
	;
prog_name : TOK_ID
	;
dec_list : dec
	|
	dec_list ';' dec
	|
	error ';' dec
	;
dec : id_list ':' type
		{
			if(ts == NULL)
				ts = new List();
			char *temp = strtok($1, ",");
			while(temp != NULL)
			{	
				if(ts->exists(temp) == 0)
					ts->add(temp);
				else{
					sprintf(msg,"%d:%d Eroare semantica: Declarare multipla pt variabila %s",@1.first_line, @1.first_column, temp);
	    				yyerror(msg);
				}
				temp = strtok(NULL, ",");
			}	
		}
	;
type : TOK_INTEGER
	;
id_list : TOK_ID
		{ $$ = $1; }
	|
	id_list ',' TOK_ID
		{
			$$ = new char[strlen($1)+strlen($3)+2];
			strcpy($$,$1);
			strcat($$,",");
			strcat($$,$3); 
		}
	;
stmt_list : stmt
	|
	stmt_list ';' stmt
	|
	error ";" stmt
	;
stmt : assign
	|
	read
	|
	write
	|
	for
	;
assign : TOK_ID TOK_ASSIGN exp
		{
			if(ts->exists($1))
			{
				ts->setInit($1);
			}
			else{
				sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", 					@1.first_line, @1.first_column, $1);
	    			yyerror(msg);
			}
			
			
		}
	|
	TOK_ID TOK_ASSIGN error
		{
			if(ts->exists($1))
			{
				ts->setInit($1);
			}
			else{
				sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", 					@1.first_line, @1.first_column, $1);
	    			yyerror(msg);
			}
			
			
		}
	;
exp : term
	|
	exp TOK_PLUS term
	|
	exp TOK_MINUS term
	;
term : factor
	|
	term TOK_MULTIPLY factor
	|
	term TOK_DIVIDE factor
	;
factor : primary
	|
	TOK_LEFT TOK_PLUS factor TOK_RIGHT
	|
	TOK_LEFT TOK_MINUS factor TOK_RIGHT
	;
primary : TOK_ID
		{
			if(ts->exists($1))
			{
				if(!(ts->getInit($1)))
				{
					sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost initializata!", @1.first_line, @1.first_column, $1);
		      			yyerror(msg);
				}
			}	
			else{
				sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", 					@1.first_line, @1.first_column, $1);
		    		yyerror(msg);
			}
		}	
	|
	TOK_INT
	|
	TOK_LEFT exp TOK_RIGHT
	;
read : TOK_READ TOK_LEFT id_list TOK_RIGHT
		{
			char *temp = strtok($3, ",");
			while(temp != NULL)
			{
				if(ts->exists(temp))
				{
					ts->setInit(temp);
				}
				else{
					sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", 					@1.first_line, @1.first_column, temp);
	    				//yyerror(msg);
	    				yyerror(msg);
				}
				temp = strtok(NULL, ",");
			}
		}
	;
write : TOK_WRITE TOK_LEFT id_list TOK_RIGHT
		{
			char *temp = strtok($3, ",");
			while(temp != NULL)
			{
				if(ts->exists(temp))
				{
					if(!(ts->getInit(temp)))
					{
						sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost initializata!", @1.first_line, @1.first_column, temp);
		      				yyerror(msg);
					}
				}	
				else{
					sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!",@1.first_line, @1.first_column, temp);
		    			yyerror(msg);
				}
				temp = strtok(NULL, ",");
			}
		}
	;
for : TOK_FOR index_exp TOK_DO body
	;
index_exp :TOK_ID TOK_ASSIGN exp TOK_TO exp
		{
			if(ts->exists($1))
			{
				ts->setInit($1);
			}
			else{
				sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", 					@1.first_line, @1.first_column, $1);
	    			yyerror(msg);
			}
			
			
		}
	;
body : stmt
	|
	TOK_BEG stmt_list TOK_END
	;
%%

int main()
{
	yyparse();
	
	if(EsteCorecta == 1)
	{
		printf("CORECTA");		
	}	
	else
	{
		printf("INCORECTA");
	}

       return 0;
}

int yyerror(const char *msg)
{
	EsteCorecta = 0;
	printf("%s\n", msg);
	return 1;
}
