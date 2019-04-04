from fl2 import fsm

def test1():
    assert fsm.parse("cb")
    assert fsm.parse("bccb")
    assert fsm.parse("bcbccb")


def test2():
    assert fsm.parse("acb")
    assert fsm.parse("bcb")
    assert fsm.parse("abcb")
    assert fsm.parse("aabcb")
    assert fsm.parse("bbbcb")


def test3():
    assert fsm.parse("aaaaaaababababbcbcabababcbbbbbcb")


def test4():
    assert not fsm.parse("c")
    assert not fsm.parse("bcccb")
    assert not fsm.parse("whatever")