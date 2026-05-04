import argparse

from ase.io import read
from ase import Atoms
from ase.units import Ha

from gpaw.new.ase_interface import GPAW
from gpaw import KohnShamConvergenceError

def supercell(gpu):
    ## Assumes data is together with script ##
    base = read("MnO2.xyz")
    
    atoms = base.copy()
    atoms.set_initial_magnetic_moments([3, 0, 0])
    atoms2 = atoms.copy()
    atoms2.translate([0, 0, 4])
    atoms.extend(atoms2)
    atoms.center(vacuum=5, axis=2)

    # Unit test
    if False: 
        return atoms.copy()
    
    if gpu:
        return atoms.copy() * (4, 4, 1)  # 96 Atoms
    else:
        return atoms.copy() * (2, 2, 1)  # 24 Atoms

def test_gpu_k(gpu, kpt, band):
    atoms = supercell(gpu)
    
    calc = GPAW(mode={'name': 'pw', 'ecut': 600},
                eigensolver='ppcg',
                parallel={'gpu': gpu,
                          'kpt': kpt,
                          'band': band,
                          'domain': 1,
                          'sl_auto': False},
                kpts=(2, 2, 1),
                spinpol=True,
                symmetry='off',
                random=True,
                maxiter=4)
    atoms.calc = calc
    try:
        atoms.get_potential_energy()
    except KohnShamConvergenceError:
        pass


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--kpt', type=int)
    parser.add_argument('--band', type=int)
    parser.add_argument('--gpu', action=argparse.BooleanOptionalAction)
    args = parser.parse_args()

    # Run workload
    test_gpu_k(args.gpu, args.kpt, args.band)
