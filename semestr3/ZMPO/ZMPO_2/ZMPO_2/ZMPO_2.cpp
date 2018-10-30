// ZMPO_2.cpp : This file contains the 'main' function. Program execution begins and ends there.

#include <iostream>
#include "CMenu.h"
#include "CMenuCommand.h"
#include "CCommand_Ala.h"
#include "CCommand_Internet.h"
#include "CCommands.h"


int main()
{
	CMenu mainMenu("Main Manu", "main");
	mainMenu.Add(new CMenu("Submenu1", "sub1"));
	mainMenu.Add(new CMenu("Submenu2", "sub2"));
	mainMenu.Add(new CMenuCommand("Write \"ala ma kota\"", "ala", new CCommand_Ala()));
	mainMenu.Add("sub1", new CMenu("Submenu3", "sub3"));
	mainMenu.Add("sub2", new CMenuCommand("Default command", "defcom", new CCommand()));
	mainMenu.Add("sub1->sub3", new CMenuCommand("Launch browser", "internet", new CCommand_Internet()));
	
	std::vector<CTable*> tables;
	mainMenu.Add(new CMenu("Table menu", "tables"));
	mainMenu.Add("tables", new CMenuCommand("List CTables", "list", new CCommand_List(&tables)));
	mainMenu.Add("tables", new CMenu("Create new CTable", "create"));
	mainMenu.Add("tables->create", new CMenuCommand("Bezparametrowa", "bezp", new CCommand_Create_Bezp(&tables)));
	mainMenu.Add("tables->create", new CMenuCommand("Z parametrem", "par", new CCommand_Create_Par(&tables)));
	mainMenu.Add("tables", new CMenuCommand("Clone CTable", "clone", new CCommand_Clone(&tables)));
	mainMenu.Add("tables", new CMenuCommand("Delete CTable", "delete", new CCommand_Delete(&tables)));
	mainMenu.Add("tables", new CMenuCommand("Delete All", "deleteall", new CCommand_DeleteAll(&tables)));
	mainMenu.Add("tables", new CMenuCommand("Rename CTable", "rename", new CCommand_Rename(&tables)));
	mainMenu.Add("tables", new CMenuCommand("Resize CTable", "resize", new CCommand_Resize(&tables)));
	mainMenu.Add("tables", new CMenuCommand("Display CTable", "display", new CCommand_Display(&tables)));
	mainMenu.Add("tables", new CMenuCommand("Set value in CTable", "setval", new CCommand_SetVal(&tables)));

	mainMenu.Run();

	for (int i = 0; i < tables.size(); i++)
		delete tables[i];
}

