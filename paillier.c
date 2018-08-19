#include <stdio.h>
#include <gmp.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>

void getMultiplication(char **array,char *multiplicationResult, mpz_t nquadro, int nElements) {
	int i = 0;
	
	mpz_t total,result,currentMul,current;
	mpz_init(total);
	mpz_init(currentMul);
	mpz_init(result);
	mpz_init(current);
	
	mpz_set_ui(currentMul,1);
	
	for(i = 0; i < nElements; i++) {
		printf("Elemento corrente: %s\n",array[i]);
		mpz_set_str(current,array[i],10);
		mpz_mul(currentMul,currentMul,current);
		// ottimizzare riducendo a modulo ad ogni ciclo
	}
	mpz_mod(result,currentMul,nquadro);
	strcpy(multiplicationResult,mpz_get_str(NULL,10,result));
	
	mpz_clear(total);
	mpz_clear(result);
	mpz_clear(currentMul);
}

void decryptMessage(mpz_t cypher, mpz_t lambda, mpz_t n, mpz_t nquadro, mpz_t mu, char *result) {
	mpz_t c0,c1,m0,m1,decrypt;
	mpz_init(c0);
	mpz_init(c1);
	mpz_init(m0);
	mpz_init(m1);
	mpz_init(decrypt);
	
	mpz_powm(c0,cypher,lambda,nquadro);
	mpz_sub_ui(c1,c0,1);
	mpz_cdiv_q(m0,c1,n);
	mpz_mul(m1,m0,mu);
	mpz_mod(decrypt,m1,n);
	strcpy(result,mpz_get_str(NULL,10,decrypt));
	
	mpz_clear(c0);
	mpz_clear(c1);
	mpz_clear(m0);
	mpz_clear(m1);
	mpz_clear(decrypt);
}

void encryptMessage(mpz_t g, mpz_t n, mpz_t nquadro, char *result) {
	int esponente;
	int base = 1000;
	
	printf("Inserire per chi votare: 1, 2, 3: ");
	scanf("%d",&esponente);

	int r = rand();
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
	
	mpz_clear(v0);
	mpz_clear(v1);
	mpz_clear(v2);
	mpz_clear(vrand);
	mpz_clear(v3);
	mpz_clear(cypher);
}

int main() {
	srand(time(NULL));
	
	int pt = 179426549;
	int qt = 179426491;
	char encryptionResult[100];
	char multiplicationResult[100];
	char finalResult[100];
	int scelta;
	
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
	
	// menù di selezione: 
	// 1) cifro
	// 2) decifro
	// 3) ottengo risultato
	printf("Selezionare operazione: \n");
	printf("1]: Cifra voto\n");
	printf("2]: Deifra voto\n");
	printf("3]: Ottieni risultato\n");
	scanf("%d",&scelta);

	if(scelta == 1) {
		encryptMessage(g, n, nquadro, encryptionResult);
		printf("Risultato cifratura: %s\n", encryptionResult);
	}
	else if(scelta == 2) {

	}
	else if(scelta = 3) {
		
	}


	// inserire controllo proof of range
	
	encryptMessage(g,n,nquadro,encryptionResult);
	printf("Risultato cifratura: %s\n",encryptionResult);
	
	char **array = (char **)malloc(12*sizeof(char*));
	
	for(int i = 0; i < 2; i++) {
		array[i] = (char *)malloc(100*sizeof(char));
	}
	
	array[0] = "902898354428103960845584700263835";
	array[1] = "902898354428103960845584700263835";
	array[2] = "902898354428103960845584700263835";
	array[3] = "902898354428103960845584700263835";
	array[4] = "902898354428103960845584700263835";
	array[5] = "556059625255528223682703371494509";
	array[6] = "556059625255528223682703371494509";
	array[7] = "556059625255528223682703371494509";
	array[8] = "556059625255528223682703371494509";
	array[9] = "556059625255528223682703371494509";
	array[10] = "556059625255528223682703371494509";
	array[11] = "556059625255528223682703371494509";
	
	
	printf("%s, %s\n",array[0],array[1]);
	
	getMultiplication(array,multiplicationResult,nquadro,12);
	printf("Risultato moltiplicazione: %s\n",multiplicationResult);
	
	mpz_t resultMul;
	mpz_init(resultMul);
	mpz_set_str(resultMul,multiplicationResult,10);
	decryptMessage(resultMul,lambda,n,nquadro,mu,finalResult);
	printf("Risultato votazione %s\n",finalResult);
	
	mpz_clear(resultMul);
	
	// FREEE DI TUTTO
	// p,q,n,lambda,nquadro,g,mu,p1,q1;
	mpz_clear(p);
	mpz_clear(q);
	mpz_clear(n);
	mpz_clear(lambda);
	mpz_clear(nquadro);
	mpz_clear(g);
	mpz_clear(mu);
	mpz_clear(p1);
	mpz_clear(q1);
	
	return 0;
}