import reframe as rfm
import reframe.utility.sanity as sn


@rfm.simple_test
class watertiny_test(rfm.RunOnlyRegressionTest):
    valid_systems = ['*']
    valid_prog_environs = ['*']
    input_file = variable(str, value='watertiny.fnl')
    venv = variable(str, value='$HOME/fennol/.venv/bin/activate')
    device = variable(str, value='cpu') # Alt. cuda:0
    executable = 'fennol_md'

    @run_after('init')
    def provide_input(self):
        self.run_input_file = 'run-' + self.input_file
        self.executable_opts = [self.run_input_file]
    
    @run_before('run')
    def activate_venv(self):
        self.prerun_cmds = [f'source {self.venv}',
                            f'echo "device {self.device}" > {self.run_input_file}',
                            f'echo "$(cat {self.input_file})" >> {self.run_input_file}']

    @sanity_function
    def validate(self):
        return sn.assert_found(r'Computing initial energy and forces', self.stdout)

    @performance_function('ns/day')
    def ns_per_day(self):
        perf_ns = sn.extractall(r'Perf.:\s+(\S+)', self.stdout, 1, float)  # list
        return max(perf_ns)

    @performance_function('step/s')
    def steps_per_second(self):
        perf_steps = sn.extractall(r'(\S+)\s+step/s', self.stdout, 1, float)  # list
        return max(perf_steps)
