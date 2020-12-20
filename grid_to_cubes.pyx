from time import perf_counter
import cython
from cpython cimport array
from libc.stdlib cimport malloc, free


@cython.cfunc
def volume(e):
    return e[0] * e[1] * e[2]

@cython.cfunc
@cython.locals(x=cython.int, y=cython.int, z=cython.int, w=cython.int, h=cython.int, d=cython.int, size_x=cython.int, size_y=cython.int, size_z=cython.int)
def create_shapes(size_x, size_y, size_z):
    sizes = [(size_x, size_y, size_z) for i in range(size_x*size_y*size_z)]

    i = 0
    for x in range(size_x):
        for y in range(size_y):
            for z in range(size_z):
                sizes[i] = (x+1,y+1,z+1)
                i += 1
    sizes.sort(key=volume, reverse=True)
    return sizes



@cython.ccall
@cython.locals(grid_size_x=cython.int, grid_size_y=cython.int, grid_size_z=cython.int, x=cython.int, y=cython.int, z=cython.int, w=cython.int, h=cython.int, d=cython.int, _x=cython.int, _y=cython.int, _z=cython.int, i=cython.int, grid_volume=cython.int)
def grid_to_cubes(grid, grid_size_x, grid_size_y, grid_size_z):
    '''
    Converts a 3d grid into cubes by finding the biggest shapes first.

    Parameters: grid(3D array), grid size x(int), grid_size_y(int), grid_size_z(int)

    Returns: a list of (position, size)
    
    For example:
        Given this: [[[1, 1, 1], [0, 0, 0], [0, 0, 0]], [[1, 1, 1], [0, 1, 0], [0, 1, 0]], [[1, 1, 1], [0, 0, 0], [0, 0, 0]]]
        Will return:[((0, 0, 0), (3, 1, 3)), ((1, 1, 1), (1, 2, 1))]
    '''

    shapes = create_shapes(grid_size_x, grid_size_y, grid_size_z)
    grid_volume = grid_size_x * grid_size_y * grid_size_z

    cdef int *filled = <int *> malloc(grid_volume * sizeof(int))
    if not filled:
        raise MemoryError()

    for i in range(grid_volume):
        filled[i] = 0

    # find number of blocks so we can exit early when alle have been found
    cdef num_solid_blocks = 0
    for x in range(grid_size_x):
        for y in range(grid_size_y):
            for z in range(grid_size_z):
                if grid[x][y][z]:
                    num_solid_blocks += 1


    cubes = []

    for shape in shapes:
        w, h, d = shape
        # print('checking shape:', w,h,d)
        # check at each position
        for x in range(grid_size_x - w + 1):
            for y in range(grid_size_y - h + 1):
                for z in range(grid_size_z - d + 1):
                    if filled[(z * grid_size_x * grid_size_y) + (y * grid_size_x) + x]:
                        continue

                    if shape_fits_in_grid(grid, x,y,z, filled, grid_size_x, grid_size_y, grid_size_z, w, h, d):
                        # print('create cube:', shape)
                        # Entity(model='cube', origin=(-.5,-.5,-.5), position=Vec3(x,y,z), scale=shape, texture='brick')
                        cubes.append(((x,y,z), shape))

                        for _x in range(w):
                            for _y in range(h):
                                for _z in range(d):
                                    # filled[x+_x][y+_y][] = 1
                                    filled[((z+_z) * grid_size_x * grid_size_y) + ((y+_y) * grid_size_x) + (x+_x)] = 1

                                    num_solid_blocks -= 1

                        if num_solid_blocks == 0:
                            free(filled)
                            # print('EXIT EARLY')
                            return cubes

    free(filled)
    return cubes


@cython.cfunc
@cython.locals(x=cython.int, y=cython.int, z=cython.int, w=cython.int, h=cython.int, d=cython.int, grid_size_x=cython.int, grid_size_y=cython.int, grid_size_z=cython.int, start_x=cython.int, start_y=cython.int, start_z=cython.int, shape_w=cython.int, shape_h=cython.int , shape_d=cython.int)
def shape_fits_in_grid(grid, start_x, start_y, start_z, int* filled, grid_size_x, grid_size_y, grid_size_z, shape_w, shape_h, shape_d):

    for x in range(shape_w):
        for y in range(shape_h):
            for z in range(shape_d):
                if filled[start_x+x + ((start_y+y)*grid_size_x) + ((start_z+z)*grid_size_x*grid_size_y)]:
                    return False
                if not grid[start_x+x][start_y+y][start_z+z]:
                    return False
    return True
