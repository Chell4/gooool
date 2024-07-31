pub mod ca;
pub mod cell_info;
pub mod cell_state;

use std::hash::{DefaultHasher, Hash, Hasher};

pub use ca::CellularAutomaton;

pub use cell_info::CellInfo;

pub use cell_state::CellState;

use ndarray::Array2;

pub struct World<'w> {
    grid: Array2<CellState<'w>>,
}

impl World<'_> {
    pub fn tick(&mut self) {
        let cell_infos = self.get_cell_infos();
        
        for ((ix, iy), info) in cell_infos.indexed_iter() {
            match self.grid[[ix, iy]].clone() {
                CellState::Dead => {
                    if !info.has_neighbors() {
                        continue
                    }
                
                    
                }
            }
            
        }
    }

    fn get_cell_infos<'w>(&'w self) -> Array2<CellInfo<'w>> {
        let mut res = Array2::<CellInfo<'w>>::default(self.grid.raw_dim());
        
        for ((ix, iy), s) in self.grid.indexed_iter() {
            let ca;
            match s.get_ca() {
                None => continue,
                Some(this_ca) => ca = this_ca,
            }
            
            for dx in -1..1 {
                for dy in -1..1 {
                    if dx == 0 && dy == 0 {
                        continue;
                    }
                    
                    let x = (ix as isize + dx)
                        .rem_euclid(res.dim().0 as isize) as usize;
                    let y = (iy as isize + dy)
                        .rem_euclid(res.dim().1 as isize) as usize;
                    
                    res[[x, y]].add_neighbor(ca)
                }
            }
        }

        res
    }
}