# grid_to_cubes

Converts a 3d grid into cubes by finding the biggest shapes first.

Parameters: grid(3D array), grid size x(int), grid_size_y(int), grid_size_z(int)

Returns: a list of (position, size)

For example:

    grid = [[[1, 1, 1], [0, 0, 0], [0, 0, 0]], [[1, 1, 1], [0, 1, 0], [0, 1, 0]], [[1, 1, 1], [0, 0, 0], [0, 0, 0]]]
    cubes = grid_to_cubes(grid, 3, 3, 3)
    
    print(cubes)    # [((0, 0, 0), (3, 1, 3)), ((1, 1, 1), (1, 2, 1))]
    
    for e in cubes:
        pos, scale = e
        print('position:', pos, 'scale:', scale)
    
