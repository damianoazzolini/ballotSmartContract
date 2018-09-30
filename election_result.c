#include <stdio.h>
#include <gmp.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>

void reverseString(char *input, char *output) {
	// printf("%s\n",input);
	int i = 0;
	int len = strlen(input) - 1;

	for(i = len; i >= 0; i--) {
		output[len - i] = input[i];
	}
	output[len+1] = '\0';
	// printf("%s\n",output);
}

void stringPad(char *input, char *output) {
	int len = strlen(input) - 1;
	int remaining = (len+1) % 3;
	int i = 0;

	strcpy(output,input);

	for(i = 0; i <= remaining; i++) {
		output[len+1+i] = '0';
	}
	output[len+1+i] = '\0';
	// printf("Pad: %s\n",output);
}



// TODO sostituire con una system call a decrypt
void decrypt(char *value) {
	// pt e qt sono i due primi
	int pt = 179426549;
	int qt = 179426491;
	char result[100]; // voto cifrato
	char reversedResult[100];
	char pad[100];
	char dest[100];
	char rev[4];
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
	mpz_init_set_str(cypher,value,10);

	mpz_powm(c0,cypher,lambda,nquadro);
	mpz_sub_ui(c1,c0,1);
	mpz_cdiv_q(m0,c1,n);
	mpz_mul(m1,m0,mu);
	mpz_mod(decrypt,m1,n);

	strcpy(result,mpz_get_str(NULL,10,decrypt));
	// printf("Risultato decifratura: %s\n",result);

	reverseString(result,reversedResult);
	stringPad(reversedResult,pad);

	int i;
	for(i = 0; i < (int)strlen(pad); i = i+3) {
		strncpy(dest,&pad[i],3);
		dest[3] = '\0';
		reverseString(dest,rev);
		printf("Candidato %d: %s voti\n - ",i/3,rev);
	}

	mpz_clear(c0);
	mpz_clear(c1);
	mpz_clear(m0);
	mpz_clear(m1);
	mpz_clear(decrypt);
}

int main() {
    char current_vote[100];
    FILE *fp;

    if ((fp = fopen("votes.txt", "r")) == NULL) {
        printf("File votes.txt not found");
        exit(-1);
    }

	// pt e qt sono i due primi
	int pt = 179426549;
	int qt = 179426491;
	char final_result[100];

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

	mpz_t total,result,currentMul,current;
	mpz_init(total);
	mpz_init(currentMul);
	mpz_init(result);
	mpz_init(current);

	mpz_set_ui(currentMul,1);

	while(fscanf(fp,"%s",current_vote) != EOF) {
		mpz_set_str(current,current_vote,10);
		mpz_mul(currentMul,currentMul,current);
		mpz_mod(currentMul,currentMul,nquadro);
	}

	mpz_mod(result,currentMul,nquadro);
	strcpy(final_result,mpz_get_str(NULL,10,result));

	mpz_clear(total);
	mpz_clear(result);
	mpz_clear(currentMul);
	fclose(fp);

	decrypt(final_result);

	return (0);
}
