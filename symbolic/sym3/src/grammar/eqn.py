import os
from lark import Lark

path = os.path.dirname(os.path.abspath(__file__))

with open(path + "/grammar.lark", "r") as f:
    grammar = f.read()
    global EQN_PARSER
    EQN_PARSER = Lark(grammar)

#----------------------------------------------#

class EqnAssignment:
    lvalue = None
    rvalue = None

    def __init__(self, lvalue, rvalue):
        self.lvalue = lvalue
        self.rvalue = rvalue


class EqnExpression:
    args = []

    def __init__(self, expr):
        self.args = [parseExpression(x) for x in expr.children]


class EqnFunction:
    name = None
    args = []

    def __init__(self, expr):
        if len(expr.children) > 1:
            name, args = expr.children
            self.args = [parseExpression(x) for x in args.children]
        else:
            name = expr.children[0]
        self.name = tokenvalue(name)


class EqnIntegral:
    intexpr = None
    diff = None
    a = None
    b = None

    def __init__(self, expr):
        # If definite, parse the bounds
        if expr.data == 'definite_integral':
            bounds, intexpr, diff = expr.children
            a, b = bounds.children
            if a.data == 'upper_bound':
                a, b = b, a
            self.a, self.b = parseChild(a), parseChild(b)
        else:
            intexpr, diff = expr.children
        self.intexpr = parseExpression(intexpr)
        self.diff = parseChild(diff)

#----------------------------------------------#

def tokenvalue(token):
    return token.children[0].value

def create(class_name, expr):
    return class_name(expr)

rules = {
    'symbol':      tokenvalue,
    'number':      lambda x: float(tokenvalue(x)),
    'brackets':    lambda x: parseChild(x),
    'sum':         lambda x: EqnExpression(x),
    'product':     lambda x: EqnExpression(x),
    'func':        lambda x: EqnFunction(x),
    'integral':    lambda x: EqnIntegral(x),
    'definite_integral': lambda x: EqnIntegral(x),

    'plus':  '+',
    'minus': '-',
    'times': '*',
    'mod':   '%',
    'over':  '/',
    'pow':   '^'
}

def parseChild(expr):
    return parseExpression(expr.children[0])

def parseExpression(expr):
    rule = rules[expr.data]
    if isinstance(rule, str):
        return rule
    return rule(expr)

def parseAssignment(expr):
    lvalue, rvalue = expr.children
    lvalue, rvalue = parseExpression(lvalue), parseExpression(rvalue)
    return EqnAssignment(lvalue, rvalue)

def parse(line):
    if line:
        expr = EQN_PARSER.parse(line)
        if expr.data == 'assignment':
            return parseAssignment(expr)
        return parseExpression(expr)