/* SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright © 2022 The TokTok team.
 */

#include "../Headers/bin_unpack.h"

#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include "../Headers/cmp.h"
#include "../Headers/attributes.h"
#include "../Headers/ccompat.h"

struct Bin_Unpack {
    const uint8_t *bytes;
    uint32_t bytes_size;
    cmp_ctx_t ctx;
};

non_null()
static bool buf_reader(cmp_ctx_t *ctx, void *data, size_t limit)
{
    uint8_t *bytes = (uint8_t *)data;
    Bin_Unpack *reader = (Bin_Unpack *)ctx->buf;
    assert(reader != nullptr && reader->bytes != nullptr);
    if (limit > reader->bytes_size) {
        return false;
    }
    memcpy(bytes, reader->bytes, limit);
    reader->bytes += limit;
    reader->bytes_size -= limit;
    return true;
}

non_null()
static bool buf_skipper(cmp_ctx_t *ctx, size_t count)
{
    Bin_Unpack *reader = (Bin_Unpack *)ctx->buf;
    assert(reader != nullptr && reader->bytes != nullptr);
    if (count > reader->bytes_size) {
        return false;
    }
    reader->bytes += count;
    reader->bytes_size -= count;
    return true;
}

non_null()
static size_t null_writer(cmp_ctx_t *ctx, const void *data, size_t count)
{
    assert(count == 0);
    return 0;
}

non_null()
static void bin_unpack_init(Bin_Unpack *bu, const uint8_t *buf, uint32_t buf_size)
{
    bu->bytes = buf;
    bu->bytes_size = buf_size;
    cmp_init(&bu->ctx, bu, buf_reader, buf_skipper, null_writer);
}

bool bin_unpack_obj(bin_unpack_cb *callback, void *obj, const uint8_t *buf, uint32_t buf_size)
{
    Bin_Unpack bu;
    bin_unpack_init(&bu, buf, buf_size);
    return callback(obj, &bu);
}

bool bin_unpack_array(Bin_Unpack *bu, uint32_t *size)
{
    return cmp_read_array(&bu->ctx, size) && *size <= bu->bytes_size;
}

bool bin_unpack_array_fixed(Bin_Unpack *bu, uint32_t required_size, uint32_t *actual_size)
{
    uint32_t size = 0;
    const bool success = cmp_read_array(&bu->ctx, &size) && size == required_size;
    if (actual_size != nullptr) {
        *actual_size = size;
    }
    return success;
}

bool bin_unpack_bool(Bin_Unpack *bu, bool *val)
{
    return cmp_read_bool(&bu->ctx, val);
}

bool bin_unpack_u08(Bin_Unpack *bu, uint8_t *val)
{
    return cmp_read_uchar(&bu->ctx, val);
}

bool bin_unpack_u16(Bin_Unpack *bu, uint16_t *val)
{
    return cmp_read_ushort(&bu->ctx, val);
}

bool bin_unpack_u32(Bin_Unpack *bu, uint32_t *val)
{
    return cmp_read_uint(&bu->ctx, val);
}

bool bin_unpack_u64(Bin_Unpack *bu, uint64_t *val)
{
    return cmp_read_ulong(&bu->ctx, val);
}

bool bin_unpack_nil(Bin_Unpack *bu)
{
    return cmp_read_nil(&bu->ctx);
}

bool bin_unpack_bin(Bin_Unpack *bu, uint8_t **data_ptr, uint32_t *data_length_ptr)
{
    uint32_t bin_size;
    if (!bin_unpack_bin_size(bu, &bin_size) || bin_size > bu->bytes_size) {
        // There aren't as many bytes as this bin claims to want to allocate.
        return false;
    }
    uint8_t *const data = (uint8_t *)malloc(bin_size);

    if (!bin_unpack_bin_b(bu, data, bin_size)) {
        free(data);
        return false;
    }

    *data_ptr = data;
    *data_length_ptr = bin_size;
    return true;
}

bool bin_unpack_bin_max(Bin_Unpack *bu, uint8_t *data, uint16_t *data_length_ptr, uint16_t max_data_length)
{
    uint32_t bin_size;
    if (!bin_unpack_bin_size(bu, &bin_size) || bin_size > max_data_length) {
        return false;
    }

    *data_length_ptr = bin_size;

    return bin_unpack_bin_b(bu, data, bin_size);
}

bool bin_unpack_bin_fixed(Bin_Unpack *bu, uint8_t *data, uint32_t data_length)
{
    uint32_t bin_size;
    if (!bin_unpack_bin_size(bu, &bin_size) || bin_size != data_length) {
        return false;
    }

    return bin_unpack_bin_b(bu, data, bin_size);
}

bool bin_unpack_bin_size(Bin_Unpack *bu, uint32_t *size)
{
    return cmp_read_bin_size(&bu->ctx, size);
}

bool bin_unpack_u08_b(Bin_Unpack *bu, uint8_t *val)
{
    return bin_unpack_bin_b(bu, val, 1);
}

bool bin_unpack_u16_b(Bin_Unpack *bu, uint16_t *val)
{
    uint8_t hi = 0;
    uint8_t lo = 0;
    if (!(bin_unpack_u08_b(bu, &hi)
            && bin_unpack_u08_b(bu, &lo))) {
        return false;
    }
    *val = ((uint16_t)hi << 8) | lo;
    return true;
}

bool bin_unpack_u32_b(Bin_Unpack *bu, uint32_t *val)
{
    uint16_t hi = 0;
    uint16_t lo = 0;
    if (!(bin_unpack_u16_b(bu, &hi)
            && bin_unpack_u16_b(bu, &lo))) {
        return false;
    }
    *val = ((uint32_t)hi << 16) | lo;
    return true;
}

bool bin_unpack_u64_b(Bin_Unpack *bu, uint64_t *val)
{
    uint32_t hi = 0;
    uint32_t lo = 0;
    if (!(bin_unpack_u32_b(bu, &hi)
            && bin_unpack_u32_b(bu, &lo))) {
        return false;
    }
    *val = ((uint64_t)hi << 32) | lo;
    return true;
}

bool bin_unpack_bin_b(Bin_Unpack *bu, uint8_t *data, uint32_t length)
{
    return bu->ctx.read(&bu->ctx, data, length);
}
