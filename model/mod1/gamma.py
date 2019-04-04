from math import exp
from scipy.special import gammainc

k=5
theta=250

def f(x):
	return gammainc(k, x/theta)

ps = []
sum = 0
for i in range(0, 1800, 200):
	p = f(i+200) - f(i)
	sum = sum + p
	ps.append(p)
	
ps.append(1 - sum)

for p in ps:
	print(str(p).replace('.', ','))
	
