#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <time.h>

int main(void) {

    printf("Hello World!\n");   // libc

    // needed to create random number
    time_t t;
    srand((unsigned) time(&t));
    int rNum = rand();

    double sr = sqrt(rNum);

    printf("Square root of %d is %f\n", rNum, sr);

    return 0;
}
