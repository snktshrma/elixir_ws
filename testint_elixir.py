start = [1,1]
a = [[2,2],[1,3],[3,4]]
n = len(a)
last = []
app = []
def permute(a, l, r):
	global app
	if l == r:
		t = tuple(a)
		app.append(t)
	else:
		for i in range(l, r + 1):
			a[l], a[i] = a[i], a[l]
			permute(a, l + 1, r)
			a[l], a[i] = a[i], a[l]

def arrange(start):
	global app, last
	for tt in range(len(app)):
		a = list(app[tt])
		a.insert(0,start)
		fin = []
		for x in range(1):
			for y in range(len(a)):
				fin.append(subt(a[x],a[y]))
				x = y
			last.append(sum(fin))


def subt(a,b):
	ap = []
	ap.append(abs(a[0] - b[0]))
	ap.append(abs(a[1] - b[1]))
	return sum(ap)


permute(a, 0, n-1)
print(app)
arrange(start)
print(last)
print(f"{list(app[last.index(min(last))])}")