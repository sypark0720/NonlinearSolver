#include "Parser.h"

Parser::Parser()
{
	// parse original & transformed data
	parseData(Config::origDataFile, h_origData);
	parseData(Config::tranDataFile, h_tranData);
}

Parser & Parser::getInstance()
{
	static Parser instance;
	return instance;
}

const HostData Parser::getOrigData()
{
	return h_origData;
}

const HostData Parser::getTranData()
{
	return h_tranData;
}

void Parser::parseData(const std::string & dataFile, HostData & h_data)
{
	Json::Reader jsonReader;
	Json::Value rootValue;

	// read & parse data file
	std::ifstream file(dataFile);
	const bool result = jsonReader.parse(file, rootValue, false);
	if (!result) throw std::runtime_error("Failed to parse host data file: " + dataFile);

	// parse nodes data
	const Json::Value nodesValue = rootValue["nodes"];
	h_data.nodes.resize(nodesValue.size());
	for (unsigned int index = 0; index < nodesValue.size(); index++)
	{
		Node & node = h_data.nodes[index];

		// parse pose data
		const Json::Value poseValue = nodesValue[index]["pose"];
		assert(poseValue.size() == 16);
		for (unsigned int i = 0; i < 4; i++) for (unsigned int j = 0; j < 4; j++)
			node.pose(i, j) = poseValue[4 * i + j].asFloat();
	}

	// parse vertices data
	const Json::Value vertices = rootValue["vertices"];
	h_data.vertices.resize(vertices.size());
	for (unsigned int index = 0; index < vertices.size(); index++)
	{
		Vertex & vertex = h_data.vertices[index];

		// parse position data
		const Json::Value positionValue = vertices[index]["position"];
		assert(positionValue.size() == 3);
		for (unsigned int i = 0; i < 3; i++) vertex.position(i) = positionValue[i].asFloat();

		// parse rigging data
		const Json::Value riggingValue = vertices[index]["rigging"];
		assert(riggingValue.size() == 4);
		for (unsigned int index = 0; index < 4; index++)
		{
			Rig & rig = vertex.rigs[index];

			// parse index data
			const Json::Value indexValue = riggingValue[index]["index"];
			rig.index = indexValue.asInt();

			// parse weight data
			const Json::Value weightValue = riggingValue[index]["weight"];
			rig.weight = weightValue.asFloat();
		}
	}
}
