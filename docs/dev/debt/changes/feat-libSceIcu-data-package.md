# libSceIcu

## change [Binary property sets]

- [Binary property sets](../../../core/libs/prx/libSceIcu/Set.cpp) expose immutable borrowed ranges through the existing guest `USet` API. Properties that ICU reads from its data files still throw: the guard in `Set.cpp` refuses them although the build now packages that data. Ranges follow the bundled Unicode version, and console behavior is unmeasured.

## change [Break iterator factories]

- [Break iterator factories](../../../core/libs/prx/libSceIcu/Export.cpp) - the prototypes are unverified. Four 3.20 NIDs hash to the ICU 68 `BreakIterator::create{Character,Word,Line,Sentence}Instance(const Locale&, UErrorCode&)` names, and each wrapper passes the `UBreakIteratorType` ICU 68 uses. They throw until the prototypes are verified, although the build now packages the rule data. The NIDs and internal layouts differ from later versions, so no forwarding or binary compatibility is claimed. Closes when: the prototypes are verified on a console.

## change [Normalization]

- [Normalization](../../../core/libs/prx/libSceIcu/Normalization.cpp) is unverified on a console. Sixteen `unorm2_*` exports and `unorm_compare` call ICU 78.1 with its compiled-in Unicode 17 NFC data, where the console's ICU 68 has Unicode 13. `unorm2_getInstance` throws for any package and for names other than `nfc`, although the build packages their `.nrm` files; the NFKC, NFKD and NFKC_Casefold getters are not implemented. `unorm2_openFiltered` freezes a snapshot of the guest range set and aliases the normalizer, which requires the original filter to stay stable; `unorm2_close` frees owned filtered normalizers and throws for a borrowed singleton. Null `UErrorCode` and null normalizers throw. Closes when: compared with the console and the `unorm2_getInstance` guard is lifted for names other than `nfc`.

## change [Converter STOP/SKIP callbacks]

- [Converter callbacks](../../../core/libs/prx/libSceIcu/ConverterCallbacks.cpp) - none has console ABI or behavior verification. STOP and SKIP signatures and decisions follow ICU 78.1's [ucnv_err.h](https://github.com/unicode-org/icu/blob/049e0d6a420629ac7db77256987d083a563287b5/icu4c/source/common/unicode/ucnv_err.h) and [ucnv_err.cpp](https://github.com/unicode-org/icu/blob/049e0d6a420629ac7db77256987d083a563287b5/icu4c/source/common/ucnv_err.cpp). The callback-specific default-ignorable ranges include U+180F, which ICU 65.1 excludes; firmware-dependent selection is not implemented. SUBSTITUTE and ESCAPE, in both directions, call ICU 78.1's own callbacks from the same file, so their output follows ICU 78.1, not the console. Reasons outside the upstream enum's 0–7 value range throw `invalid_argument`. Null converter arguments and null error pointers throw on every SUBSTITUTE and ESCAPE call, even reset calls where ICU reads neither; ESCAPE also throws on null code units with a nonzero length. Untouched pointers remain unread for STOP and SKIP, including the error pointer on no-write paths. Converter execution is unavailable, so the output-writing replacement paths are not exercised by tests. Closes when: compared with the console, including converter output.

# TechnicalDebt

## add Build

- The ICU data package from `cmake/IcuData.cmake` is built from the ICU 78.1 sources in the [3rdparty/icu](https://github.com/unicode-org/icu/tree/049e0d6a420629ac7db77256987d083a563287b5/icu4c/source) submodule with Python 3 (`icutools.databuilder`, `pkgdata`, `genccode`) and linked in place of the stub data. The console's ICU 68 data is not measured, so output differences against firmware are unverified. `-DANYPS5_ICU_STUB_DATA=ON` restores the stub data without Python. Closes when: the ICU 68 data is compared with ICU 78.1 on a PS5.
