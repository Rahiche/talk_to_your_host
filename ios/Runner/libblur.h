// libblur.h
#ifndef LIBBLUR_H
#define LIBBLUR_H

#include <stdint.h>

uint8_t* gaussian_blur(uint8_t* pixels, int width, int height, int radius);

#endif // LIBBLUR_H
