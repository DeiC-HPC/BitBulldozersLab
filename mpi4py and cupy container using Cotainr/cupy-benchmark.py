import numpy as np
import cupy as cp
from cupyx.profiler import benchmark as timeit


class Runner:
    headers={'host_to_device': "# CuPy Host to Device Test",
             'device_to_device': '# CuPu Device to Device Test'}
    
    def __init__(self, method_name):
        self.method_name = method_name
        print(self.headers[method_name])

    def run(self, args, **kwargs):
        return getattr(self, self.method_name)(args, **kwargs)

    def prepare_data(self, size):        
        if self.method_name == 'device_to_device':
            with cp.cuda.Device(0):
                data_gpu_0 = cp.arange(0, size, dtype=np.float16)
            return data_gpu_0
        else:
            data_cpu = np.arange(0, size, dtype=np.float16)
            return data_cpu
            
    @staticmethod
    def host_to_device(data_cpu):
        data_gpu = cp.asarray(data_cpu)  # move the data to the current device
        # return_data_cpu = cp.asnumpy(data_gpu)  # explicitly move the data back to the host
        return

    @staticmethod
    def device_to_device(data_gpu_0):
        with cp.cuda.Device(1):
            data_gpu_1 = cp.asarray(data_gpu_0)
        return


class Process:    
    @staticmethod
    def bandwidth(nbytes, res):
        header = ("# Size (B)  Bandwidth (MB/s)\n" +
                  "#              CPU       GPU")
        
        t_avg_cpu = np.average(res.cpu_times)
        bw_cpu = '{:.2f}'.format(round(nbytes / (t_avg_cpu * 1000000), 2) )

        gpu_str = ''
        for i, gpu_time_i in enumerate(res.gpu_times):
            t_avg_gpu_i = np.average(gpu_time_i)
            bw_gpu_i = '{:.2f}'.format(round(nbytes / (t_avg_gpu_i * 1000000), 2) )
            gpu_str += f" {bw_gpu_i.rjust(9, ' ')}"
            if i > 0:
                if i == 1:
                    header += '0'
                header += f'      GPU{i}'
            
        result = f"{str(nbytes).ljust(8, ' ')} {bw_cpu.rjust(9, ' ')}" + gpu_str
        return (header, result)

    @staticmethod
    def latency(nbytes, res):
        header = ("# Size (B)      Latency (µs)\n" +
                  "#              CPU       GPU")

        t_avg_cpu = np.average(res.cpu_times)
        t_cpu_str = '{:.2f}'.format(round(t_avg_cpu * 1000000, 2))

        gpu_str = ''
        for i, gpu_time_i in enumerate(res.gpu_times):
            t_avg_gpu_i = np.average(gpu_time_i)
            t_gpu_str = '{:.2f}'.format(round(t_avg_gpu_i * 1000000, 2))
            gpu_str += f"  {t_gpu_str.rjust(8, ' ')}"
            if i > 0:
                if i == 1:
                    header += '0'
                header += f'      GPU{i}'

        result = f"{str(nbytes).ljust(8, ' ')}  {t_cpu_str.rjust(8, ' ')}" + gpu_str
        return (header, result)


def main(benchmark_name: str, measure_name: str, size_max: int, gpus: int):
    devices = tuple(i for i in range(gpus))
    
    benchmark = Runner(benchmark_name)
    measure = getattr(Process, measure_name)
    for i in range(0, size_max):
        size = 2**i
        data = benchmark.prepare_data(size)
        result = timeit(benchmark.run, (data,), n_repeat=1000, devices=devices)
        header, timings = measure(data.nbytes, result)
        if i == 0:
            print(header)
        print(timings)


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='')
    parser.add_argument('--benchmark', default = 'host_to_device',
                        type = str, help = 'The name of the benchmark')    
    parser.add_argument('--measure', default = 'bandwidth',
                        type = str, help = 'The performance measure')
    parser.add_argument('--size_max', default = 22,
                        type = int, help = 'The max size is calculated as 2**size_max')
    parser.add_argument('--gpus', default = 1,
                        type = int, help = 'The number of gpus')

    args = parser.parse_args()
    main(args.benchmark, args.measure, args.size_max, args.gpus)
