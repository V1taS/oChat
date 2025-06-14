/* SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright © 2019-2021 The TokTok team.
 */
#include "../Headers/timed_auth.h"

#include <string.h>

#include "../Headers/attributes.h"
#include "../Headers/ccompat.h"
#include "../Headers/crypto_core.h"
#include "../Headers/mono_time.h"

non_null(1, 6) nullable(4)
static void create_timed_auth_to_hash(const Mono_Time *mono_time, uint16_t timeout, bool previous, const uint8_t *data,
                                      uint16_t length, uint8_t *to_hash)
{
    const uint64_t t = (mono_time_get(mono_time) / timeout) - (previous ? 1 : 0);
    memcpy(to_hash, &t, sizeof(t));

    if (data != nullptr) {
        memcpy(to_hash + sizeof(t), data, length);
    }
}

void generate_timed_auth(const Mono_Time *mono_time, uint16_t timeout, const uint8_t *key,
                         const uint8_t *data, uint16_t length, uint8_t *timed_auth)
{
    const uint16_t to_hash_size = sizeof(uint64_t) + length;
    VLA(uint8_t, to_hash, to_hash_size);
    create_timed_auth_to_hash(mono_time, timeout, false, data, length, to_hash);
    crypto_hmac(timed_auth, key, to_hash, to_hash_size);
}

bool check_timed_auth(const Mono_Time *mono_time, uint16_t timeout, const uint8_t *key, const uint8_t *data,
                      uint16_t length, const uint8_t *timed_auth)
{
    const uint16_t to_hash_size = sizeof(uint64_t) + length;
    VLA(uint8_t, to_hash, to_hash_size);

    for (uint8_t i = 0; i < 2; ++i) {
        create_timed_auth_to_hash(mono_time, timeout, i != 0, data, length, to_hash);

        if (crypto_hmac_verify(timed_auth, key, to_hash, to_hash_size)) {
            return true;
        }
    }

    return false;
}
