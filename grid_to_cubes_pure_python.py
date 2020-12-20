# from ursina import *
from time import perf_counter


def create_shapes(size):
    def volume(e):
        return e[0] * e[1] * e[2]

    sizes = [(size, size, size) for i in range(4096)]
    for x in range(size):
        for y in range(size):
            for z in range(size):
                sizes.append((x+1,y+1,z+1))

    sizes.sort(key=volume, reverse=True)
    return sizes


def grid_to_cubes(grid):
    size = len(grid)
    shapes = create_shapes(size)
    filled = [[[0 for z in range(size)]for y in range(size)] for x in range(size)]
    cubes = []

    for shape in shapes:
        # check at each position
        for x in range(size - int(shape[0])):
            for y in range(size - int(shape[1])):
                for z in range(size - int(shape[2])):
                    if filled[x][y][z]:
                        continue
                    # print('check position', Vec3(x,y,z))
                    if check_grid(grid, (x,y,z), shape, filled):
                        # print('create cube:', shape)
                        # Entity(model='cube', origin=(-.5,-.5,-.5), position=Vec3(x,y,z), scale=shape, texture='brick')
                        cubes.append(((x,y,z), shape))

                        for _x in range(int(shape[0])):
                            for _y in range(int(shape[1])):
                                for _z in range(int(shape[2])):
                                    # filled.append(Vec3(int(x+_x),int(y+_y),int(z+_z)))
                                    filled[int(x+_x)][int(y+_y)][int(z+_z)] = 1


    return cubes


def main():
    size = 16
    grid = [[[0 for z in range(size)]for y in range(size)] for x in range(size)]
    for x in range(size):
        for z in range(size):
            grid[x][0][z] = 1

    for x in range(2,5):
        for z in range(2,5):
            for y in range(1,4):
                grid[x][y][z] = 1

    t = perf_counter()
    cubes = grid_to_cubes(grid)
    print('--------', perf_counter() - t)


def check_grid(grid, start_position, shape, filled):
    for x in range(int(shape[0])):
        for y in range(int(shape[1])):
            for z in range(int(shape[2])):
                if filled[int(start_position[0]+x)][int(start_position[1]+y)][int(start_position[2]+z)]:
                    return False
                if not grid[int(start_position[0]+x)][int(start_position[1]+y)][int(start_position[2]+z)]:
                    return False
    return True


main()
