// ZMPO_4.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include "Error.h"
#include "CMenu.h"
#include "CMenuCommand.h"
#include "Commands.h"


int main()
{
	CMenu mainMenu("Main menu", "main");
	mainMenu.Add(new CMenu("KnapsackProblem", "knap"));
	mainMenu.Add(new CMenuCommand("OneMaxProblem", "max", "empty", new CommandRunOneMax()));
	mainMenu.Add(new CMenuCommand("LeadingOnesProblem", "ones", "empty", new CommandRunLeadingOnes()));
	mainMenu.Add("knap", new CMenuCommand("bool", "bool", "empty", new CommandRunKnapBool()));
	mainMenu.Add("knap", new CMenuCommand("int", "int", "empty", new CommandRunKnapInt()));
	mainMenu.Add("knap", new CMenuCommand("double", "double", "empty", new CommandRunKnapDouble()));

	mainMenu.Run();
	
	
}
