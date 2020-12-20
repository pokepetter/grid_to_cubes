from time import perf_counter
# from grid_to_cubes_pure_python import grid_to_cubes # python version: 3.8 seconds
# import pyximport; pyximport.install(language_level=3) # easy way to import .pyx files, auto-compiles
from grid_to_cubes import grid_to_cubes # no changes: 1.8 , with types: 0.09 seconds


size = 16
grid = [[[0 for z in range(size)]for y in range(size)] for x in range(size)]


for x in range(size):
    for y in range(1):
        for z in range(size):
            grid[x][y][z] = 1

for x in range(2,5):
    for z in range(2,5):
        for y in range(1,4):
            grid[x][y][z] = 1


t = perf_counter()
cubes = grid_to_cubes(grid, 16,16,16)
print('--------', perf_counter() - t)
print(cubes)


from ursina import *
app = Ursina()

entities = []
for e in cubes:
    pos, scale = e
    entities.append(Entity(model='cube', origin=(-.5,-.5,-.5), position=pos, scale=scale, texture='white_cube'))


EditorCamera()
app.run()
