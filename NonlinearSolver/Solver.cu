#include "Solver.cuh"

__constant__ int d_numOfNodes;
__constant__ int d_numOfVertices;

__global__ void kernelInitNodes(DeviceData d_origData, DeviceData d_tranData);
__global__ void kernelInitVertices(DeviceData d_origData, DeviceData d_tranData);
__global__ void kernelSolveNodes(DeviceData d_origData, DeviceData d_tranData);
__global__ void kernelSolveVertices(DeviceData d_origData, DeviceData d_tranData);

Solver & Solver::getInstance()
{
	static Solver solver;
	return solver;
}

void Solver::run(HostData & h_origData, HostData & h_tranData)
{
	// allocate device memory
	mallocData(h_origData, h_tranData);

	// copy data from host to device
	copyDataFromHostToDevice(h_origData, h_tranData);

	// execute nonlinear solver with CUDA kernels
	executeKernel(h_origData, h_tranData);

	// copy data from device to host
	copyDataFromDeviceToHost(h_origData, h_tranData);
}

void Solver::mallocData(const HostData & h_origData, const HostData & h_tranData)
{
	cudaError_t result;

	// allocate device memory of original data
	result = cudaMalloc(&d_origData.nodes, h_origData.nodes.size() * sizeof(Node));
	if (result != cudaSuccess) throw std::runtime_error("Failed to allocate device memory");
	result = cudaMalloc(&d_origData.vertices, h_origData.vertices.size() * sizeof(Vertex));
	if (result != cudaSuccess) throw std::runtime_error("Failed to allocate device memory");

	// allocate device memory of transformed data
	result = cudaMalloc(&d_tranData.nodes, h_tranData.nodes.size() * sizeof(Node));
	if (result != cudaSuccess) throw std::runtime_error("Failed to allocate device memory");
	result = cudaMalloc(&d_tranData.vertices, h_tranData.vertices.size() * sizeof(Vertex));
	if (result != cudaSuccess) throw std::runtime_error("Failed to allocate device memory");
}

void Solver::copyDataFromHostToDevice(const HostData & h_origData, const HostData & h_tranData) const
{
	cudaError_t result;

	// copy original data from host to device
	result = cudaMemcpy(d_origData.nodes, h_origData.nodes.data(),
		h_origData.nodes.size() * sizeof(Node), cudaMemcpyHostToDevice);
	if (result != cudaSuccess) throw std::runtime_error("Failed to copy data from host to device");
	result = cudaMemcpy(d_origData.vertices, h_origData.vertices.data(),
		h_origData.vertices.size() * sizeof(Vertex), cudaMemcpyHostToDevice);
	if (result != cudaSuccess) throw std::runtime_error("Failed to copy data from host to device");

	// copy transformed data from host to device
	result = cudaMemcpy(d_tranData.nodes, h_tranData.nodes.data(),
		h_tranData.nodes.size() * sizeof(Node), cudaMemcpyHostToDevice);
	if (result != cudaSuccess) throw std::runtime_error("Failed to copy data from host to device");
	result = cudaMemcpy(d_tranData.vertices, h_tranData.vertices.data(),
		h_tranData.vertices.size() * sizeof(Vertex), cudaMemcpyHostToDevice);
	if (result != cudaSuccess) throw std::runtime_error("Failed to copy data from host to device");

	// copy the number of nodes
	const int h_numOfNodes = h_origData.nodes.size();
	cudaMemcpyToSymbol(d_numOfNodes, &h_numOfNodes, sizeof(int));

	// copy the number of vertices
	const int h_numOfVertices = h_origData.vertices.size();
	cudaMemcpyToSymbol(d_numOfVertices, &h_numOfVertices, sizeof(int));
}

void Solver::copyDataFromDeviceToHost(HostData & h_origData, HostData & h_tranData) const
{
	cudaError_t result;

	// copy original data from device to host
	result = cudaMemcpy(h_origData.nodes.data(), d_origData.nodes,
		h_origData.nodes.size() * sizeof(Node), cudaMemcpyDeviceToHost);
	if (result != cudaSuccess) throw std::runtime_error("Failed to copy data from device to host");
	result = cudaMemcpy(h_origData.vertices.data(), d_origData.vertices,
		h_origData.vertices.size() * sizeof(Vertex), cudaMemcpyDeviceToHost);
	if (result != cudaSuccess) throw std::runtime_error("Failed to copy data from device to host");

	// copy transformed data from device to host
	result = cudaMemcpy(h_tranData.nodes.data(), d_tranData.nodes,
		h_tranData.nodes.size() * sizeof(Node), cudaMemcpyDeviceToHost);
	if (result != cudaSuccess) throw std::runtime_error("Failed to copy data from device to host");
	result = cudaMemcpy(h_tranData.vertices.data(), d_tranData.vertices,
		h_tranData.vertices.size() * sizeof(Vertex), cudaMemcpyDeviceToHost);
	if (result != cudaSuccess) throw std::runtime_error("Failed to copy data from device to host");
}

void Solver::executeKernel(const HostData & h_origData, const HostData & h_tranData) const
{
	// get the number of nodes and vertices
	const int numOfNodes = h_origData.nodes.size();
	const int numOfVertices = h_origData.vertices.size();

	// compute dimension of nodes and vertices for CUDA kernels
	const int dimOfNodes = (numOfNodes + Config::threadPerBlock - 1) / Config::threadPerBlock;
	const int dimOfVertices = (numOfVertices + Config::threadPerBlock - 1) / Config::threadPerBlock;

	// execute initializing kernels
	kernelInitNodes << <dimOfNodes, Config::threadPerBlock >> > (d_origData, d_tranData);
	kernelInitVertices << <dimOfVertices, Config::threadPerBlock >> > (d_origData, d_tranData);

	// execute nonlinear solving kernels with iterations
	for (int i = 0; i < Config::numOfIterations; i++)
	{
		kernelSolveNodes << <dimOfNodes, Config::threadPerBlock >> > (d_origData, d_tranData);
		kernelSolveVertices << <dimOfVertices, Config::threadPerBlock >> > (d_origData, d_tranData);
	}
}

__global__ void kernelInitNodes(DeviceData d_origData, DeviceData d_tranData)
{
	const int index = threadIdx.x + blockIdx.x * blockDim.x;

	// set initial transformed poses to original poses
	d_tranData.nodes[index].pose = d_origData.nodes[index].pose;
}

__global__ void kernelInitVertices(DeviceData d_origData, DeviceData d_tranData)
{
	const int index = threadIdx.x + blockIdx.x * blockDim.x;

	// do nothing
}

__global__ void kernelSolveNodes(DeviceData d_origData, DeviceData d_tranData)
{
	const int index = threadIdx.x + blockIdx.x * blockDim.x;

	// TODO: do nonlinear solve for each node
}

__global__ void kernelSolveVertices(DeviceData d_origData, DeviceData d_tranData)
{
	const int index = threadIdx.x + blockIdx.x * blockDim.x;

	// TODO: do nonlinear solve for each vertex
}
