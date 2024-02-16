#pragma once

class Contestant {
public:
    std::string get_fname();
    std::string get_lname();
    double get_time();
    double get_score();

    void set_fname(std::string);
    void set_lname(std::string);
    void set_time(double time);
    void set_score(double score);

private:
    std::string fname, lname, event;
    double time{0.0}, score{0.0};
};