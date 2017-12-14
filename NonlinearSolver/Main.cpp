#include "Parser.h"
#include "Solver.cuh"
#include <cstdlib>
#include <iostream>
#include <stdexcept>

int main()
{
	try
	{
		// parse original & transformed data
		HostData h_origData = Parser::getInstance().getOrigData();
		HostData h_tranData = Parser::getInstance().getTranData();

		// copy ground truth data
		const HostData h_trueData = h_tranData;

		// run nonlinear solver
		Solver::getInstance().run(h_origData, h_tranData);

		// compute error (sum of poses' norm)
		float sumOfNorm = 0.0f;
		for (unsigned int index = 0; index < h_trueData.nodes.size(); index++)
			sumOfNorm += (h_trueData.nodes.at(index).pose - h_tranData.nodes.at(index).pose).norm();

		// print error
		std::cout << "Sum of Poses' Norm: " << sumOfNorm << std::endl;
	}
	catch (const std::exception& e)
	{
		// print runtime error
		std::cerr << "[Runtime Error] " << e.what() << std::endl;
		return EXIT_FAILURE;
	}
	return EXIT_SUCCESS;
}
