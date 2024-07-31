
use itertools::Itertools;

#[derive(PartialEq, Eq, Hash)]
pub struct CellularAutomaton {
    stay_alive_rules: Box<[u8]>,
    go_live_rules: Box<[u8]>,
}

impl CellularAutomaton {
    pub fn new(new_stay_alive_rules: &[u8], new_go_live_rules: &[u8]) -> CellularAutomaton {
        CellularAutomaton{
            stay_alive_rules: new_stay_alive_rules.into_iter()
                .sorted()
                .filter(|&&n| n <= 8)
                .unique()
                .map(|&n| n)
                .collect(),

            go_live_rules: new_go_live_rules.into_iter()
                .sorted()
                .filter(|&&n| 1 <= n && n <= 8) // this part is different
                .unique()
                .map(|&n| n)
                .collect(),
        }
    }

    pub fn should_go_live(&self, neighbors_num: u8) -> bool {
        if self.go_live_rules.contains(&neighbors_num) {
            return true
        }
        
        false
    }
    
    pub fn should_stay_alive(&self, neighbors_num: u8) -> bool {
        if self.stay_alive_rules.contains(&neighbors_num) {
            return true
        }
        
        false
    }
}