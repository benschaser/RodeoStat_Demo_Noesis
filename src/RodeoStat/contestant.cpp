#include "contestant.h"
#include <string>

Contestant::Contestant(std::string fname, std::string lname, std::string event, double time, double score) 
    : fname{fname}, lname{lname}, event{event}, time{time}, score{score} {}

std::string Contestant::get_fname() const {
    return fname;
}
std::string Contestant::get_lname() const {
    return lname;
}
std::string Contestant::get_event() const {
    return event;
}
void Contestant::set_time(double new_time) {
    time = new_time;
}
void Contestant::set_score(double new_score) {
    score = new_score;
}
