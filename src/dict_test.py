
import jwt

users = []

dicta = {'data1' : 'POTAT', "token": 2}

datab = {'data1': 3, 'token': 4}

users.append(dicta)
users.append(datab)


def func1():
    datac = {'data1': 100, 'token': 100}
    users.append(datac)

func1()
print(users)

def func2():
    global users
    datad = {'data1': 10033212312, 'token': 11233123100}
    users.append(datad)
    users[2]['data1'] = None

func2()

print(users)






#print(users)

#if 'POTAT' in users[0]:
#    print('LMAOOOOOOOO')


#if 'POTAT' in dicta['data1']:
#    print('LMAOOOOOOOO')
#print(users[1]['data1'])
'''

called_by = 0
#Determinig which user requested
print(users)
for user in users:
    print(user)
    if 4 == user['token']:
        print("LMAOO")
        break
    called_by += 1

print(called_by)

    if 4 == user['token']:
        print(user)
        print(user['token'])
        print(called_by)
        break
    called_by += called_by
'''



'''
secret = 'hello'
payload = {
    'email' : 'email',
    'timestamp' : 'poatat',
}
print(payload)

print("-----------------------------")

encoded = jwt.encode(payload, secret, algorithm='HS256')
print(encoded)
print("-----------------------------")
print(encoded.decode('utf-8'))
print("-----------------------------")
print(jwt.decode(encoded, secret))
'''