from fsm import InitState, State, TerminalState, FSM

fsm = FSM({
    'A': InitState({'a': 'A', 'b': 'B', 'c': 'D'}),
    'B': State({'a': 'A', 'b': 'B', 'c': 'C'}),
    'C': State({'a': 'A', 'b': 'F', 'c': 'D'}),
    'D': State({'b': 'E'}),
    'E': TerminalState({}),
    'F': TerminalState({'a': 'A', 'b': 'B', 'c': 'C'})
})