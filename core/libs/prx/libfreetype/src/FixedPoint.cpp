/*
 * Derived from FreeType 2.15.0 src/base/ftcalc.c (FT_MulDiv, FT_MulFix_64,
 * FT_DivFix) and src/base/ftcalc.c / freetype.h (FT_RoundFix, FT_CeilFix,
 * FT_FloorFix), 64-bit integer path. FreeType License.
 */
#include "prx/libfreetype/include/FixedPoint.hpp"

namespace {

std::uint64_t Magnitude(std::int64_t value, bool& negative) {
    if (value < 0) {
        negative = !negative;
        return std::uint64_t{0} - static_cast<std::uint64_t>(value);
    }
    return static_cast<std::uint64_t>(value);
}

std::int64_t Signed(std::uint64_t magnitude, bool negative) {
    const auto value = static_cast<std::int64_t>(magnitude);
    return negative ? static_cast<std::int64_t>(std::uint64_t{0} - static_cast<std::uint64_t>(value)) : value;
}

}

extern "C" {

std::int64_t APS5_VABI FT_MulDiv_nid_postfix(std::int64_t a_, std::int64_t b_, std::int64_t c_) {
    bool negative = false;
    const auto a = Magnitude(a_, negative);
    const auto b = Magnitude(b_, negative);
    const auto c = Magnitude(c_, negative);
    const auto d = c > 0 ? (a * b + (c >> 1)) / c : std::uint64_t{0x7FFFFFFF};
    return Signed(d, negative);
}

std::int64_t APS5_VABI FT_MulFix_nid_postfix(std::int64_t a, std::int64_t b) {
    const auto product = static_cast<std::int64_t>(static_cast<std::uint64_t>(a) * static_cast<std::uint64_t>(b));
    const auto rounded = static_cast<std::int64_t>(static_cast<std::uint64_t>(product) +
                                                   static_cast<std::uint64_t>(0x8000 + (product >> 63)));
    return rounded >> 16;
}

std::int64_t APS5_VABI FT_DivFix_nid_postfix(std::int64_t a_, std::int64_t b_) {
    bool negative = false;
    const auto a = Magnitude(a_, negative);
    const auto b = Magnitude(b_, negative);
    const auto q = b > 0 ? ((a << 16) + (b >> 1)) / b : std::uint64_t{0x7FFFFFFF};
    return Signed(q, negative);
}

std::int64_t APS5_VABI FT_RoundFix_nid_postfix(std::int64_t a) {
    const auto biased = static_cast<std::int64_t>(static_cast<std::uint64_t>(a) +
                                                  static_cast<std::uint64_t>(0x8000 - (a < 0 ? 1 : 0)));
    return biased & ~std::int64_t{0xFFFF};
}

std::int64_t APS5_VABI FT_CeilFix_nid_postfix(std::int64_t a) {
    const auto biased = static_cast<std::int64_t>(static_cast<std::uint64_t>(a) + std::uint64_t{0xFFFF});
    return biased & ~std::int64_t{0xFFFF};
}

std::int64_t APS5_VABI FT_FloorFix_nid_postfix(std::int64_t a) {
    return a & ~std::int64_t{0xFFFF};
}

}
