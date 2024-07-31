use super::{CellState, CellularAutomaton};

use std::collections::HashMap;

#[derive(Clone, Default)]
pub struct CellInfo<'ci> {
    neighbors: HashMap<&'ci CellularAutomaton, u8>
}

impl<'ci> CellInfo<'ci> {
    pub fn add_neighbor(&mut self, ca: &'ci CellularAutomaton) {
        let cnt = self.neighbors.entry(ca).or_insert(0);
        *cnt += 1;
    }

    pub fn has_neighbors(&self) -> bool {
        self.neighbors.len() == 0
    }
    
    pub fn iter_neighbors(&self) -> impl Iterator<Item = (&CellularAutomaton, u8)> {
        self.neighbors.iter().map(|(&ca, &n)| (ca, n))
    }
}