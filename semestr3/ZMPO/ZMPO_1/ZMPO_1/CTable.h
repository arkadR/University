#pragma once

#include <string>
#include <iostream>
#include <sstream>

#define DEFAULT_LENGTH 10
#define DEFAULT_NAME "new_CTable"

class CTable {
public:
	CTable();
	CTable(std::string tableName, int tableLen = DEFAULT_LENGTH);
	CTable(const CTable& other);
	~CTable();

	void SetSize(int len, int* excCode);
	void SetName(std::string name);
	void SetElement(int n, int val, int* excCode);
	int GetElement(int n, int* excCode);
	int GetSize();
	CTable* getClone();
	std::string toString();
	std::string GetName();
private:
	std::string name;
	int* table;
	int length;
};