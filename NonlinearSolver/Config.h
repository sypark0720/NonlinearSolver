#pragma once
#include <string>

namespace Config
{
	// name and path of original data file
	const std::string origDataFile = "DataOriginal.json";

	// name and path of transformed data file
	const std::string tranDataFile = "DataTransformed.json";

	// thread per block for CUDA kernels
	const int threadPerBlock = 1024;

	// the number of iterations for nonlinear solver
	const int numOfIterations = 10;
}
