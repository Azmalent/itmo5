from sage.calculus.integration import numerical_integral
from sage.symbolic.integration.integral import definite_integral, indefinite_integral

def numerical(f, a, b, step):
    x = a
    lst = []
    while x + step < b:
        dy, _ = numerical_integral(f, x, x + step)
        lst.append((x, dy))
        x += step
    return lst

def symbolic(f, a, b, step):
    x = a
    lst = []
    while x + step < b:
        dy = RR(f(x + step) - f(x))
        lst.append((x, dy)) 
        x += step
    return lst

x = SR.var('x')

functions = [
    SR('1 / (x^2 + 1)^2'),
    SR('x^2 / (1 + x^2)^2'),
    SR('1 / (exp(x) + 1)')
]

ranges = [
    (4, 10),
    (-9, 0),
    (2, 10)
]

for i, f in enumerate(functions):
    print('Function {0}: {1}'.format(i+1, f))
    antiderivative = f.integral(x)
    print('Antiderivative: ' + str(antiderivative) + '\n')

    f_plot = plot(f, (-10, 10), color='green', legend_label=str(f))
    g_plot = plot(antiderivative, (-10, 10), color='orange', legend_label=str(antiderivative))
    show(f_plot + g_plot)

    a, b = ranges[i]
    num_result = numerical(f, a, b, 0.01)
    sym_result = symbolic(f, a, b, 0.01)
    
    num_plot = line(num_result, color='blue', legend_label='Numerical')
    sym_plot = line(sym_result, color='red', legend_label='Symbolic')
    show(num_plot + sym_plot)

    delta = [(s[0], s[1] - n[1]) for n, s in zip(num_result, sym_result)]
    delta_plot = line(delta, color='purple', legend_label='Difference')
    show(delta_plot)