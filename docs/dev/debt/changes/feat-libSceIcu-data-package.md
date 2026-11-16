# libSceIcu

## change [Binary property sets]

- [Binary property sets](../../../core/libs/prx/libSceIcu/Set.cpp) expose immutable borrowed ranges through the existing guest `USet` API. Properties that ICU reads from its data files still throw: the guard in `Set.cpp` refuses them although the build now packages that data. Ranges follow the bundled Unicode version, and console behavior is unmeasured.

## change [Break iterator factories]

- [Break iterator factories](../../../core/libs/prx/libSceIcu/Export.cpp) - Four 3.20 callable NIDs are the ICU 68 `BreakIterator::createCharacterInstance`, `createWordInstance`, `createLineInstance` and `createSentenceInstance(const Locale&, UErrorCode&)`: their `icu_68` mangled names hash to these NIDs, and the selector each wrapper passes is the `UBreakIteratorType` that ICU 68 passes to `BreakIterator::createInstance`. They are declared as throwing placeholders; their prototypes are not verified. Break iteration needs ICU rule data, which the build now packages, so the placeholders still throw until their prototypes are verified. The four selector wrappers have identical instruction bytes in the 3.20 and later version-labelled modules, and corresponding consumer switch cases call them. Their NIDs and internal layouts differ, and the later NIDs match no `icu_60` to `icu_79` name of these functions; no forwarding or binary compatibility is claimed. Later image version metadata does not authenticate a retail firmware release.

## change [Normalization]

- [Normalization](../../../core/libs/prx/libSceIcu/Normalization.cpp) is unverified on a console. Sixteen `unorm2_*` exports call ICU 78.1 with its compiled-in NFC data (Unicode 17; the console's ICU 68 has Unicode 13): the NFC and NFD instances, `unorm2_getInstance` for `nfc` without a package, normalization, appending, quick checks, decompositions, composition, combining classes and boundaries. `unorm_compare` calls ICU 78.1 [unormcmp.cpp](https://github.com/unicode-org/icu/blob/049e0d6a420629ac7db77256987d083a563287b5/icu4c/source/common/unormcmp.cpp), unchanged since 68.2, with the same compiled-in data. `unorm2_getInstance` still throws for any package and for any name other than `nfc`, although the build packages their `.nrm` files. The NFKC, NFKD and NFKC_Casefold instance getters are not implemented. `unorm2_openFiltered` converts the guest range set to an owned, frozen ICU snapshot and aliases the underlying normalizer. ICU requires callers to keep the original filter stable for the normalizer lifetime. `unorm2_close` releases owned filtered normalizers and throws for a borrowed singleton. A null `UErrorCode`, and a null normalizer where ICU dereferences it, throw. Closes when: compared with the console, and the `unorm2_getInstance` guard is lifted for names other than `nfc`.

# TechnicalDebt

## add Build

- The ICU data package from `cmake/IcuData.cmake` is built from the ICU 78.1 sources in the [3rdparty/icu](https://github.com/unicode-org/icu/tree/049e0d6a420629ac7db77256987d083a563287b5/icu4c/source) submodule with Python 3 (`icutools.databuilder`, `pkgdata -m common`, `genccode`) and linked as `icudt78_dat` in place of the stub data. The console's ICU 68 data is not measured, so output differences against firmware are unverified. `-DANYPS5_ICU_STUB_DATA=ON` restores the stub data and needs no Python. Closes when: measured on a PS5 and the ICU 68 data is compared with ICU 78.1.
