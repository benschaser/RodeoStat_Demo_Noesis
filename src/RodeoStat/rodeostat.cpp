#include <iostream>
#include "rodeostat.h"


void RodeoStat::add_contestant(std::string fname, std::string lname, std::string event, double time, double score) {
    contestants.push_back(Contestant{fname, lname, event, time, score});
}
void RodeoStat::remove_contestant(int index) {
    contestants.erase(contestants.begin() + index);
    if(current_contestant >= index) {
        current_contestant = (index - 1) % contestants.size();
    }
}
void RodeoStat::save_contestant_stats() {
    contestants.at(current_contestant).score = control.score.get_score();
    contestants.at(current_contestant).time = control.clock.get_current_time();
}