#pragma once
#include <string>

class Contestant {
public:
    Contestant(std::string fname, std::string lname, std::string event, double time, double score);
    std::string get_fname() const;
    std::string get_lname() const;
    std::string get_event() const;
    void set_time(double new_time);
    void set_score(double new_score);

    std::string fname, lname, event;
    double time{0.0}, score{0.0};
private:
    
};