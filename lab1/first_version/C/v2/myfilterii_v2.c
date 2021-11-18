#include<stdio.h>
#include<stdlib.h>
#include<math.h>

#define N 2 /// order of the filter
#define NB 9  /// number of bits
#define NB_MULT 18 // multiplier parallelism 2.16
#define NB_FIRST_ADD 10 // first (upper-left) adder parallelism 2.8
#define NB_ADD 8 // other adder parallelism 2.6
#define N_TRUNC_MULT 10

const int b0 = 52; /// coefficient b0
const int b[N]={105, 52}; /// b array
const int a[N]={-95, 50}; /// a array

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
  static int sw[N]; /// w shift register
  static int first_run = 0; /// for cleaning the shift register
  int i; /// index
  int w; /// intermediate value (w)
  int y; /// output sample
  int fb, ff; /// feed-back and feed-forward results
  int fb_mult;
  int ff_mult;
  int b0_mult;

  /// clean the buffer
  if (first_run == 0)
  {
    first_run = 1;
    for (i=0; i<N; i++)
      sw[i] = 0;
  }

  /// compute feed-back and feed-forward
  fb = 0;
  ff = 0;
  for (i=0; i<N; i++) {
    fb_mult = sw[i]*-a[i];
    fb_mult = saturation(fb_mult, NB_MULT);
    fb += (fb_mult >> N_TRUNC_MULT);
    fb = saturation(fb, NB_ADD);

    ff_mult = sw[i]*b[i];
    ff_mult = saturation(ff_mult, NB_MULT);
    ff += (ff_mult >> N_TRUNC_MULT);
    ff = saturation(ff, NB_ADD);
  }

  /// compute intermediate value (w) and output sample
  w = x + (fb << (NB_FIRST_ADD - NB_ADD));
  w = saturation(w, NB_FIRST_ADD);
  b0_mult = w*b0;
  b0_mult = saturation(b0_mult, NB_MULT);

  y = b0_mult >> N_TRUNC_MULT;
  y += ff;
  y = y << (NB_FIRST_ADD - NB_ADD);
  y = saturation(y, NB);

  /// update the shift register
  for (i=N-1; i>0; i--)
    sw[i] = sw[i-1];
  sw[0] = w;

  return y;
}

int main (int argc, char **argv)
{
  FILE *fp_in;
  FILE *fp_out;

  int x;
  int y;

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
    fprintf(fp_out,"%d\n", y);
    fscanf(fp_in, "%d", &x);
  } while (!feof(fp_in));

  fclose(fp_in);
  fclose(fp_out);

  return 0;

}
