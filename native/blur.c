#include <stdlib.h>
#include <stdint.h>
#include <math.h>

uint8_t* gaussian_blur(uint8_t* pixels, int width, int height, int radius) {
    int size = width * height * 4;
    uint8_t* result = (uint8_t*)malloc(size);
    int rs = ceil(radius * 2.57); // significant radius

    for (int i = 0; i < size; i++) {
        result[i] = pixels[i];
    }

    for (int i = 0; i < height; ++i) {
        for (int j = 0; j < width; ++j) {
            float r = 0, g = 0, b = 0, a = 0, wsum = 0;
            for (int iy = i - rs; iy < i + rs + 1; ++iy) {
                for (int ix = j - rs; ix < j + rs + 1; ++ix) {
                    int x = fmin(width - 1, fmax(0, ix));
                    int y = fmin(height - 1, fmax(0, iy));
                    int dsq = (ix - j) * (ix - j) + (iy - i) * (iy - i);
                    float wght = exp(-dsq / (2.0 * radius * radius)) / (M_PI * 2.0 * radius * radius);
                    int index = 4 * (y * width + x);
                    r += pixels[index + 0] * wght;
                    g += pixels[index + 1] * wght;
                    b += pixels[index + 2] * wght;
                    a += pixels[index + 3] * wght;
                    wsum += wght;
                }
            }
            int index = 4 * (i * width + j);
            result[index + 0] = round(r / wsum);
            result[index + 1] = round(g / wsum);
            result[index + 2] = round(b / wsum);
            result[index + 3] = round(a / wsum);
        }
    }

    return result;
}
