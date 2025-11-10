import reframe as rfm
import reframe.utility.sanity as sn


@rfm.simple_test
class watertiny_test(rfm.RunOnlyRegressionTest):
    valid_systems = ['*']
    valid_prog_environs = ['*']
    input_file = variable(str, value='watertiny.fnl')
    venv = variable(str, value='$HOME/fennol/.venv/bin/activate')
    executable = 'fennol_md'

    @run_after('init')
    def provide_input(self):
        self.executable_opts = [self.input_file]
    
    @run_before('run')
    def activate_venv(self):
        self.prerun_cmds = [f'source {self.venv}']

    @sanity_function
    def validate(self):
        return sn.assert_found(r'Computing initial energy and forces', self.stdout)

    @performance_function('ns/day')
    def ns_per_day(self):
        return sn.extractsingle(r'Perf.:\s+(\S+)', self.stdout, 1, float)

    @performance_function('step/s')
    def steps_per_second(self):
        return sn.extractsingle(r'(\S+)\s+step/s', self.stdout, 1, float)
    
