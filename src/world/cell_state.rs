use super::CellularAutomaton;

#[derive(Clone)]
pub enum CellState<'c> {
    Dead,
    Alive{
        ca: &'c CellularAutomaton,
    },
}

impl <'c> CellState<'c> {
    pub fn get_ca(&self) -> Option<&'c CellularAutomaton> {
        match *self {
            CellState::Dead => None,
            CellState::Alive{ca} => Some(ca),
        }
    }
}