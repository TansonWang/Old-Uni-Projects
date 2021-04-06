class Dog:

    def __init__(self, name, age, species, gender):
        self.name = name
        self.age = age
        self.species = species
        self.gender = gender
    
    def age(self):
        return "{} is {} years old. It is a {} and is {}.".format(self.name, self.age, self.species, self.gender)

    def action(self, action):
        



Pepi = Dog("Pepi", 6, "Chihuahua", "Male")
Balla = Dog("Balla", 7, "Pug", "Male")
Sandy = Dog("Sandy", 8, "Poodle", "Female")

    
