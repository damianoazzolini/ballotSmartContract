#include <stdio.h>
#include <gmp.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {
	if(argc != 2) {
		printf("Usage: ./encrypt <vote_number>\n");
		exit(-1);
	}

	// pt e qt sono i due primi	
	int pt = 179426549;
	int qt = 179426491;
	int esponente = atoi(argv[1]); // controllare se va bene
	int base = 1000; // suppongo milite di 1000 votanti
	int r = rand();
	char result[100]; // voto cifrato
	
	mpz_t p,q,n,lambda,nquadro,g,mu,p1,q1;
	
	// n = pq, lambda = fi(n), g = n+1, mu = fi(n)^-1 mod n
	mpz_init(p);
	mpz_init(q);
	mpz_init(n);
	mpz_init(lambda);
	mpz_init(nquadro);
	mpz_init(g);
	mpz_init(mu);
	mpz_init(p1);
	mpz_init(q1);
	
	// inizializzo p e q
	mpz_set_ui(p,pt);
	mpz_set_ui(q,qt);
	mpz_mul(n,p,q);
	mpz_sub_ui(p1,p,1);
	mpz_sub_ui(q1,q,1);
	mpz_mul(lambda,p1,q1);
	mpz_add_ui(g,n,1);
	mpz_mul(nquadro,n,n);
	
	if(mpz_invert(mu,lambda,n) == 0) {
		printf("Impossibile invertire lamda mod n\n");
		exit(-1);
	}

	mpz_t v0,v1,v2,vrand,v3,cypher;
	mpz_init(v0);
	mpz_init(v1);
	mpz_init(v2);
	mpz_init(vrand);
	mpz_init(v3);
	mpz_init(cypher);
	
	mpz_set_ui(vrand,r);
	mpz_ui_pow_ui(v0,base,esponente);
	mpz_powm(v1,g,v0,nquadro);
	mpz_powm(v2,vrand,n,nquadro);
	mpz_mul(v3,v1,v2);
	mpz_mod(cypher,v3,nquadro);
	
	strcpy(result,mpz_get_str(NULL,10,cypher));
	printf("%s\n",result);
	
	mpz_clear(v0);
	mpz_clear(v1);
	mpz_clear(v2);
	mpz_clear(vrand);
	mpz_clear(v3);
	mpz_clear(cypher);

	return(0);
}
