#include <iostream>

#define checkCudaErrors(val) check_cuda((val), #val, __FILE__, __LINE__)
void check_cuda(cudaError_t result, char const *const func,
                const char *const file, int const line) {
    if (result) {
        std::cerr << "CUDA error = " << static_cast<unsigned int>(result)
                  << " at " << file << ":" << line << " '" << func << "' \n";
        cudaDeviceReset();
        exit(99);
    }
}

__global__ void render(float *fb, int max_x, int max_y) {
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    int j = threadIdx.y + blockIdx.y * blockDim.y;
    if ((i < max_x) && (j < max_y)) {
        int pixel_index = j * max_x * 3 + i * 3;
        fb[pixel_index + 0] = float(i) / max_x;
        fb[pixel_index + 1] = float(j) / max_y;
        fb[pixel_index + 2] = 0.2f;
    }
}

int main() {
    int image_width = 1024;
    int image_height = 1024;
    int tile_width = 8;
    int tile_height = 8;

    int num_pixels = image_width * image_height;
    size_t fb_size = 3 * num_pixels * sizeof(float);
    float *fb;

    checkCudaErrors(cudaMallocManaged((void **)&fb, fb_size));

    dim3 blocks(image_width / tile_width + 1, image_height / tile_height + 1);
    dim3 threads(tile_width, tile_height);
    render<<<blocks, threads>>>(fb, image_width, image_height);

    checkCudaErrors(cudaGetLastError());
    checkCudaErrors(cudaDeviceSynchronize());

    // -------------------------------

    std::cout << "P3\n" << image_width << " " << image_height << "\n255\n";

    for (int j = image_height - 1; j >= 0; j--) {
        for (int i = 0; i < image_width; i++) {
            size_t pixel_index = j * 3 * image_width + i * 3;
            float r = fb[pixel_index + 0];
            float g = fb[pixel_index + 1];
            float b = fb[pixel_index + 2];
            int ir = int(255.99 * r);
            int ig = int(255.99 * g);
            int ib = int(255.99 * b);
            std::cout << ir << " " << ig << " " << ib << "\n";
        }
    }

    checkCudaErrors(cudaFree(fb));

    return 0;
}