#include <stdio.h>
#include <gmp.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>

// in teoria non dovrebbe essere usata perché 
// richiede la conoscenza della chiave privata che 
// dovrebbe essere nota solamente a chi gestisce
// l'asta

void getNumber(char *result, int base) {
	mpz_t total, current;
	mpz_init(current);
	mpz_set_ui(current,base);
	mpz_init_set_str(total,result,10);
	// TODO calcolare resti moduli successivi
}

int main(int argc, char **argv) {
	if(argc != 2) {
		printf("Usage: ./encrypt <encrypted>\n");
		exit(-1);
	}
	
	// pt e qt sono i due primi	
	int pt = 179426549;
	int qt = 179426491;
	char result[100]; // voto cifrato
	// int base = 1000; 
	
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
	
	mpz_t c0,c1,m0,m1,decrypt,cypher;
	mpz_init(c0);
	mpz_init(c1);
	mpz_init(m0);
	mpz_init(m1);
	mpz_init(decrypt);
	mpz_init_set_str(cypher,argv[1],10);
	
	mpz_powm(c0,cypher,lambda,nquadro);
	mpz_sub_ui(c1,c0,1);
	mpz_cdiv_q(m0,c1,n);
	mpz_mul(m1,m0,mu);
	mpz_mod(decrypt,m1,n);
	
	strcpy(result,mpz_get_str(NULL,10,decrypt));
	printf("Risultato decifratura: %s\n",result);
	
	mpz_clear(c0);
	mpz_clear(c1);
	mpz_clear(m0);
	mpz_clear(m1);
	mpz_clear(decrypt);

	return(0);

}
