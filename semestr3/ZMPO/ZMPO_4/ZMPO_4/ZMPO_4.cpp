// ZMPO_4.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include "pch.h"
#include <iostream>
#include "KnapsackProblem.h"
#include "GeneticAlgorithmAgent.h"

int main()
{
	KnapsackProblem* knapProblem = new KnapsackProblem();
	knapProblem->ReadFromFile("p08");
	GeneticAlgorithmAgent* agent = new GeneticAlgorithmAgent(10, 0.25, 0.1, knapProblem);
	long lastBest = -1;
	for (int i = 0; i < 10000; i++) {
		agent->RunGeneration();
		long best = agent->GetBestFitness();
		if (lastBest != best) {
			std::cout << "Generation " << i << " best: " << best << std::endl;
			lastBest = best;
		}
	}
}
