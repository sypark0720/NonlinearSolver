#pragma once
#include "Global.h"
#include "Config.h"
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <cassert>
#include <stdexcept>

class Solver
{
public:
	static Solver & getInstance();
	void run(HostData & h_origData, HostData & h_tranData);
private:
	DeviceData d_origData;
	DeviceData d_tranData;
	void mallocData(const HostData & h_origData, const HostData & h_tranData);
	void copyDataFromHostToDevice(const HostData & h_origData, const HostData & h_tranData) const;
	void copyDataFromDeviceToHost(HostData & h_origData, HostData & h_tranData) const;
	void executeKernel(const HostData & h_origData, const HostData & h_tranData) const;
};
