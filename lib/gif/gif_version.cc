#include <iostream>
#include <sstream>
#include <string>

#include <gif_lib.h>

std::string gif_version() {
	std::ostringstream out;
	out << GIFLIB_MAJOR << "." << GIFLIB_MINOR << "." << GIFLIB_RELEASE;
	return out.str();
}
