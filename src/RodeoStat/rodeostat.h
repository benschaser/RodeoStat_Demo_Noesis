#pragma once
#include <vector>
#include "control.h"
#include "graphics.h"
#include "settings.h"
#include "contestant.h"

class RodeoStat {
public:
    Control control;
    Graphics graphics;
    void add_contestant(std::string fname, std::string lname, std::string event, double time, double score);
    void remove_contestant(int index);
    void save_contestant_stats();

    int current_contestant = 0;
    std::vector<Contestant> contestants;
private:
    Settings settings;
    
};