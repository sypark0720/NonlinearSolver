#include <cstdlib>
#include <iostream>
#include <fstream>
#include <json/json.h>

int main()
{
	// Read and parse JSON from the file.
	// 'root' will contain the root value after parsing.
	Json::Value root;
	Json::Reader reader;
	std::ifstream sample("Sample.json");
	bool result = reader.parse(sample, root, false);
	if (!result)
	{
		std::cerr << "Failed to parse .json file" << std::endl;
		return EXIT_FAILURE;
	}

	// Get the value of the member of root named 'encoding',
	// and return 'UTF-8' if there is no such member.
	std::string encoding = root.get("encoding", "UTF-8").asString();
	std::cout << encoding << std::endl;

	// Get the value of the member of root named 'plug-ins'; return a 'null' value if
	// there is no such member.
	const Json::Value plugins = root["plug-ins"];

	// Iterate over the sequence elements.
	for (unsigned int index = 0; index < plugins.size(); ++index)
		std::cout << plugins[index].asString() << std::endl;

	// Try other datatypes. Some are auto-convertible to others.
	std::cout << root["indent"].get("length", 3).asInt() << std::endl;
	std::cout << root["indent"].get("use_space", true).asBool() << std::endl;

	// Since Json::Value has an implicit constructor for all value types, it is not
	// necessary to explicitly construct the Json::Value object.
	root["encoding"] = "EUC-KR";
	root["indent"]["length"] = 4;
	root["indent"]["use_space"] = false;

	// If you like the defaults, you can insert directly into a stream.
	std::cout << root;

	// Of course, you can write to `std::ostringstream` if you prefer.
	// If desired, remember to add a linefeed and flush.
	std::cout << std::endl;

	return EXIT_SUCCESS;
}