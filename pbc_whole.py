#!/usr/bin/env python

import numpy as np
import sys
import math
import MDAnalysis as mda 
from MDAnalysis.analysis.distances import dist

u = mda.Universe('system.gro', 'system.xtc')

oxygens = u.select_atoms('name O')
hydrogens = u.select_atoms('name H')

def smallest_distance_to(A, group_B, box):
    return dist(mda.core.groups.AtomGroup([A for i in range(len(group_B))]), group_B, box=box)[-1]

def transform1(all):
    def wrapped(ts):
        cartesian_positions = ts.positions 
        unitcell = ts.triclinic_dimensions 
        inv_unitcell = np.linalg.inv(unitcell)
        direct_positions = np.matmul(cartesian_positions, inv_unitcell) 
        inside_direct_positions = direct_positions % 1.0  
        for oxygen in oxygens:
            hydrogen_per_oxygen_dist = smallest_distance_to(oxygen, hydrogens, ts.dimensions)
            each_oxygen_two_hydrogens = np.argpartition(hydrogen_per_oxygen_dist, 1)[:2] 
            oxygen_stored_direct_coord = inside_direct_positions[oxygen.index] 
            for one_hydrogen in each_oxygen_two_hydrogens: 
                hydrogen_stored_direct_coord = inside_direct_positions[hydrogens[one_hydrogen].index]
                hydrogen_ref_to_oxygen_direct_coord = hydrogen_stored_direct_coord - np.round(hydrogen_stored_direct_coord- oxygen_stored_direct_coord)
                inside_direct_positions[hydrogens[one_hydrogen].index] = hydrogen_ref_to_oxygen_direct_coord
        all.positions = np.matmul(inside_direct_positions,unitcell)
        return ts
    return wrapped
    
all = u.atoms
workflow = (transform1(all),)
u.trajectory.add_transformations(*workflow)

with mda.Writer("inside.xtc", multiframe=True, bonds=None, n_atoms=u.atoms.n_atoms) as Writer:
    for ts in u.trajectory:
        Writer.write(u.atoms)

    