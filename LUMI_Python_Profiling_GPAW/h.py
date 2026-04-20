from ase import Atoms
from ase.units import Ha

from gpaw.dft import DFT

# Adapted from unit-test in
# https://gitlab.com/gpaw/gpaw/-/blob/9de644511ecc4bc2b1e04b2a3ea72074a6643db0/gpaw/test/gpu/test_pw.py
def test_gpu_k(gpu=True):
    atoms = Atoms('H', pbc=True, cell=[1, 1.1, 1.1])

    dft = DFT(
        atoms,
        mode={'name': 'pw'},
        spinpol=True,
        xc='PBE',
        convergence={'density': 1e-8},
        kpts=(4, 1, 1),
        parallel={'gpu': gpu,
                  # 'domain': 4,
                  # 'band': 4,
                  'kpt': 2},
        setups='paw')
    dft.converge()
    dft.energy()
    dft.forces()
    dft.stress()

    ref_energy = -17.304186
    assert (dft.results['energy'] * Ha - ref_energy) < 1e-6


if __name__ == "__main__":
    test_gpu_k()
