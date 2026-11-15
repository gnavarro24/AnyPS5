#include "prx/libfreetype/include/FixedPoint.hpp"

#include <ft2build.h>
#include FT_FREETYPE_H

#include <array>
#include <cstdio>
#include <cstdlib>

static void Require(bool value, const char* message) {
    if (value) return;
    std::fprintf(stderr, "%s\n", message);
    std::abort();
}

int main() {
    constexpr std::array<long, 9> values{0, 1, -1, 0x7fff, -0x8000, 0x10000, 0x18000, -0x18001, 0x7fffffff};
    for (const long a : values) {
        Require(FT_RoundFix_nid_postfix(a) == FT_RoundFix(a), "FT_RoundFix matches FreeType");
        Require(FT_CeilFix_nid_postfix(a) == FT_CeilFix(a), "FT_CeilFix matches FreeType");
        Require(FT_FloorFix_nid_postfix(a) == FT_FloorFix(a), "FT_FloorFix matches FreeType");
        for (const long b : values) {
            Require(FT_MulFix_nid_postfix(a, b) == FT_MulFix(a, b), "FT_MulFix matches FreeType");
            Require(FT_DivFix_nid_postfix(a, b) == FT_DivFix(a, b), "FT_DivFix matches FreeType");
            for (const long c : values) {
                Require(FT_MulDiv_nid_postfix(a, b, c) == FT_MulDiv(a, b, c), "FT_MulDiv matches FreeType");
            }
        }
    }
    Require(FT_MulFix_nid_postfix(0x10000, 0x18000) == 0x18000, "FT_MulFix(1.0, 1.5) is 1.5");
    Require(FT_DivFix_nid_postfix(0x10000, 0x20000) == 0x8000, "FT_DivFix(1.0, 2.0) is 0.5");
    Require(FT_MulDiv_nid_postfix(2, 3, 4) == 2, "FT_MulDiv(2, 3, 4) rounds 1.5 up to 2");
    Require(FT_RoundFix_nid_postfix(0x18000) == 0x20000, "FT_RoundFix(1.5) is 2.0");
    Require(FT_CeilFix_nid_postfix(0x10001) == 0x20000, "FT_CeilFix(1.0 + epsilon) is 2.0");
    Require(FT_FloorFix_nid_postfix(0x18000) == 0x10000, "FT_FloorFix(1.5) is 1.0");
}
