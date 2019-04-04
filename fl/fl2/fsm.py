from functools import reduce
from operator import or_


class State:
    transitions = {}

    def __init__(self, transitions):
        self.transitions = transitions


class InitState(State):
    pass


class TerminalState(State):
    pass


class FSM:
    states = {}
    initState = InitState({})


    def __init__(self, states):
        self.states = states
        
        state_values = dict.values(states)
        initStates = [s for s in state_values if isinstance(s, InitState)]
        terminalStates = [s for s in state_values if isinstance(s, TerminalState)]

        assert len(initStates) == 1
        assert any(terminalStates)
        
        self.initState = initStates[0]


    def doTransition(self, state, char):
        if state is not None:
            next_state = state.transitions.get(char)
            return self.states.get(next_state)
        else:
            return None


    def parse(self, sentence):
        state = reduce(self.doTransition, sentence, self.initState)
        return isinstance(state, TerminalState) if state is not None else False