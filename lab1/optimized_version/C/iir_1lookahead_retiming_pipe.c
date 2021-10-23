#include<stdio.h>
#include<stdlib.h>
#include<math.h>

#define N 2 /// order of the filter
#define NB 9  /// number of bits
#define NB_MULT 17 // multiplier parallelism 2.16
#define NB_FIRST_ADD 10 // first (upper-left) adder parallelism 2.8
#define NB_ADD 7 // other adder parallelism 2.6
#define N_TRUNC_MULT 10
#define N_PIPE 2 // number of pipeline registers

const int b0 = 52; /// coefficient b0
const int b1 = 105;
const int b2 = 52;
const int c0 = 95; /// coefficient a0
const int c1 = -16;
const int c2 = -19;

int saturation(int number, int paralellism) {
  int sat_number;
  int max_pos_number = pow(2, paralellism - 1) - 1;
  int max_neg_number = -pow(2, paralellism - 1);

  if(number>max_pos_number) {
    sat_number = max_pos_number;
    printf("Overflow (positive)\n");
  }
  else if(number<max_neg_number) {
    sat_number = max_neg_number;
    printf("Overflow (negative)\n");
  }
  else {
    sat_number = number;
  }

  return sat_number;
}

/// Perform fixed point filtering assuming direct form II
///\param x is the new input sample
///\return the new output sample
int myfilter(int x)
{
  //static int sw[N+1]; /// w shift register
  static int first_run = 0; /// for cleaning the shift register
  int i; /// index
  int w; /// intermediate value (w)
  int y; /// output sample
  int fb, ff; /// feed-back and feed-forward results
  int mul_c0;
  int mul_c1;
  int mul_c2;
  int mul_b0;
  int mul_b1;
  int mul_b2;
  static int mul_c0_del1;
  static int mul_c1_del1;
  static int mul_c2_del[2];
  static int w_del1;
  static int w_del2;
  static int mul_b0_del1;
  static int mul_b1_del1;
  static int mul_b2_del[2];

  /// clean the buffer
  if (first_run == 0)
  {
    first_run = 1;
    mul_c0_del1 = 0;
    mul_c1_del1 = 0;
    w_del1 = 0;
    w_del2 = 0;
    mul_b0_del1 = 0;
    mul_b1_del1 = 0;
    for (i=0; i<2; i++){
        mul_c2_del[i] = 0;
        mul_b2_del[i] = 0;
    }
  }

  /// compute feed-back and feed-forward
  fb = mul_c1_del1 + mul_c2_del[1];
  fb = saturation(fb, NB_ADD);
  w = (mul_c0_del1 << 2) + x + (fb << 2);
  w = saturation(w, NB_FIRST_ADD);
  ff = mul_b1_del1 + mul_b2_del[1];
  ff = saturation(ff, NB_ADD);
  y = (mul_b0_del1 + ff) << 2;
  y = saturation(y, NB_ADD+2);

  /// compute intermediate values
  mul_c0 = c0 * x;
  mul_c0 = saturation(mul_c0, NB_MULT);
  mul_c0 = mul_c0 >> N_TRUNC_MULT;
  mul_c0 = saturation(mul_c0, NB_ADD);
  mul_c1 = c1 * w_del1;
  mul_c1 = saturation(mul_c1, NB_MULT);
  mul_c1 = mul_c1 >> N_TRUNC_MULT;
  mul_c1 = saturation(mul_c1, NB_ADD);
  mul_c2 = c2 * w_del1;
  mul_c2 = saturation(mul_c2, NB_MULT);
  mul_c2 = mul_c2 >> N_TRUNC_MULT;
  mul_c2 = saturation(mul_c2, NB_ADD);
  mul_b0 = b0 * w_del1;
  mul_b0 = saturation(mul_b0, NB_MULT);
  mul_b0 = mul_b0 >> N_TRUNC_MULT;
  mul_b0 = saturation(mul_b0, NB_ADD);
  mul_b1 = b1 * w_del2;
  mul_b1 = saturation(mul_b1, NB_MULT);
  mul_b1 = mul_b1 >> N_TRUNC_MULT;
  mul_b1 = saturation(mul_b1, NB_ADD);
  mul_b2 = b2 * w_del2;
  mul_b2 = saturation(mul_b2, NB_MULT);
  mul_b2 = mul_b2 >> N_TRUNC_MULT;
  mul_b2 = saturation(mul_b2, NB_ADD);

  /// update registers
  for (i=1; i>0; i--){
    mul_c2_del[i] = mul_c2_del[i-1];
    mul_b2_del[i] = mul_b2_del[i-1];
  }
  mul_c0_del1 = mul_c0;
  mul_c1_del1 = mul_c1;
  mul_c2_del[0] = mul_c2;
  w_del2 = w_del1;
  w_del1 = w;
  mul_b0_del1 = mul_b0;
  mul_b1_del1 = mul_b1;
  mul_b2_del[0] = mul_b2;

  return y;
}

int main (int argc, char **argv)
{
  FILE *fp_in;
  FILE *fp_out;

  int x;
  int y;
  int i = 0;

  /// check the command line
  if (argc != 3)
  {
    printf("Use: %s <input_file> <output_file>\n", argv[0]);
    exit(1);
  }

  /// open files
  fp_in = fopen(argv[1], "r");
  if (fp_in == NULL)
  {
    printf("Error: cannot open %s\n");
    exit(2);
  }
  fp_out = fopen(argv[2], "w");

  /// get samples and apply filter
  fscanf(fp_in, "%d", &x);
  do{
    y = myfilter(x);
	// avoid to print first 2 results due to pipeline queue is empty
    if(i >= N_PIPE){
        fprintf(fp_out,"%d\n", y);
    }
    i++;
    fscanf(fp_in, "%d", &x);
  } while (!feof(fp_in));

  // read last 2 data from pipeline queue
  for(int i = 0; i < N_PIPE; i++){
    y = myfilter(0);
    fprintf(fp_out,"%d\n", y);
  }

  fclose(fp_in);
  fclose(fp_out);

  return 0;

}

