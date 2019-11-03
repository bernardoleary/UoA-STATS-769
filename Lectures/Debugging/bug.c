
#include <R.h>
#include <stdlib.h>

void f(double* x, int* i, double *y) {
    if (*i < 0) {
        error("Invalid index");
    }
    if (*i > 1) {
        y = 0;
    }
    *y = x[*i] + 1;
}
