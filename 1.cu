#include <iostream>
#include <chrono>
using namespace std;
#include "cuda_interval_lib.h"
#include "cuda_check_error.cu"


#define TYPE float
typedef TYPE T;

__constant__ float dev_box[4];
// __constant__ int dev_threads[1];
// __constant__ int dev_blocks[1];
__constant__ int dev_n_of_ints[1];
__constant__ float dev_angle[1];

#include "functions.cu"



template<class T>
__global__ void large_grid(int* res){
  interval_gpu<T>* x = new interval_gpu<T>[dev_n_of_ints[0]];
  x[0] = interval_gpu<T>(dev_box[0] +  (threadIdx.x) * (dev_box[1] - dev_box[0])/blockDim.x,
                         dev_box[0] +(1+threadIdx.x) * (dev_box[1] - dev_box[0])/blockDim.x);
  x[1] = interval_gpu<T>(dev_box[2] +   (blockIdx.x) * (dev_box[3] - dev_box[2])/gridDim.x,
                         dev_box[2] + (1+blockIdx.x) * (dev_box[3] - dev_box[2])/gridDim.x);
  x[2] = interval_gpu<T>(M_PI/180*dev_angle[0], M_PI/180*(dev_angle[0]+1));
  res[(blockIdx.x*blockDim.x + threadIdx.x)] = 1;

  for(int i = 0; i < dev_n_of_func[0]; i++){
    res[(blockIdx.x*blockDim.x + threadIdx.x)] *= (*dev_func_pp[i])(x);
  }
}

void cout_objects(int* h_res, int blocks, int threads, float* host_box, double dx, double dy, float angle, int max_function_value){
for(int i = 0; i < blocks; i++){
  for(int j = 0; j < threads; j++){
    if(h_res[i * threads + j] % max_function_value > 0){
      interval_gpu<T> x3(host_box[0] + j*dx, host_box[0] + (j+1)*dx );
      interval_gpu<T> x4(host_box[2] + i*dy ,host_box[2] + (i+1)*dy );
      interval_gpu<T> xz(angle, angle + 1);
      cout<<x3<<":"<<x4<<":"<<xz<<"\n";
    }
  }
}
}

int main(int argc, char* argv[]){
cout<<fixed;
cout.precision(5);
int elapsed_seconds;

int n_of_ints = 3;
int n_of_func = 6;
int max_function_value = pow(2,n_of_func);
float host_box[4] = {-10,20,-10,20};
int blocks = 150;
double proportion = abs(host_box[1]-host_box[0])/abs(host_box[3]-host_box[2]);
int threads = blocks*proportion;
int second_grid = 100;
double dx = abs(host_box[1]-host_box[0])/threads;
double dy = abs(host_box[3]-host_box[2])/blocks;
double offset_x = host_box[0];
double offset_y = host_box[2];
int* res;
int* h_res   = (int*)malloc(sizeof(int)*blocks*threads);
int* h_res_2 = (int*)malloc(sizeof(int)*second_grid*second_grid);
int* corner  = (int*)malloc(sizeof(int));

float side_triangle = 2.0;
float xb1 = -side_triangle/2;
float yb1 =  side_triangle * sqrt(3)/6;
float xb2 =  side_triangle/2;
float yb2 =  side_triangle * sqrt(3)/6;
float xb3 =  0;
float yb3 =  side_triangle * sqrt(3)/3;
float host_triangle[6] = {xb1,yb1,xb2,yb2,xb3,yb3};
float host_angle;
int use_doublegrid = 1;

std::chrono::time_point<std::chrono:: high_resolution_clock> start, end;
start = std::chrono::high_resolution_clock::now();

for(int ang = -90; ang < 90; ang++){
    host_angle = ang;
    cudaMalloc(&res, sizeof(int)*blocks*threads);
    cudaMemcpyToSymbol(dev_n_of_ints, &n_of_ints,     sizeof(int));
    cudaMemcpyToSymbol(dev_n_of_func, &n_of_func,     sizeof(int));
    cudaMemcpyToSymbol(dev_box,       &host_box,      sizeof(float)*4);
    cudaMemcpyToSymbol(triangle,      &host_triangle, sizeof(float)*6);
    cudaMemcpyToSymbol(dev_angle,     &host_angle,    sizeof(float));

    large_grid<T><<<blocks, threads>>>(res);
    CudaCheckError();
    cudaDeviceSynchronize();
    cudaMemcpy(h_res, res, sizeof(int)*blocks*threads, cudaMemcpyDeviceToHost);
    cudaDeviceSynchronize();
    CudaCheckError();
    cudaFree(res);
    cudaDeviceReset();

    if(use_doublegrid == 0)
    {
      cout_objects(h_res, blocks, threads, host_box, dx,dy, host_angle, max_function_value);
    }
    else
    {
    for(int i = 0; i < blocks; i++){
      for(int j = 0; j < threads; j++){
        if(h_res[i * threads + j] % max_function_value > 0){
          host_box[0] = offset_x + j * dx;
          host_box[1] = offset_x + (j+1) * dx;
          host_box[2] = offset_y + i * dy;
          host_box[3] = offset_y + (i+1) * dy;
          double dx_1 = abs(host_box[1] - host_box[0]) / second_grid;
          double dy_1 = abs(host_box[3] - host_box[2]) / second_grid;

          cudaDeviceReset();
          cudaMalloc(&res, sizeof(int)*blocks*blocks);
          cudaMemcpyToSymbol(dev_n_of_ints, &n_of_ints,     sizeof(int));
          cudaMemcpyToSymbol(dev_n_of_func, &n_of_func,     sizeof(int));
          cudaMemcpyToSymbol(dev_box,       &host_box,      sizeof(float)*4);
          cudaMemcpyToSymbol(triangle,      &host_triangle, sizeof(float)*6);
          cudaMemcpyToSymbol(dev_angle,     &host_angle,    sizeof(float));
          large_grid<T><<<second_grid,second_grid>>>(res);

          CudaCheckError();
          cudaDeviceSynchronize();
          cudaMemcpy(h_res_2, res, sizeof(int)*second_grid*second_grid, cudaMemcpyDeviceToHost);
          cudaDeviceSynchronize();
          CudaCheckError();
          cout_objects(h_res_2, second_grid, second_grid, host_box, dx_1,dy_1, host_angle, max_function_value);
        }
    }
  }
}

cudaDeviceReset();
}
    cudaFree(res);
    cudaFree(corner);
    cudaFree(dev_n_of_ints);
    cudaFree(dev_box);
    cudaDeviceReset();

  end = std::chrono:: high_resolution_clock::now();
	elapsed_seconds = std::chrono::duration_cast<std::chrono::microseconds>(end-start).count();
	std::time_t end_time = std::chrono::system_clock::to_time_t(end);
	cout<< "#. Время выполнения: " << elapsed_seconds << "  microseconds ~ "<<elapsed_seconds/1000000<<"sec\n";
  cout<< "#. Acc = "<<blocks << "x" <<threads<<"\n";

return 0;
}
