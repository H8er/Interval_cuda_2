// __device__ __host__ __forceinline__ int g1(interval_gpu<T> *x){
// interval_gpu<T> lmax(12);
// interval_gpu<T> f(x[0]*x[0] + x[1]*x[1] - lmax*lmax);
// return int(bool(f.upper() < 0) + bool(f.lower() < 0));
// }
// __device__ __host__ __forceinline__ int g2(interval_gpu<T> *x){
// interval_gpu<T> l(8);
// interval_gpu<T> f(l*l - x[0]*x[0] - x[1]*x[1]);
// return int(bool(f.upper() < 0) + bool(f.lower() < 0));
// }
//
// __device__ __host__ __forceinline__ int g3(interval_gpu<T> *x){
// interval_gpu<T> lmax(12);
// interval_gpu<T> l0(5);
// interval_gpu<T> f((x[0]-l0)*(x[0]-l0) + x[1]*x[1] - lmax*lmax);
// return int(bool(f.upper() < 0) + bool(f.lower() < 0));
// }
// __device__ __host__ __forceinline__ int g4(interval_gpu<T> *x){
// interval_gpu<T> l(8);
// interval_gpu<T> l0(5);
// interval_gpu<T> f(l*l  - (x[0]-l0)*(x[0]-l0) - x[1]*x[1]);
// return int(bool(f.upper() < 0) + bool(f.lower() < 0));
// }
//
// __constant__ int(*dev_func_pp[4])(interval_gpu<T>*) = {&g1,&g2,&g3,&g4};

#include <cmath>
__constant__ float triangle[6];

__device__ __forceinline__ int g1(interval_gpu<T> *x){
interval_gpu<T> lmax(6);
interval_gpu<T> xi(triangle[0]);
interval_gpu<T> yi(triangle[1]);
interval_gpu<T> xa1(0);
interval_gpu<T> ya1(0);
interval_gpu<T> rot_x(xi*cos(x[2]));
interval_gpu<T> rot_y(yi*sin(x[2]));
interval_gpu<T> f( square(x[0]+rot_x-rot_y-xa1) +
                   square(x[1]+rot_x+rot_y-ya1)-lmax*lmax );
return int(bool(f.upper() < 0) + bool(f.lower() < 0));
}
__device__ __forceinline__ int g2(interval_gpu<T> *x){
interval_gpu<T> lmin(1);
interval_gpu<T> xi(triangle[0]);
interval_gpu<T> yi(triangle[1]);
interval_gpu<T> xa1(0);
interval_gpu<T> ya1(0);
interval_gpu<T> rot_x(xi*cos(x[2]));
interval_gpu<T> rot_y(yi*sin(x[2]));
interval_gpu<T> f( lmin*lmin - square(x[0]+rot_x-rot_y-xa1) -
                   square(x[1]+rot_x+rot_y-ya1) );
return int(bool(f.upper() < 0) + bool(f.lower() < 0));
}

__device__ __forceinline__ int g3(interval_gpu<T> *x){
interval_gpu<T> lmax(6);
interval_gpu<T> xi(triangle[2]);
interval_gpu<T> yi(triangle[3]);
interval_gpu<T> xa2(6);
interval_gpu<T> ya2(0);
interval_gpu<T> rot_x(xi*cos(x[2]));
interval_gpu<T> rot_y(yi*sin(x[2]));
interval_gpu<T> f( square(x[0]+rot_x-rot_y-xa2) +
                   square(x[1]+rot_x+rot_y-ya2)-lmax*lmax );
return int(bool(f.upper() < 0) + bool(f.lower() < 0));
}
__device__ __forceinline__ int g4(interval_gpu<T> *x){
interval_gpu<T> lmin(1);
interval_gpu<T> xi(triangle[2]);
interval_gpu<T> yi(triangle[3]);
interval_gpu<T> xa2(6);
interval_gpu<T> ya2(0);
interval_gpu<T> rot_x(xi*cos(x[2]));
interval_gpu<T> rot_y(yi*sin(x[2]));
interval_gpu<T> f( lmin*lmin - square(x[0]+rot_x-rot_y-xa2) -
                   square(x[1]+rot_x+rot_y-ya2) );
return int(bool(f.upper() < 0) + bool(f.lower() < 0));
}

__device__ __forceinline__ int g5(interval_gpu<T> *x){
interval_gpu<T> lmax(6);
interval_gpu<T> xi(triangle[4]);
interval_gpu<T> yi(triangle[5]);
interval_gpu<T> xa3(3);
interval_gpu<T> ya3(6*1.7320508076/2);
interval_gpu<T> rot_x(xi*cos(x[2]));
interval_gpu<T> rot_y(yi*sin(x[2]));
interval_gpu<T> f( square(x[0]+rot_x-rot_y-xa3) +
                   square(x[1]+rot_x+rot_y-ya3)-lmax*lmax );
return int(bool(f.upper() < 0) + bool(f.lower() < 0));
}
__device__ __forceinline__ int g6(interval_gpu<T> *x){
interval_gpu<T> lmin(1);
interval_gpu<T> xi(triangle[4]);
interval_gpu<T> yi(triangle[5]);
interval_gpu<T> xa3(3);
interval_gpu<T> ya3(6*1.7320508076/2);
interval_gpu<T> rot_x(xi*cos(x[2]));
interval_gpu<T> rot_y(yi*sin(x[2]));
interval_gpu<T> f( lmin*lmin - square(x[0]+rot_x-rot_y-xa3) -
                   square(x[1]+rot_x+rot_y-ya3) );
return int(bool(f.upper() < 0) + bool(f.lower() < 0));
}

__constant__ int dev_n_of_func[1];
__constant__ int(*dev_func_pp[6])(interval_gpu<T>*) = {
  &g1,&g2,
  &g3,&g4,
  &g5,&g6
};
