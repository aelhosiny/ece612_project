#include <stdio.h>

int main()
{

	
	int nsamples = 10000;
	unsigned int multiplier, multiplicand;
	unsigned long long result;

	int temp = sizeof(result);
	printf("size of result is %d\n", temp);
	// ***** Open o/p files
	FILE *opa_f = fopen("multiplicand_c.txt", "w");
	FILE *opb_f = fopen("multiplier_c.txt", "w");
	FILE *res_f = fopen("result_c.txt", "w");

	int i;
	for (i=0; i<nsamples; i++) {
		multiplicand = rand();
		multiplier = rand();
		result = (unsigned long long) multiplicand * (unsigned long long) multiplier;
		fprintf(opa_f, "%u\n", multiplicand);
		fprintf(opb_f, "%u\n", multiplier);
		fprintf(res_f, "%llu\n", result);
	}

	fclose(opa_f);
	fclose(opb_f);
	fclose(res_f);

	return 0;
}
