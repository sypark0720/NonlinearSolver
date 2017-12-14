#pragma once
#include "Global.h"
#include "Config.h"
#include <Eigen/Core>
#include <json/json.h>
#include <cassert>
#include <stdexcept>
#include <string>
#include <fstream>

class Parser
{
public:
	Parser();
	static Parser & getInstance();
	const HostData getOrigData();
	const HostData getTranData();
private:
	HostData h_origData;
	HostData h_tranData;
	void parseData(const std::string & dataFile, HostData & h_data);
};
