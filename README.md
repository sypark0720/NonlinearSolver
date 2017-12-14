# Nonlinear Solver

__Programming Assignment 2__

__AAA633(00) Visual Computing__

## Roles

We will implement the four kinds of nonlinear solvers by dividing roles as follows

1. Cholesky Factorization : Chris
2. Gauss-Newton Method : 선영
3. Levenberg-Marquardt Method : 은비
4. Preconditioned Conjugate Gradient (PCG) : 승욱, 정현

You can freely modify the program codes if you want

## Classes

### Parser

Parser.h & Parser.cpp

- Parse data files written in JSON (DataOriginal.json & DataTransformed.json)

### Solver

Solver.h & Solver.cpp

- Load data on the device (GPU) and run a nonlinear solver
- __You need to create a nonlinear solver by implementing some CUDA kernels__

## Others

### Global

Global.h

- Define some data structures used throughout the project
- Each vertex is related to four nodes with indices and weights

### Config

Config.h

- Define some global constants used throughout the project

### Main

Main.cpp

- The overall process of the program is implemented on the main function
