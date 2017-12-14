#pragma once
#include <Eigen/Core>
#include <vector>

typedef int Index;
typedef float Weight;
typedef Eigen::Vector3f Position;
typedef Eigen::Matrix4f Pose;

struct Node
{
	Pose pose;
};

struct Rig
{
	Index index;
	Weight weight;
};

struct Vertex
{
	Position position;
	Rig rigs[4]; // rigging data of four related nodes
};

struct HostData
{
	std::vector<Node> nodes;
	std::vector<Vertex> vertices;
};

struct DeviceData
{
	Node* nodes;
	Vertex* vertices;
};
