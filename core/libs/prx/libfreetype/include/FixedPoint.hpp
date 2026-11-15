#pragma once

#include "prx/libc/include/general/VabiMacros.hpp"
#include <cstdint>

extern "C" {

std::int64_t APS5_VABI FT_MulDiv_nid_postfix(std::int64_t, std::int64_t, std::int64_t);
std::int64_t APS5_VABI FT_MulFix_nid_postfix(std::int64_t, std::int64_t);
std::int64_t APS5_VABI FT_DivFix_nid_postfix(std::int64_t, std::int64_t);
std::int64_t APS5_VABI FT_RoundFix_nid_postfix(std::int64_t);
std::int64_t APS5_VABI FT_CeilFix_nid_postfix(std::int64_t);
std::int64_t APS5_VABI FT_FloorFix_nid_postfix(std::int64_t);

}
